require 'lib/draw'
require 'lib/ui/payout_panel'

module Scenes
  class Payout
    include Draw
    include UI::PayoutPanel

    def tick(args)
      @args = args
      draw_background_color(args)

      handle_input
      render
    end

    private

    attr_reader :args

    def handle_input
      return unless continue_pressed?

      args.state.stay_payout = nil
      args.state.next_scene = :title
    end

    def render
      payout = args.state.stay_payout
      return unless payout

      render_payout_cashbox(payout)

      draw_title(
        args,
        { x: 640, y: 80, text: 'Press ENTER or SPACE to continue', size_px: 22, color: RGB_MUTED }
      )
    end

    def continue_pressed?
      args.inputs.keyboard.key_down.enter || args.inputs.keyboard.key_down.space
    end
  end
end
