# frozen_string_literal: true

# ==============================================================================
# API Key Model
# Demonstrates: Senior Backend - API authentication, secure token storage
# ==============================================================================

class ApiKey < ApplicationRecord
  # ============================================================================
  # Security
  # ============================================================================
  has_secure_token :key

  # ============================================================================
  # Validations
  # ============================================================================
  validates :name, presence: true
  validates :key, presence: true, uniqueness: true

  # ============================================================================
  # Scopes
  # ============================================================================
  scope :active, -> { where(revoked_at: nil).where('expires_at IS NULL OR expires_at > ?', Time.current) }
  scope :expired, -> { where('expires_at <= ?', Time.current) }
  scope :revoked, -> { where.not(revoked_at: nil) }

  # ============================================================================
  # Instance Methods
  # ============================================================================

  def revoke!
    update!(revoked_at: Time.current)
  end

  def active?
    revoked_at.nil? && (expires_at.nil? || expires_at > Time.current)
  end

  def expired?
    expires_at.present? && expires_at <= Time.current
  end
end
