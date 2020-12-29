#!/usr/bin/env ruby
require_relative 'index_fund.rb'


def do_it(filename, date=nil) 

  year = filename.split('_')[1][4..7]
  day = filename.split('_')[1][2..3]
  month = filename.split('_')[1][0..1]
  date = date || Date.new(year.to_i, month.to_i, day.to_i).to_time.to_i 
  get_portfolio_value(filename, date)
end 

puts do_it(*ARGV)

