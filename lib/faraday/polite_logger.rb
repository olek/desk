require 'logger'

module Faraday
  class PoliteLogger < Response::Middleware
    def initialize(app, logger = nil)
      super(app)
      @logger = logger || ::Logger.new(STDOUT)
    end

    attr_accessor :logger

    def call(env)
      logger.info("#{reference(env)} - started")
      super
    end

    def on_complete(env)
      logger.info("#{reference(env)} - finished with status #{env.status}")
    end

    private

    def reference(env)
      "#{env.method} #{env.url}"
    end
  end
end
