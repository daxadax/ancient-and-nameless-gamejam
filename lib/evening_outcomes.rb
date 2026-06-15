require 'lib/characters/character'
require 'lib/resolve_outcomes'

module EveningOutcomes
  DATA_FILE = 'data/evening/beats.json'.freeze
  MAX_BEATS_PER_STATION = 1
  DEFAULT_COMMUNICATION_TYPE = 'Compound update'

  def self.compound_page_beats(run, exclude_ids: [])
    beats_for_station(
      :compound,
      normalize_flags(run.flags),
      meter_deltas(run),
      exclude_ids: exclude_ids,
      compound_quiet: day_quiet?(run)
    )
  end

  def self.day_quiet?(run)
    return true unless run.last_resolve

    run.last_resolve.none? do |result|
      normalize_flags(result[:effects]).any?
    end
  end

  def self.beats_for_station(station_id, station_flags, station_meters, exclude_ids: [], compound_quiet: true)
    station_key = station_id.to_s

    matched = load_beats.select do |beat|
      next false if exclude_ids.include?(beat['id'])
      next false if compound_fallback?(beat)
      next false unless beat['station'] == station_key

      matches_requirements?(beat['requires'], station_flags, station_meters)
    end

    unless station_key == 'compound'
      matched.reject! { |beat| redundant_with_resolve?(beat, station_flags) }
    end

    if station_key == 'compound'
      unless matched.empty?
        return matched.sort_by { |beat| [beat_priority(beat), -flag_specificity(beat)] }.first(1)
      end

      fallback_key = compound_quiet ? 'default' : 'default_busy'
      fallback = load_beats.find { |beat| beat.dig('requires', fallback_key) }
      return fallback ? [fallback] : []
    end

    matched.sort_by { |beat| beat_priority(beat) }.first(MAX_BEATS_PER_STATION)
  end

  def self.compound_fallback?(beat)
    requires = beat['requires'] || {}
    requires['default'] || requires['default_busy']
  end

  def self.beat_priority(beat)
    requires = beat['requires'] || {}
    return 0 if requires['flags_all']
    return 1 if requires['flags_any']
    return 2 if requires['meter_delta']&.any?

    3
  end

  def self.flag_specificity(beat)
    requires = beat['requires'] || {}
    requires.fetch('flags_all', requires.fetch('flags_any', [])).length
  end

  def self.redundant_with_resolve?(beat, station_flags)
    requires = beat['requires'] || {}
    return false if requires['meter_delta']&.any?

    if requires['flags_all']
      return requires['flags_all'].all? { |flag| station_flags[flag.to_sym] }
    end

    if requires['flags_any']
      return requires['flags_any'].any? { |flag| station_flags[flag.to_sym] }
    end

    false
  end

  def self.communication_type_for(beat)
    beat['communication_type'] || DEFAULT_COMMUNICATION_TYPE
  end

  def self.matches_requirements?(requires, station_flags, station_meters)
    requires ||= {}

    if requires['flags_all']
      return false unless requires['flags_all'].all? { |flag| station_flags[flag.to_sym] }
    end

    if requires['flags_any']
      return false unless requires['flags_any'].any? { |flag| station_flags[flag.to_sym] }
    end

    requires.fetch('meter_delta', {}).each do |meter, rule|
      key = meter.to_sym
      value = station_meters[key]
      return false if value.nil?

      return false unless ResolveOutcomes.matches?(rule, value)
    end

    true
  end

  def self.meter_deltas(run)
    Character::METER_KEYS.to_h do |meter|
      [meter, run.meters.send(meter) - run.meters_at_day_start.send(meter)]
    end
  end

  def self.format_meter_summary(day_deltas)
    Character::METER_KEYS.map do |meter|
      delta = day_deltas[meter]
      sign = delta.negative? ? '' : '+'
      "#{meter.to_s.capitalize} #{sign}#{delta}"
    end.join('  ')
  end

  def self.normalize_flags(flags)
    return {} unless flags

    flags.each_with_object({}) do |(key, value), memo|
      memo[key.to_sym] = value if value
    end
  end

  def self.load_beats
    @beats ||= $gtk.parse_json_file(DATA_FILE) || []
  end
end
