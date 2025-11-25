# frozen_string_literal: true

module Api
  module V1
    class BaseController < ApplicationController
      skip_before_action :verify_authenticity_token, raise: false
      before_action :set_default_format

      private

      def set_default_format
        request.format = :json
      end

      def render_success(data, status: :ok, meta: {})
        render json: { success: true, data: data, meta: meta }, status: status
      end

      def render_error(message, status: :unprocessable_entity)
        render json: { success: false, error: message }, status: status
      end
    end
  end
end
