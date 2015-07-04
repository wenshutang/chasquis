class RemoveTagsFromFeedEntries < ActiveRecord::Migration
  def change
    remove_column :feed_entries, :tags, :string
  end
end
