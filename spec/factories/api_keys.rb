# frozen_string_literal: true

FactoryBot.define do
  factory :api_key do
    sequence(:name) { |n| "API Key #{n}" }
    key { SecureRandom.hex(32) }
    description { "API key for testing" }
    expires_at { nil }
    revoked_at { nil }

    trait :active do
      expires_at { 1.year.from_now }
    end

    trait :expired do
      expires_at { 1.day.ago }
    end

    trait :revoked do
      revoked_at { 1.hour.ago }
    end
  end
end
