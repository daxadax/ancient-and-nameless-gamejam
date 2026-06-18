require 'lib/campaign'

module Audio
  MUSIC_KEY = :music
  MUSIC_PATH = 'sounds/headscratcher.ogg'
  COIN_RATTLE_PATH = 'sounds/coins-rattling.mp3'
  COIN_CLINK_PATH = 'sounds/coin-4.mp3'
  COIN_RATTLE_GAIN = 0.72
  COIN_CLINK_GAIN = 0.55
  CLICK_GAIN = 0.28

  STEP = 0.1

  def self.tick!(args)
    gain = music_gain(args)
    track = args.audio[MUSIC_KEY]

    return start_music!(args) if track.nil? && gain.positive?

    return unless track

    track.gain = gain
    stop_music!(args) if gain.zero?
  end

  def self.start_music!(args)
    gain = music_gain(args)
    return if gain.zero?

    args.audio[MUSIC_KEY] = {
      input: MUSIC_PATH,
      looping: true,
      gain: gain
    }
  end

  def self.stop_music!(args)
    args.audio[MUSIC_KEY] = nil
  end

  def self.play_sfx!(args, path)
    gain = sfx_gain(args)
    return if gain.zero?

    args.audio["sfx_#{Kernel.tick_count}".to_sym] = {
      input: path,
      gain: gain
    }
  end

  def self.play_click!(args)
    gain = sfx_gain(args)
    return if gain.zero?

    args.audio["click_#{Kernel.tick_count}".to_sym] = {
      input: COIN_CLINK_PATH,
      gain: gain * CLICK_GAIN,
      pitch: 1.4
    }
  end

  def self.play_coin_rattle!(args)
    gain = sfx_gain(args)
    return if gain.zero?

    args.audio[:coin_rattle] = {
      input: COIN_RATTLE_PATH,
      gain: gain * COIN_RATTLE_GAIN
    }
  end

  def self.play_coin_clink!(args, index: 0)
    gain = sfx_gain(args)
    return if gain.zero?

    path = COIN_CLINK_PATH
    args.audio["coin_clink_#{Kernel.tick_count}_#{index}".to_sym] = {
      input: path,
      gain: gain * COIN_CLINK_GAIN
    }
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
    track.gain = gain
    stop_music!(args) if gain.zero?
  end

  def self.volume_label(volume)
    "#{(volume * 100).round}%"
  end
end
