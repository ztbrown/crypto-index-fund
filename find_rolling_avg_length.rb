require_relative './lib/get_top_currencies' 
require_relative './lib/weight_calculation' 

require 'net/http'
require 'open-uri'
require 'json'

# trying to reverse engineer the window length used by CCi30 for rebalancing / reconstitution

def ghmc(symbol, start, finish)
  begin
    data = JSON.load(File.open("./currencies/#{symbol}-1578632400-to-1608607741.json"))
    mc = data['data'].reject {|key| DateTime.parse(key) > DateTime.parse(finish) || DateTime.parse(key) < DateTime.parse(start)}
    return mc.to_a.map {|el| el[1]['USD'][2]}.reverse
  rescue
    puts "#{name} failed to find market cap"
    return [0]
  end
end

mc = ghmc("BTC", "2020-12-19T11:29:43.000Z","2020-12-22T02:29:43.000Z")

puts mc

avg = wma(mc, 0.0096)

puts avg
