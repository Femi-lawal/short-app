# frozen_string_literal: true

# ==============================================================================
# Routes Configuration
# Demonstrates: Senior Backend - RESTful API design, versioning, namespacing
# ==============================================================================

Rails.application.routes.draw do
  # ============================================================================
  # Health Check Endpoints (SRE)
  # ============================================================================
  get '/health', to: 'health#liveness'
  get '/liveness', to: 'health#liveness'
  get '/readiness', to: 'health#readiness'
  get '/metrics', to: 'health#metrics'

  # ============================================================================
  # Sidekiq Web UI (Admin)
  # ============================================================================
  require 'sidekiq/web'

  # Protect Sidekiq in production with basic auth
  if Rails.env.production?
    Sidekiq::Web.use Rack::Auth::Basic do |username, password|
      # Use secure comparison to prevent timing attacks
      ActiveSupport::SecurityUtils.secure_compare(
        ::Digest::SHA256.hexdigest(username),
        ::Digest::SHA256.hexdigest(ENV.fetch('SIDEKIQ_USERNAME', 'admin'))
      ) & ActiveSupport::SecurityUtils.secure_compare(
        ::Digest::SHA256.hexdigest(password),
        ::Digest::SHA256.hexdigest(ENV.fetch('SIDEKIQ_PASSWORD', 'password'))
      )
    end
  end

  mount Sidekiq::Web => '/admin/sidekiq'

  # ============================================================================
  # API V1 Routes
  # ============================================================================
  namespace :api do
    namespace :v1 do
      resources :short_urls, only: %i[index create show] do
        member do
          get :stats
        end
      end
    end
  end

  # ============================================================================
  # Legacy API Routes (Backward Compatibility)
  # ============================================================================
  # These routes maintain compatibility with existing clients
  scope module: 'api/v1' do
    resources :short_urls, only: %i[index create], path: 'short_urls', defaults: { format: :json }
  end

  # ============================================================================
  # Redirect Routes (Core Functionality)
  # ============================================================================
  # This must be last as it's a catch-all
  get '/:short_code', to: 'redirects#show', as: :short_redirect,
                      constraints: { short_code: /[a-zA-Z0-9]+/ }

  # ============================================================================
  # Root Route (Frontend)
  # ============================================================================
  root to: 'home#index'
end
