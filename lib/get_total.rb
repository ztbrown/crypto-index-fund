require_relative 'get_currency_price_by_symbol'

def get_total(snapshot)
  total = 0.0
  snapshot.holdings.each do |holding|
    symbol = holding.coin.symbol
    if symbol == 'IOTA'
      symbol = 'MIOTA'
    end
    price = get_currency_price_by_symbol(symbol)
    puts "#{holding.coin.name} price is $#{price}"
    total += price * holding.amount
    puts "we have $#{price * holding.amount} in #{holding.coin.name}"
    sleep 1
  end
  total
end

