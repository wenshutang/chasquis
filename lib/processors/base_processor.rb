
module BaseProcessor

  # traverse all nodes and strips:
  # emtpy nodes and all styling attributes
  def sanitize (content)
    content.each do |node|
      next if node.nil?
      if node.blank?
        content.delete(node)
        next
      end
      node.traverse do |sub_node|
        sub_node.keys.each { |attr| sub_node.delete attr }
      end
    end
    content.to_html
  end

  # extract the leading paragraph
  def extract_lead (htext)
    content = Nokogiri::HTML::DocumentFragment.parse htext
    lead    = Nokogiri::HTML::DocumentFragment.parse ""
    content.traverse do |node|
      if node.name == "p"
        lead << node
        break
      end
    end
    lead.to_html
  end

  # extract first n number of characters from full text
  def extract_summary (htext, n)

    content = Nokogiri::HTML::DocumentFragment.parse htext

    # extracted summary
    summary = Nokogiri::HTML::DocumentFragment.parse ""
    content.traverse do |node|
      next if node.blank? || node.nil?
      next unless node.name == "p" || node.name == "br"
      ntext = node.text
      if n <= ntext.size
        text_arr = ntext[0..n-1].split(' ')
        text_arr.pop # just knock off last word since it's incomplete
        new_p_node(summary, text_arr.join(' ') )
        break;
      else
        new_p_node(summary, node.text)
        n -= ntext.size
      end
    end
    summary.to_html
  end

  # Helper to create a new paragraph node
  def new_p_node(frag, text)
    new_p = Nokogiri::XML::Node.new("p", frag)
    new_p.content = text
    frag << new_p
  end
end