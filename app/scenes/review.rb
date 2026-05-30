require 'lib/draw'
require 'lib/run'
require 'lib/review'

module Scenes
  class Review
    include Draw

    def tick(args)
      draw_background_color(args)

      handle_input(args)
      render(args)
    end

    private

    def handle_input(args)
      continue = args.inputs.keyboard.key_down.enter || args.inputs.keyboard.key_down.space

      return unless continue

      args.state.run = nil
      args.state.next_scene = :title
    end

    def render(args)
      return if args.state.run.nil?
      review = ::Review.build(args.state.run)

      draw_title(args, { x: 640, y: 560, text: 'Guest Review', size_px: 48 })
      draw_title(
        args,
        { x: 640, y: 490, text: review[:star_line], size_px: 40, color: RGB_GREEN }
      )
      draw_title(
        args,
        { x: 640, y: 420, text: "\"#{review[:headline]}\"", size_px: 24, color: RGB_WHITE }
      )
      draw_title(
        args,
        { x: 640, y: 350, text: review[:body], size_px: 20, color: RGB_GRAY }
      )
      draw_title(
        args,
        { x: 640, y: 280, text: review[:meter_text], size_px: 18, color: RGB_DARK_GRAY }
      )

      prompt = 'Press ENTER or SPACE to return to title'
      draw_title(args, { x: 640, y: 80, text: prompt, size_px: 22, color: RGB_DARK_GRAY })
    end
  end
end
