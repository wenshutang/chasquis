class ArticlesController < ApplicationController

  def show
    @article = FeedEntry.find_by_slug(params[:id])

    if request.path != article_path(@article)
      redirect_to @article, status: :moved_permanently
    else
      respond_to do |format|
        format.html
        format.xml { render :xml => @article.to_xml }
      end
    end
  end

end
