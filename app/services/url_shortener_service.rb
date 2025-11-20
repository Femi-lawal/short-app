# frozen_string_literal: true

# ==============================================================================
# URL Shortener Service
# Demonstrates: Senior Backend - Service Objects, Single Responsibility
# ==============================================================================

class UrlShortenerService
  Result = Struct.new(:success?, :short_url, :error, keyword_init: true)

  def initialize(params, request_ip: nil)
    @params = params
    @request_ip = request_ip
  end

  def self.call(params, request_ip: nil)
    new(params, request_ip: request_ip).call
  end

  def call
    validate_url!
    
    ActiveRecord::Base.transaction do
      short_url = create_short_url
      short_url.generate_short_code!
      
      AppMetrics.counter(:short_urls_created_total, 1) if defined?(AppMetrics)
      
      Result.new(success?: true, short_url: short_url, error: nil)
    end
  rescue ActiveRecord::RecordNotUnique
    handle_duplicate_url
  rescue ValidationError => e
    Result.new(success?: false, short_url: nil, error: e.message)
  rescue StandardError => e
    Rails.logger.error("UrlShortenerService error: #{e.class} - #{e.message}")
    Result.new(success?: false, short_url: nil, error: 'An unexpected error occurred')
  end

  private

  def validate_url!
    url = @params[:full_url]
    
    raise ValidationError, 'URL is required' if url.blank?
    
    begin
      uri = URI.parse(url)
      unless uri.is_a?(URI::HTTP) || uri.is_a?(URI::HTTPS)
        raise ValidationError, 'URL must be a valid HTTP or HTTPS URL'
      end
    rescue URI::InvalidURIError
      raise ValidationError, 'URL format is invalid'
    end
  end

  def create_short_url
    ShortUrl.create!(
      full_url: @params[:full_url],
      custom_alias: @params[:custom_alias].presence,
      expires_at: parse_expires_at,
      created_by_ip: @request_ip,
      metadata: build_metadata
    )
  end

  def parse_expires_at
    return nil if @params[:expires_at].blank?
    
    Time.zone.parse(@params[:expires_at])
  rescue ArgumentError
    nil
  end

  def build_metadata
    {
      utm_source: @params[:utm_source],
      utm_medium: @params[:utm_medium],
      utm_campaign: @params[:utm_campaign]
    }.compact
  end

  def handle_duplicate_url
    existing = ShortUrl.find_by(full_url: @params[:full_url], deleted_at: nil)
    
    if existing
      Result.new(success?: true, short_url: existing, error: nil)
    else
      Result.new(success?: false, short_url: nil, error: 'URL already exists')
    end
  end

  class ValidationError < StandardError; end
end
