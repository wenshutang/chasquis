
# Implements a basic subset of caching heuristics


class ArticleCache

  def initialize
    @rankings = {}
  end

  def update
    # Once date and order has been normalized, restrict to age and base score
    mock_score = 10
    FeedEntry.all.each do |entry|
      key = entry.guid
      section = entry.category
      cached_entry = {  url:            entry.url,
                        title:          entry.title,
                        source:         entry.source,
                        author:         entry.author,
                        summary:        entry.summary,
                        category:       section,
                        #published_at:   entry.published_at
                        location:       entry.location,
                        text:           entry.article_text,
                        image_url:      entry.image_url,
                        score:          mock_score }
      store key, cached_entry
      # Generate some fake scores
      mock_score += 1

      # index ranking of each section in a sorted list
      index_section_ranking(section, key)

    end

  end

  def index_section_ranking(section, guid)
    return if section.empty?
    score = $redis.hmget(guid, "score")
    # sort entries based on score
    $redis.zadd("#{section}_ranking", score, guid)
  end

  def clear_all
    $redis.flushall
  end


  private:
    # Helper to store hashes
    def store(key, val)
      $redis.mapped_hmset(key, val) unless $redis.exists(key)
    end

end


