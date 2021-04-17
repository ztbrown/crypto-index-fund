 
require_relative 'config/boot'
require_relative 'app/services/binance_api'

current_snapshot = Snapshot.where(fund_id: Fund.first.id).last
snapshot = Snapshot.new(fund_id: Fund.first.id)
snapshot.save

def place_order(order, snapshot, new_amount)
  api_proxy = BinanceAPI.new(ENV['BINANCE_API_KEY'], ENV['BINANCE_SECRET'])
  response = order.execute(api_proxy)
  if response.nil?
    return false
  else
    order.save
    if !new_amount.nil?
      snapshot.holdings << Holding.create({coin_id: order.coin.id, amount: new_amount})
    end
    return true
  end
end

Order.where({completed: false, side: "SELL"}).each do |order|
  current_holding = current_snapshot.holdings.where(coin_id: order.coin.id).first 
  if current_holding.nil? || current_holding.amount == order.amount
    resp = place_order(order, snapshot, nil)
  else
    resp = place_order(order, snapshot, current_holding.amount - order.amount.to_f)
  end
  puts resp ? "Success for #{order.coin.name}" : "Failure for #{order.coin.name}"
end

Order.where({completed: false, side: "BUY"}).each do |order|
  current_holding = current_snapshot.holdings.where(coin_id: order.coin.id).first 
  if !current_holding.nil?
    resp = place_order(order, snapshot, current_holding.amount + order.amount.to_f)
  else
    resp = place_order(order, snapshot, order.amount.to_f)
  end
  puts resp ? "Success for #{order.coin.name}" : "Failure for #{order.coin.name}"
end

snapshot.save
