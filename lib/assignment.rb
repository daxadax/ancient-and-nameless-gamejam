require 'lib/resolve'
require 'lib/run'
require 'lib/stations'

module Assignment
  def self.read(run, station_id)
    run.assignments[station_id]
  end

  def self.pick!(run, station_id, cultist_id)
    Stations::IDS.each do |sid|
      next if sid == station_id
      next unless read(run, sid) == cultist_id

      run.assignments[sid] = nil
    end

    run.assignments[station_id] = cultist_id
  end

  def self.confirm!(run)
    return false unless Resolve.valid_assignments?(run.assignments, Run.crew_ids(run))

    Run.capture_day_meter_baseline!(run)
    Resolve.run!(run)
    run.phase = :resolve
    true
  end
end
