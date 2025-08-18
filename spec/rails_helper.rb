# frozen_string_literal: true

# ==============================================================================
# RSpec Configuration
# Demonstrates: Senior SWE - Comprehensive test setup
# ==============================================================================

require 'spec_helper'
ENV['RAILS_ENV'] ||= 'test'

require_relative '../config/environment'

# Prevent database truncation if the environment is production
abort('The Rails environment is running in production mode!') if Rails.env.production?

require 'rspec/rails'
require 'webmock/rspec'
require 'factory_bot_rails'
require 'shoulda/matchers'
require 'database_cleaner/active_record'

# Load support files
Dir[Rails.root.join('spec/support/**/*.rb')].each { |f| require f }

# Checks for pending migrations before tests are run
begin
  ActiveRecord::Migration.maintain_test_schema!
rescue ActiveRecord::PendingMigrationError => e
  abort e.to_s.strip
end

RSpec.configure do |config|
  # ===========================================================================
  # Fixture Configuration
  # ===========================================================================
  config.fixture_paths = [Rails.root.join('spec/fixtures')]
  config.use_transactional_fixtures = false

  # ===========================================================================
  # FactoryBot
  # ===========================================================================
  config.include FactoryBot::Syntax::Methods

  # ===========================================================================
  # Database Cleaner
  # ===========================================================================
  config.before(:suite) do
    DatabaseCleaner.clean_with(:truncation)
  end

  config.before(:each) do
    DatabaseCleaner.strategy = :transaction
  end

  config.before(:each, type: :feature) do
    DatabaseCleaner.strategy = :truncation
  end

  config.before(:each) do
    DatabaseCleaner.start
  end

  config.after(:each) do
    DatabaseCleaner.clean
  end

  # ===========================================================================
  # Type Inference
  # ===========================================================================
  config.infer_spec_type_from_file_location!

  # ===========================================================================
  # Filter Rails Backtrace
  # ===========================================================================
  config.filter_rails_from_backtrace!

  # ===========================================================================
  # ActiveJob Test Helpers
  # ===========================================================================
  config.include ActiveJob::TestHelper, type: :job

  # ===========================================================================
  # Request Spec Helpers
  # ===========================================================================
  config.include ActionDispatch::TestProcess::FixtureFile

  # ===========================================================================
  # WebMock Configuration
  # ===========================================================================
  WebMock.disable_net_connect!(
    allow_localhost: true,
    allow: ['chromedriver.storage.googleapis.com']
  )

  # ===========================================================================
  # Sidekiq Test Mode
  # ===========================================================================
  config.before(:each) do
    Sidekiq::Worker.clear_all if defined?(Sidekiq)
  end
end

# ===========================================================================
# Shoulda Matchers Configuration
# ===========================================================================
Shoulda::Matchers.configure do |config|
  config.integrate do |with|
    with.test_framework :rspec
    with.library :rails
  end
end
