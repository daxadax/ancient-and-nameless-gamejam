require 'lib/draw'

module Scenes
  class Title
    include Draw

    TITLE = 'Ancient & Nameless'
    SUBTITLE = 'A Hangman Roguelite Cultist Simulator'

    def tick(args)
      @args = args

      handle_input
      render
    end

    private
    attr_reader :args

    def render
      draw_background_color(args)

      draw_label(args, { x: 640, y: 420, text: TITLE, size_px: 56 })
      draw_label(args, { x: 640, y: 360, text: SUBTITLE, size_px: 36 }, color: RGB_DARK_GRAY)

      start_text = 'Press ENTER or SPACE to begin'
      draw_label(args, { x: 640, y: 80, text: start_text, size_px: 22 }, color: RGB_DARK_GRAY)
    end

    def handle_input
      start = args.inputs.keyboard.key_down.enter || args.inputs.keyboard.key_down.space

      return unless start
      args.state.next_scene = :gameplay
    end
  end
end
