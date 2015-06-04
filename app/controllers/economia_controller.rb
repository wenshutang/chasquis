class EconomiaController < ApplicationController
  def index
    @economia_articles = $redis.zrangebyscore("economia_ranking", 0, "+inf", :limit=> [0, 6])
  end
end
