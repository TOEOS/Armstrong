require 'faraday'

module Fetcher
  class PTT
    class InternalServerError < StandardError; end

    class ErrorHandlingMiddleware < Faraday::Middleware
      def call(request_env)
        @app.call(request_env).on_complete do |response_env|
          raise InternalServerError if response_env[:status] =~ /500/
        end
      end
    end

    class Client < Faraday::Connection
      def initialize(base_url = nil)
        super(base_url || 'https://www.ptt.cc/') do |builder|
          yield builder if block_given?
          builder.response :logger
          builder.response :raise_error
          builder.adapter Faraday.default_adapter
        end

        self.headers['cookie'] = 'over18=1'
      end
    end
  end
end
