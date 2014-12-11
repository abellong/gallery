class UsersController < ApplicationController
  def show
    @user = User.find(params[:id])
    @albums = @user.albums
  end
end
