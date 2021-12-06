class ShortUrlsController < ApplicationController

  # Since we're working on an API, we don't have authenticity tokens
  skip_before_action :verify_authenticity_token

  def index
    @short_urls = ShortUrl.most_popular
    render json: { urls: @short_urls }
  end

  def create
    @short_url = ShortUrl.new(short_url_params)
    if @short_url.save
      render json: @short_url, status: :created
    else
      render json: { errors: @short_url.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def show
    @short_url = ShortUrl.find_by_short_code(params[:id])
    if @short_url
      @short_url.update_count!
      redirect_to @short_url.full_url
    else
      render json: @short_url, status: :not_found
    end
  end

  private

  def short_url_params
    params.permit(:full_url)
  end
end
