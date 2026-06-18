require 'lib/campaign'

module Audio
  MUSIC_KEY = :music
  MUSIC_PATH = 'sounds/headscratcher.ogg'
  COIN_RATTLE_PATH = 'sounds/coins-rattling.ogg'
  COIN_CLINK_PATH = 'sounds/coin-4.ogg'
  COIN_RATTLE_GAIN = 0.72
  COIN_CLINK_GAIN = 0.55
  CLICK_GAIN = 0.35

  STEP = 0.1

  def self.tick!(args)
    unlock_web_audio!(args)

    gain = music_gain(args)
    track = args.audio[MUSIC_KEY]

    return start_music!(args) if track.nil? && gain.positive? && web_audio_ready?(args)

    return unless track

    track.gain = gain.to_f
    stop_music!(args) if gain.zero?
  end

  def self.start_music!(args)
    gain = music_gain(args)
    return if gain.zero?
    return unless web_audio_ready?(args)

    args.audio[MUSIC_KEY] = {
      input: MUSIC_PATH,
      looping: true,
      gain: gain.to_f
    }
  end

  def self.stop_music!(args)
    args.audio[MUSIC_KEY] = nil
  end

  def self.play_click!(args)
    play_one_shot!(args, COIN_CLINK_PATH, gain: CLICK_GAIN)
  end

  def self.play_coin_rattle!(args)
    play_one_shot!(args, COIN_RATTLE_PATH, gain: COIN_RATTLE_GAIN)
  end

  def self.play_coin_clink!(args, index: 0)
    play_one_shot!(args, COIN_CLINK_PATH, gain: COIN_CLINK_GAIN)
  end

  def self.preview_sfx!(args)
    play_click!(args)
  end

  def self.music_gain(args)
    Campaign.music_volume(args).to_f
  end

  def self.sfx_gain(args)
    Campaign.sfx_volume(args).to_f
  end

  def self.adjust_music!(args, delta)
    Campaign.set_music_volume!(args, Campaign.music_volume(args) + delta)
    sync_music_gain!(args)
  end

  def self.adjust_sfx!(args, delta)
    Campaign.set_sfx_volume!(args, Campaign.sfx_volume(args) + delta)
    preview_sfx!(args) if delta.positive?
  end

  def self.sync_music_gain!(args)
    track = args.audio[MUSIC_KEY]
    return start_music!(args) unless track

    gain = music_gain(args)
    track.gain = gain.to_f
    stop_music!(args) if gain.zero?
  end

  def self.volume_label(volume)
    "#{(volume * 100).round}%"
  end

  def self.web_audio_ready?(args)
    return true unless $gtk.platform?(:web)

    args.state.web_audio_ready
  end

  def self.unlock_web_audio!(args)
    return if web_audio_ready?(args)
    return unless web_user_input?(args)

    args.state.web_audio_ready = true
    start_music!(args) if args.audio[MUSIC_KEY].nil? && music_gain(args).positive?
  end

  def self.web_user_input?(args)
    inputs = args.inputs
    return true if inputs.mouse.up || inputs.mouse.down

    inputs.keyboard.key_down.truthy_keys.any?
  end

  def self.play_one_shot!(args, path, gain:)
    level = sfx_gain(args)
    return if level.zero?

    args.outputs.sounds << {
      path: path,
      gain: (level * gain).to_f
    }
  end
end
