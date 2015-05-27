class AddFeedStreamToFeedEntry < ActiveRecord::Migration
  def change
    add_reference :feed_entries, :feed_stream, index: true
    add_foreign_key :feed_entries, :feed_streams
  end
end
