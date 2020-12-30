class Market
  def initialize(api_proxy)
    @api_proxy = api_proxy
  end
  def price(symbol)
    JSON.parse(@api_proxy.price(symbol))
  end
end
