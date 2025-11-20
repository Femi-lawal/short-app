# frozen_string_literal: true

namespace :urls do
  desc 'Sync click counts from Redis cache to database'
  task sync_click_counts: :environment do
    puts 'Syncing click counts...'
    synced = 0
    ShortUrl.find_each { |url| url.sync_click_count!; synced += 1 }
    puts "Synced #{synced} URLs"
  end

  desc 'Clean up expired URLs (soft delete)'
  task cleanup_expired: :environment do
    expired = ShortUrl.where('expires_at < ?', Time.current).where(deleted_at: nil).update_all(deleted_at: Time.current)
    puts "Soft deleted #{expired} expired URLs"
  end

  desc 'Show statistics about short URLs'
  task stats: :environment do
    total = ShortUrl.count
    active = ShortUrl.where(deleted_at: nil).count
    total_clicks = ShortUrl.sum(:click_count)
    puts "Total: #{total}, Active: #{active}, Total clicks: #{total_clicks}"
  end
end

namespace :api_keys do
  desc 'Generate a new API key'
  task :generate, [:name] => :environment do |_t, args|
    name = args[:name] || "Key-#{SecureRandom.hex(4)}"
    api_key = ApiKey.create!(name: name, expires_at: 1.year.from_now)
    puts "Created API key: #{api_key.name} - #{api_key.key}"
  end

  desc 'List all active API keys'
  task list: :environment do
    ApiKey.active.each { |k| puts "#{k.name}: #{k.key[0..8]}..." }
  end

  desc 'Revoke an API key by name'
  task :revoke, [:name] => :environment do |_t, args|
    key = ApiKey.find_by(name: args[:name])
    key&.revoke! && puts("Revoked: #{args[:name]}")
  end
end
