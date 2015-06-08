class AddOrderSeqToFeedEntries < ActiveRecord::Migration
  def change
    add_column :feed_entries, :order_seq, :integer
  end
end
