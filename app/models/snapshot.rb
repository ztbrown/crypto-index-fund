require 'active_record'

class Snapshot < ActiveRecord::Base
  belongs_to :fund
  has_many :holdings
  has_many :coins, :through => :holdings 
end
