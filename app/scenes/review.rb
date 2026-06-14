require 'lib/campaign'
require 'lib/draw'
require 'lib/run'
require 'lib/review'

module Scenes
  class Review
    include Draw

    TEXT_WIDTH = 100

    def tick(args)
      draw_background_color(args)

      handle_input(args)
      render(args)
    end

    private

    def handle_input(args)
      continue = args.inputs.keyboard.key_down.enter || args.inputs.keyboard.key_down.space

      return unless continue

      # NOTE: later: moves to payout screen
      # for now: applies credits + runs_completed
      Campaign.complete_run!(args, args.state.run)
      args.state.run = nil
      args.state.next_scene = :title
    end

    def render(args)
      return if args.state.run.nil?
      review = ::Review.build(args.state.run)

      y = 600
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
      wrap_text(review[:body], TEXT_WIDTH).each do |line|
        draw_title(
          args,
          { x: 640, y: y, text: line, size_px: 24, color: RGB_INK }
        )
        y -= 40
      end

      if review[:callbacks].any?
        review[:callbacks].each do |callback|
          wrap_text(callback, TEXT_WIDTH).each do |line|
            draw_title(args, { x: 640, y: y, text: line, size_px: 24, color: RGB_INK })
            y -= 40
          end
        end
      end

      if review[:crew_high]
        wrap_text(review[:crew_high], TEXT_WIDTH).each do |line|
          draw_title(args, { x: 640, y: y, text: line, size_px: 24, color: RGB_INK })
          y -= 40
        end
      end

      if review[:crew_low]
        draw_title(args, { x: 640, y: y, text: review[:crew_low], size_px: 24, color: RGB_INK })
        y -= 40
      end

      draw_title(
        args,
        { x: 640, y: y, text: review[:meter_text], size_px: 18, color: RGB_MUTED }
      )

      prompt = 'Press ENTER or SPACE to continue'
      draw_title(args, { x: 640, y: 80, text: prompt, size_px: 22, color: RGB_MUTED })
    end
  end
end
