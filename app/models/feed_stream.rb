class FeedStream < ActiveRecord::Base
  has_many :feed_entries

  VALID_IMAGE_REGEX = /http:\/\/.*\.(jpeg|jpg|gif|png)/i
  @name_map = { 'eldiario' => 'El Diario', 'la-razon' => 'La Razón', 'eldeber' => 'El Deber' }

  #Using some bullshit
  def self.update_from_feed(url)
    feed_url, feed_name = url, URI.parse(url).host.scan(/[a-z\-]{4,}/)[0]

    # Display name
    full_name = @name_map[feed_name] || 'Sin Nombre'

    stream = FeedStream.create! feed_url: url, feed_name: feed_name, source_name: full_name

    feeds = Feedjira::Feed.fetch_and_parse feed_url

    feeds.entries.each do |entry|
      unless FeedEntry.exists? :guid => entry.id
        entry = FeedEntry.create!(
          source:       feed_name,
          feed_stream:  stream,
          name:         entry.title,
          summary:      entry.summary,
          url:          entry.url,
          published_at: entry.published,
          guid:         entry.id,
          image_url:    entry.image #(entry.image =~ VALID_IMAGE_REGEX).nil? ? nil : entry.image.match(VALID_IMAGE_REGEX)[0]
        )
      end
    end

  end

end
