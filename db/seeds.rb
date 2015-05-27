# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

FeedStream.update_from_feed "http://www.la-razon.com/rss"
FeedStream.update_from_feed "http://www.eldiario.net/rss"
FeedStream.update_from_feed "http://www.eldeber.com.bo/rss"
#FeedStream.update_from_feed "http://www.abi.bo/rss/abi.xml"