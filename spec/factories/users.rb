# frozen_string_literal: true

FactoryBot.define do
  factory :user do
    uid { Faker::Number.number(digits: 18) }
  end
end
