# frozen_string_literal: true

# ==============================================================================
# Short URL Model
# Demonstrates: Senior Backend - ActiveRecord best practices, caching, scopes
# ==============================================================================

class ShortUrl < ApplicationRecord
  # ============================================================================
  # Constants
  # ============================================================================
  CHARACTERS = [*'0'..'9', *'a'..'z', *'A'..'Z'].freeze
  BASE = CHARACTERS.length # 62

  # ============================================================================
  # Associations (for future extensibility)
  # ============================================================================
  # belongs_to :user, optional: true  # Future: user authentication
  # has_many :click_events             # Future: detailed analytics

  # ============================================================================
  # Callbacks
  # ============================================================================
  after_create :generate_short_code!
  after_commit :invalidate_cache, on: %i[update destroy]

  # ============================================================================
  # Validations
  # ============================================================================
  validates :full_url, presence: true
  validate :validate_url_format

  # ============================================================================
  # Scopes
  # ============================================================================
  scope :most_popular, -> { order(click_count: :desc) }
  scope :recent, -> { order(created_at: :desc) }
  scope :active, -> { where(deleted_at: nil) }
  scope :accessed_since, ->(time) { where('last_accessed_at >= ?', time) }
  scope :created_between, ->(start_time, end_time) { where(created_at: start_time..end_time) }

  # Soft delete scope (if paranoia/discard not used)
  default_scope { where(deleted_at: nil) }

  # ============================================================================
  # Class Methods
  # ============================================================================
  class << self
    # Find by short code with caching
    def find_by_short_code(code)
      Rails.cache.fetch(cache_key_for_code(code), expires_in: 1.hour) do
        unscoped.active.find_by(short_code: code)
      end
    end

    def cache_key_for_code(code)
      "short_url:code:#{code}"
    end
  end

  # ============================================================================
  # Instance Methods
  # ============================================================================

  # Generate short code from ID using Base62 encoding
  def generate_short_code!
    return if short_code.present?

    encoded = UrlShortenerService.encode_id(id)
    update_column(:short_code, encoded)
  end

  # Record a click/access with caching for high-traffic URLs
  def record_access!(request_metadata = {})
    # Use Redis for high-frequency counter updates
    if Rails.cache.respond_to?(:redis)
      increment_cached_count
    else
      increment!(:click_count)
    end

    # Update last accessed timestamp (less frequently to reduce DB writes)
    update_last_accessed if should_update_timestamp?

    # Log access for analytics (async)
    log_access_event(request_metadata)
  end

  # Sync cached click count to database
  def sync_click_count!
    cached_count = Rails.cache.read(click_count_cache_key)
    return unless cached_count.present?

    update_column(:click_count, cached_count.to_i)
    Rails.cache.delete(click_count_cache_key)
  end

  # Get click count (from cache or DB)
  def effective_click_count
    Rails.cache.fetch(click_count_cache_key, expires_in: 5.minutes) do
      click_count
    end
  end

  # Soft delete
  def soft_delete!
    update_column(:deleted_at, Time.current)
    invalidate_cache
  end

  # Restore soft-deleted record
  def restore!
    update_column(:deleted_at, nil)
  end

  # Update title asynchronously
  def update_title!
    result = TitleFetcherService.call(full_url)
    update_column(:title, result.title) if result.success? && result.title.present?
    result
  end

  private

  # ============================================================================
  # Validation Methods
  # ============================================================================
  def validate_url_format
    return errors.add(:full_url, "can't be blank") if full_url.blank?

    begin
      uri = URI.parse(full_url)
      unless uri.is_a?(URI::HTTP) || uri.is_a?(URI::HTTPS)
        errors.add(:full_url, 'must be a valid HTTP or HTTPS URL')
      end

      if uri.host.blank?
        errors.add(:full_url, 'must have a valid host')
      end
    rescue URI::InvalidURIError
      errors.add(:full_url, 'is not a valid URL')
    end
  end

  # ============================================================================
  # Cache Methods
  # ============================================================================
  def click_count_cache_key
    "short_url:#{id}:click_count"
  end

  def increment_cached_count
    cache = Rails.cache
    key = click_count_cache_key

    if cache.read(key)
      cache.increment(key)
    else
      cache.write(key, click_count + 1, expires_in: 1.hour)
    end
  end

  def invalidate_cache
    Rails.cache.delete(self.class.cache_key_for_code(short_code)) if short_code.present?
    Rails.cache.delete(click_count_cache_key)
  end

  def should_update_timestamp?
    last_accessed_at.nil? || last_accessed_at < 1.minute.ago
  end

  def update_last_accessed
    update_column(:last_accessed_at, Time.current)
  end

  def log_access_event(metadata)
    # Future: Log to analytics table or external service
    Rails.logger.info({
      event: 'url_accessed',
      short_code: short_code,
      ip: metadata[:ip],
      user_agent: metadata[:user_agent],
      referer: metadata[:referer]
    }.to_json)
  end
end
