require 'active_record'

class Tagging < ActiveRecord::Base
  belongs_to :tag
  belongs_to :coin
end
