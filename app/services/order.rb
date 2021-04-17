class Order
  def initialize(api_proxy)
    @api_proxy = api_proxy
  end
  def details(order_id, symbol)
    JSON.parse(@api_proxy.order_details(order_id, symbol))
  end
  def buy(symbol, type, quantity)
    order(symbol, "BUY", type, quantity)
  end
  def sell(symbol, type, quantity)
    order(symbol, "SELL", type, quantity)
  end

  private

  def order(symbol, side, type, quantity)
    JSON.parse(@api_proxy.order(symbol, side, type, quantity))
  end
end
