require 'lib/evening_outcomes'

module ReviewOutcomes
  DATA_FILE = 'data/review/lines.json'.freeze

  NEGATIVE_FLAGS = %i[
    kitchen_incident salt_casserole property_damage guest_disturbed
    ritual_disrupted authenticity_too_real filmed_ritual guest_confused
    guest_learned_something_new
  ].freeze

  POSITIVE_FLAGS = %i[
    food_praised guest_delighted authenticity_boost guest_awed
  ].freeze

  def self.matched_lines(flags)
    load_lines
      .reject { |line| line.dig('requires', 'default') }
      .select { |line| EveningOutcomes.matches_requirements?(line['requires'], flags, {}) }
      .sort_by { |line| [EveningOutcomes.beat_priority(line), -EveningOutcomes.flag_specificity(line)] }
  end

  def self.primary_line(flags)
    matched = matched_lines(flags)
    return matched.first if matched.any?

    load_lines.find { |line| line.dig('requires', 'default') }
  end

  def self.star_adjustment(flags)
    adjustment = 0
    NEGATIVE_FLAGS.each { |flag| adjustment -= 1 if flags[flag] }
    POSITIVE_FLAGS.each { |flag| adjustment += 1 if flags[flag] }
    adjustment.clamp(-2, 2)
  end

  def self.load_lines
    @lines ||= $gtk.parse_json_file(DATA_FILE) || []
  end
end
