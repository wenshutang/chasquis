class AddScoreToFeedEntries < ActiveRecord::Migration
  def change
    add_column :feed_entries, :score, :integer
  end
end
