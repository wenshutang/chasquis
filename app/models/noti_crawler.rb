require 'rubygems'
require 'nokogiri'
require 'open-uri'
require 'uri'
require 'yaml'

class NotiCrawler

  def initialize(file)
    # Check for configuration
    @config = YAML.load_file(file)
    @src      = @config['source']
    @src_url  = @config['url']
  end

  def crawl
    # If not found, don't make duplicate entries
    @fstream = FeedStream.find_or_create_by(source_name: @config['source']) do |stream|
      stream.feed_url  = @src_url
      stream.feed_name = @config['src_name']
    end

    @config['sections'].each do |section, config|
      puts "crawling #{@config['source']} seccion: #{section}"
      fetch_feed_url section, config
    end
  end

  def fetch_feed_url(section, config)
    page_url = config['section_url']

    doc = Nokogiri::HTML(open(page_url))

    config['feed-selectors'].each do |rule|
      doc.css(rule).each do |elem|
        next if elem['href'].nil?
        target_url = URI.join(page_url, URI.encode(elem['href']))
        fetch_content(target_url, section, config['content-selectors'])
      end
    end
  end

  # Parses the content of a single news page based on the rules defined
  # by the config file
  def fetch_content(url, section, selectors)
    # Need error handling
    doc = Nokogiri::HTML(open(url))

    FeedEntry.find_or_create_by(url: url) do |entry|
      entry.title        = fetch_single_text(doc, selectors['title'])
      entry.source       = @src
      entry.category     = section
      # TODO: change dates from string to datetime
      # entry.published_at = fetch_single_text(doc, selectors['date'])
      entry.location     = fetch_single_text(doc, selectors['location'])
      entry.author       = fetch_single_text(doc, selectors['author'])
      entry.image_url    = fetch_single_text(doc, selectors['img_url'])
      entry.article_text = doc.at_css(selectors['content']).to_html.to_s
      entry.feed_stream  = @fstream
    end
  end

  # Given a selection expression, fetches the first text object
  def fetch_single_text(doc, sel_expr)
    return nil if sel_expr.nil?
    doc.at_css(sel_expr).nil? ? nil : doc.at_css(sel_expr).text.strip
  end

end