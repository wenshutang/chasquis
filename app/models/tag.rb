class Tag < ActiveRecord::Base
  has_many :taggings
  has_many :feed_entries, through: :taggings
end
