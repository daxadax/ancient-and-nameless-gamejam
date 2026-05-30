require 'lib/draw'
require 'lib/run'
require 'lib/crystal_glow'

module Scenes
  class Title
    include Draw

    TITLE = 'Culty Towers'
    SUBTITLE = 'A cult experience simulator'

    def tick(args)
      @args = args

      handle_input
      render
    end

    private
    attr_reader :args

    def handle_input
      start = args.inputs.keyboard.key_down.enter || args.inputs.keyboard.key_down.space

      return unless start

      Run.start!(args)
      args.state.next_scene = :compound
    end

    def render
      draw_title_background(args)

      draw_glowing_title(args, { x: 666, y: 666, text: TITLE, size_px: 56, color: RGB_CREAM })

      draw_glowing_title(
        args,
        { x: 735, y: 620, text: SUBTITLE, size_px: 36, color: RGB_CREAM },
        glow_alpha: 120
      )

      start_text = 'Press ENTER or SPACE to begin'
      draw_glowing_title(
        args,
        { x: 640, y: 50, text: start_text, size_px: 22, color: RGB_CREAM },
        glow_alpha: 100
      )
    end

    def draw_title_background(args)
      args.outputs.sprites << {
        x: 0,
        y: 0,
        w: 1280,
        h: 720,
        path: 'sprites/compound.jpg'
      }

      args.outputs.primitives << {
        x: 0,
        y: 0,
        w: 1280,
        h: 720,
        r: 212,
        g: 198,
        b: 175,
        a: 50,
        primitive_marker: :solid
      }

      CrystalGlow.render(args)
    end
  end
end
