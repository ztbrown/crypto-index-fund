#!/usr/bin/env ruby

require 'date'
require_relative './index_fund.rb'

def help()
  puts "usage: ruby simulate.rb <start_date (YY-MM-DD)> <end_date (YY-MM-DD)> starting_sum index_size"
end

def simulate(start_date, end_date, starting_sum, index_size) 
  start_date = DateTime.strptime(start_date, '%Y-%m-%d')
  end_date = DateTime.strptime(end_date, '%Y-%m-%d')
  puts "There are #{(end_date.year * 12 + end_date.month) - (start_date.year * 12 + start_date.month)} months between dates"

  (0...12).each do |months|
    current_date = start_date >> months
    top_ccs = get_historical_top_currencies(index_size.to_i, current_date.year.to_s, "%02d" % current_date.month.to_s, "%02d" % current_date.day.to_s)
    #puts top_ccs
    market_cap = get_total_market_cap(top_ccs) 
    adjusted_index_weights = build_index_weights(market_cap, top_ccs)  
    adjusted_index_weights[0]["index_weight"] = 1
    #adjusted_index_weights = balance_indicies(index_weights, market_cap, 0.10)

    shares = purchase_shares(starting_sum.to_f, adjusted_index_weights, top_ccs)
    starting_sum = sell_all_shares(shares, (current_date >> 1).to_time.to_i)
    # output
    current_date.strftime("%m/%d/%y")
    shares.each {|share| puts "#{share["name"]} - #{share["symbol"]}: #{share["shares"]} #{share["owned_usd"]}"}
    puts starting_sum 
  end
end

if ARGV.length != 4
  help()
else
  simulate(*ARGV)
end

