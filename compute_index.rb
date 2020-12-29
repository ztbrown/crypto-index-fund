# this is spike code and should probably be deleted
#

require_relative './lib/get_top_currencies' 
require_relative './lib/weight_calculation' 
require_relative 'app/models/coin'
require_relative 'app/models/quote'

require 'net/http'
require 'open-uri'
require 'json'

def ghmc(symbol, start, finish)
  begin
    return Coin.find_by_symbol(symbol).quotes.recorded_between(start, finish).map {|quote| quote.market_cap }
  rescue
    puts "#{name} failed to find market cap"
    return [0]
  end
end

ActiveRecord::Base.establish_connection(adapter: 'sqlite3', database: 'db/development.sqlite3')

currencies = get_top_currencies(50)

currencies.each do |currency|
  if !currency['tags'].include?("stablecoin") || currency['slug'] == 'wrapped-bitcoin'
    symbol = currency['symbol']
    mc = ghmc(symbol, DateTime.parse("2020-11-25T01:29:43.000Z"),DateTime.parse("2020-11-30T20:29:43.000Z"))
    # alpha with a 3 day halflife decay
    avg = wma(mc, 0.0096)
    currency['mc_avg'] = avg || 0
  end
end

currencies.reject! {|cur| cur['mc_avg'].nil? || cur['mc_avg'].nan? }
currencies.sort_by! { |obj| obj['mc_avg'] }
currencies.reverse.take(30).each.with_index {|cur, i| puts "#{i+1}.) #{cur['slug']}: #{cur['mc_avg']}"}

mcs = currencies.reverse.take(30).map {|cur| cur['mc_avg']}

currencies.reverse.take(30).each.with_index {|cur, i| puts "#{i+1}.) #{cur['slug']}: #{weight_calc(cur['mc_avg'], mcs)}"} 

