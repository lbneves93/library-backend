FactoryBot.define do
  factory :user do
    name { Faker::Name.name }
    email { Faker::Internet.unique.email }
    password { '123456' }
    role { 0 }
    jti { SecureRandom.hex(20) }
  end
end
