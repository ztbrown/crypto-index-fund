require_relative "get_historical_market_cap"
require_relative "weighted_moving_average"

require 'net/http'
require 'open-uri'
require 'json'

def get_top_currencies_by_mc(limit)
  currencies = get_top_currencies(limit)

  currencies.each do |currency|
    if !currency['tags'].include?("stablecoin") || currency['slug'] == 'wrapped-bitcoin'
      slug = currency['slug']
      mc = get_historical_market_cap(slug, 20201101, 20201201)
      avg = wma(mc)
      currency['mc_avg'] = avg || 0
    end
  end
  currencies.reject! {|cur| cur['mc_avg'].nil? }
  currencies.sort_by! { |obj| obj['mc_avg'] }
  currencies.reverse.take(30).each.with_index {|cur, i| puts "#{i+1}.) #{cur['slug']}: #{cur['mc_avg']}"}
end

def get_top_currencies(limit) 
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
  data["data"]
end

#get_top_currencies_by_mc(50)
