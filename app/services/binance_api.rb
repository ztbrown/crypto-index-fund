require 'json'
require 'net/http'
require "openssl"

KeyValue = Struct.new(:key, :value)

class BinanceAPI
  def initialize(api_key, secret_key)
    @api_key = api_key
    @secret_key = secret_key
  end

  # GET /api/v3/ticker/price
  def price(symbol)
    get("/api/v3/ticker/price", "symbol=#{symbol}")
  end

  # GET /api/v3/order
  def order_details(id, symbol)
    query = "timestamp=#{(Time.now.getutc.to_f * 1000).round(0)}&orderId=#{id}&symbol=#{symbol}"
    query += "&signature=#{OpenSSL::HMAC.hexdigest(OpenSSL::Digest.new('sha256'), @secret_key, query)}"
    get("/api/v3/order", query)
  end

  # POST /api/v3/order
  def order(symbol, side, type, quantity)
    query = "timestamp=#{(Time.now.getutc.to_f * 1000).round(0)}&symbol=#{symbol}&side=#{side}&type=#{type}&quantity=#{quantity}"
    query += "&signature=#{OpenSSL::HMAC.hexdigest(OpenSSL::Digest.new('sha256'), @secret_key, query)}"
    puts "https://api.binance.com/api/v3/order?#{query}"
    post("/api/v3/order", query)
  end

  # GET /api/v3/account
  def account()
    query = "timestamp=#{(Time.now.getutc.to_f * 1000).round(0)}"
    query += "&signature=#{OpenSSL::HMAC.hexdigest(OpenSSL::Digest.new('sha256'), @secret_key, query)}"
    get("/api/v3/account", query)
  end

  def exchange_info()
    get("/api/v3/exchangeInfo", "")
  end

  private
  def get(url, query)
    uri = URI.parse("https://api.binance.com#{url}?#{query}")
    request = Net::HTTP::Get.new(uri)
    call(request, uri)
  end

  def post(url, query)
    uri = URI.parse("https://api.binance.com#{url}?#{query}")
    request = Net::HTTP::Post.new(uri)
    call(request, uri)
  end

  def call(request, uri)
    request["X-MBX-APIKEY"] = @api_key
    request["Accept"] = "application/json"

    req_options = {
      use_ssl: uri.scheme == "https",
    }

    begin
      response = Net::HTTP.start(uri.hostname, uri.port, req_options) do |http|
        http.request(request)
      end
    rescue Timeout::Error, Errno::EINVAL, Errno::ECONNRESET, EOFError,
       Net::HTTPBadResponse, Net::HTTPHeaderSyntaxError, Net::ProtocolError => e
      puts e
    end

    response.body
  end
end
