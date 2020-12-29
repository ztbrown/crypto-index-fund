require 'active_record'

class Coin < ActiveRecord::Base
  has_many :quotes
  has_many :funds, :through => :holdings 
end
