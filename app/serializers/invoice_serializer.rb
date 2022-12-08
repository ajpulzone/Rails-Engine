class InvoiceSerializer
  include JSONAPI::Serializer 
  attributes :status

  has_many :items, through: :invoice_items
  has_many :invoice_items  
end