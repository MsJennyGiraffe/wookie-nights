class SpacesController < ApplicationController
  def index
    if planet = Planet.find_by(name: params[:planet].capitalize, active: true)
      @spaces = Space.where("planet_id = ? AND occupancy >= ?", planet.id, params[:occupancy].to_i)
      query_search_with_dates
      deliver_query_results
    else
      flash[:warning] = "Please include a planet"
      redirect_to root_url
    end
  end

  def show
    @space = Space.find_by(slug: params[:space_slug], active: true)
    if @space.approved
      @space
      @search_hash = { start_date: params[:check_in], end_date: params[:check_out] }
    else
      flash[:notice] = "This space is currently not available."
      request.referer ? (redirect_to request.referer) : (redirect_to root_url)
    end
  end

  def new
    if current_user
      @space = Space.new
    else
      flash[:warning] = "You must be logged in to post a space."
      redirect_to login_path
    end
  end

  def create
    @space = Space.new_space(space_params)
    if @space.save
      current_user.spaces << @space
      flash[:success] = "Your space has successfully been submitted for approval!"
      redirect_to "/dashboard"
    else
      flash.now[:error] = @space.errors.full_messages.join(", ")
      render :new
    end
  end

  def edit
    @space = Space.find_by(slug: params[:space_slug], active: true)
    if @space.users.include?(current_user)
      @space
      session[:return_to] = request.referer
    else
      flash[:warning] = "You are not authorized to edit this space."
      redirect_to space_path(@space)
    end
  end

  def update
    @space = Space.find_by(slug: params[:space_slug], active: true)
    if @space.update_space(space_params)
      flash[:success] = "Your space has been successfully updated!"
      redirect_to session[:return_to]
    else
      flash.now[:error] = @space.errors.full_messages.join(", ")
      render :edit
    end
  end

  private

  def space_params
    params.require(:space).permit(:name, :occupancy, :description, :price,
                                 :image_url, :style, :planet)
  end

  def query_search_with_dates
    if (params[:start_date] != "") && (params[:end_date] != "")
      @spaces = Space.find_unreserved_spaces(@spaces, params[:start_date], params[:end_date])
    end
  end

  def deliver_query_results
    if @spaces.count > 0
      @styles = Space.associated_style_names_list(@spaces)
      @search_hash = { planet: params[:planet], occupancy: params[:occupancy], start_date: params[:start_date], end_date: params[:end_date] }
    else
      flash[:warning] = "There were no valid search results."
      redirect_to root_url
    end
  end

end
