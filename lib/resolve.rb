require 'lib/cultists'
require 'lib/stations'

module Resolve
  def self.default_meters
    Cultists::METER_KEYS.map { |x| [x, 0] }.to_h
  end

  def self.valid_assignments?(assignments)
    return false unless assignments
    return false unless assignments.keys.sort == Stations::IDS.sort

    cultist_ids = assignments.values
    return false unless cultist_ids.uniq.length == cultist_ids.length
    return false unless cultist_ids.all? { |id| Cultists::IDS.include?(id) }

    true
  end

  def self.run!(run)
    return nil unless valid_assignments?(run.assignments)

    results = []

    Stations::IDS.each do |station_id|
      result = resolve_station!(run, station_id, run.assignments[station_id])
      results << result
    end

    run.last_resolve = results
    results
  end

  def self.resolve_station!(run, station_id, cultist_id)
    station = Stations::ALL.fetch(station_id)
    primary = roll_line(cultist_id, station[:primary_meter], station[:primary_die])
    secondary = roll_line(cultist_id, station[:secondary_meter], station[:secondary_die])

    add_meter!(run, primary[:meter], primary[:total])
    add_meter!(run, secondary[:meter], secondary[:total])

    {
      station: station_id,
      station_label: Stations.label(station_id),
      cultist: cultist_id,
      cultist_label: Cultists.label(cultist_id),
      primary: primary,
      secondary: secondary
    }
  end

  def self.add_meter!(run, meter, delta)
    case meter
    when :vibes
      run.meters.vibes += delta
    when :food
      run.meters.food += delta
    when :cleanliness
      run.meters.cleanliness += delta
    when :authenticity
      run.meters.authenticity += delta
    end
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
