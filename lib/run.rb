require 'lib/resolve'

module Run
  MAX_DAYS = 3

  def self.start!(args)
    args.state.run = {
      day: 1,
      max_days: MAX_DAYS,
      phase: :assign,
      meters: Resolve.default_meters,
      assignments: {},
      last_resolve: nil
    }
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
    run.assignments = {}
    run.last_resolve = nil
    run.phase = :assign
  end

  def self.last_day?(run)
    run.day >= run.max_days
  end
end
