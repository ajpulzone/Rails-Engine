class Api::V1::ItemsController < ApplicationController

  def index
    items = Item.all
    items = render json: ItemSerializer.new(items)
  end

  def show
    if Item.exists?(params[:id])
      item = Item.find(params[:id])
      render json: ItemSerializer.new(item)
    else
      render json: {error: "An item with this id doesn't exist"}, status: 404
    end
  end 

  def create
    item = Item.create!(item_params)
    render json: ItemSerializer.new(item), status: 201
  end

  def update
    item = Item.update(params[:id], item_params)
    if item.save
      item = Item.update(params[:id], item_params)
      render json: ItemSerializer.new(item)
    else  
      render json: { error: "Item can't be updated"}, status: 404
    end
  end 

  def destroy
    #if invoice.item.count = 1
    render json: Item.delete(params[:id])

    #else destroy invoice
  end

  private
    def item_params
      params.require(:item).permit(:name, :description, :unit_price, :merchant_id)
    end
end