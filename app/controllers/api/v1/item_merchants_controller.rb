class Api::V1::ItemMerchantsController < ApplicationController

  def index
    if Item.exists?(params[:item_id])
      item = Item.find(params[:item_id])
      merchant = item.merchant
      render json: MerchantSerializer.new(merchant)
    else
      render json: {errors: "Not found" }, status: 404
    end 
  end 
end