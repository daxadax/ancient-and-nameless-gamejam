require 'lib/helpers/audio'

module Animations
  module Payout
    DELAY = 40
    DURATION = 180
    FLOATER_DURATION = 180
    MIN_CLINKS = 10
    MAX_CLINKS = 24
    CREDITS_PER_CLINK = 10

    def self.start!(args)
      args.state.payout_anim = {
        started_at: args.state.tick_count,
        rattle_played: false,
        clinks_played: 0,
        clink_schedule: nil
      }
    end

    def self.reset!(args)
      args.state.payout_anim = nil
    end

    def self.tick_sfx!(args, payout)
      return unless args.state.payout_anim
      return unless clinkable?(payout)

      elapsed = args.state.tick_count - args.state.payout_anim[:started_at]
      anim_elapsed = elapsed - DELAY
      return if anim_elapsed.negative?

      anim = args.state.payout_anim
      unless anim[:rattle_played]
        Audio.play_coin_rattle!(args)
        anim[:rattle_played] = true
        anim[:clink_schedule] = clink_schedule(payout)
      end

      schedule = anim[:clink_schedule] || []
      played = anim[:clinks_played] || 0

      while played < schedule.length && anim_elapsed >= schedule[played]
        Audio.play_coin_clink!(args, index: played)
        played += 1
      end

      anim[:clinks_played] = played
    end

    def self.clinkable?(payout)
      payout[:total].positive? && credit_delta(payout).positive?
    end

    def self.clink_count(payout)
      [(payout[:total] / CREDITS_PER_CLINK.to_f).ceil, MIN_CLINKS].max.clamp(MIN_CLINKS, MAX_CLINKS)
    end

    def self.clink_schedule(payout)
      count = clink_count(payout)

      (0...count).map do |index|
        fraction = ((index + 1.0) / (count + 1))**0.9
        (DURATION * fraction).to_i
      end
    end

    def self.snapshot(args, payout)
      return static_snapshot(payout) unless args.state.payout_anim

      elapsed = args.state.tick_count - args.state.payout_anim[:started_at]
      anim_elapsed = [elapsed - DELAY, 0].max
      t = progress_for(payout, anim_elapsed)
      eased = ease_out(t)

      {
        t: t,
        in_delay: in_delay?(elapsed),
        complete: complete?(payout, elapsed),
        credits: lerp(payout[:credits_before], payout[:credits_after], eased).round,
        bar_ratio: bar_ratio(payout, eased),
        floater: floater_state(payout, anim_elapsed, t)
      }
    end

    def self.in_delay?(elapsed)
      elapsed < DELAY
    end

    def self.complete?(payout, elapsed)
      return true if credit_delta(payout).zero?

      elapsed >= DELAY + DURATION
    end

    def self.progress_for(payout, anim_elapsed)
      return 1.0 if credit_delta(payout).zero?

      (anim_elapsed.to_f / DURATION).clamp(0.0, 1.0)
    end

    def self.static_snapshot(payout)
      {
        t: 1.0,
        complete: true,
        credits: payout[:credits_after],
        bar_ratio: bar_ratio(payout, 1.0),
        floater: nil
      }
    end

    def self.credit_delta(payout)
      payout[:credits_after] - payout[:credits_before]
    end

    def self.bar_ratio(payout, eased)
      goal = payout[:farm_save_goal]
      return 0.0 unless goal.positive?

      before = payout[:credits_before].to_f / goal
      after = payout[:credits_after].to_f / goal
      (before + (after - before) * eased).clamp(0.0, 1.0)
    end

    def self.floater_state(payout, anim_elapsed, t)
      amount = payout[:total]
      return nil if amount.zero?
      return nil if anim_elapsed >= FLOATER_DURATION || t >= 1.0

      float_t = (anim_elapsed.to_f / FLOATER_DURATION).clamp(0.0, 1.0)
      {
        text: format_floater(amount),
        y_offset: (float_t * 48).to_i,
        alpha: ((1.0 - float_t) * 255).to_i
      }
    end

    def self.format_floater(amount)
      sign = amount.negative? ? '-' : '+'
      "#{sign}#{amount.abs}"
    end

    def self.ease_out(t)
      1.0 - (1.0 - t)**3
    end

    def self.lerp(from, to, t)
      from + (to - from) * t
    end
  end
end
