class ChargesController < ApplicationController
  def new
    @amount = @cart.total_price
  end

  def create
    @amount = @cart.total

    customer = Stripe::Customer.create(
      email: params[:stripeEmail],
      source: params[:stripeToken]
    )

    charge = Stripe::Charge.create(
      customer:    customer.id,
      amount:      @amount,
      description: "Socks and Found Checkout",
      currency:    "usd"
    )

  rescue Stripe::CardError => e
    flash[:error] = e.message
    redirect_to new_charge_path
  end
end
