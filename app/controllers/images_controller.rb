class ImagesController < ApplicationController
  before_action :authenticate_user!
  
  def index
    if params[:album].nil?
      @images = Image.all
    else
      @images = Album.find(params[:album]).images
    end
    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @images.map{|image| image.to_jq_upload } }
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
        format.json { render json: {files: [@image.to_jq_upload]}, status: :created, location: @image }
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
end
