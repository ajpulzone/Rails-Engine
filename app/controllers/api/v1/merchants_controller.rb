class Api::V1::MerchantsController < ApplicationController

  def index
    merchants = Merchant.all
    render json: MerchantSerializer.new(merchants)
  end

  def show
    if Merchant.exists?(params[:id])
      merchant = Merchant.find(params[:id])
      render json: MerchantSerializer.new(merchant)
    else
      render json: {errors: "merchant does not exist" }, status: 404
    end
  end

  # private
  #   def merchant_params
  #     params.require(:merchant).permit(:id, :name)
  #   end
end