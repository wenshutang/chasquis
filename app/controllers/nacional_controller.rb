class NacionalController < ApplicationController
  def index

    # top 8 articles based on score
    @nacional_articles = FeedEntry.where(category: "nacional").order(score: :desc).limit(8)

  end
end
