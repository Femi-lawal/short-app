# frozen_string_literal: true

class FetchUrlTitleJob < ApplicationJob
  queue_as :default

  def perform(short_url_id)
    short_url = ShortUrl.find_by(id: short_url_id)
    return unless short_url

    result = TitleFetcherService.call(short_url.full_url)
    short_url.update(title: result.title) if result.success? && result.title.present?
  rescue StandardError => e
    Rails.logger.error("FetchUrlTitleJob failed: #{e.message}")
  end
end
