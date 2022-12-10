# frozen_string_literal: true

FactoryBot.define do
  factory :user do
    uid { Faker::Number.number(digits: 18) }
    image { Faker::Avatar.image(format: 'jpg') }
  end
end
