class AddImageIdToFeedEntry < ActiveRecord::Migration
  def change
    add_column :feed_entries, :image_url, :string
  end
end
