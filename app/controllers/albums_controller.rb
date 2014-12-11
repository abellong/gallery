# -*- coding: utf-8 -*-
class AlbumsController < ApplicationController
  before_action :authenticate_user!

  def new
    @album = Album.new()
  end

  def create
    @album = current_user.albums.new(album_params)
    if @album.save
      redirect_to @album, notice: '创建相册成功'
    else
      render :new
    end
  end

  def show
    @album = Album.find(params[:id])
    @images = @album.images
    
  end

  def destroy
  end

  def admin
    @image = Image.new
    @album = Album.find(params[:id])
  end

  private
    def album_params
      params.require(:album).permit(:name)
    end
end
