$redis = Redis::Namespace.new("content cache", :redis => Redis.new)
