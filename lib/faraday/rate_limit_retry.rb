module Faraday
  class RateLimitRetry < Faraday::Response::Middleware
    # Public: Initialize middleware
    def initialize(app, logger = nil)
      super(app)
      @logger = logger || ::Logger.new(STDOUT)
    end

    def call(env)
      attempt ||= :first
      request_body ||= env.body
      request_headers ||= env.request_headers

      super
    rescue Error::ClientError
      if env.status == 429 && attempt == :first
        attempt = :second
        sleep_until_limit_reset(env)
        env.body = request_body
        env.request_headers = request_headers
        retry
      else
        raise
      end
    end

    private

    attr_accessor :logger

    def sleep_until_limit_reset(env)
      headers = env.response_headers
      rate_limit_limit = Integer(headers['x-rate-limit-limit'])
      rate_limit_reset = Integer(headers['x-rate-limit-reset'])

      logger.warn("#{reference(env)} - waiting #{rate_limit_reset} seconds for rate limit (#{rate_limit_limit}) to be reset.")

      sleep(rate_limit_reset)
    end

    def reference(env)
      "#{env.method} #{env.url}"
    end
  end
end
