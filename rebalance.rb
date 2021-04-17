require_relative './lib/get_top_currencies' 
require_relative './lib/get_total' 
require_relative './lib/weight_calculation' 
require_relative './lib/get_currency_price_by_symbol'
require_relative './config/boot'
require_relative './app/services/binance_api'
require_relative './app/services/market'
require_relative './app/services/account'

require 'net/http'
require 'open-uri'
require 'json'

def ghmc(coin, start, finish)
  begin
    return coin.quotes.recorded_between(start, finish).map {|quote| quote.market_cap }
  rescue
    puts "#{coin.name} failed to find market cap"
    return [0]
  end
end

coins = Fund.first.snapshots.last.coins.to_a

api_proxy = BinanceAPI.new(ENV['BINANCE_API_KEY'], ENV['BINANCE_SECRET'])
market = Market.new(api_proxy)
account = Account.new(api_proxy)

coins.each do |coin|
  coin.priceusdt = market.price("#{coin.symbol}USDT")
  coin.pricebtc = market.price("#{coin.symbol}BTC")
  mc = ghmc(coin, DateTime.parse("2020-12-01T01:29:43.000Z"), DateTime.parse("2020-12-29T01:29:43.000Z"))
  # alpha with a 3 day halflife
  avg = wma(mc, 0.0096) 
  if avg.to_f.nan?
    avg = 0.0
  end
  coin.mc_avg = avg
end

coins.each {|coin| puts "#{coin.name}: #{coin.mc_avg}"}

coins.sort_by! {|coin| coin.mc_avg}

mcs = coins.reverse.map {|cur| cur.mc_avg}
weights = []
coins.reverse.each.with_index do |coin, i|
  coin.weight = weight_calc(coin.mc_avg, mcs) 
  weights << coin.weight
  puts "#{i+1}.) #{coin.slug}: #{coin.weight}"
end

puts weights.inject(:+)

snapshot = Snapshot.last
total = ARGV[0] || get_total(snapshot)
puts "total = #{total}"

(1..60).each do |sec|
  puts sec
  sleep 1
end

btc_price = get_currency_price_by_symbol('BTC')

holdings = snapshot.holdings.map

exchange_info = JSON.parse(api_proxy.exchange_info)

coins.reverse.take(30).each do |coin|
  amount = 0.0
  order = Order.new({coin_id: coin.id})
  if !coin.pricebtc.nil?
    order.pair = "BTC"
    coin_info = exchange_info['symbols'].find {|symbol| symbol['symbol'] == "#{coin.symbol}BTC"}
    amount = (coin.weight * (total / btc_price)) / coin.pricebtc 
  else
    order.pair = "USDT"
    coin_info = exchange_info['symbols'].find {|symbol| symbol['symbol'] == "#{coin.symbol}USDT"}
    puts coin.name
    puts coin.weight
    amount = (coin.weight * total) / coin.priceusdt
  end
  puts "#{coin.slug}: #{amount}"
  current_coin = holdings.find {|h| h.coin_id == coin.id}
  if current_coin.nil? 
    current_amount = 0.0
  else
    current_amount = current_coin.amount
    holdings = holdings.reject {|holding| holding.coin_id == coin.id } 
  end
  new_amount = amount - current_amount
  side = (new_amount < 0.0) ? "SELL" : "BUY"
  order.side = side
  precision = coin_info.nil? ? 7 : Math.log10(coin_info['filters'].find{|filter| filter['filterType'] == "LOT_SIZE"}['stepSize'].to_f).to_i.abs
  order.amount = new_amount.abs.round(precision) 
  order.save!
end
