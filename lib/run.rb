require 'lib/character'
require 'lib/campaign'
require 'lib/crew_rolls'

module Run
  MAX_DAYS = 3

  def self.start!(args)
    crew = Campaign.roster_data(args).map(&:dup)

    args.state.run = {
      day: 1,
      max_days: MAX_DAYS,
      phase: :assign,
      meters: default_meters,
      assignments: {},
      last_resolve: nil,
      resolve_step: 0,
      day_report: nil,
      flags: {},
      stay_flags: {},
      mara_asides: [],
      review_callbacks: [],
      used_evening_beat_ids: [],
      crew: crew,
      crew_rolls: CrewRolls.default_stats(crew)
    }
    capture_day_meter_baseline!(args.state.run)
  end

  def self.active?(args)
    !args.state.run.nil?
  end

  def self.crew(run)
    run.crew.map { |data| Character.wrap(data) }
  end

  def self.character(run, id)
    data = run.crew.find { |entry| entry['id'] == id.to_s }
    Character.wrap(data) if data
  end

  def self.crew_ids(run)
    run.crew.map { |entry| entry['id'] }
  end

  def self.end_day!(args)
    run = args.state.run
    return unless run

    if last_day?(run)
      args.state.next_scene = :review
      return
    end

    advance_day!(args)
  end

  def self.advance_day!(args)
    run = args.state.run
    return unless run
    return if run.day >= run.max_days

    run.day += 1
    reset_daily!(run)
  end

  def self.reset_daily!(run)
    capture_day_meter_baseline!(run)
    run.assignments = {}
    run.last_resolve = nil
    run.resolve_step = 0
    run.day_report = nil
    run.flags = {}
    run.mara_asides = []
    run.phase = :assign
  end

  def self.capture_day_meter_baseline!(run)
    run.meters_at_day_start = meter_snapshot(run)
  end

  def self.meter_snapshot(run)
    Character::METER_KEYS.to_h { |meter| [meter, run.meters.send(meter).to_i] }
  end

  def self.last_day?(run)
    run.day >= run.max_days
  end

  def self.default_meters
    @default_meters ||= Character::METER_KEYS.map { |x| [x, 0] }.to_h
  end
end
