module EventDeck
  def self.draw(args)
    raise NotImplementedError
    # run = args.state.run
    # events = Events::Cult.all

    # events.select { |x| eligible?(run, x) }.sample
  end

  def self.eligible?(run, event)
    # return false if run.events_seen.include?(event.id)
    # return false if run.act != event.act

    # true
  end
end
