require 'rubygems'
require 'nokogiri'
require 'open-uri'
require 'uri'
require 'yaml'



class NotiCrawler

  def initialize
    # Check for configuration
    @config = YAML.load_file('erbol.yml')
  end


  def crawl
    @config.each do |section, config|
      puts config.inspect
      fetch_feed_url config
    end
  end

  def fetch_feed_url config
    page_url = config['url']
    doc = Nokogiri::HTML(open(page_url))

    config['feed-selectors'].each do |rule|
      doc.css(rule).each do |elem|
        next if elem['href'].nil?
        target_url = URI.join(page_url, URI.encode(elem['href']))
        fetch_content(target_url, config['content-selectors'])
      end
    end
  end

  def fetch_content(url, selectors)
    # Need error handling
    doc = Nokogiri::HTML(open(url))
    puts fetch_single_text(doc, selectors['title'])
    puts fetch_single_text(doc, selectors['summary'])
    puts fetch_single_text(doc, selectors['date'])
    puts fetch_single_text(doc, selectors['location'])
    puts fetch_single_text(doc, selectors['author'])
    puts fetch_single_text(doc, selectors['img_url'])
    doc.at_css(selectors['content']).to_html
  end

  def fetch_single_text(doc, sel_expr)
    return nil if sel_expr.nil?
    doc.at_css(sel_expr).nil? ? nil : doc.at_css(sel_expr).text.strip
  end

end