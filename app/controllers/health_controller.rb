# frozen_string_literal: true

# ==============================================================================
# Health Controller
# Provides health check endpoints for Kubernetes/Docker
# ==============================================================================

class HealthController < ApplicationController
  skip_before_action :verify_authenticity_token, raise: false

  def liveness
    render json: { status: 'ok', timestamp: Time.current.iso8601 }
  end

  def readiness
    checks = {
      database: check_database,
      redis: check_redis
    }

    status = checks.values.all? ? :ok : :service_unavailable
    render json: { status: status == :ok ? 'ok' : 'unhealthy', checks: checks }, status: status
  end

  def metrics
    metrics_data = AppMetrics.to_prometheus_format if defined?(AppMetrics)
    render plain: metrics_data || "# No metrics available\n", content_type: 'text/plain'
  end

  private

  def check_database
    ActiveRecord::Base.connection.execute('SELECT 1')
    true
  rescue StandardError
    false
  end

  def check_redis
    Redis.new(url: ENV.fetch('REDIS_URL', 'redis://localhost:6379')).ping == 'PONG'
  rescue StandardError
    false
  end
end
