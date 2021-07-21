FactoryBot.define do
  factory :access_token do
    user
    sequence(:token){ |n| "#{n}" }
  end
end
