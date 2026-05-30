require 'lib/draw'
require 'lib/run'

module Scenes
  class Title
    include Draw

    TITLE = 'Culty Towers'
    SUBTITLE = 'A gig-economy cult experience'

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

      draw_title(args, { x: 640, y: 420, text: TITLE, size_px: 56, color: RGB_CREAM })
      draw_title(args, { x: 640, y: 360, text: SUBTITLE, size_px: 36, color: RGB_PANEL_MUTED })

      start_text = 'Press ENTER or SPACE to begin'
      draw_title(args, { x: 640, y: 80, text: start_text, size_px: 22, color: RGB_CREAM })
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
        a: 90,
        primitive_marker: :solid
      }
    end
  end
end
