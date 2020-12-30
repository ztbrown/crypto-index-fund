require 'json'

class Account
  def initialize(api_proxy)
    @api_proxy = api_proxy
  end

  def balance
    JSON.parse(@api_proxy.account)["balances"]
  end
end
