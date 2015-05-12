class SingleSourceFeedController < ApplicationController
  @display_limit = 20
  def show

    @feed_list = FeedEntry.where(source: params[:src]).limit(@display_limit).order(published_at: :desc)
  end


  private
    def user_params
      params.require(:user).permit(:name, :email, :password,
                                   :password_confirmation)
    end
end
