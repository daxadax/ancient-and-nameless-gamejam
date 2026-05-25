require 'lib/draw'

module Scenes
  class RitualSpace
    include Draw

    def tick(args)
      @args = args
      draw_background_color(args)

      handle_input
      render
    end

    private
    attr_reader :args

    def handle_input
      args.outputs.sounds << "sounds/drip.wav"
    end

    def render
      args.outputs.sprites << {
        x: 560,
        y: 0,
        w: 720,
        h: 720,
        path: 'sprites/ritual_space.png'
      }
    end
  end
end
