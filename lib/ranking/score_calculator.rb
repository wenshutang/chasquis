require 'yaml'

module ScoreCalculator

  @DECAY_CONST = 1
  @RELEVANCE_HOURS = 36
  file = File.open("#{Rails.root.join('config','scoring')}/baseline_alpha.yml", 'r')
  @scoring_conf= YAML.load_file(file)

  def self.update_all
    FeedEntry.all.each { |entry| update_entry(entry) }
  end

  # Updates the score of a section
  def self.update_section(section)
    FeedEntry.where(category: section) { |entry| update(entry) }
  end

  # Updates each entry
  def self.update_entry(entry)

#    puts "dynamic eval: #{dynamic_eval(entry)}, base_score: #{calc_base_score(entry)}, decay #{time_decay(entry.published_at)}"
    new_score = (dynamic_eval(entry) + calc_base_score(entry)) * time_decay(entry.published_at)

#    puts "#{entry.guid} has score #{new_score}"
    entry.score = new_score
    entry.save
  end

  # Calculates base score
  def self.calc_base_score(entry)
    base = 100
    # bump up score based on source
    src = entry.source
    if @scoring_conf["source_weight"].has_key?(src)
      base += @scoring_conf["source_weight"][src]
    end
    # penalize for missing image
    base += @scoring_conf["image_penalty"] if entry.image_url.nil?

    return base
  end


  # re-evaluate score based on dynamically changing parameters
  def self.dynamic_eval(entry)
    order = entry.order_seq
    if @scoring_conf["sequence_order"].has_key?(order)
      return (@scoring_conf['sequence_order'][order]).to_i
    else
      0
    end
  end

  # Time decay formula: after the age crosses a time threshold,
  # there is rapid decay in score
  def self.time_decay( published_at )
    delta_hrs = ((Time.parse(DateTime.now.to_s) - Time.parse(published_at.to_s))/3600).round
    return 1 if delta_hrs <= @RELEVANCE_HOURS
    x = delta_hrs - @RELEVANCE_HOURS
    Math.exp(-@DECAY_CONST*x*x)

  end

end
