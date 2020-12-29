def weight_calc(currency, currencies)
  numerator = Math.sqrt(currency) 
  denominator = 0.0
  currencies.each do |val|
    denominator += Math.sqrt(val)
  end
  (numerator / denominator).round(4)
end


