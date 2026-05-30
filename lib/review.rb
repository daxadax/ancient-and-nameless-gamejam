module Review
  METER_KEYS = [:vibes, :food, :cleanliness, :authenticity].freeze

  METER_LABELS = {
    vibes: 'Vibes',
    food: 'Food',
    cleanliness: 'Cleanliness',
    authenticity: 'Authenticity'
  }.freeze

  HEADLINES = {
    1 => 'Would not recommend to my ex. Or anyone.',
    2 => 'An experience. That is the nicest thing I can say.',
    3 => 'Perfectly adequate cult retreat. The crystals were nice.',
    4 => 'Genuinely weird in a good way. Already told two friends.',
    5 => 'They had me at the summoning circle. Five stars, no notes.'
  }.freeze

  METER_HIGH = {
    vibes: 'aldous is a riot. He\'s worth the price of admission alone.',
    food: 'the food was better than any of the hipster brunch places.',
    cleanliness: 'the place is spotless. Suspiciously spotless.',
    authenticity: 'it\s very authentic. Uncomfortably so, in fact.'
  }.freeze

  METER_LOW = {
    vibes: 'Something about the tour felt off. Actually the whole thing did',
    food: 'I wanted breakfast and only got a bad tarot reading',
    cleanliness: 'There was blood on the carpet...Not a lot, but enough',
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
      meter_text: meter_summary(meters)
    }
  end

  def self.star_count(meters)
    average = METER_KEYS.sum { |key| meter_value(meters, key) } / METER_KEYS.length.to_f

    # NOTE: thresholds are a first pass for three-day playtests from zero meters.
    return 1 if average < 8
    return 2 if average < 18
    return 3 if average < 28
    return 4 if average < 40

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
      METER_HIGH.fetch(best).capitalize
    else
      "#{METER_LOW.fetch(worst)} - on the upside #{METER_HIGH.fetch(best)} "
    end
  end

  def self.meter_summary(meters)
    METER_KEYS.map do |key|
      "#{METER_LABELS.fetch(key)} #{meter_value(meters, key)}"
    end.join('  ')
  end

  def self.meter_values(meters)
    METER_KEYS.to_h { |key| [key, meter_value(meters, key)] }
  end

  def self.meter_value(meters, key)
    case key
    when :vibes then meters.vibes
    when :food then meters.food
    when :cleanliness then meters.cleanliness
    when :authenticity then meters.authenticity
    end
  end
end
