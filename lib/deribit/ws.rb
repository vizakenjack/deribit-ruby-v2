require "websocket-client-simple"

module Deribit
  class WS
    attr_reader :key, :secret, :url, :socket, :ids_stack, :handlers, :subscriptions

    def initialize(key = nil, secret = nil, handlers: [Handler.new], test_server: false)
      @key = key
      @secret = secret
      @ids_stack = {}

      @url = set_server_url(test_server)
      @handlers = handlers
    end

    def connect
      start_handle
      sleep 0.1
      auth if key && secret
      handlers.each { |h| subscribe(channels: h.subscriptions.to_a) if h.subscriptions.any? }
    end

    def handler
      handlers.find { |handler| handler.is_a?(Handler) }
    end

    # methods like ws.get_account_history
    def method_missing(name, **params, &block)
      method = Deribit.find_method(name, params)
      # puts "Found method: #{method}, params = #{params}"
      api_send(path: method[:path], params: params)
    end

    def close
      socket.close
    end

    def auth
      timestamp = (Time.now.utc.to_f * 1000).to_i
      nonce = rand(100000000)

      params = {
        grant_type: "client_signature",
        client_id: key,
        timestamp: timestamp.to_s,
        signature: generate_signature(timestamp, nonce),
        data: "",
        nonce: nonce.to_s,
      }

      api_send(path: "public/auth", params: params)

      # todo: refactor
      30.times do |i|
        handler.access_token == nil ? sleep(0.1) : return
      end
    end

    def process_data(json)
      stack_id = ids_stack[json[:id]]
      method = json.fetch(:method) { stack_id&.fetch(:method, nil) }
      handlers.each { |hander| hander.process(json, method: method, ws: self) }
      ids_stack.delete(stack_id) if stack_id
    end

    private

    def start_handle
      @socket = WebSocket::Client::Simple.connect(url)

      instance = self
      @socket.on :message do |msg|
        # debug:
        puts "msg = #{msg}"
        begin
          if msg.type == :text
            json = JSON.parse(msg.data, symbolize_names: true)
            instance.process_data(json)
          elsif msg.type == :close
            # debug:
            # puts "trying to connect= got close event, msg: #{msg.inspect}"
            instance.connect
          end
        rescue StandardError => error
          puts "Error #{error.class}: #{error.full_message}\nGot message: #{json.inspect}"
        end
      end

      @socket.on(:error) { |e| puts e }
    end

    def api_send(path:, params: {})
      raise Error.new(message: "Socket is not initialized") unless socket
      params = {} if params == []

      args = { id: Time.now.to_i, jsonrps: "2.0", method: path, params: params }
      method = path.split("/").last
      @ids_stack[args[:id]] = { method: method, path: path, params: params }

      # puts debug:
      puts "Sending: #{args}"
      socket.send(args.to_json)
    end

    def generate_signature(timestamp, nonce, data = "")
      payload = [timestamp, nonce, data].join("\n")
      OpenSSL::HMAC.hexdigest("SHA256", secret, payload)
    end

    def set_server_url(test_server)
      (ENV["DERIBIT_SERVER"].downcase == "test" || test_server) ? WS_TEST_URL : WS_SERVER_URL
    end
  end
end
