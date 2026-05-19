require 'lib/draw'

module Scenes
  class GameOver
    include Draw

    def tick(args)
      draw_background_color(args)

      if args.state.won
        text = 'You win!'
        draw_label(args, { x: 640, y: 360, text: text, size_px: 36 }, color: COLOR_GREEN)
      else
        text = "You lose! I am ancient & nameless!"
        draw_label(args, { x: 640, y: 360, text: text, size_px: 36 }, color: COLOR_RED)
      end

      # TODO: handle play again or meta-progression
    end
  end
end
