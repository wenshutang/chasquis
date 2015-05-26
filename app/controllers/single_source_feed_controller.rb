class SingleSourceFeedController < ApplicationController
  @display_limit = 20
  def show
    @feed_name = FeedStream.where(feed_name: params[:src]).first.source_name
    @feed_list = FeedEntry.where(source: params[:src]).limit(@display_limit).order(published_at: :desc)
  end

end
