module Deribit
  class WS
    class BaseHandler
      attr_accessor :timestamp, :ws

      def initialize
        update_timestamp
      end

      def process(json, method: nil, ws: nil)
        @ws = ws

        if method && self.respond_to?(method)
          self.send(method, json)
        else
          puts "Received method #{method}: #{json}"
        end

        update_timestamp
      end

      private

      def update_timestamp
        @timestamp = Time.now.to_i
      end
    end
  end
end
