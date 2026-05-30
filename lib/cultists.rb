# Cultist stat mods for station resolve rolls.
module Cultists
  METER_KEYS = [:vibes, :food, :cleanliness, :authenticity].freeze

  ALL = {
    aldous: {
      vibes: 2,
      food: -3,
      cleanliness: 0,
      authenticity: -1
    },
    jules: {
      vibes: 1,
      food: -2,
      cleanliness: 1,
      authenticity: -1
    },
    dmitros: {
      vibes: 2,
      food: 2,
      cleanliness: -2,
      authenticity: 0
    },
    mara: {
      vibes: -2,
      food: 1,
      cleanliness: 2,
      authenticity: 3
    }
  }.freeze

  IDS = ALL.keys.freeze

  def self.by_name(name)
    ALL[name.to_sym] || raise_not_found_error!(name)
  end

  # TODO: this should be elsewhere / different
  def self.label(id)
    case id
    when :aldous then 'Aldous'
    when :jules then 'Jules'
    when :dmitros then 'Dmitros'
    when :mara then 'Mara'
    else
      raise_not_found_error!(id)
    end
  end

  def self.raise_not_found_error!(name)
    raise ArgumentError, "Can't find cultist named #{name}"
  end

  def self.mod(cultist, attribute)
    by_name(cultist)[attribute.to_sym]
  end
end
