module ErbolProcessor

  include BaseProcessor

  def process_full_text(content)
    sanitize(content.children)
  end

  def process_datetime(dt)
    DateTime.parse(dt)
  end

end