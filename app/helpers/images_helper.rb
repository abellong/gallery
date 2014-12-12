module ImagesHelper

  def get_image_info(image)
    if image.width.nil?
      image_info = JSON.parse(Net::HTTP.get(URI.parse(image.file.url+"?imageInfo")))
      image.update_attribute(:width, image_info["width"])
      image.update_attribute(:height, image_info["height"])
    else
      image_info = {"width" => image.width, "height" => image.height}
    end
    return image_info
  end

  def get_image_url(image, params={})
    thumbnail = image.thumbnails.find_by(params: params.to_s)
    if not thumbnail.nil?
      return thumbnail.url
    else
      params_base64 = Base64.strict_encode64(params.to_s)
      path = params_base64 + "-" + image.file.path
      data = Qiniu::RS.get(ENV['BUCKET_NAME'], image.file.path)
      result = Qiniu::RS.image_mogrify_save_as(ENV['BUCKET_NAME'], path, data["url"], params)
      if result
        url = "http://#{ENV['BUCKET_NAME']}.qiniudn.com" + "/#{path}"
        image.thumbnails.create(url: url, params: params.to_s)
        return url
      else
        return qiniu_image_path(image.file.url, params)
      end
    end
  end
end
