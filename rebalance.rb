require_relative './lib/get_top_currencies' 
require_relative './lib/weight_calculation' 
require_relative './config/boot'

require 'net/http'
require 'open-uri'
require 'json'

def ghmc(coin, start, finish)
  begin
    return coin.quotes.recorded_between(start, finish).map {|quote| quote.market_cap }
  rescue
    puts "#{name} failed to find market cap"
    return [0]
  end
end

coins = Fund.first.coins

class CoinPlusMarketCap
  attr_reader :coin, :mc_avg
  def initialize(mc_avg, coin)
    @coin = coin
    @mc_avg = mc_avg
  end
end

coins_mc = []

coins.each do |coin|
  mc = ghmc(coin, DateTime.parse("2020-12-01T01:29:43.000Z"), DateTime.parse("2020-12-29T01:29:43.000Z"))
  # alpha with a 3 day halflife
  avg = wma(mc, 0.0096) 
  if avg.to_f.nan?
    avg = 0.0
  end
  coins_mc << CoinPlusMarketCap.new(avg, coin) 
end

coins_mc.each {|coin| puts coin.mc_avg}

coins_mc.sort_by! {|mc| mc.mc_avg}

mcs = coins_mc.reverse.map {|cur| cur.mc_avg}
weights = []
coins_mc.reverse.each.with_index do |coin, i|
  weight = weight_calc(coin.mc_avg, mcs) 
  weights << weight
  puts "#{i+1}.) #{coin.coin.slug}: #{weight}"
end

puts weights.inject(:+)
