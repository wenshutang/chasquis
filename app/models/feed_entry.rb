class FeedEntry < ActiveRecord::Base

  belongs_to :feed_stream

  def self.update_from_feed(feed_url)
    feeds = Feedjira::Feed.fetch_and_parse(feed_url)
    feeds.entries.each do |entry|
      unless exists? :guid => entry.id
        create!(
            :source       => 'larazon',
            :name         => entry.title,
            :summary      => entry.summary,
            :url          => entry.url,
            :published_at => entry.published,
            :guid         => entry.id,
            :image_url    => entry.image
        )
      end
    end
  end

end
