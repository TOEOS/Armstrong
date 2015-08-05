require 'faraday'

module Fetcher
  class PTT
    class Client < Faraday::Connection
      def initialize(*args)
        super(*args) do |builder|
          yield builder if block_given?
          builder.adapter Faraday.default_adapter
        end

        self.headers['cookie'] = 'over18=1'
      end
    end
  end
end
