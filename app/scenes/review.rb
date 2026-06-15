require 'lib/helpers/draw'
require 'lib/campaign'
require 'lib/stay/run'
require 'lib/review'

module Scenes
  class Review
    include Draw

    TEXT_WIDTH = 85

    def tick(args)
      draw_background_color(args)

      handle_input(args)
      render(args)
    end

    private

    def handle_input(args)
      continue = args.inputs.keyboard.key_down.enter || args.inputs.keyboard.key_down.space

      return unless continue

      args.state.next_scene = :payout
    end

    def render(args)
      return if args.state.run.nil?
      review = ::Review.build(args.state.run)

      y = 540
      draw_title(args, { x: 640, y: y, text: 'Guest Review', size_px: 48, color: RGB_INK })

      y -= 60
      draw_title(
        args,
        { x: 640, y: y, text: review[:star_line], size_px: 40, color: RGB_GOLD }
      )

      y -= 60
      draw_title(
        args,
        { x: 640, y: y, text: review[:headline], size_px: 24, color: RGB_INK }
      )

      y -= 40
      wrap_text(build_review_text(review), TEXT_WIDTH).each do |line|
        draw_title(
          args,
          { x: 640, y: y, text: line, size_px: 24, color: RGB_INK }
        )
        y -= 35
      end

      draw_title(
        args,
        { x: 640, y: y, text: review[:meter_text], size_px: 18, color: RGB_MUTED }
      )

      prompt = 'Press ENTER or SPACE to continue'
      draw_title(args, { x: 640, y: 80, text: prompt, size_px: 22, color: RGB_MUTED })
    end

    def build_review_text(review)
      text = review[:body] + ' '
      text += review[:callbacks].join(' ') + ' ' if review[:callbacks].any?
      text += review[:crew_high] + ' ' if review[:crew_high]
      text += review[:crew_low] + ' ' if review[:crew_low]

      text
    end
  end
end
