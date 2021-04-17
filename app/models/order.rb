require 'active_record'
require 'json'

class Order < ActiveRecord::Base
  belongs_to :coin

  def execute(api)
    if !completed
      response = JSON.parse(api.order("#{coin.symbol}#{pair}", side, "MARKET", amount.to_f))
      if !response['msg']    
        update_attribute(:completed, true)
        update_attribute(:order_id, response['order_id'])
        return response
      else
        puts "ERROR: #{response['msg']}"
        return nil
      end
    else
      puts "ERROR: Order previously executed"
      return nil
    end
  end

  def details(api)
    order_id.nil? ? nil : JSON.parse(api.order_details(order_id, "#{coin.symbol}#{pair}"))
  end

end
