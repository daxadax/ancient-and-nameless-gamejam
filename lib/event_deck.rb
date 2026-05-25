require 'data/events/cult'

module EventDeck
  def self.draw(args)
    run = args.state.run

    pool = Events::Cult.all.select { |event| eligible?(run, event) }
    pool = Events::Cult.all if pool.empty?

    pool.sample
  end

  def self.eligible?(run, event)
    return false if run.events_seen.include?(event.id)

    # TODO: later
    # act = event.act
    # return false if act && run.act != act

    # min_threat = event.min_threat || 0
    # run.threat >= min_threat
  end
end
