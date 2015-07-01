# Implements a basic subset of caching heuristics
require 'ranking/score_calculator'

class ArticleCache

  # Add modules as mixins
  include ScoreCalculator

  def update
    # Once date and order has been normalized, restrict to age and base score

    # TODO: enforce some rules to cache articles
    FeedEntry.all.each do |entry|
      key = entry.guid

      cached_entry = {  url:            entry.url,
                        title:          entry.title,
                        source:         entry.source,
                        author:         entry.author,
                        summary:        entry.summary,
                        category:       entry.category,
                        published_at:   entry.published_at,
                        location:       entry.location,
                        order:          entry.order_seq,
                        text:           entry.article_text,
                        image_url:      entry.image_url }

      # seed an entry with a base score
      cached_entry[:score] = base_score(cached_entry)

      store key, cached_entry
      # index ranking of each section in a sorted list
      index_section_ranking(section, key)
    end
  end

  # Clears the cache
  def clear_all
    $redis.flushall
  end

  # Helper to index ranking
  def index_section_ranking(section, guid)
    return if section.empty?
    score = $redis.hmget(guid, "score")
    # sort entries based on score
    $redis.zadd("#{section}_ranking", score, guid)
  end

  # Helper to store hashes
  def store(key, val)
    $redis.mapped_hmset(key, val) unless $redis.exists(key)
  end

end


