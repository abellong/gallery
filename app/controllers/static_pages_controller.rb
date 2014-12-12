class StaticPagesController < ApplicationController
  def home
    if user_signed_in?
      @user = current_user
      @albums = @user.albums
      render 'users/show'
    end

    @album = Album.first rescue nil?
    @images = @album.images rescue nil?
    if @images.nil?
          @images = {}
    end
  end

  def about
  end
end
