require "rails_helper"

describe "Items API" do
  it "sends a list of items" do
    items = create_list(:item, 3)

    get "/api/v1/items"

    expect(response).to be_successful
    expect(response.status).to eq(200)
    items = JSON.parse(response.body, symbolize_names: true)

    expect(items[:data].count).to eq(3)

    items[:data].each do |item|
      expect(item).to have_key(:id)
      expect(item[:id]).to be_an(String)

      expect(item).to have_key(:type)
      expect(item[:type]).to be_an(String)

      expect(item).to have_key(:type)
      expect(item[:type]).to eq("item")

      expect(item[:attributes]).to have_key(:name)
      expect(item[:attributes][:name]).to be_a(String)

      expect(item[:attributes]).to have_key(:description)
      expect(item[:attributes][:description]).to be_a(String)

      expect(item[:attributes]).to have_key(:unit_price)
      expect(item[:attributes][:unit_price]).to be_a(Float)
    end
  end

  it "returns an array, even if only 1 item is found" do
    create_list(:item, 1)

    get "/api/v1/items"

    expect(response).to be_successful
    expect(response.status).to eq(200)

    items = JSON.parse(response.body, symbolize_names: true)
    expect(items[:data].count).to eq(1)
  end

  it "returns an array, even if no items are found" do
    get "/api/v1/items"

    expect(response).to be_successful
    expect(response.status).to eq(200)

    items = JSON.parse(response.body, symbolize_names: true)
    expect(items[:data]).to be_an(Array)
    expect(items[:data]).to eq([])
    expect(items[:data].count).to eq(0)
  end 

  it "can get one item based on its id" do
    id = create(:item).id

    get "/api/v1/items/#{id}"

    item = JSON.parse(response.body, symbolize_names: true)

    expect(response).to be_successful
    expect(response.status).to eq(200)

    expect(item[:data]).to have_key(:id)
    expect(item[:data][:id]).to eq("#{id}")

    expect(item[:data][:attributes]).to have_key(:name)
    expect(item[:data][:attributes][:name]).to be_a(String)

    expect(item[:data][:attributes]).to have_key(:description)
    expect(item[:data][:attributes][:description]).to be_a(String)

    expect(item[:data][:attributes]).to have_key(:unit_price)
    expect(item[:data][:attributes][:unit_price]).to be_a(Float)
  end

  it "can create a new item" do

    merchant = create(:merchant).id
    item_params = ({
      name: "Strawberry Cheesecake",
      description: "Made with fresh strawberries from Hoberts Farm",
      unit_price: 8.44,
      merchant_id: merchant
    })

    headers = {"CONTENT_TYPE" => "application/json"}
    #We include this header to make sure that these params are passed as JSON rather than as plain text

    post "/api/v1/items", headers: headers, params: JSON.generate(item: item_params)
    
    created_item = Item.last

    expect(response).to be_successful
    expect(response.status).to eq(201)
    
    expect(created_item.name).to eq(item_params[:name])
    expect(created_item.description).to eq(item_params[:description])
    expect(created_item.unit_price).to eq(item_params[:unit_price])
  end

  xit "can update an existing item" do

  end

  xit "can destroy an item" do

  end
end