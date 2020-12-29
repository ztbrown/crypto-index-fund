require 'active_record'
require_relative '../lib/get_top_currencies' 
require_relative '../app/models/coin'

currencies = get_top_currencies(250)
ActiveRecord::Base.establish_connection(adapter: 'sqlite3', database: 'db/development.sqlite3')
currencies.each do |cur|
  coin = Coin.find_or_initialize_by({slug: cur['slug']})
  if coin.id.nil?
    coin.name = cur['name']
    coin.cmc_id = cur['id']
    coin.symbol = cur['symbol']
    coin.save
  end
end
