class FeedEntry < ActiveRecord::Base

  belongs_to :feed_stream
  before_create :create_unique_identifier

  def create_unique_identifier
    self.guid = SecureRandom.urlsafe_base64(8,true) # generate uuid of length 10
  end


end