# frozen_string_literal: true

require_relative 'boot'

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module ShortApp
  class Application < Rails::Application
    # ==========================================================================
    # Rails 7.1 Defaults
    # ==========================================================================
    config.load_defaults 7.1

    # ==========================================================================
    # Time Zone Configuration
    # ==========================================================================
    config.time_zone = 'UTC'
    config.active_record.default_timezone = :utc

    # ==========================================================================
    # Background Job Configuration (Sidekiq)
    # ==========================================================================
    config.active_job.queue_adapter = :sidekiq
    config.active_job.queue_name_prefix = "short_app_#{Rails.env}"

    # ==========================================================================
    # API Configuration
    # ==========================================================================
    # Generate only API controllers (no views)
    config.api_only = false # Keep false to support Sidekiq Web UI

    # Configure generators
    config.generators do |g|
      g.test_framework :rspec,
                       fixtures: false,
                       view_specs: false,
                       helper_specs: false,
                       routing_specs: false
      g.factory_bot dir: 'spec/factories'
    end

    # ==========================================================================
    # Logging Configuration
    # ==========================================================================
    # Use lograge for structured JSON logging in production
    if Rails.env.production?
      config.lograge.enabled = true
      config.lograge.formatter = Lograge::Formatters::Json.new
      config.lograge.custom_options = lambda do |event|
        {
          request_id: event.payload[:request_id],
          user_agent: event.payload[:user_agent],
          ip: event.payload[:ip],
          time: Time.current.iso8601
        }
      end
    end

    # ==========================================================================
    # Security Configuration
    # ==========================================================================
    # Configure allowed hosts in production
    config.hosts.clear if Rails.env.development? || Rails.env.test?

    # ==========================================================================
    # Auto-loading Configuration
    # ==========================================================================
    # Add lib to autoload paths
    config.autoload_lib(ignore: %w[assets tasks])

    # ==========================================================================
    # Redis Configuration
    # ==========================================================================
    config.cache_store = :redis_cache_store, {
      url: ENV.fetch('REDIS_URL', 'redis://localhost:6379/1'),
      namespace: 'short_app_cache',
      expires_in: 1.hour,
      connect_timeout: 2,
      read_timeout: 1,
      write_timeout: 1,
      reconnect_attempts: 1,
      error_handler: lambda { |method:, returning:, exception:|
        Rails.logger.error("Redis cache error: #{exception.class} - #{exception.message}")
        AppMetrics.counter(:redis_errors_total, 1, { method: method.to_s }) if defined?(AppMetrics)
      }
    }
  end
end
