module EventResolver
  METER_KEYS = [:provisions, :faith, :secrecy, :security].freeze

  def self.apply_choice!(args, choice_key)
    event = args.state.current_event
    return unless event

    choice = event.choices[choice_key]
    return unless choice

    run = args.state.run
    apply_effects!(run, choice)
    run.events_seen << event.id

    args.state.current_event = nil
    args.state.ui_mode = :hub
  end

  def self.apply_effects!(run, choice)
    METER_KEYS.each do |key|
      delta = choice[key]
      next unless delta

      run.meters[key] += delta
    end

    if choice.threat
      run.threat += choice.threat
      run.threat = 0 if run.threat < 0
      run.threat = 5 if run.threat > 5
    end

    return unless choice.flags

    choice.flags.each do |flag_key, value|
      run.flags[flag_key] = value
    end
  end
end
