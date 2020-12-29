#!/usr/bin/env ruby

require 'net/http'
require 'open-uri'
require 'json'
require 'mechanize'
require 'colorize'

def get_top_currencies(limit) 
  json = ''
  if File.exists?("currencies-#{limit}.json")
    data = JSON.load(File.open("currencies-#{limit}.json"))
  else
    uri = URI.parse("https://pro-api.coinmarketcap.com/v1/cryptocurrency/listings/latest?limit=#{limit}")
    request = Net::HTTP::Get.new(uri)
    request["X-Cmc_pro_api_key"] = ENV['CMC_API_KEY'] 
    request["Accept"] = "application/json"

    req_options = {
      use_ssl: uri.scheme == "https",
    }

    response = Net::HTTP.start(uri.hostname, uri.port, req_options) do |http|
      http.request(request)
    end

    File.open("currencies-#{limit}.json", 'w') { |file| file.write(response.body) }

    data = JSON.parse(response.body)
  end
  data["data"]
end

def get_total_market_cap(currencies)
  currencies.inject(0){|sum,b| sum + b["quote"]["USD"]["market_cap"].to_i}
end

def balance_indicies(currencies, total_market_cap, cap)
  fund_size = 1
  adjusted_market_cap = total_market_cap
  currencies.map do |currency| 
    if currency["index_weight"].to_f > cap
      adjusted_market_cap -= currency["quote"]["USD"]["market_cap"].to_i
      currency["index_weight"] = cap
      fund_size -= cap
    else
      currency["index_weight"] = (currency["quote"]["USD"]["market_cap"].to_f / adjusted_market_cap.to_f) * fund_size
      if currency["index_weight"].to_f > cap
        adjusted_market_cap -= currency["quote"]["USD"]["market_cap"].to_i
        currency["index_weight"] = cap
        fund_size -= cap
      end
    end
    currency
  end  
end

def build_index_weights(total_market_cap, currencies)
  currencies.map do |currency|
    weight = currency["quote"]["USD"]["market_cap"].to_f / total_market_cap
    currency.merge({"index_weight" => weight})
  end
end 

def purchase_shares(usd, index_weights, cc)
  index_weights.map  do |weight| 
    puts weight
    cost = weight["index_weight"] * usd.to_f
    weight.merge({"shares"=> cost / weight["quote"]["USD"]["price"].to_f, "owned_usd"=> cost})
  end
end

def get_historical_price(ticker, date_in_millis)
  begin
    data = URI.parse("https://min-api.cryptocompare.com/data/pricehistorical?fsym=#{ticker}&tsyms=USD&ts=#{date_in_millis}").read
  rescue Exception => err
    puts err 
  end 
    
    JSON.parse(data)
end

def get_historical_top_currencies(limit, yyyy, mm, dd)
  a = Mechanize.new
  while true
    begin
      page = a.get("http://coinmarketcap.com/historical/#{yyyy}#{mm}#{dd}/")   
      break
    rescue
      puts "No data for #{yyyy} #{mm} #{dd}, trying #{yyyy} #{mm} #{"%02d" % (dd.to_i + 1)}"
      dd = "%02d" % (dd.to_i + 1)
    end
  end

  market_caps = page.css('table#currencies-all td[4]')
  currencies = page.css('table#currencies-all td[3]')
  usd_prices = page.css('table#currencies-all td[5] a')
    
  (0..limit).map {|i| {"name"=> currencies[i].text, "symbol"=> currencies[i].text, "price_usd"=> usd_prices[i].text.delete('$'), "market_cap_usd"=> market_caps[i]["data-usd"]}}
end

def sell_all_shares(ccs, date_in_millis)
  ccs.inject(0) do |sum, currency| 
    symbol = currency["symbol"]
    #lol
    if symbol == "MIOTA" && date_in_millis >= 1483660800
      symbol = "IOTA"
    end
    price = get_historical_price(symbol, date_in_millis) 
    shares = currency["shares"]
    if price 
      begin
        sum += (price[symbol]["USD"] * shares)
      rescue 
        puts "ISSUE WITH #{currency["name"]}"
      end
    else
      puts "ERROR: CURRENCY #{currency["name"]} IS ALL FUCKED UP"
    end
    sum
  end
end

def get_currency_price_by_symbol(symbol)
  begin
    uri = URI.parse("https://pro-api.coinmarketcap.com/v1/cryptocurrency/quotes/latest?symbol=#{symbol}")
    request = Net::HTTP::Get.new(uri)
    request["X-Cmc_pro_api_key"] = ENV['CMC_API_KEY'] 
    request["Accept"] = "application/json"

    req_options = {
      use_ssl: uri.scheme == "https",
    }

    response = Net::HTTP.start(uri.hostname, uri.port, req_options) do |http|
      http.request(request)
    end

    JSON.parse(response.body)["data"]["#{symbol}"]["quote"]["USD"]["price"].to_f
  rescue => error
    puts "Error Looking for Price of #{symbol}"
    puts error
  end
end

def get_portfolio_value(filename, purchase_date)
  sum = 0
  purchase_date_sum = 0
#  purchase_date = Date.new(2018, 1, 15).to_time.to_i
  File.open(filename) do |file|
    file.each do |line|
      line = line.split(' ')
      shares = line[3].to_f
      purchase_date_price = get_historical_price(line[2], purchase_date)[line[2]]["USD"].to_f
      price = get_currency_price_by_symbol(line[2])
      percent_change = 100 * ((price - purchase_date_price) / purchase_date_price)
      puts "#{line[0]}: $#{price} #{(percent_change > 0) ? percent_change.round(2).to_s.green : percent_change.round(2).to_s.red}"
      sum += (shares * price)
      purchase_date_sum += (shares * purchase_date_price)
    end
  end
  puts "PURCHASE DATE SUM = #{purchase_date_sum}"
  percent_delta = 100 * ((sum - purchase_date_sum) / purchase_date_sum)
  puts "#{(percent_delta > 0) ? percent_delta.round(2).to_s.green : percent_delta.round(2).to_s.red}"
  sum
end

def get_portfolio_value_at_date(filename, date_in_millis)
  sum = 0
  File.open(filename) do |file|
    file.each do |line|
      begin
        line = line.split(' ')
        shares = line[3].to_f
        price = get_historical_price(line[2], date_in_millis)[line[2]]["USD"].to_f
        #puts "#{line[2]}: $#{price}"
        sum += (shares * price)
      rescue
        puts "Failed getting historical price of #{line[2]}"
      end
    end
  end
  sum
end

def build_order(current, desired)
  dropped = current.select do |coin|
    desired.select {|data| data['symbol'] == coin['symbol'] }.first.nil?
  end
  dropped = dropped.map {|item| {"symbol" => item["symbol"], "name" => item["name"], "amount" => item["shares"].to_f * -1}} 
  desired.map do |coin|
    current_coin = current.select {|data| data['symbol'] == coin['symbol'] }.first || {'shares' => 0}
    {"symbol" => coin['symbol'], 'name' => coin['name'], 'amount' => coin['shares'].to_f - current_coin["shares"].to_f }
  end + dropped 
end

def open_current_portfolio_file_and_compare_against_current_market_cap(filename) 
  current = []
  File.open(filename) do |file|
    file.each {|line| current.push({"name" => line.split(' ')[0], "symbol" => line.split(' ')[2], "shares" => line.split(' ')[3].to_f})}
  end
  current
end
