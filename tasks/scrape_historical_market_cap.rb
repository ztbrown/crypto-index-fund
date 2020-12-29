require_relative "../lib/get_top_currencies"

require 'net/http'
require 'open-uri'
require 'json'
require 'active_record'
require 'date'
require_relative '../app/models/quote'
require_relative '../app/models/coin'

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


currencies = get_top_currencies(50)

ActiveRecord::Base.establish_connection(adapter: 'sqlite3', database: 'db/development.sqlite3')

currencies.each do |currency|
  data = scrape_historical_market_cap(currency['symbol'], currency['id'], 1608607741, DateTime.now.to_i)
  coin = Coin.find_by_symbol(currency['symbol'])
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
