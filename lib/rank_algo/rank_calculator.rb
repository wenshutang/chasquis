# Template for a rank calculator. We need to extract some metrics correctly (date, sequence order)
# before we can meaningfully calculate ranking scores

$score_modifiers = {}

$score_modifiers['sequence'] = {
  name: 'sequence order modifier'
  proc: Proc.new do |article|
    article['score']
  end
}

$score_modifiers['src_weight'] = {
  name: 'source weight modifier'
  proc: Proc.new do |article|
    article['score']
  end
}

$score_modifiers['section_weight'] = {
  name: 'section weight modifier'
  proc: Proc.new do |article|
    article['section']
  end

}

class RankCalculator

  # Updates score based on: 1) applying score modifiers
  # 2) Applying score function
  def crunch_entry(id, article)
    #score * weight * time_decay

  end

  def crunch_all
    $redis.scan_each(:match=> "prefix*") do |id|
      crunch_entry (id, $redis.mapped_hmget(id))
    end

  end

end
