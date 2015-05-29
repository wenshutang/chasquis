class AddTitleToFeedEntries < ActiveRecord::Migration
  def change
    add_column :feed_entries, :title, :string
    add_column :feed_entries, :location, :string
    add_column :feed_entries, :article_text, :text
  end
end
