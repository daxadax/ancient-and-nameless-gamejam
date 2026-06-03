module Campaign
  # NOTE: Campaign survives title ↔ compound ↔ review loops.
  # Run is one guest stay (days, meters, assignments).
  # Campaign is the player/session layer.

  def self.resume!(args)
    args.state.campaign ||= default_state
  end

  def self.default_state
    {
      intro_seen: false
    }
  end

  def self.intro_seen?(args)
    args.state.campaign.intro_seen
  end

  def self.mark_intro_seen!(args)
    args.state.campaign.intro_seen = true
  end

  def self.entry_scene(args)
    intro_seen?(args) ? :compound : :intro
  end
end
