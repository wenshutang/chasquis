namespace :harvest do
  desc "harvest all sources"
  task all: :environment do
    harvesters = []
    Dir.glob("#{Rails.root.join('config','sources')}/*.yml") do |file|
      harvesters << NotiCrawler.new(file)
    end

    # Sequentially crawl each harvester
    # TODO: separate them to individual daemons
    harvesters.each { |h| h.crawl }
  end

  desc "harvests a single source"
  task :source, [:src] => :environment  do |t, args|
    puts "Harvesting from #{args[:src]}"
    # TODO: error handling
    file = File.open("#{Rails.root.join('config','sources')}/#{args[:src]}.yml", 'r')
    crawler = NotiCrawler.new(file)
    crawler.crawl
  end

end
