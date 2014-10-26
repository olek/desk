require "oauth"

class DeskGateway
  API_CONSUMER_KEY = ENV['API_CONSUMER_KEY'].freeze
  API_CONSUMER_SECRET = ENV['API_CONSUMER_SECRET'].freeze
  ACCESS_TOKEN = ENV['ACCESS_TOKEN'].freeze
  ACCESS_TOKEN_SECRET = ENV['ACCESS_TOKEN_SECRET'].freeze

  def initialize
  end

  def list_filters
    oauth_access_token.get("https://woodenbits.desk.com/api/v2/filters")
  end

  private

  def oauth_access_token
    OAuth::AccessToken.from_hash(
            oauth_consumer,
            oauth_token: ACCESS_TOKEN,
            oauth_token_secret: ACCESS_TOKEN_SECRET
    )
  end

  def oauth_consumer
    OAuth::Consumer.new(
            API_CONSUMER_KEY,
            API_CONSUMER_SECRET,
            site: "https://woodenbits.desk.com",
            scheme: :header
    )
  end
end
