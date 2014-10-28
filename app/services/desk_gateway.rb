require_dependency 'faraday/polite_logger'
require_dependency 'faraday/rate_limit_retry'
require_dependency 'faraday/etag_cache'

class DeskGateway
  def initialize
  end

  def fetch_records(url, data = nil, conn_options = {})
    response = create_connection(conn_options).get do |req|
      req.url url
    end

    if block_given?
      yield(response.status, response.body)
    end

    response.body
  rescue => e
    logger.error("Failed to fetch desk records: #{e.class} (#{e.message})")

    raise e
  end

  def post_data(url, data, conn_options = {})
    send_data(:post, url, data, conn_options)
  end

  def patch_data(url, data, conn_options = {})
    send_data(:patch, url, data, conn_options)
  end

  private

  def send_data(verb, url, data, conn_options = {})
    fail unless [:post, :patch].include?(verb)

    response = create_connection(conn_options).send(verb) do |req|
      req.url url

      req.headers['Content-Type'] = 'application/json'
      req.body = data.to_json
    end

    if block_given?
      yield(response.status, response.body)
    end

    response.body
  rescue => e
    logger.error("Failed to send data to desk: #{e.class} (#{e.message})")

    raise e
  end

  def create_connection(options={})
    Faraday.new(connection_options) do |builder|
      builder.use Faraday::Request::Retry, :max => 3, :interval => 3.seconds

      builder.use FaradayMiddleware::OAuth, oauth_options

      builder.use Faraday::Response::ParseJson unless options[:json] == false

      builder.use Faraday::ETagCache, logger: logger, store: store
      builder.use Faraday::RateLimitRetry, logger # relies on RaiseError to raise ClientError, must be above it
      builder.use Faraday::Response::RaiseError

      builder.use FaradayMiddleware::FollowRedirects unless options[:follow_redirects] == false

      if ENV['DEBUG_HTTP'] =~ /true/i
        builder.use Faraday::Response::Logger, logger
      else
        builder.use Faraday::PoliteLogger, logger
      end

      if stubs = faraday_stubs
        builder.adapter(:test, stubs)
      else
        builder.adapter  :net_http
      end
    end
  end

  def faraday_stubs
    # to be implemented by test cases
    nil
  end

  def connection_options
    @connection_options ||= {
      :url => 'https://woodenbits.desk.com',
      :request => {
        :timeout => 10,                   # open/read timeout Integer in seconds
        :open_timeout => 5                # open timeout Integer in seconds
      }
    }
  end

  def oauth_options
    @oauth_options ||= {
      consumer_key: ENV['API_CONSUMER_KEY'],
      consumer_secret: ENV['API_CONSUMER_SECRET'],
      token: ENV['ACCESS_TOKEN'],
      token_secret: ENV['ACCESS_TOKEN_SECRET']
    }
  end

  def logger
    @logger ||= Rails.logger
  end

  def store
    # store is shared between all instances of this class
    @@store ||= ActiveSupport::Cache::MemoryStore.new
  end
end
