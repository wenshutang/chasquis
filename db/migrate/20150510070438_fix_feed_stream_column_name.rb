class FixFeedStreamColumnName < ActiveRecord::Migration
  def change
    rename_column :feed_streams, :source_url, :feed_url
    add_column :feed_streams, :feed_name, :string
  end
end
