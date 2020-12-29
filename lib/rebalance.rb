#!/usr/bin/env ruby
require_relative 'index_fund.rb'
cc = get_top_currencies(21)
cc.reject! {|currency| currency["symbol"] == "BTG" }
total_market_cap = get_total_market_cap(cc)
puts total_market_cap
index_weights = build_index_weights(total_market_cap, cc)

index_weights.each {|a| puts "#{a["name"]}: #{a["index_weight"] * 100}"}

puts "==============================================================="

adjusted_index_weights = balance_indicies(index_weights, total_market_cap, 0.10)

adjusted_index_weights.each {|a| puts "#{a["name"]}: #{a["index_weight"] * 100}"}

puts adjusted_index_weights.inject(0){|sum,b| sum + b["index_weight"].to_f} 

shares = purchase_shares(18630, adjusted_index_weights, cc)

shares.each {|share| puts "#{share["name"]} - #{share["symbol"]}: #{share["shares"]} #{share["owned_usd"]}"}
