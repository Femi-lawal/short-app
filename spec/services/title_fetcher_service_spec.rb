# frozen_string_literal: true

require 'rails_helper'

RSpec.describe TitleFetcherService, type: :service do
  describe '.call' do
    let(:url) { 'https://www.example.com/test-page' }
    let(:html_with_title) { '<html><head><title>Example Page Title</title></head></html>' }

    before do
      TitleFetcherService.circuit_breaker.reset! if TitleFetcherService.respond_to?(:circuit_breaker)
    end

    context 'when request is successful' do
      before do
        stub_request(:get, url)
          .to_return(status: 200, body: html_with_title, headers: { 'Content-Type' => 'text/html' })
      end

      it 'returns success with title' do
        result = described_class.call(url)
        expect(result.success?).to be true
        expect(result.title).to eq('Example Page Title')
      end
    end

    context 'when request times out' do
      before do
        stub_request(:get, url).to_timeout
      end

      it 'returns failure' do
        result = described_class.call(url)
        expect(result.success?).to be false
      end
    end
  end
end
