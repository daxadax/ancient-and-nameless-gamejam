require 'lib/characters/character'
require 'lib/characters/character_generator'
require 'lib/economy'
require 'lib/stay_payout'

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
      credits: 0,
      farm_note_paid: false,
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

  def self.complete_run!(args, run)
    jitter_seed = args.state.campaign.runs_completed.to_i
    payout = StayPayout.for_run(run, jitter_seed: jitter_seed)
    credits_before = credits(args)
    was_paid = farm_note_paid?(args)

    args.state.campaign.runs_completed += 1
    args.state.campaign.credits = credits_before + payout[:total]

    now_saved = farm_saved?(args)
    just_saved_farm = !was_paid && now_saved
    args.state.campaign.farm_note_paid = true if now_saved

    payout.merge(
      credits_before: credits_before,
      credits_after: credits(args),
      farm_save_goal: Economy.farm_save_goal,
      farm_saved: now_saved,
      just_saved_farm: just_saved_farm
    )
  end

  def self.credits(args)
    args.state.campaign.credits.to_i
  end

  def self.farm_saved?(args)
    credits(args) >= Economy.farm_save_goal
  end

  def self.farm_note_paid?(args)
    args.state.campaign.farm_note_paid == true
  end

  def self.runs_completed(args)
    args.state.campaign.runs_completed.to_i
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
