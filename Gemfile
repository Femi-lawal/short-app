# frozen_string_literal: true

source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby '3.2.2'

# ====================================
# Core Framework
# ====================================
gem 'rails', '~> 7.1.2'
gem 'puma', '~> 6.4'         # High-performance, concurrent web server

# ====================================
# Database & Caching
# ====================================
gem 'mysql2', '~> 0.5.5'     # MySQL/MariaDB adapter
gem 'redis', '~> 5.0'        # Redis client for caching and Sidekiq
gem 'connection_pool', '~> 2.4'  # Connection pooling for Redis

# ====================================
# Background Processing
# ====================================
gem 'sidekiq', '~> 7.2'      # Modern background job processor
gem 'sidekiq-scheduler', '~> 5.0'  # Scheduled/recurring jobs

# ====================================
# API & Serialization
# ====================================
gem 'oj', '~> 3.16'          # Optimized JSON parser
gem 'multi_json', '~> 1.15'  # Flexible JSON backend
gem 'jbuilder', '~> 2.11'    # JSON API views
gem 'pagy', '~> 6.2'         # Lightweight pagination

# ====================================
# Security & Rate Limiting
# ====================================
gem 'rack-attack', '~> 6.7'  # Rack middleware for rate limiting
gem 'rack-cors', '~> 2.0'    # CORS support

# ====================================
# HTTP Client (for URL title fetching)
# ====================================
gem 'faraday', '~> 2.8'      # HTTP client
gem 'faraday-retry', '~> 2.2'  # Retry middleware
gem 'nokogiri', '~> 1.15'    # HTML parsing

# ====================================
# Validation & Form Objects
# ====================================
gem 'dry-validation', '~> 1.10'  # Powerful validation library
gem 'dry-types', '~> 1.7'        # Type system for dry-rb

# ====================================
# Monitoring & Observability
# ====================================
gem 'prometheus_exporter', '~> 2.0'  # Prometheus metrics
gem 'lograge', '~> 0.14'             # Structured logging
gem 'request_store', '~> 1.5'        # Per-request global storage

# ====================================
# OpenTelemetry (Distributed Tracing)
# ====================================
gem 'opentelemetry-sdk', '~> 1.3'
gem 'opentelemetry-exporter-otlp', '~> 0.26'
gem 'opentelemetry-instrumentation-all', '~> 0.60'

# ====================================
# Performance & Boot Time
# ====================================
gem 'bootsnap', '>= 1.16', require: false  # Reduces boot times

# ====================================
# Frontend (Minimal - API focused)
# ====================================
gem 'propshaft', '~> 0.8'    # Modern asset pipeline (Rails 7+)
gem 'turbo-rails', '~> 1.5'  # Hotwire Turbo
gem 'stimulus-rails', '~> 1.3'  # Hotwire Stimulus

# Windows TZ data
gem 'tzinfo-data', platforms: %i[mingw mswin x64_mingw jruby]

# ====================================
# Development & Test
# ====================================
group :development, :test do
  gem 'debug', platforms: %i[mri mingw x64_mingw]  # Debugger (replaces byebug)
  gem 'rspec-rails', '~> 6.1'      # Testing framework
  gem 'factory_bot_rails', '~> 6.4'  # Test factories
  gem 'faker', '~> 3.2'              # Fake data generation
  gem 'dotenv-rails', '~> 2.8'       # Environment variables

  # Code Quality
  gem 'rubocop', '~> 1.59', require: false
  gem 'rubocop-rails', '~> 2.23', require: false
  gem 'rubocop-rspec', '~> 2.25', require: false
  gem 'rubocop-performance', '~> 1.20', require: false
  gem 'brakeman', '~> 6.1', require: false  # Security scanner
end

group :development do
  gem 'web-console', '>= 4.2'  # Console on exception pages
  gem 'listen', '~> 3.8'       # File system change listener
  gem 'spring', '~> 4.1'       # App preloader

  # Documentation
  gem 'rswag-api', '~> 2.11'   # Swagger/OpenAPI
  gem 'rswag-ui', '~> 2.11'
end

group :test do
  gem 'capybara', '>= 3.39'
  gem 'selenium-webdriver', '~> 4.16'
  gem 'webmock', '~> 3.19'         # HTTP request stubbing
  gem 'simplecov', '~> 0.22', require: false  # Code coverage
  gem 'shoulda-matchers', '~> 5.3' # One-liner tests
  gem 'database_cleaner-active_record', '~> 2.1'
  gem 'rspec-sidekiq', '~> 4.1'    # Sidekiq test helpers
  gem 'timecop', '~> 0.9'          # Time manipulation
end
