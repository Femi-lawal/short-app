# frozen_string_literal: true

# ==============================================================================
# Redirects Controller
# Handles short URL redirects
# ==============================================================================

class RedirectsController < ApplicationController
  skip_before_action :verify_authenticity_token, raise: false

  def show
    short_url = ShortUrl.find_by(short_code: params[:short_code], deleted_at: nil)

    if short_url.nil?
      render json: { error: 'Not found' }, status: :not_found
      return
    end

    if short_url.expired?
      render json: { error: 'URL has expired' }, status: :gone
      return
    end

    short_url.increment!(:click_count)
    short_url.update_column(:last_accessed_at, Time.current)

    redirect_to short_url.full_url, status: :moved_permanently, allow_other_host: true
  end
end
