namespace :content do
  desc "refresh redis based content cache"
  task refresh: :environment do
    @content_cache = ArticleCache.new
    @content_cache.update
  end

  task flush: :environment do
    $redis.flushall
    #@content_cache.clear_all
  end

end
