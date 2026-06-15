require 'lib/draw'
require 'lib/animations/payout'
require 'lib/ui/payout_panel'

module Scenes
  class Payout
    include Draw
    include UI::PayoutPanel

    def tick(args)
      @args = args
      draw_background_color(args)

      tick_sfx
      handle_input
      render
    end

    private

    attr_reader :args

    def tick_sfx
      payout = args.state.stay_payout
      return unless payout

      Animations::Payout.tick_sfx!(args, payout)
    end

    def handle_input
      return unless continue_pressed?
      return unless animation_complete?

      Animations::Payout.reset!(args)
      payout = args.state.stay_payout
      args.state.next_scene = payout&.fetch(:just_saved_farm, false) ? :win : :title
      args.state.stay_payout = nil
    end

    def render
      payout = args.state.stay_payout
      return unless payout

      anim = Animations::Payout.snapshot(args, payout)
      render_payout_cashbox(payout, anim: anim)

      prompt = anim[:complete] ? 'Press ENTER or SPACE to continue' : 'Counting the till...'
      draw_title(
        args,
        { x: 640, y: 80, text: prompt, size_px: 22, color: RGB_MUTED }
      )
    end

    def animation_complete?
      payout = args.state.stay_payout
      return true unless payout

      Animations::Payout.snapshot(args, payout)[:complete]
    end

    def continue_pressed?
      args.inputs.keyboard.key_down.enter || args.inputs.keyboard.key_down.space
    end
  end
end
