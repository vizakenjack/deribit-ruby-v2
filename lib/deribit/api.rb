require "base64"
require "net/http"
require "uri"
require "json"

module Deribit
  class API
    attr_accessor :key, :secret

    def initialize(key = nil, secret = nil, test_server: false)
      @key = key
      @secret = secret
      @server = set_server_uri(test_server)
    end

    # For direct calls like `api.get_account_summary`
    # Trying to find API method in Deribit::REST_METHODS
    def method_missing(name, **params, &block)
      method = Deribit.find_method(name, params)
      send(method[:path], params)
    end

    def send(route, params = {})
      uri = URI(@server + route.to_s)
      response = get(uri, params)

      if is_error_response?(response)
        json = JSON.parse(response.body) rescue nil
        message = "Failed for #{key}. "
        message << json["error"].to_s if json

        raise Error.new(code: response.code, message: message)
      else
        process(response)
      end
    end

    def process(response)
      json = JSON.parse(response.body, symbolize_names: true)

      if json.include?(:error)
        raise Error.new(message: "Failed for #{key}. " + json[:error])
      elsif json.include?(:result)
        json[:result]
      elsif json.include?(:message)
        json[:message]
      else
        "ok"
      end
    end

    def generate_signature(uri, params = {})
      timestamp = (Time.now.utc.to_f * 1000).to_i
      nonce = rand(100000000)
      http_method = "GET"
      path = uri.path
      path << "?" << uri.query if uri.query
      body = ""
      data = [timestamp, nonce, http_method, path, body, ""].join("\n")
      sig = OpenSSL::HMAC.hexdigest("SHA256", secret, data)

      {
        signature: sig,
        header: "deri-hmac-sha256 id=#{key},ts=#{timestamp},sig=#{sig},nonce=#{nonce}",
      }
    end

    def is_error_response?(response)
      response.code.to_i.yield_self { |code| code == 0 || code >= 400 }
    end

    private

    def http(uri)
      Net::HTTP.new(uri.host, uri.port).tap { |h| h.use_ssl = true }
    end

    def get(uri, params = {})
      uri.query = URI.encode_www_form(params) if params.any?
      http(uri).tap { |h| h.set_debug_output($stdout) if ENV["DEBUG"] }.
        get(uri.request_uri, set_headers(uri))
    end

    def post(uri, params = {})
      http(uri).tap { |h| h.set_debug_output($stdout) if ENV["DEBUG"] }.
        post(uri.request_uri, URI.encode_www_form(params), set_headers(uri, params))
    end

    def set_headers(uri, params = {})
      headers = { "Content-Type" => "application/json" }
      headers.tap do |h|
        h["Authorization"] = generate_signature(uri, params)[:header] if uri.to_s.index "private"
      end
    end

    def set_server_uri(test_server)
      (test_server || ENV["DERIBIT_SERVER"] == "test") ? TEST_URL : SERVER_URL
    end
  end
end
