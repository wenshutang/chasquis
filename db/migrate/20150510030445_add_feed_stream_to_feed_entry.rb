class AddFeedStreamToFeedEntry < ActiveRecord::Migration
  def change
    remove_column :feed_entries, :feed_stream_id
    add_reference :feed_entries, :feed_stream, index: true
    add_foreign_key :feed_entries, :feed_streams
  end
end
