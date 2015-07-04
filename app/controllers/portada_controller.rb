class PortadaController < ApplicationController
  helper_method :elapsed_time

  def index
    # top 8 articles based on score
    @portada_articles = FeedEntry.tagged_with('portada').order(score: :desc).limit(8)
  end

  def elapsed_time(article)
    delta_time = Time.parse(DateTime.now.to_s) - Time.parse(article.published_at.to_s)
    return "hace más de un día" if delta_time > 3600*24
    return "#{(delta_time/60).round} minutos" if delta_time.round < 3600
    return "#{(delta_time/3600).round} horas"

  end
end
