class MerchantSerializer
  include JSONAPI::Serializer 
  attributes :name

  # has_many :items
  # has_many :invoices 

  # def self.format_merchants(merchants)
  #   merchants.map do |merchant|
  #     {
  #       id: merchant.id,
  #       name: merchant.name,
  #     }
  #   end
  # end 
end