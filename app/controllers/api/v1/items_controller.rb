class Api::V1::ItemsController < ApplicationController

  def index
    render json: ItemSerializer.new(Item.all)
  end

  def show
    render json: ItemSerializer.new(Item.find(params[:id]))
  end

  def create
    
  end

  # private
  #   def merchant_params
  #     params.require(:item).permit(:id, :name, :description, :unit_price)
  #   end
end