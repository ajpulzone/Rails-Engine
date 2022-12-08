FactoryBot.define do
  factory :invoice do
    status { Faker::Tea.type }
  end
end