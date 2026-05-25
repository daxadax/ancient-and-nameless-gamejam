require 'lib/draw'

module Scenes
  class GameOver
    include Draw

    def tick(args)
      draw_background_color(args)

      # TODO: handle play again or meta-progression
      # this is likely not game over but it's a reasonable placeholder for now
      text = 'Game over!'
      draw_title(args, { x: 640, y: 360, text: text, size_px: 36, color: RGB_RED })
    end
  end
end
