class HostsController < ApplicationController

  def new
    @space = Space.find_by(slug: params[:space_slug])
    @user = User.new
  end

  def create
    @space = Space.find_by(slug: params[:space_slug])
    if @user = User.find_by(username: params[:user][:username])
      @space.users << @user
      redirect_to edit_space_path(@space)
    else
      flash[:warning] = "This username does not exist"
      redirect_to "/hosts/#{@space.slug}/new"
    end
  end
end
