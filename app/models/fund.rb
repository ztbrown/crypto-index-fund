require 'active_record'

class Fund < ActiveRecord::Base
  has_many :snapshots
end

