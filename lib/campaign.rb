require 'lib/character'
require 'lib/character_generator'

module Campaign
  # NOTE: Campaign survives title ↔ compound ↔ review loops.
  # Run is one guest stay (days, meters, assignments).
  # Campaign is the player/session layer.

  def self.resume!(args)
    args.state.campaign ||= default_state

    default_state.each do |key, value|
      args.state.campaign[key] = value unless args.state.campaign.key?(key)
    end

    ensure_founding_lineup!(args)
  end

  def self.default_state
    {
      intro_seen: false,
      music_volume: 0.6,
      sfx_volume: 0.6,
      seed: nil,
      stage: 1,
      runs_completed: 0,
      founding_complete: false,
      roster: []
    }
  end

  def self.founding_complete?(args)
    args.state.campaign.founding_complete
  end

  def self.ensure_founding_lineup!(args)
    return if founding_complete?(args)
    return if args.state.campaign.roster.any?

    args.state.campaign.seed ||= rand(1_000_000)
    recruits = CharacterGenerator.generate_recruits(
      args.state.campaign.seed,
      stage: args.state.campaign.stage
    )
    args.state.campaign.roster = [Character.mara.to_h.dup] + recruits
  end

  def self.complete_founding!(args)
    args.state.campaign.founding_complete = true
  end

  def self.roster_data(args)
    args.state.campaign.roster
  end

  def self.roster(args)
    roster_data(args).map { |data| Character.wrap(data) }
  end

  def self.roster_ids(args)
    roster_data(args).map { |data| data['id'] }
  end

  def self.character(args, id)
    data = roster_data(args).find { |entry| entry['id'] == id.to_s }
    Character.wrap(data) if data
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
    return :intro unless intro_seen?(args)
    return :compound if founding_complete?(args)

    :crew_select
  end
end
