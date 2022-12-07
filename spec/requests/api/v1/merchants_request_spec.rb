require "rails_helper"

describe "Merchants API" do
  it "sends a list of merchants" do
    create_list(:merchant, 3)

    get "/api/v1/merchants"

    expect(response).to be_successful
    expect(response.status).to eq(200)

    merchants = JSON.parse(response.body, symbolize_names: true)

    expect(merchants[:data].count).to eq(3)

    merchants[:data].each do |merchant|
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

    expect(response).to be_successful
    expect(response.status).to eq(200)

    merchants = JSON.parse(response.body, symbolize_names: true)
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

  it "can get one merchant by their id" do
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