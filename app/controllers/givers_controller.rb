class GiversController < ApplicationController
  def thanks
  end

  def new
    gon.client_token = generate_client_token
    @giver = Giver.new
  end

  def create
    @giver = Giver.new(giver_params)
    result = GiverDonate.new(@giver).donate(
      params[:giver][:amount],
      params[:payment_method_nonce]
    )
    if result.success?
      flash[:name] = @giver.full_name
      flash[:email] = @giver.email
      redirect_to thanks_path
    else
      flash.now[:danger] = result.error_message
      gon.client_token = generate_client_token
      render :new
    end
  end

  def giver_params
    params.require(:giver).permit(:full_name, :message, :email, :amount, :mailing_list)
  end

  private

  def generate_client_token
    Braintree::ClientToken.generate
  end
end
