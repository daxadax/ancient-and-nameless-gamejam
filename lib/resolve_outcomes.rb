require 'lib/cultists'

module ResolveOutcomes
  DATA_DIR = 'data/resolve'.freeze
  FALLBACK = {
    'text' => 'The shift ended without incident. Probably.',
    'effects' => {}
  }.freeze

  def self.pick(cultist_id, station_id, primary_total)
    outcomes = load(cultist_id)[station_id.to_s] || []
    matched = outcomes.find { |entry| matches?(entry['result'], primary_total) }
    matched || outcomes.last || FALLBACK
  end

  def self.apply_effects!(run, effects)
    return if effects.nil? || effects.empty?

    run.flags ||= {}
    effects.each do |key, value|
      run.flags[key.to_sym] = value if value
    end
  end

  def self.load(cultist_id)
    @cache ||= {}
    key = cultist_id.to_sym
    return @cache[key] if @cache.key?(key)

    path = "#{DATA_DIR}/#{cultist_id.to_s}.json"
    @cache[key] = $gtk.parse_json_file(path)
  end

  def self.matches?(rule, total)
    return false if rule.nil?

    rule = rule.to_s.strip
    return true if rule == 'default' || rule == '*'

    case
    when rule.start_with?('<=')
      total <= rule[2..].to_i
    when rule.start_with?('>=')
      total >= rule[2..].to_i
    when rule.start_with?('<')
      total < rule[1..].to_i
    when rule.start_with?('>')
      total > rule[1..].to_i
    when rule.include?('-')
      low, high = rule.split('-', 2).map(&:to_i)
      total >= low && total <= high
    else
      total == rule.to_i
    end
  end
end
