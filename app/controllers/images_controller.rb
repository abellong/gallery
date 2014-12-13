class ImagesController < ApplicationController
  before_action :authenticate_user!
  after_action :add_thumbnails, only: :create
  
  def index
    if params[:album].nil?
      @images = Image.all
    else
      @images = Album.find(params[:album]).images
    end
    json = get_json_data(@images)
    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: json }
    end
  end

  def show
    @image = Image.find(params[:id])
    @album = @image.album
    @images = @album.images
    @user = @album.user
    @image_info = get_image_info(@image)
    render layout: 'image_layout'
  end

  def new
    @image = Image.new
    @album_id = params[:album]
  end

  def edit
    image = Image.find(params[:id])
  end

  def create
    album = Album.find(params[:album])
    image_p = image_params
    image_p[:serial_n] = album.images.size
    @image = album.images.new(image_p)
    
    respond_to do |format|
      if @image.save
        format.html {
          render :json => [@image.to_jq_upload].to_json,
          :content_type => 'text/html',
          :layout => false
        }
        format.json { render json: {files: get_json_data([@image])}, status: :created, location: @image }
      else
        format.html { render action: "new" }
        format.json { render json: @image.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
  end

  def destroy
    @image = Image.find(params[:id])
    serial_n = @image.serial_n
    @image.destroy
    @image.album.images.each do |image|
      n = image.serial_n
      if n > serial_n
        image.update_attribute(:serial_n, n - 1)
      end
    end

    respond_to do |format|
      format.html { redirect_to images_url }
      format.json { head :no_content }
    end
  end

  private
    def image_params
      params.require(:image).permit(:file)
    end

    def get_json_data(images)
      json = []
      existed_images_json = images.map do |image| 
        tmp = image.to_jq_upload 
        tmp["url"] = get_image_url(image, :thumbnail => 'x50', :quality => 80)
        json << tmp
      end
      return json
    end

  protected
    def add_thumbnails
      params_array = [
        { thumbnail: 'x130>', quality: 80 }, # album show
        { thumbnail: '160x160^', crop: "!160x160a0a0" }, # user show, cover
        { thumbnail: '600x600', quality: 80 }, # image show, image
        { thumbnail: '80x80^', crop: "!80x80a0a0", quality: 80 }, # image show, thumbnail
        { thumbnail: 'x50', quality: 80 } # admin
      ]

      params_array.each do |params| 
        thumbnail = @image.thumbnails.find_by(params: params.to_s)
        if thumbnail.nil?
          params_base64 = Base64.strict_encode64(params.to_s)
          suffix = /(\.[A-Za-z]*)$/.match(@image.file.path)
          des_path = "thumbnail-" + @image.file.path.sub(/(\.[A-Za-z]*)$/, 
                                                        "-#{params_base64}#{suffix}")
          sleep 10
          data = Qiniu::RS.get(ENV['BUCKET_NAME'], @image.file.path)
          Rails.logger.info "==============-#{@image.file.path}-============="
          Rails.logger.info "==============-#{data.to_s}-============="
          result = Qiniu::RS.image_mogrify_save_as(ENV['BUCKET_NAME'], 
                                                   des_path, data["url"], params)
          if result
            url = "http://#{ENV['BUCKET_NAME']}.qiniudn.com" + "/#{des_path}?imageInfo"
            image_info = JSON.parse(Net::HTTP.get(URI.parse(URI.escape(url))))
            @image.thumbnails.create(path: des_path, params: params.to_s,
                                    width: image_info["width"],
                                    height: image_info["height"])
          end
        end
      end
    end
end
