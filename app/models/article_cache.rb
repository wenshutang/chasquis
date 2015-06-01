
# Implements a basic subset of caching heuristics


class ArticleCache

  def update
    # Once date and order has been normalized, restrict to age and base score
    FeedEntry.all.each do |entry|
      key = entry.guid
      cached_entry = {  url:            entry.url,
                        title:          entry.title,
                        source:         entry.source,
                        author:         entry.author,
                        summary:        entry.summary,
                        #published_at:   entry.published_at
                        location:       entry.location,
                        text:           entry.article_text,
                        image_url:      entry.image_url,
                        score:          10 }
      store key, cached_entry
    end

  end

  def store(key, val)
    $redis.mapped_hmset(key, val) unless $redis.exists(key)
  end

  def clear
    $redis.flushall
  end

end


