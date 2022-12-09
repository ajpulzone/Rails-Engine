require "rails_helper"

describe "Items API" do

  #Unable to get shoulda-matchers to work, so unable to get validataions to pass
  #This is messing up my create sad path of not having all attributes filled out
  # describe "relationships" do
  #   it { should belong_to :merchant }
  #   it { should have_many :invoice_items }
  #   it { should have_many(:invoices).through(:invoice_items) }
  # end 

  # describe "validations" do
  #   it { should validate_presence_of :name }
  #   it { should validate_presence_of :description }
  #   it { should validate_presence_of :unit_price }
  # end

  describe "all items" do
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

    it "when sending all items, returns an array, even if only 1 item is found" do
      create_list(:item, 1)

      get "/api/v1/items"

      expect(response).to be_successful
      expect(response.status).to eq(200)

      items = JSON.parse(response.body, symbolize_names: true)
      expect(items[:data].count).to eq(1)
    end

    it "when sending all items, returns an array, even if no items are found" do
      get "/api/v1/items"

      expect(response).to be_successful
      expect(response.status).to eq(200)

      items = JSON.parse(response.body, symbolize_names: true)
      expect(items[:data]).to be_an(Array)
      expect(items[:data]).to eq([])
      expect(items[:data].count).to eq(0)
    end 
  end 

  describe "getting one item" do
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

    it "will return a 404 error if the item id does not exist" do
      get "/api/v1/items/4"

      item = JSON.parse(response.body, symbolize_names: true)
      expect(response.status).to eq(404)
      expect(item).to have_key(:errors)
      expect(item[:errors]).to eq("An item with this id doesn't exist")
    end
  end 

  describe "creating a new item" do
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
      expect(created_item.name).to be_a(String)
      expect(created_item.name).to eq("Strawberry Cheesecake")

      expect(created_item.description).to eq(item_params[:description])
      expect(created_item.description).to be_a(String)
      expect(created_item.description).to eq("Made with fresh strawberries from Hoberts Farm")

      expect(created_item.unit_price).to eq(item_params[:unit_price])
      expect(created_item.unit_price).to be_a(Float)
      expect(created_item.unit_price).to eq(8.44)

      expect(created_item.merchant_id).to eq(item_params[:merchant_id])
    end

    it "will ignore any attributes that are passed by the user that are 
      not allowed and still create the item" do
      merchant = create(:merchant).id
      item_params = ({
        name: "Strawberry Cheesecake",
        description: "Made with fresh strawberries from Hoberts Farm",
        unit_price: 8.44,
        weight: 12,
        merchant_id: merchant
      })

      headers = {"CONTENT_TYPE" => "application/json"}
      #We include this header to make sure that these params are passed as JSON rather than as plain text
      post "/api/v1/items", headers: headers, params: JSON.generate(item: item_params)
      
      created_item = Item.last
      get "/api/v1/items/#{created_item.id}"

      found_created_item = JSON.parse(response.body, symbolize_names: true)
      expect(response).to be_successful
      expect(response.status).to eq(200)
      expect(found_created_item[:data][:attributes]).to_not have_key(:weight)
    end

    it "will return a 400 error is the user does not enter all of the required attributes
      needed to create an item" do
      merchant = create(:merchant).id
      item_params = ({
        name: "Strawberry Cheesecake",
        description: "",
        unit_price: "",
        merchant_id: merchant
      })

      headers = {"CONTENT_TYPE" => "application/json"}
      #We include this header to make sure that these params are passed as JSON rather than as plain text
      post "/api/v1/items", headers: headers, params: JSON.generate(item: item_params)
      
      created_item = JSON.parse(response.body, symbolize_names: true)

      expect(response.status).to eq(400)
      expect(created_item).to have_key(:errors)
      expect(created_item[:errors]).to eq("item was not created")
    end
  end 

  describe "updating an item" do
    it "can update an existing item if all information is updated" do
      id = create(:item).id
      previous_name = Item.last.name
      item_params = { name: "Blueberry Muffin" }
      headers = { "CONTENT_TYPE" => "application/json"}
      
      patch "/api/v1/items/#{id}", headers: headers, params: JSON.generate(item: item_params)
      item = Item.find_by(id: id)

      expect(response).to be_successful
      expect(response.status).to eq(200)
      expect(item.name).to_not eq(previous_name)
      expect(item.name).to eq("Blueberry Muffin")
    end

    it "can update an existing item if only partial information is updated" do
      id = create(:item).id
      previous_name = Item.last.name
      previous_description = Item.last.description
      previous_unit_price = Item.last.unit_price
      item_params = { name: "Blueberry Muffin",
                      description: "Best blueberries in town",
                      unit_price: 4.65
                    }
      headers = { "CONTENT_TYPE" => "application/json"}
      
      patch "/api/v1/items/#{id}", headers: headers, params: JSON.generate(item: item_params)
      item = Item.find_by(id: id)

      expect(response).to be_successful
      expect(response.status).to eq(200)
      expect(item.name).to_not eq(previous_name)
      expect(item.name).to eq("Blueberry Muffin")
      expect(item.description).to_not eq(previous_description)
      expect(item.description).to eq("Best blueberries in town")
      expect(item.unit_price).to_not eq(previous_unit_price)
      expect(item.unit_price).to eq(4.65)
    end

    it "will throw a 404 error if the id is passed as a string" do
      id = (create(:item).id).to_s
      previous_name = Item.last.name
      item_params = { name: "Blueberry Muffin" }
      headers = { "CONTENT_TYPE" => "application/json"}
      
      patch "/api/v1/items/'id'", headers: headers, params: JSON.generate(item: item_params)
      
      created_item = JSON.parse(response.body, symbolize_names: true)

      expect(response.status).to eq(404)
      expect(created_item).to have_key(:errors)
      expect(created_item[:errors]).to eq("An item could not be found")
    end

    it "will throw a 404 error if a bad integer id is submitted" do
      id = create(:item).id
      previous_name = Item.last.name
      item_params = { name: "Blueberry Muffin" }
      headers = { "CONTENT_TYPE" => "application/json"}
      
      patch "/api/v1/items/600", headers: headers, params: JSON.generate(item: item_params)
      
      created_item = JSON.parse(response.body, symbolize_names: true)

      expect(response.status).to eq(404)
      expect(created_item).to have_key(:errors)
      expect(created_item[:errors]).to eq("An item could not be found")
    end

    it "will throw a 404 error if a bad merchant id is submitted" do
      id = create(:item).id
      previous_name = Item.last.name
      item_params = { name: "Blueberry Muffin",
                      merchant_id: 60000}
      headers = { "CONTENT_TYPE" => "application/json"}
      
      patch "/api/v1/items/#{id}", headers: headers, params: JSON.generate(item: item_params)
      
      created_item = JSON.parse(response.body, symbolize_names: true)

      expect(response.status).to eq(404)
      expect(created_item).to have_key(:errors)
      expect(created_item[:errors]).to eq("Item wasn't updated")
    end
  end 

  describe "Getting the merchant for a specified item" do
    it "can get the merchant of a given item" do
      merchant = create(:merchant)
      create_list(:item, 2, merchant_id: merchant.id)
      item = Item.first

      headers = { "CONTENT_TYPE" => "application/json"}
      get "/api/v1/items/#{item.id}/merchant"
      expect(response.status).to eq(200)
    end
  end 

  describe "destroy an item" do
    it "can destroy an item" do
      merchant = create(:merchant).id
      invoice = create(:invoice).id
      item = create(:item).id
      invoice << item
      expect(Item.count).to eq(1)
      # expect(Invoice.item.count).to eq(1)
      expect{ delete "/api/v1/items/#{item}" }.to change(Item, :count).by(-1)

      expect(Item.count).to eq(0)
      expect(response).to be_successful
      expect(response.status).to eq(200)
      expect{Item.find(item)}.to raise_error(ActiveRecord::RecordNotFound)
    end

    xit "SAD PATH-NEED TO WRITE TEST: will destroy the invoice if the item that is destroyed is the only one on the invoice" do
    end

    xit "SAD PATH-NEED TO WRITE TEST: it will NOT destroy the invoice if there are aditional items on it" do
    end
  end

  describe "find all items that match a search for name" do
    xit "should return a list of items that match the search name, sorted in case-insensitive alphabetical order" do
    end

    xit "will return a 404 error if no matches are found" do
    end
  end

  describe "can find one item by price" do
    xit "will return one item that is the first when results are sorted case-insensitive alphabetical order" do
    end

    xit "it will return a 400 error if no matching item is found" do
    end
  end 

  describe "c" do
  end
end