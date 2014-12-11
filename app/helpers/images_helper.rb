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
end
