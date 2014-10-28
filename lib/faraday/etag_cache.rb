module Faraday
  class ETagCache < Faraday::Middleware
    def initialize(app, options = {})
      super(app)
      @store = options[:store] || fail
        # raise("need :store option e.g. ActiveSupport::Cache::MemoryStore.new")
      @logger = options[:logger] || ::Logger.new(STDOUT)
    end

    def call(env)
      if [:get, :head].include?(env.method)
        call_and_cache(env)
      else
        @app.call(env)
      end
    end

    private

    def call_and_cache(environment)
      cached = store.read(cache_key(environment))

      if cached
        environment.request_headers["If-None-Match"] ||= cached[:response_headers][:etag]
      end

      @app.call(environment).on_complete do |env|
        if cached && env.status == 304
          logger.info("#{reference(env)} - cache hit")
          env.body = cached[:body]
          env.response_headers.merge!(
            :etag => cached[:response_headers][:etag],
            :content_type => cached[:response_headers][:content_type],
            :content_length => cached[:response_headers][:content_length],
            :content_encoding => cached[:response_headers][:content_encoding]
          )
        elsif env.status == 200 && env.response_headers[:etag]
          logger.info("#{reference(env)} - cache miss & store")
          store.write(cache_key(env), env.to_hash)
        end
      end
    end

    def cache_key(env)
      "etag_cache:#{env[:url]}"
    end

    def reference(env)
      "#{env.method} #{env.url}"
    end

    attr_accessor :logger, :store
  end
end
