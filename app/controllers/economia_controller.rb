class EconomiaController < ApplicationController
  helper_method :elapsed_time

  def index
    # top 8 articles based on score
    @economia_articles = FeedEntry.tagged_with('economia').order(score: :desc).limit(8)
  end

  def elapsed_time(article)
    delta_time = Time.parse(DateTime.now.to_s) - Time.parse(article.published_at.to_s)

    return "#{(delta_time/3600).round} horas" if delta_time.round > 1
    return "#{(delta_time/60)}.round minutos"
  end

end
