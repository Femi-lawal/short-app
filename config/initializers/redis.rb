# frozen_string_literal: true

# ==============================================================================
# Redis Configuration
# Provides a Redis connection pool for the application
# Sidekiq has its own Redis configuration in config/initializers/sidekiq.rb
# ==============================================================================

# Configure a shared Redis connection for caching
REDIS_URL = ENV.fetch('REDIS_URL', 'redis://localhost:6379/0')

# Create a connection pool for Redis if not using Rails cache
# Rails.application.config.cache_store is already configured in application.rb