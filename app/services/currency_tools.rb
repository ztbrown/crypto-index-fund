require 'net/http'
require 'open-uri'
require 'json'

require_relative '../../config/boot'

class CurrencyTools

  def self.get_top_currencies(limit) 
    json = ''
    if File.exists?("currencies-#{limit}.json")
      data = JSON.load(File.open("currencies-#{limit}.json"))
    else
      uri = URI.parse("https://pro-api.coinmarketcap.com/v1/cryptocurrency/listings/latest?limit=#{limit}")
      request = Net::HTTP::Get.new(uri)
      request["X-Cmc_pro_api_key"] = ENV['CMC_API_KEY'] 
      request["Accept"] = "application/json"

      req_options = {
        use_ssl: uri.scheme == "https",
      }

      response = Net::HTTP.start(uri.hostname, uri.port, req_options) do |http|
        http.request(request)
      end

      File.open("currencies-#{limit}.json", 'w') { |file| file.write(response.body) }

      data = JSON.parse(response.body)
    end
    data["data"].map do |cur|
      coin = Coin.find_by_cmc_id(cur['id'])
      if coin.symbol == "MIOTA"
        coin.symbol = "IOTA"
      end
      coin
    end
  end

end
