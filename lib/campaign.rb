module Campaign
  # NOTE: Campaign survives title ↔ compound ↔ review loops.
  # Run is one guest stay (days, meters, assignments).
  # Campaign is the player/session layer.

  def self.resume!(args)
    args.state.campaign ||= default_state

    default_state.each do |key, value|
      args.state.campaign[key] = value unless args.state.campaign.key?(key)
    end
  end

  def self.default_state
    {
      intro_seen: false,
      music_volume: 0.6,
      sfx_volume: 0.6
    }
  end

  def self.music_volume(args)
    args.state.campaign.music_volume.to_f.clamp(0.0, 1.0)
  end

  def self.sfx_volume(args)
    args.state.campaign.sfx_volume.to_f.clamp(0.0, 1.0)
  end

  def self.set_music_volume!(args, volume)
    args.state.campaign.music_volume = volume.to_f.clamp(0.0, 1.0)
  end

  def self.set_sfx_volume!(args, volume)
    args.state.campaign.sfx_volume = volume.to_f.clamp(0.0, 1.0)
  end

  def self.intro_seen?(args)
    args.state.campaign.intro_seen
  end

  def self.mark_intro_seen!(args)
    args.state.campaign.intro_seen = true
  end

  def self.entry_scene(args)
    intro_seen?(args) ? :crew_select : :intro
  end
end
