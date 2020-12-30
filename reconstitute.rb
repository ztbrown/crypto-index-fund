require_relative './lib/get_top_currencies' 
require_relative './lib/weight_calculation' 
require_relative './config/boot'
require_relative './app/services/binance_api'
require_relative './app/services/market'

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

currencies = get_top_currencies(70)
coins = currencies.map do |cur| 
  coin = Coin.find_by_cmc_id(cur['id'])
  if coin.symbol = "MIOTA"
    coin.symbol = "IOTA"
  end
  coin
end

class CoinPlusMarketCap
  attr_reader :coin, :mc_avg, :price
  def initialize(mc_avg, coin)
    @coin = coin
    @mc_avg = mc_avg
  end
end

coins_mc = []

api_proxy = BinanceAPI.new(ENV['BINANCE_API_KEY'], ENV['BINANCE_SECRET'])
market = Market.new(api_proxy)

coins.each do |coin|
  if !coin.is_stablecoin? || coin.slug == 'wrapped-bitcoin'
    priceusdt = market.price("#{coin.symbol}USDT")
    pricebtc = market.price("#{coin.symbol}BTC")
    unless !priceusdt['msg'].nil? && !pricebtc['msg'].nil?
      mc = ghmc(coin, DateTime.parse("2020-01-01T01:29:43.000Z"), DateTime.parse("2020-09-30T23:29:43.000Z"))
      # alpha with a 3 day halflife
      avg = wma(mc, 0.0096) || 0.0
      if avg.to_f.nan?
        avg = 0.0
      end
      coins_mc << CoinPlusMarketCap.new(avg, coin) 
    end
  end
end

coins_mc.sort_by! {|mc| mc.mc_avg}

mcs = coins_mc.reverse.take(30).map {|cur| cur.mc_avg}
weights = []
coins_mc.reverse.take(30).each.with_index do |coin, i|
  weight = weight_calc(coin.mc_avg, mcs) 
  weights << weight
  puts "#{i+1}.) #{coin.coin.slug}: #{weight}"
end

puts weights.inject(:+)
