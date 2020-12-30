require_relative '../config/boot'
require_relative '../lib/get_top_currencies' 

currencies = get_top_currencies(250)
puts currencies
currencies.each do |cur|
  coin = Coin.find_or_initialize_by({slug: cur['slug']})
  unless coin.nil?
    cur['tags'].each do |tag|
      coin.tags << Tag.find_or_create_by({name: tag}) 
    end
  end
end

