# frozen_string_literal: true

# ==============================================================================
# Title Fetcher Service
# Demonstrates: Senior Backend - HTTP client, error handling, fallback logic
# ==============================================================================

class TitleFetcherService
  Result = Struct.new(:success?, :title, :error, keyword_init: true)

  TIMEOUT = 5
  MAX_REDIRECTS = 3
  USER_AGENT = 'ShortApp TitleFetcher/1.0'

  class CircuitOpenError < StandardError; end

  def initialize(url)
    @url = url
  end

  def self.call(url)
    new(url).call
  end

  def self.circuit_breaker
    @circuit_breaker ||= CircuitBreaker.new(
      failure_threshold: 5,
      recovery_timeout: 30
    )
  end

  def call
    unless self.class.circuit_breaker.allow_request?
      raise CircuitOpenError, 'Circuit breaker is open'
    end

    response = fetch_page
    title = extract_title(response.body)
    
    self.class.circuit_breaker.record_success
    Result.new(success?: true, title: title, error: nil)
  rescue CircuitOpenError => e
    Result.new(success?: false, title: nil, error: e.message)
  rescue StandardError => e
    handle_failure(e)
  end

  private

  def fetch_page
    conn = Faraday.new do |f|
      f.options.timeout = TIMEOUT
      f.options.open_timeout = TIMEOUT
      f.response :follow_redirects, limit: MAX_REDIRECTS
      f.adapter Faraday.default_adapter
    end

    conn.get(@url) do |req|
      req.headers['User-Agent'] = USER_AGENT
      req.headers['Accept'] = 'text/html'
    end
  end

  def extract_title(html)
    return nil if html.blank?

    doc = Nokogiri::HTML(html)
    
    # Priority: og:title > title tag > h1
    og_title = doc.at_css('meta[property="og:title"]')&.[]('content')
    return sanitize_title(og_title) if og_title.present?

    title_tag = doc.at_css('title')&.text
    return sanitize_title(title_tag) if title_tag.present?

    h1_tag = doc.at_css('h1')&.text
    return sanitize_title(h1_tag) if h1_tag.present?

    nil
  end

  def sanitize_title(title)
    title.to_s
         .gsub(/\s+/, ' ')
         .strip
         .truncate(500)
  end

  def handle_failure(error)
    self.class.circuit_breaker.record_failure
    Rails.logger.warn("TitleFetcher failed for #{@url}: #{error.class} - #{error.message}")
    Result.new(success?: false, title: nil, error: error.message)
  end
end
