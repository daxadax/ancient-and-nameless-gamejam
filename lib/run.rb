require 'lib/resolve'

module Run
  MAX_DAYS = 3

  def self.start!(args)
    reset_state!(args)

    args.state.run = {
      day: 1,
      max_days: MAX_DAYS,
      phase: :assign,
      meters: Resolve.default_meters,
      assignments: {},
      last_resolve: nil
    }
  end

  def self.active?(args)
    !args.state.run.nil?
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

  def self.lose?(_args)
    false
  end

  def self.reset_state!(args)
    args.state.ui_mode = nil
    args.state.current_event = nil
    args.state.next_scene = nil
    args.state.won = nil
    args.state.game_over = nil
  end
end
