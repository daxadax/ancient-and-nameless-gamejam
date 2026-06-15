require 'lib/characters/character'
require 'lib/characters/crew_rolls'
require 'lib/stay/stations'
require 'lib/outcomes/resolve_outcomes'
require 'lib/stay/run'

module Resolve
  def self.valid_assignments?(assignments, crew_ids)
    return false unless assignments
    return false unless assignments.keys.sort == Stations::IDS.sort

    assigned = assignments.values
    return false unless assigned.uniq.length == assigned.length
    return false unless assigned.all? { |id| crew_ids.include?(id.to_s) }

    true
  end

  def self.run!(run)
    return nil unless valid_assignments?(run.assignments, Run.crew_ids(run))

    results = []

    Stations::IDS.each do |station_id|
      character_id = run.assignments[station_id]
      result = resolve_station!(run, station_id, character_id)
      results << result
    end

    run.last_resolve = results
    results
  end

  def self.resolve_station!(run, station_id, character_id)
    character = Run.character(run, character_id)
    station = Stations::ALL.fetch(station_id)
    primary = roll_line(character, station[:primary_meter], station[:primary_die])
    secondary = roll_line(character, station[:secondary_meter], station[:secondary_die])

    add_meter!(run, primary[:meter], primary[:total])
    add_meter!(run, secondary[:meter], secondary[:total])
    CrewRolls.record!(run, character_id, primary[:total])

    outcome = ResolveOutcomes.pick(character, station_id, primary[:total])
    ResolveOutcomes.apply_outcome!(run, outcome, character.display_name)

    {
      station: station_id,
      station_label: Stations.label(station_id),
      cultist: character_id,
      cultist_label: character.display_name,
      primary: primary,
      secondary: secondary,
      narrative: outcome['text'],
      mara: outcome['mara'],
      effects: outcome['effects'] || {},
      station_meters: station_meters(primary, secondary)
    }
  end

  def self.station_meters(primary, secondary)
    {
      primary[:meter] => primary[:total],
      secondary[:meter] => secondary[:total]
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

  def self.roll_line(character, meter, sides)
    roll = roll_die(sides)
    mod = character.mod(meter)
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
