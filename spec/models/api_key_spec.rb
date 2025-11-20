# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ApiKey, type: :model do
  describe 'validations' do
    subject { build(:api_key) }
    it { is_expected.to validate_presence_of(:name) }
    it { is_expected.to validate_presence_of(:key) }
  end

  describe 'scopes' do
    describe '.active' do
      let!(:active_key) { create(:api_key, :active) }
      let!(:expired_key) { create(:api_key, :expired) }

      it 'includes non-expired keys' do
        expect(described_class.active).to include(active_key)
        expect(described_class.active).not_to include(expired_key)
      end
    end
  end

  describe '#revoke!' do
    let(:api_key) { create(:api_key, :active) }

    it 'sets revoked_at' do
      api_key.revoke!
      expect(api_key.revoked_at).to be_present
    end
  end

  describe '#active?' do
    it 'returns true when not expired/revoked' do
      api_key = create(:api_key, :active)
      expect(api_key.active?).to be true
    end

    it 'returns false when expired' do
      api_key = create(:api_key, :expired)
      expect(api_key.active?).to be false
    end
  end
end
