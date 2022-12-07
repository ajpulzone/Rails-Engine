FactoryBot.define do
  factory :item do
    name { Faker::Dessert.variety }
    description { Faker::Lorem.paragraph(sentence_count: 1) }
    unit_price { Faker::Number.decimal(l_digits: 2) }
  end
end