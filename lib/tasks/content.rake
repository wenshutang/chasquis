namespace :content do
  desc "refresh content cache"
  task refresh: :environment do
    ArticleCache.new.update
  end

  desc "flush all cached content in redis"
  task flush: :environment do
    ArticleCache.new.flushall
  end

  require 'ranking/score_calculator'
  desc "update all scores in cache"
  task update_scores: :environment do
    ScoreCalculator.update_all
  end

end
