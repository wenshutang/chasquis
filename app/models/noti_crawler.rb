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
    @src_name = @config['src_name']
  end

  def crawl
    # If not found, don't make duplicate entries
    @fstream = FeedStream.where(source_name: @config['source']).first_or_create do |stream|
      stream.feed_url, stream.feed_name = @src_url, @src_name
    end

    @config['sections'].each do |section, config|
      puts "crawling #{@config['source']} seccion: #{section}"
      fetch_feed_url section, config
    end
  end

  # Parses an article page
  def fetch_feed_url(section, config)
    @page_root_url = page_url = config['section_url']

    doc = Nokogiri::HTML(open(page_url))
    seq = 1
    config['feed-selectors'].each do |rule|
      doc.css(rule).each do |elem|
        next if elem['href'].nil?
        target_url = URI.join(page_url, URI.encode(elem['href']))
        # Go to the target page and grab content
        fetch_content(target_url, section, seq, config['content-selectors'])

        seq += 1
      end
    end
  end

  # Parses the content of a single news page based on the rules defined
  # by the config file
  def fetch_content(url, section, seq, selectors)
    # Need error handling
    entry = FeedEntry.where(url: url.to_s).first
    if entry.blank?
      puts "Fetching #{url}"
      # Fill out basic info
      entry = FeedEntry.create do |article|
        article.url           = url.to_s
        article.category      = section
        article.source        = @src
        article.name          = @src_name
        article.order_seq     = seq
        article.feed_stream   = @fstream
      end

      doc = Nokogiri::HTML(open(url))
      entry = update_article_content(entry, doc, selectors)
    else
      puts "Skipping #{url}"
      # Update columns for an existing entry
      # update sequence order if changed
      entry.order_seq = seq unless entry.order_seq == seq
    end

    # write to db
    entry.save!

  end

  private
    def update_article_content(article, doc, selectors)
      # Fetch simple elements based on css selectors
      article.title       = fetch_single_text(doc, selectors['title'])
      article.location    = fetch_single_text(doc, selectors['location'])
      article.author      = fetch_single_text(doc, selectors['author']) || @src_name
      article.deck        = fetch_single_text(doc, selectors['deck'])
      article.image_url   = fetch_image_src(doc, selectors['img_url'])

      # load custom processing modules based on source
      extend "#{@src.capitalize}Processor".constantize

      # Run through source specific processor to extract relevant text
      text_html = process_full_text(doc.at_css(selectors['content']))
      article.article_text = text_html
      article.summary      = article.image_url.nil? ? extract_summary(text_html, 500) :
                                                      extract_lead(text_html)

      article.published_at = selectors['date'].nil? ? DateTime.now :
                                                      parse_date_time(doc, selectors['date'] )

      article
    end


    def fetch_single_text(doc, sel_expr)
      # Given a selection expression, fetches the first text object
      return nil if sel_expr.nil?
      doc.at_css(sel_expr).nil? ? nil : doc.at_css(sel_expr).text.strip
    end

    # fetches the url source of an image element
    def fetch_image_src(doc, sel_expr)
      node = doc.at_css(sel_expr)
      return nil if node.nil?

      if node.child.nil?
        return URI.join(@page_root_url, URI.encode(node['src']))
      elsif ( node.child.has_attribute?('src') )
        # Sometimes the child node contains the img src (e.g. erbol)
        return URI.join(@page_root_url, URI.encode(node.child.attribute('src').to_s ) )
      end
    end

    def parse_date_time(doc, date_sel)
      if date_sel.has_key? 'datetime'
        dt = doc.at_css(date_sel['datetime']).text
        return process_datetime( dt )
      elsif date_sel.has_key?('date') && date_sel.has_key?('time')
        date_str = doc.at_css(date_sel['date']).text.strip
        time_str = doc.at_css(date_sel['time']).text.strip
        return process_date_and_time(date_str, time_str)
      end
      DateTime.now
    end

end