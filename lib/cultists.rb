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
    ALL.fetch(name.to_sym) { "Can't find cultist named #{name}" }
  end

  def self.mod(cultist, attribute)
    by_name(cultist)[attribute.to_sym]
  end
end
