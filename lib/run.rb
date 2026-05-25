module Run
  DEFAULT_METERS = {
    provisions: 20,
    faith: 10,
    secrecy: 8,
    security: 6
  }.freeze

  DEFAULT_PARTY = [:aldous, :mara, :jules].freeze

  PARTY_SIZE = DEFAULT_PARTY.length

  def self.start!(args)
    args.state.run = {
      day: 1,
      act: :arrival,
      threat: 0,
      meters: duplicate_meters,
      party: default_party,
      flags: {},
      perks: [],
      events_seen: []
    }
    args.state.ui_mode = :hub
    args.state.current_event = nil
    reset_state!(args)
  end

  def self.active?(args)
    !args.state.run.nil?
  end

  def self.advance_day!(args)
    run = args.state.run
    return unless run

    apply_night_drain!(run)
    run.day += 1
    run.act = act_for_day(run.day)
    maybe_tick_threat!(run)
  end

  def self.act_for_day(day)
    return :decision if day >= 15
    return :revelation if day >= 11
    return :tension if day >= 7
    return :discovery if day >= 4

    :arrival
  end

  def self.lose?(args)
    run = args.state.run
    return false unless run

    meters = run.meters
    meters.provisions <= 0 ||
      meters.faith <= 0 ||
      meters.secrecy <= 0 ||
      meters.security <= 0
  end

  def self.duplicate_meters
    {
      provisions: DEFAULT_METERS[:provisions],
      faith: DEFAULT_METERS[:faith],
      secrecy: DEFAULT_METERS[:secrecy],
      security: DEFAULT_METERS[:security]
    }
  end

  def self.default_party
    DEFAULT_PARTY.map do |name|
      { name: name, alive: true }
    end
  end

  def self.apply_night_drain!(run)
    meters = run.meters
    alive_count = run.party.count { |member| member.alive }

    meters.provisions -= alive_count
    meters.faith -= 1
    meters.security -= 1 if run.threat >= 2
  end

  def self.maybe_tick_threat!(run)
    return if run.threat >= 5
    return unless run.day % 3 == 0

    run.threat += 1
  end

  def self.reset_state!(args)
    args.state.secret = nil
    args.state.guessed = nil
    args.state.wrong = nil
    args.state.game_over = nil
    args.state.won = nil
  end
end
