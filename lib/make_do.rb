#!/usr/bin/env ruby
require 'colorize'
require_relative 'index_fund.rb'

def do_it(amount)

  current = open_current_portfolio_file_and_compare_against_current_market_cap("rebalance_index_0421.txt")

  cc = get_top_currencies(22)
  cc.reject! {|currency| currency["symbol"] == "BTG" || currency["symbol"] == "USDT" }
  total_market_cap = get_total_market_cap(cc)  
  index_weights = build_index_weights(total_market_cap, cc)
  adjusted_index_weights = balance_indicies(index_weights, total_market_cap, 0.10)
  desired = purchase_shares(amount.to_f, adjusted_index_weights, cc)

  build_order(current, desired).each do |order|
    
    coin = cc.find { |c| c['symbol'] == order['symbol'] }  
    if coin.nil?
      puts order['name']
    else
      order_val = (coin['price_usd'].to_f * order['amount']).abs 

      if order_val < 200
        puts order.to_s.red
      elsif order_val < 400
        puts order.to_s.yellow
      else
        puts order.to_s.green
      end
    end
  end
end

do_it(*ARGV)

