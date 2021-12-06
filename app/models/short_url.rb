class ShortUrl < ApplicationRecord
  after_create :run_title_job
  after_save :update_short_code!
  scope :most_popular, -> { order(click_count: :desc).limit(100) }

  CHARACTERS = [*'0'..'9', *'a'..'z', *'A'..'Z'].freeze

  validate :validate_full_url

  def update_short_code!
    short_url = []
    short_url_id = id
    # convert id integer into base 62 format
    while short_url_id.positive?
      short_url.append(CHARACTERS[short_url_id % 62])
      short_url_id /= 62
    end
    # reversing the short_url to complete base conversion
    base62_url = short_url.reverse.join
    update_column(:short_code, base62_url)
  end

  def update_count!
    increment!(:click_count)
  end

  def update_title!
    doc = Nokogiri::HTML(URI.parse(full_url).open)
    new_title = doc.at_css('title').text
    update_column(:title, new_title)
  end

  def run_title_job
    UpdateTitleJob.perform_later(id)
  end

  private

  def validate_full_url
    return errors.add(:full_url, "can't be blank") unless full_url

    # begin
    #   parsed_url = URI.parse(full_url)
    #   errors.add(:full_url, 'url must conform to http or https') unless parsed_url.is_a?(URI::HTTP)
    # rescue URI::InvalidURIError
    #   errors.add(:full_url, 'is not a valid url')
    # end
    url_regex = %r{^((http|https)://)[a-z0-9]+([\-.]{1}[a-z0-9]+)*\.[a-z]{2,5}(:[0-9]{1,5})?(/.*)?$}ix
    errors.add(:full_url, 'is not a valid url') unless full_url.match(url_regex)
  end

end
