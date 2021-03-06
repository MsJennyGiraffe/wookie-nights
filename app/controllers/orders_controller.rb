class OrdersController < ApplicationController
  before_action :require_login

  def index
    @orders = current_user.orders
  end

  def show
    @order = current_user.orders.find(params[:id])
    @reservations = @order.reservations.where(active: true)
  end

  def create
    order = Order.create(user_id: current_user.id, status: "ordered")
    order.create_reservations(@cart.reservations)
    session.delete(:cart)
    flash[:success] = "Order was successfully placed"
    redirect_to order_path(order)
  end

  private

  def require_login
    unless current_user
      flash[:notice] = "You must be logged in to view this page."
      redirect_to login_path
    end
  end
end
