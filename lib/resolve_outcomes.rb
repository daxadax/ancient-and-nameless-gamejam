require 'lib/traits'
require 'lib/station_outcomes'
require 'lib/character'

module ResolveOutcomes
  FALLBACK = {
    'text' => Traits::DEFAULT_TEXT,
    'effects' => {},
    'mara' => nil,
    'events' => {}
  }.freeze

  def self.pick(character, station_id, primary_total)
    character = Character.wrap(character)
    name = character.display_name

    outcome = if character.bespoke_resolve?
                pick_bespoke_resolve(character, station_id, primary_total)
              elsif character.traits.any?
                pick_from_traits(character, station_id, primary_total)
              else
                StationOutcomes.pick(station_id, primary_total)
              end

    interpolate!(outcome, name)
  end

  def self.pick_from_traits(character, station_id, primary_total)
    entry = Traits.first_station_entry(character.traits, station_id)

    if entry
      Traits.build_outcome(entry, primary_total)
    else
      StationOutcomes.pick(station_id, primary_total)
    end
  end

  def self.pick_bespoke_resolve(character, station_id, primary_total)
    outcomes = load_bespoke_resolve(character.resolve_file)[station_id.to_s] || []
    matched = outcomes.find { |entry| matches?(entry['result'], primary_total) }
    outcome = matched || outcomes.last || FALLBACK

    {
      'text' => outcome['text'],
      'effects' => outcome['effects'] || {},
      'mara' => nil,
      'events' => {}
    }
  end

  def self.interpolate!(outcome, name)
    outcome['text'] = Traits.substitute(outcome['text'], name) if outcome['text']
    outcome['mara'] = Traits.substitute(outcome['mara'], name) if outcome['mara']
    outcome
  end

  def self.load_bespoke_resolve(path)
    @bespoke_resolve ||= {}
    @bespoke_resolve[path] ||= $gtk.parse_json_file(path)
  end

  def self.apply_outcome!(run, outcome, name)
    apply_effects!(run, outcome['effects'])
    apply_events!(run, outcome, name)
  end

  def self.apply_effects!(run, effects)
    return if effects.nil? || effects.empty?

    run.flags ||= {}
    effects.each do |key, value|
      run.flags[key.to_sym] = value if value
    end
  end

  def self.apply_events!(run, outcome, name)
    mara = outcome['mara']
    if mara
      run.mara_asides ||= []
      run.mara_asides << mara
    end

    events = outcome['events'] || {}
    effects = outcome['effects'] || {}
    effects.each_key do |flag|
      callback = review_callback_for(events, flag.to_s)
      next unless callback

      line = Traits.substitute(callback, name)
      run.review_callbacks ||= []
      run.review_callbacks << line unless run.review_callbacks.include?(line)
    end
  end

  def self.review_callback_for(events, flag)
    event = events[flag]
    return nil unless event

    event['review_callback']
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
