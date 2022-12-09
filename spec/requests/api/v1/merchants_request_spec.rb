require "rails_helper"

describe "Merchants API" do

  describe "all merchants" do
    it "sends a list of merchants" do
      create_list(:merchant, 3)

      get "/api/v1/merchants"
      response_body = JSON.parse(response.body, symbolize_names: true)
      merchants = response_body[:data]

      expect(merchants.count).to eq(3)
      expect(response).to be_successful
      expect(response.status).to eq(200)

      merchants.each do |merchant|
        expect(merchant).to have_key(:id)
        expect(merchant[:id]).to be_an(String)

        expect(merchant).to have_key(:type)
        expect(merchant[:type]).to be_a(String)
        
        expect(merchant).to have_key(:type)
        expect(merchant[:type]).to eq("merchant")

        expect((merchant)[:attributes]).to have_key(:name)
        expect((merchant)[:attributes][:name]).to be_a(String)
      end
    end 

    it "returns an array, even if only 1 merchant is found" do
      create_list(:merchant, 1)

      get "/api/v1/merchants"

      merchants = JSON.parse(response.body, symbolize_names: true)
      expect(response).to be_successful
      expect(response.status).to eq(200)
      expect(merchants[:data].count).to eq(1)
    end

    it "returns an array, even if no merchants are found" do
      get "/api/v1/merchants"
      expect(response).to be_successful
      expect(response.status).to eq(200)
      merchants = JSON.parse(response.body, symbolize_names: true)

      expect(merchants[:data]).to be_an(Array)
      expect(merchants[:data]).to eq([])
      expect(merchants[:data].count).to eq(0)
    end 
  end 

  describe "find one merchant" do
    it "can get one merchant by their id" do
      get "/api/v1/merchants/3"

      merchant = JSON.parse(response.body, symbolize_names: true)
      expect(response.status).to eq(404)
      expect(merchant).to have_key(:errors)
      expect(merchant[:errors]).to eq("merchant does not exist")
    end 

    it "will respond with a 404 error if merchant id is not valid" do
      id = create(:merchant).id

      get "/api/v1/merchants/#{id}"

      merchant = JSON.parse(response.body, symbolize_names: true)
      expect(response).to be_successful
      expect(response.status).to eq(200)

      expect(merchant[:data]).to have_key(:id)
      expect(merchant[:data][:id]).to eq("#{id}")

      expect(merchant[:data][:attributes]).to have_key(:name)
      expect(merchant[:data][:attributes][:name]).to be_a(String)
    end 
  end 

  describe "find a merchants items" do
    it "can find all items that belong to a merchant" do
      merchant = create(:merchant).id
      items = create_list(:item, 3, merchant_id: merchant)

      get "/api/v1/merchants/#{merchant}/items"
      
      items = JSON.parse(response.body, symbolize_names: true)[:data]
      expect(items.count).to eq(3)
      expect(response).to be_successful
      expect(response.status).to eq(200)

      items.each do |item|
        expect(item[:attributes]).to have_key(:name)
        expect(item[:attributes][:name]).to be_a(String)

        expect(item[:attributes]).to have_key(:description)
        expect(item[:attributes][:description]).to be_a(String)

        expect(item[:attributes]).to have_key(:unit_price)
        expect(item[:attributes][:unit_price]).to be_a(Float)

        expect(item[:attributes]).to have_key(:merchant_id)
        expect(item[:attributes][:merchant_id]).to be_an(Integer)
      end
    end

    it "will respond with a 404 error if merchant id is not valid" do
      get "/api/v1/merchants/3/items"

      merchant_items = JSON.parse(response.body, symbolize_names: true)
      expect(response.status).to eq(404)
      expect(merchant_items).to have_key(:errors)
      expect(merchant_items[:errors]).to eq("merchant does not exist")
    end 
  end

  describe "can find one merchant by name" do
    it "will return one merchant that is the first when results are sorted case-insensitive alphabetical order" do
      merchant1 = create(:merchant, name: "Joel")
      merchant2 = create(:merchant, name: "Pamela")
      merchant3 = create(:merchant, name: "Elaine")

      get "/api/v1/merchants/find_all?name=el"
      result = JSON.parse(response.body, symbolize_names: true)[:data]
      expect(response).to be_successful
      expect(response.status).to eq(200)
      expect(result[:id].to_i).to eq(merchant3.id)
      expect(result[:attributes][:name]).to eq(merchant3.name)
    end

    it "will return a 404 error if there are no matches" do
      merchant1 = create(:merchant, name: "Joel")
      merchant2 = create(:merchant, name: "Pamela")
      merchant3 = create(:merchant, name: "Elaine")

      get "/api/v1/merchants/find_all?name=frog"
      result = JSON.parse(response.body, symbolize_names: true)
      expect(response.status).to eq(404)
      expect(result[:data][:errors]).to eq("Your search has no matches")
    end
  end
end 
