class FeedEntry < ActiveRecord::Base

  belongs_to :feed_stream
  has_many :taggings
  has_many :tags, through: :taggings

  # Basic validations
  validates :title, presence: true
  validates :url, uniqueness: true

  # Callbacks
  before_create :create_unique_identifier
  before_save :slugize_title
  after_initialize :defaults


  # Set default values
  def defaults
  end

  def tag=(name)
    # Prevent tag duplicates
    unless self.has_tag?(name)
      self.tags << Tag.where(name: name.strip).first_or_create!
    end
  end

  # adding multiple tags helper
  # (not sure if it's working, shouldn't be a complete replace)
  def tag_list=(names)
    self.tags = names.split(",").map do |n|
      Tag.where(name: n.strip).first_or_create!
    end
  end

  def tag_list
    tags.map(&:name).join(", ")
  end

  def has_tag?(tag_name)
    tags.exists?(name: tag_name)
  end

  # Class method
  def self.tagged_with(tag_name)
    Tag.where(name: tag_name).first.feed_entries
  end

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