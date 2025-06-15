# frozen_string_literal: true

# ==============================================================================
# UpdateTitleJob (Deprecated - use FetchUrlTitleJob instead)
# This job is kept for backward compatibility only
# Demonstrates: Senior Backend - Graceful deprecation
# ==============================================================================

class UpdateTitleJob < ApplicationJob
  queue_as :default

  # @deprecated Use {FetchUrlTitleJob} instead
  def perform(short_url_id)
    ActiveSupport::Deprecation.warn(
      'UpdateTitleJob is deprecated. Use FetchUrlTitleJob instead.',
      caller
    )
    
    # Delegate to the preferred job
    FetchUrlTitleJob.perform_now(short_url_id)
  end
end
