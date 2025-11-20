# frozen_string_literal: true

# ==============================================================================
# Home Controller
# Serves the main frontend application
# ==============================================================================

class HomeController < ApplicationController
  def index
    @recent_urls = ShortUrl.where(deleted_at: nil)
                           .order(created_at: :desc)
                           .limit(5)
    @stats = {
      total_urls: ShortUrl.count,
      total_clicks: ShortUrl.sum(:click_count),
      urls_today: ShortUrl.where('created_at >= ?', Time.current.beginning_of_day).count
    }
  end
end
