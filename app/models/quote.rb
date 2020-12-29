require 'active_record'

class Quote < ActiveRecord::Base
  belongs_to :coin
  scope :recorded_between, ->(start_date, end_date) {where("timestamp >= ? AND timestamp <= ?", start_date, end_date ) }
end
