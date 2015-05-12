class CreateFeedStreams < ActiveRecord::Migration
  def change
    create_table :feed_streams do |t|
      t.string :source_name
      t.string :source_url

      t.timestamps null: false
    end
  end
end
