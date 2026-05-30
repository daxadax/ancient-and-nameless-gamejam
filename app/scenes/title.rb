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
      draw_background_color(args)

      draw_title(args, { x: 640, y: 420, text: TITLE, size_px: 56, color: RGB_INK })
      draw_title(args, { x: 640, y: 360, text: SUBTITLE, size_px: 36, color: RGB_MUTED })

      start_text = 'Press ENTER or SPACE to begin'
      draw_title(args, { x: 640, y: 80, text: start_text, size_px: 22, color: RGB_MUTED })
    end
  end
end
