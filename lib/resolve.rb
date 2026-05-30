require 'lib/cultists'
require 'lib/stations'

module Resolve
  def self.default_meters
    {
      vibes: 0,
      food: 0,
      cleanliness: 0,
      authenticity: 0
    }
  end

  def self.valid_assignments?(assignments)
    return false unless assignments.is_a?(Hash)
    return false unless assignments.keys.sort == Stations::IDS.sort

    cultist_ids = assignments.values
    return false unless cultist_ids.uniq.length == cultist_ids.length
    return false unless cultist_ids.all? { |id| Cultists::IDS.include?(id) }

    true
  end

  def self.run!(run)
    assignments = run[:assignments]
    return nil unless valid_assignments?(assignments)

    run[:meters] ||= default_meters
    results = []

    Stations::IDS.each do |station_id|
      result = resolve_station!(run, station_id, assignments[station_id])
      results << result
    end

    run[:last_resolve] = results
    results
  end

  def self.resolve_station!(run, station_id, cultist_id)
    station = Stations::ALL.fetch(station_id)
    primary = roll_line(cultist_id, station[:primary_meter], station[:primary_die])
    secondary = roll_line(cultist_id, station[:secondary_meter], station[:secondary_die])

    run[:meters][primary[:meter]] += primary[:total]
    run[:meters][secondary[:meter]] += secondary[:total]

    {
      station: station_id,
      station_label: station_id.to_s.split('_').map(&:capitalize).join(' '),
      cultist: cultist_id,
      cultist_label: cultist_id.to_s.capitalize,
      primary: primary,
      secondary: secondary
    }
  end

  def self.roll_line(cultist_id, meter, sides)
    roll = roll_die(sides)
    mod = Cultists.mod(cultist_id, meter)
    total = roll + mod

    {
      meter: meter,
      die: sides,
      roll: roll,
      mod: mod,
      total: total
    }
  end

  def self.roll_die(sides)
    1 + rand(sides)
  end
end
