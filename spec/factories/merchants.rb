FactoryBot.define do
  factory :merchant do
    name {Faker::Merchant.name}
  end
end