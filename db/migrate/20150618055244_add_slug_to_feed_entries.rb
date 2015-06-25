class AddSlugToFeedEntries < ActiveRecord::Migration
  def change
    add_column :feed_entries, :slug, :string
  end
end
