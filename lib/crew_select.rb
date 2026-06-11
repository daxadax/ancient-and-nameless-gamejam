require 'lib/campaign'

module CrewSelect
  def self.reset!(args)
    args.state.crew_select = { focus_index: 0 }
    Campaign.ensure_founding_lineup!(args)
  end

  def self.focus_index(args)
    ensure!(args)
    args.state.crew_select[:focus_index]
  end

  def self.focused_id(args)
    ids = CrewRoster.ids(args)
    ids[focus_index(args)]
  end

  def self.move_focus!(args, delta)
    ids = CrewRoster.ids(args)
    return if ids.empty?

    next_index = (focus_index(args) + delta) % ids.length
    args.state.crew_select[:focus_index] = next_index
  end

  def self.select_focus!(args, index)
    ensure!(args)
    max = CrewRoster.ids(args).length - 1
    args.state.crew_select[:focus_index] = index.clamp(0, max)
  end

  def self.ensure!(args)
    args.state.crew_select ||= { focus_index: 0 }
  end
end
