module EldeberProcessor

  include BaseProcessor

  def process_full_text(content)
    sanitize content.children
  end

  def extract_lead(text)
    extract_summary(text, 250)
  end

  def process_datetime(dt)
    DateTime.strptime(dt, '%d/%m/%Y%H:%M')
  end

end