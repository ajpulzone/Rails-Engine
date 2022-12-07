class ItemSerializer
  include JSONAPI::Serializer 
  attributes :name, :description, :unit_price

  # has_many :items
  # has_many :invoices 
end