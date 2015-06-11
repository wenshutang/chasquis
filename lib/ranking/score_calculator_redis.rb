require 'yaml'

module ScoreCalculator

  @DECAY_CONST = 8
  @RELEVANCE_HOURS = 36
  file = File.open("#{Rails.root.join('config','scoring')}/baseline_alpha.yml", 'r')
  @scoring_conf= YAML.load_file(file)

  puts @scoring_conf.inspect

  def update_all
    $redis.scan_each(:match=> "prefix*") do |id|
      update_entry(id, $redis.mapped_hmget(id))
    end
  end

  # Updates the score of a section
  def update_section

  end

  # Updates each entry
  def update_entry(id, entry)
    section = entry['category']

    new_score = dynamic_eval(entry) * base_score(entry)
    # udpate content cache
    # TODO: handle error
    $redis.mapped_hmset(id, {'score': new_score})

    # update section ranking
    $redis.zadd("#{section}_ranking", new_score, id)
  end

  # re-evaluate score based on dynamically changing parameters
  def dynamic_eval(entry)
    order = [entry[:order]]
    if @scoring_conf["sequence_order"].has_key?(order_str)
      entry[:score] + (@scoring_conf['sequence_order'][order]).to_i
    else
      entry[:score]
    end
  end

  # Calculates base score
  def base_score(entry)
    base = 100
    # bump up score based on source
    src = entry[:source]
    puts src
    puts @scoring_conf.inspect
    puts @scoring_conf["source_weight"].inspect

    base += @scoring_conf["source_weight"][src]
    # penalize for missing image
    base += @scoring_conf["image_penalty"] if entry[:image].nil?

    return base
  end

  # Time decay formula: after the age crosses a time threshold,
  # there is rapid decay in score
  def time_decay( published_at )
    delta_hrs = ( DateTime.now - entry.published_at )/(60*60)
    x = delta_hrs - @RELEVANCE_HOURS
    Math.exp(-@DECAY_CONST*x*x)
  end

end
