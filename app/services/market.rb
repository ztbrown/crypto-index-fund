class Market
  def initialize(api_proxy)
    @api_proxy = api_proxy
  end
  def price(symbol)
    price = JSON.parse(@api_proxy.price(symbol))
    price['msg'].nil? ? price['price'].to_f : nil 
  end
end
