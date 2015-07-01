class FeedEntry < ActiveRecord::Base

  belongs_to :feed_stream

  # Basic validations
  validates :title, presence: true
  validates :url, uniqueness: true

  # Callbacks
  before_create :create_unique_identifier
  before_save :slugize_title

  def create_unique_identifier
    self.guid = SecureRandom.urlsafe_base64(8,true) # generate uuid of length 10
  end

  # Overriding rails to_param to generate slugs
  def to_param
    FeedEntry.slugize(title, 10)
  end

  def slugize_title
    self.slug = FeedEntry.slugize(title, 10) if self.slug.nil?
  end

  # Class method to create a slug
  def self.slugize(title, max)
    title_arr = title.split(' ')
    title_arr.size > max ? title_arr[0..max-1].join(' ').parameterize :
        title.parameterize
  end

end