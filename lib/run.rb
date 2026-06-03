require 'lib/cultists'

module Run
  MAX_DAYS = 3

  def self.start!(args)
    args.state.run = {
      day: 1,
      max_days: MAX_DAYS,
      phase: :assign,
      meters: default_meters,
      assignments: {},
      last_resolve: nil,
      flags: {}
    }
    capture_day_meter_baseline!(args.state.run)
    args.state.next_scene = nil
  end

  def self.active?(args)
    !args.state.run.nil?
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
    run.flags = {}
    run.phase = :assign
  end

  def self.capture_day_meter_baseline!(run)
    run.meters_at_day_start = meter_snapshot(run)
  end

  def self.meter_snapshot(run)
    Cultists::METER_KEYS.to_h { |meter| [meter, run.meters.send(meter).to_i] }
  end

  def self.default_meters
    @default_meters ||= Cultists::METER_KEYS.map { |x| [x, 0] }.to_h
  end

  def self.last_day?(run)
    run.day >= run.max_days
  end
end
