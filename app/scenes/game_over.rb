require 'lib/draw'
require 'lib/run'

module Scenes
  class GameOver
    include Draw

    def tick(args)
      draw_background_color(args)

      handle_input(args)
      render(args)
    end

    private

    def handle_input(args)
      start = args.inputs.keyboard.key_down.enter || args.inputs.keyboard.key_down.space

      return unless start

      Run.start!(args)
      args.state.next_scene = :title
    end

    def render(args)
      run = args.state.run
      meters = run.meters

      draw_title(args, { x: 640, y: 420, text: 'Checkout', size_px: 48 })
      draw_title(
        args,
        {
          x: 640,
          y: 360,
          text: 'The guest leaves a review soon. (Stars coming in a later pass.)',
          size_px: 20,
          color: RGB_DARK_GRAY
        }
      )

      meter_text = "Vibes #{meters.vibes}  Food #{meters.food}  "
      meter_text += "Clean #{meters.cleanliness}  Auth #{meters.authenticity}"
      draw_title(args, { x: 640, y: 300, text: meter_text, size_px: 22, color: RGB_GRAY })

      restart_text = 'Press ENTER or SPACE to return to title'
      draw_title(args, { x: 640, y: 80, text: restart_text, size_px: 22, color: RGB_DARK_GRAY })
    end
  end
end
