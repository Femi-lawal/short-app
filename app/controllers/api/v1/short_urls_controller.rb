# frozen_string_literal: true

module Api
  module V1
    class ShortUrlsController < BaseController
      def index
        urls = ShortUrl.where(deleted_at: nil)
                       .order(click_count: :desc)
                       .limit(params[:limit] || 100)
        render_success(urls.map { |u| serialize(u) })
      end

      def create
        result = UrlShortenerService.call(
          short_url_params,
          request_ip: request.remote_ip
        )

        if result.success?
          render_success(serialize(result.short_url), status: :created)
        else
          render_error(result.error, status: :unprocessable_entity)
        end
      end

      def show
        url = ShortUrl.find_by(short_code: params[:id], deleted_at: nil)
        return render_error('Not found', status: :not_found) unless url

        render_success(serialize(url))
      end

      def stats
        url = ShortUrl.find_by(short_code: params[:id], deleted_at: nil)
        return render_error('Not found', status: :not_found) unless url

        render_success({
          short_code: url.short_code,
          click_count: url.click_count,
          created_at: url.created_at,
          last_accessed_at: url.last_accessed_at
        })
      end

      private

      def short_url_params
        params.require(:short_url).permit(:full_url, :custom_alias, :expires_at)
      end

      def serialize(url)
        {
          id: url.id,
          short_code: url.short_code,
          short_url: "#{request.base_url}/#{url.short_code}",
          full_url: url.full_url,
          title: url.title,
          click_count: url.click_count,
          created_at: url.created_at,
          expires_at: url.expires_at
        }
      end
    end
  end
end
