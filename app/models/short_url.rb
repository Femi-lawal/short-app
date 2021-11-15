class ShortUrl < ApplicationRecord

  CHARACTERS = [*'0'..'9', *'a'..'z', *'A'..'Z'].freeze

  validate :validate_full_url

  def short_code
    short_url = []
    short_url_id = id
    # convert id integer into base 62 format
    while short_url_id.positive?
      short_url.append(CHARACTERS[short_url_id % 62])
      short_url_id /= 62
    end
    # reversing the short_url to complete base conversion
    short_url.reverse.join
  end

  def update_title!
  end

  private

  def validate_full_url
  end

end
