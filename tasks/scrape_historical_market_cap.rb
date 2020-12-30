require_relative "../lib/get_top_currencies"

require 'net/http'
require 'open-uri'
require 'json'
require 'date'
require_relative '../config/boot'

def scrape_historical_market_cap(name, id, start_time, end_time)
    uri = URI.parse("https://web-api.coinmarketcap.com/v1.1/cryptocurrency/quotes/historical?convert=USD,BTC&format=chart_crypto_details&id=#{id}&interval=1h&time_end=#{end_time}&time_start=#{start_time}")

    request = Net::HTTP::Get.new(uri)

    req_options = {
      use_ssl: uri.scheme == "https",
    }

    response = Net::HTTP.start(uri.hostname, uri.port, req_options) do |http|
      http.request(request)
    end

    JSON.parse(response.body)
end

Coin.all.each do |coin|
  data = scrape_historical_market_cap(coin.symbol, coin.cmc_id, 1608607741, DateTime.now.to_i)
  puts coin.name
  data['data'].each do |q|
    quote = coin.quotes.find_or_initialize_by({timestamp: DateTime.parse(q[0])})
    if quote.id.nil?
      quote.price = q[1]['USD'][0]
      quote.volume_24h = q[1]['USD'][1]
      quote.market_cap = q[1]['USD'][2]
      quote.save
    end
  end
end
