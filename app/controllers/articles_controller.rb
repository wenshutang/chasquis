class ArticlesController < ApplicationController
  def show
    @article = FeedEntry.find_by_slug(params[:id])
  end
end
