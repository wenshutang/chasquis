class EconomiaController < ApplicationController
  def index
    ranking = $redis.zrangebyscore("economia_ranking", 0, "+inf", :limit=> [0, 6])
    # Fetch all relevant information of an article
    @economia_articles = ranking.map { |guid| $redis.hgetall(guid) }

  end
end
