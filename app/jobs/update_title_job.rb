class UpdateTitleJob < ApplicationJob
  require 'nokogiri'
  require 'open-uri'

  queue_as :default

  def perform(short_url_id)
    @short_url = ShortUrl.find(short_url_id)
    doc = Nokogiri::HTML(URI.parse(@short_url.full_url).open)
    title = doc.at_css('title').text
    @short_url.update_column(:title, title)
  end
end
