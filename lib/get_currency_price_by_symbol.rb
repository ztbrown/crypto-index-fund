require 'net/http'
require 'open-uri'
require 'json'

def get_currency_price_by_symbol(symbol)
  begin
    uri = URI.parse("https://pro-api.coinmarketcap.com/v1/cryptocurrency/quotes/latest?symbol=#{symbol}")
    request = Net::HTTP::Get.new(uri)
    request["X-Cmc_pro_api_key"] = ENV['CMC_API_KEY'] 
    request["Accept"] = "application/json"

    req_options = {
      use_ssl: uri.scheme == "https",
    }

    response = Net::HTTP.start(uri.hostname, uri.port, req_options) do |http|
      http.request(request)
    end

    JSON.parse(response.body)["data"]["#{symbol}"]["quote"]["USD"]["price"].to_f
  rescue => error
    puts "Error Looking for Price of #{symbol}"
    puts error
  end
end
