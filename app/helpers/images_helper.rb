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
      return "http://#{ENV['BUCKET_NAME']}.qiniudn.com/#{thumbnail.path}"
    else
      params_base64 = Base64.strict_encode64(params.to_s)
      suffix = /(\.[A-Za-z]*)$/.match(image.file.path)
      des_path = "thumbnail-" + image.file.path.sub(/(\.[A-Za-z]*)$/, 
                                                    "-#{params_base64}#{suffix}")
      data = Qiniu::RS.get(ENV['BUCKET_NAME'], image.file.path)
      result = Qiniu::RS.image_mogrify_save_as(ENV['BUCKET_NAME'], des_path,
                                               data["url"], params)
      if result
        url = "http://#{ENV['BUCKET_NAME']}.qiniudn.com/#{des_path}"
        image_info = JSON.parse(Net::HTTP.get(URI.parse(URI.escape(url+"?imageInfo"))))
        image.thumbnails.create(path: des_path, params: params.to_s,
                                width: image_info["width"],
                                height: image_info["height"])
        return url
      else
        return qiniu_image_path(image.file.url, params)
      end
    end
  end
end
