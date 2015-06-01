namespace :content do
  desc "refresh redis based content cache"
  task refresh: :environment do
    ArticleCache.new.update
  end

end
