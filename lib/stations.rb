# Station definitions for daily assignment resolve.
module Stations
  ALL = {
    tour_guide: {
      primary_meter: :vibes,
      primary_die: 10,
      secondary_meter: :authenticity,
      secondary_die: 6
    },
    kitchen: {
      primary_meter: :food,
      primary_die: 10,
      secondary_meter: :cleanliness,
      secondary_die: 6
    },
    housekeeping: {
      primary_meter: :cleanliness,
      primary_die: 10,
      secondary_meter: :vibes,
      secondary_die: 6
    },
    ritual: {
      primary_meter: :authenticity,
      primary_die: 10,
      secondary_meter: :vibes,
      secondary_die: 6
    }
  }.freeze

  IDS = ALL.keys.freeze

  def self.by_name(name)
    ALL.fetch(name.to_sym) { "Can't find station named #{name}" }
  end
end
