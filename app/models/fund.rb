require 'active_record'

class Fund < ActiveRecord::Base
  has_many :holdings
  has_many :coins, :through => :holdings 
end
