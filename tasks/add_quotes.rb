require 'net/http'
require 'open-uri'
require 'json'
require 'active_record'
require 'date'
require_relative '../app/models/quote'
require_relative '../app/models/coin'

def add_quotes(data, symbol)
  coin = Coin.find_by_symbol(symbol)
  puts coin.name
  data['data'].each do |q|
    quote = coin.quotes.find_or_initialize_by({timestamp: DateTime.parse(q[0])})
    quote.price = q[1]['USD'][0]
    quote.volume_24h = q[1]['USD'][1]
    quote.market_cap = q[1]['USD'][2]
    quote.save
  end
  puts coin
end

#symbol = ARGV[0]
#

ActiveRecord::Base.establish_connection(adapter: 'sqlite3', database: 'db/development.sqlite3')

Coin.all.each do |coin|
  symbol = coin.symbol
  unless symbol.nil? 
    data = JSON.load(File.open("./currencies/#{symbol}-1578632400-to-1608607741.json"))

    add_quotes(data, symbol)
  end
end
