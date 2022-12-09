class Api::V1::MerchantSearchController < ApplicationController

  def index
    search_params = params[:name]
    merchant = Merchant.where("name ILIKE ?", "%#{search_params}%").order(:name).first
    if merchant != nil
      render json: MerchantSerializer.new(merchant)
    else
      render json: { data: { errors: "Your search has no matches"}}, status: 404
    end 
  end 
end
