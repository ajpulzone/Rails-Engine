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
      render json: {errors: "An item with this id doesn't exist"}, status: 404
    end
  end 

  def create
    item = Item.new(item_params)
    if item.save
      render json: ItemSerializer.new(item), status: 201
    else 
      render json: { errors: "item was not created" }, status: 400
    end
  end

  def update
    if Item.exists?(params[:id])
      item = Item.update(params[:id], item_params)
      if item.save
        item = Item.update(params[:id], item_params)
        render json: ItemSerializer.new(item)
      else  
        render json: { errors: "Item wasn't updated"}, status: 404
      end
    else
      render json: { errors: "An item could not be found"}, status: 404
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