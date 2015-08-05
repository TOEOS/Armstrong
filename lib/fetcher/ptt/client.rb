require 'faraday'

module Fetcher
  class PTT
    class Client < Faraday::Connection
      def initialize(base_url = nil)
        super(base_url || 'https://www.ptt.cc/') do |builder|
          yield builder if block_given?
          builder.adapter Faraday.default_adapter
        end

        self.headers['cookie'] = 'over18=1'
      end
    end
  end
end
