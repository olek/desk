require 'logger'

module Faraday
  class PoliteLogger < Response::Middleware
    def initialize(app, logger = nil)
      super(app)
      @logger = logger || ::Logger.new(STDOUT)
    end

    attr_accessor :logger

    def call(env)
      logger.info(reference(env))
      super
    end

    def on_complete(env)
      logger.info("Status: #{env[:status]} for #{reference(env)}")
    end

    private

    def reference(env)
      "#{env[:method]} #{env[:url].to_s}"
    end
  end
end
