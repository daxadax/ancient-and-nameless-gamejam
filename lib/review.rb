require 'lib/character'
require 'lib/crew_rolls'
require 'lib/run'

module Review
  METER_KEYS = Character::METER_KEYS

  HEADLINES = {
    1 => 'Would not recommend to my ex. Or anyone.',
    2 => 'An experience. That is the nicest thing I can say.',
    3 => 'Perfectly adequate cult retreat. The crystals were nice.',
    4 => 'Genuinely weird in a good way. Already told two friends.',
    5 => 'They had me at the summoning circle. Five stars, no notes.'
  }.freeze

  METER_HIGH = {
    vibes: 'I felt like I was in a farcical British sitcom and I loved that.',
    food: 'the food was better than any of the hipster brunch places.',
    cleanliness: 'the place is spotless. Suspiciously spotless.',
    authenticity: 'it\'s very authentic. Uncomfortably so, in fact.'
  }.freeze

  METER_LOW = {
    vibes: 'Something about the tour felt off. Actually the experience did',
    food: 'Instead of breakfast I got a vision board crafting session',
    cleanliness: 'There was blood on the carpet...not a lot, but enough',
    authenticity: 'Not sure this counts as occult, it felt more like community theater.'
  }.freeze

  def self.build(run)
    meters = run.meters
    stars = star_count(meters)

    {
      stars: stars,
      star_line: star_line(stars),
      headline: HEADLINES.fetch(stars),
      body: body_for(meters, stars),
      callback: callback_line(run),
      crew_high: crew_high_line(run),
      crew_low: crew_low_line(run),
      meter_text: meter_summary(meters)
    }
  end

  def self.callback_line(run)
    run.review_callbacks&.first
  end

  # TODO: reconfigure this based on star-rating / category and then ~avg
  def self.star_count(meters)
    # current total max (without buffs) is 256
    # total possible vibes: 88
    # total possible authenticity: 64
    # total possible cleanliness: 64
    # total possible food: 40
    total = METER_KEYS.sum { |key| meter_value(meters, key) }

    return 1 if total < 60
    return 2 if total < 120
    return 3 if total < 180
    return 4 if total < 240

    5
  end

  def self.star_line(stars)
    filled = '★' * stars
    empty = '☆' * (5 - stars)
    "#{filled}#{empty}"
  end

  def self.body_for(meters, stars)
    values = meter_values(meters)
    worst = values.min_by { |_key, value| value }.first
    best = values.max_by { |_key, value| value }.first

    if stars <= 2
      METER_LOW.fetch(worst)
    elsif stars >= 4
      METER_HIGH.fetch(best).split('. ').map(&:capitalize).join('. ')
    else
      "#{METER_LOW.fetch(worst)} - on the upside #{METER_HIGH.fetch(best)} "
    end
  end

  def self.meter_summary(meters)
    METER_KEYS.map do |key|
      "#{key.to_s.capitalize} #{meter_value(meters, key)}"
    end.join('  ')
  end

  def self.meter_values(meters)
    METER_KEYS.to_h { |key| [key, meter_value(meters, key)] }
  end

  def self.meter_value(meters, key)
    raise ArgumentError, "Can't find #{key} in #{METER_KEYS}" unless METER_KEYS.include?(key)

    meters.send(key)
  end

  # TODO: these should be based on traits / more fun / interesting
  def self.crew_high_line(run)
    return nil unless CrewRolls.callout?(run)

    summary = CrewRolls.summary(run)
    character = Run.character(run, summary[:best_id])
    return nil unless character

    "#{character.display_name} carried the weekend."
  end

  def self.crew_low_line(run)
    return nil unless CrewRolls.callout?(run)

    summary = CrewRolls.summary(run)
    character = Run.character(run, summary[:worst_id])
    return nil unless character

    "#{character.display_name} had a rough few days."
  end
end
