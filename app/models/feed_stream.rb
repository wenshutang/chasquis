class FeedStream < ActiveRecord::Base
  has_many :feed_entries
  attr_accessor :feed_source, :feed_url, :source_name


  def FeedStream.update_from_feed
    feeds = Feedjira::Feed.fetch_and_parse self.feed_url

    feeds.entries.each do |entry|
      unless FeedEntry.exists? :guid => entry.id
        FeedEntry.create!(
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

  private
    def user_params
      params.require(:user).permit(:name, :email, :password,
                                   :password_confirmation)
    end


end
