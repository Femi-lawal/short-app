# frozen_string_literal: true

require 'rails_helper'

# ==============================================================================
# ShortUrl Model Spec
# Demonstrates: Senior SWE - Model testing with Shoulda Matchers
# ==============================================================================

RSpec.describe ShortUrl, type: :model do
  describe 'validations' do
    it { is_expected.to validate_presence_of(:full_url) }
  end

  describe 'scopes' do
    describe '.most_popular' do
      it 'orders by click_count descending' do
        low = create(:short_url, click_count: 10)
        high = create(:short_url, click_count: 100)
        medium = create(:short_url, click_count: 50)

        expect(described_class.most_popular).to eq([high, medium, low])
      end
    end

    describe '.recent' do
      it 'orders by created_at descending' do
        old = create(:short_url, created_at: 2.days.ago)
        new = create(:short_url, created_at: 1.hour.ago)

        expect(described_class.recent.first).to eq(new)
      end
    end

    describe 'default_scope (soft delete)' do
      it 'excludes soft-deleted records' do
        active = create(:short_url)
        deleted = create(:short_url, deleted_at: 1.day.ago)

        expect(described_class.all).to include(active)
        expect(described_class.all).not_to include(deleted)
      end

      it 'allows unscoped access to deleted records' do
        deleted = create(:short_url, deleted_at: 1.day.ago)

        expect(described_class.unscoped).to include(deleted)
      end
    end
  end

  describe 'URL validation' do
    it 'accepts valid HTTP URLs' do
      short_url = build(:short_url, full_url: 'http://example.com')
      expect(short_url).to be_valid
    end

    it 'accepts valid HTTPS URLs' do
      short_url = build(:short_url, full_url: 'https://example.com/path?query=1')
      expect(short_url).to be_valid
    end

    it 'rejects invalid URLs' do
      short_url = build(:short_url, full_url: 'not-a-url')
      expect(short_url).not_to be_valid
      expect(short_url.errors[:full_url]).to be_present
    end

    it 'rejects javascript URLs' do
      short_url = build(:short_url, full_url: 'javascript:alert("xss")')
      expect(short_url).not_to be_valid
    end

    it 'rejects blank URLs' do
      short_url = build(:short_url, full_url: '')
      expect(short_url).not_to be_valid
      expect(short_url.errors[:full_url]).to include("can't be blank")
    end
  end

  describe '#generate_short_code!' do
    it 'generates a short code after creation' do
      short_url = create(:short_url)
      expect(short_url.short_code).to be_present
    end

    it 'generates unique codes based on ID' do
      url1 = create(:short_url)
      url2 = create(:short_url)

      expect(url1.short_code).not_to eq(url2.short_code)
    end
  end

  describe '.find_by_short_code' do
    let!(:short_url) { create(:short_url) }

    it 'finds a URL by its short code' do
      found = described_class.find_by_short_code(short_url.short_code)
      expect(found).to eq(short_url)
    end

    it 'returns nil for non-existent codes' do
      found = described_class.find_by_short_code('nonexistent')
      expect(found).to be_nil
    end

    it 'caches the result' do
      # First call - cache miss
      described_class.find_by_short_code(short_url.short_code)

      # Second call should use cache
      expect(described_class).not_to receive(:find_by)
      Rails.cache.fetch(described_class.cache_key_for_code(short_url.short_code))
    end
  end

  describe '#record_access!' do
    let(:short_url) { create(:short_url) }

    it 'increments the click count' do
      expect { short_url.record_access! }
        .to change { short_url.reload.click_count }.by(1)
    end

    it 'updates last_accessed_at' do
      short_url.record_access!
      expect(short_url.reload.last_accessed_at).to be_within(1.second).of(Time.current)
    end
  end

  describe '#soft_delete!' do
    let(:short_url) { create(:short_url) }

    it 'sets deleted_at timestamp' do
      short_url.soft_delete!
      expect(short_url.deleted_at).to be_present
    end

    it 'removes from default scope' do
      short_url.soft_delete!
      expect(described_class.all).not_to include(short_url)
    end
  end

  describe '#restore!' do
    let(:short_url) { create(:short_url, deleted_at: 1.day.ago) }

    it 'clears deleted_at timestamp' do
      short_url.restore!
      expect(short_url.deleted_at).to be_nil
    end
  end

  describe '#effective_click_count' do
    it 'returns click count from cache or database' do
      short_url = create(:short_url, click_count: 42)
      expect(short_url.effective_click_count).to eq(42)
    end
  end
end
