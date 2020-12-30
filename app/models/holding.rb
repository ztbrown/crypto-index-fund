require 'active_record'

class Holding < ActiveRecord::Base
  belongs_to :coin
  belongs_to :snapshot
end
