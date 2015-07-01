# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20150623023251) do

  create_table "feed_entries", force: true do |t|
    t.string   "name"
    t.text     "summary"
    t.string   "url"
    t.datetime "published_at"
    t.string   "guid"
    t.datetime "created_at",     null: false
    t.datetime "updated_at",     null: false
    t.string   "source"
    t.integer  "feed_stream_id"
    t.string   "image_url"
    t.string   "title"
    t.string   "location"
    t.text     "article_text"
    t.string   "category"
    t.string   "author"
    t.integer  "order_seq"
    t.integer  "score"
    t.string   "slug"
    t.string   "deck"
  end

  add_index "feed_entries", ["feed_stream_id"], name: "index_feed_entries_on_feed_stream_id"

  create_table "feed_streams", force: true do |t|
    t.string   "source_name"
    t.string   "feed_url"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
    t.string   "feed_name"
  end

end
