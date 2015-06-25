class AddDeckTextToFeedEntries < ActiveRecord::Migration
  def change
    add_column :feed_entries, :deck, :string
  end
end
