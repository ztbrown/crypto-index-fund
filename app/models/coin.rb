require 'active_record'

class Coin < ActiveRecord::Base
  has_many :quotes
  has_many :holdings
  has_many :taggings
  has_many :snapshots, :through => :holdings 
  has_many :tags, -> { distinct }, :through => :taggings

  scope :by_tag, lambda {|tag_name|
    joins(:tags).where(tags: {name: tag_name}).distinct
  }

  def is_stablecoin?
    tags.include?(Tag.find_by_name('stablecoin'))
  end
end
