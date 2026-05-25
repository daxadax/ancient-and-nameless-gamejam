require 'lib/run'
require 'lib/event_deck'

module DayCycle
  def self.end_day!(args)
    Run.advance_day!(args)

    event = EventDeck.draw(args)
    if event
      args.state.current_event = event
      args.state.ui_mode = :event
    else
      args.state.current_event = nil
      args.state.ui_mode = :hub
    end
  end
end
