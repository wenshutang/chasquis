module BoliviaentusmanosProcessor

  include BaseProcessor

  # boliviaentusmanos uses br tags to differentiate paragraphs
  def process_full_text(text)
    frag = Nokogiri::HTML::DocumentFragment.parse text.to_html
    clean_text = Nokogiri::HTML::DocumentFragment.parse ""

    frag.traverse do |node|
      # skip empty <br> elements
      next if node.nil? || node.name == "br"

      # Construct a new <p> with extracted text
      if node.text?
        new_p = Nokogiri::XML::Node.new("p", clean_text)
        new_p.content = node.text.strip
        clean_text << new_p
      end
    end
    clean_text.to_html
  end

  def process_datetime(dt)
    DateTime.now
  end

end