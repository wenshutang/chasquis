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
    doc = Nokogiri::HTML(open(url))
    puts "Parsing #{url}"
    # store url in string format
    FeedEntry.where(url: url.to_s).first_or_create do |entry|
      entry.title        = fetch_single_text(doc, selectors['title'])
      entry.source       = @src
      entry.category     = section
      entry.published_at = selectors['date'].nil? ? DateTime.now :
                                                    parse_date_time(doc, selectors['date'])
      entry.location     = fetch_single_text(doc, selectors['location'])
      entry.author       = fetch_single_text(doc, selectors['author']) || @src_name
      entry.summary      = fetch_single_text(doc, selectors['summary'])
      entry.image_url    = fetch_image_src(doc, selectors['img_url'])
      entry.article_text = doc.at_css(selectors['content']).to_html.to_s
      entry.order_seq    = seq
      entry.feed_stream  = @fstream
    end
  end

  private
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
        time = doc.at_css(date_sel['datetime']).text
        if date_sel.has_key? 'fmt'
          return DateTime.strptime(time, date_sel['fmt'])
        else
          return DateTime.parse(time)
        end
      end

      dt = DateTime.new
      if date_sel.has_key? 'date'
        date_str = doc.at_css(date_sel['date']).text
        # format parsed string from given configuration
        if date_sel.has_key? 'date_fmt'
          func = date_sel['date_fmt'].first
          args = date_sel['date_fmt'][1..-1]
          date_str.send(func, *args)
        end
        dt = DateTime.parse(date_str)
      end

      if date_sel.has_key? 'time'
        time_str = doc.at_css(date_sel['time']).text
        dt = DateTime.parse(time_str)
      end
      return dt
    end

end