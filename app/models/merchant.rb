class Merchant < ApplicationRecord
  has_many :items
  has_many :invoices

  def self.merchant_by_name

  end 
end