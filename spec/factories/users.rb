FactoryBot.define do
  factory :user do
    name { 'Leonardo' }
    email { 'leonardo@email.com' }
    password { '123456' }
    role { 0 }
    jti { SecureRandom.hex(20) }
  end
end
