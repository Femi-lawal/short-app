# frozen_string_literal: true

require 'rails_helper'

RSpec.describe CircuitBreaker do
  subject(:circuit_breaker) do
    described_class.new(failure_threshold: 3, recovery_timeout: 5)
  end

  describe '#allow_request?' do
    it 'allows requests when closed' do
      expect(circuit_breaker.allow_request?).to be true
    end

    context 'when failures exceed threshold' do
      before { 3.times { circuit_breaker.record_failure } }

      it 'blocks requests' do
        expect(circuit_breaker.allow_request?).to be false
      end
    end
  end

  describe '#record_success' do
    it 'resets failure count' do
      2.times { circuit_breaker.record_failure }
      circuit_breaker.record_success
      circuit_breaker.record_failure
      expect(circuit_breaker.allow_request?).to be true
    end
  end

  describe '#reset!' do
    before { 3.times { circuit_breaker.record_failure } }

    it 'resets to closed state' do
      circuit_breaker.reset!
      expect(circuit_breaker.allow_request?).to be true
    end
  end
end
