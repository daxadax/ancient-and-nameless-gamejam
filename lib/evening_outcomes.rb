require 'lib/cultists'
require 'lib/resolve_outcomes'

module EveningOutcomes
  DATA_FILE = 'data/evening/beats.json'.freeze
  MAX_BEATS = 3

  def self.build(run)
    flags = normalize_flags(run.flags)
    day_deltas = meter_deltas(run)
    beats = pick_beats(flags, day_deltas)

    {
      beats: beats,
      meter_summary: format_meter_summary(day_deltas)
    }
  end

  def self.pick_beats(flags, day_deltas)
    matched = []
    fallback = nil

    load_beats.each do |beat|
      if beat.dig('requires', 'default')
        fallback = beat
        next
      end

      next unless matches_requirements?(beat['requires'], flags, day_deltas)

      matched << beat
      break if matched.length >= MAX_BEATS
    end

    matched = [fallback] if matched.empty? && fallback
    matched
  end

  def self.matches_requirements?(requires, flags, day_deltas)
    requires ||= {}

    return false if requires['flags_all']&.any? { |flag| !flags[flag.to_sym] }

    return false if requires['flags_any']&.none? { |flag| flags[flag.to_sym] }

    requires.fetch('meter_delta', {}).each do |meter, rule|
      key = meter.to_sym
      return false unless ResolveOutcomes.matches?(rule, day_deltas.fetch(key, 0))
    end

    true
  end

  def self.meter_deltas(run)
    Cultists::METER_KEYS.to_h do |meter|
      [meter, run.meters.send(meter) - run.meters_at_day_start.send(meter)]
    end
  end

  def self.format_meter_summary(day_deltas)
    Cultists::METER_KEYS.map do |meter|
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
