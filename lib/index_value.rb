# {weight, purchase_price, current_price}
def index_value(currencies)
  value = 0.0
  currencies.each do |currency|
    puts currency
    value += (currency['weight'] * (currency['current_price']/currency['purchase_price']))
  end
  value * 100
end

#cur = [
#  {"weight" => 0.15, "purchase_price" => 150, "current_price" => 175},
#  {"weight" => 0.55, "purchase_price" => 250, "current_price" => 175},
#  {"weight" => 0.25, "purchase_price" => 150, "current_price" => 1175},
#  {"weight" => 0.05, "purchase_price" => 150, "current_price" => 175}
#] 
#
#puts index_value(cur)

