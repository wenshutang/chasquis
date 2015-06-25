module LarazonProcessor

  include BaseProcessor

  def process_full_text(content)
    sanitize(content.children)
  end

  def process_date_and_time(date, time)
    date.gsub!('de', ' ')
    DateTime.parse( date+' '+time )
  end

end