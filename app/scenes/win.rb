require 'lib/helpers/buttons'
require 'lib/helpers/draw'
require 'lib/campaign'
require 'lib/ui'

module Scenes
  class Win
    include Draw
    include Buttons
    include UI

    TEXT_WIDTH = 72
    KEEP_PLAYING_BTN = { x: 520, y: 120, w: 240, h: 44 }

    def tick(args)
      @args = args
      draw_background_color(args)

      handle_input
      render
    end

    private

    attr_reader :args

    def handle_input
      return if settings_open?(args)

      continue = continue_pressed? || clicked_button?(args, KEEP_PLAYING_BTN)
      return unless continue

      args.state.next_scene = :title
    end

    def render
      y = 620
      draw_title(args, { x: 640, y: y, text: 'You\'re (currently) debt free!', size_px: 48, color: RGB_GOLD })

      y -= 70
      wrap_text(body_copy, TEXT_WIDTH).each do |line|
        draw_title(args, { x: 640, y: y, text: line, size_px: 24, color: RGB_INK })
        y -= 36
      end

      y -= 20
      draw_title(
        args,
        {
          x: 640,
          y: y,
          text: "#{Campaign.credits(args)} quid in the hidden safe.",
          size_px: 22,
          color: RGB_MUTED
        }
      )

      draw_button(args, label: 'Keep playing?', area: KEEP_PLAYING_BTN)

      draw_title(
        args,
        { x: 640, y: 70, text: 'Press ENTER or SPACE to continue', size_px: 20, color: RGB_MUTED }
      )
    end

    def body_copy
      <<~TEXT.strip
        The county stops sending letters. Mara is very mildly less tense, which is a huge deal.
        You could stop here. The guest calendar has more booking requests though...
      TEXT
    end

    def continue_pressed?
      args.inputs.keyboard.key_down.enter || args.inputs.keyboard.key_down.space
    end
  end
end
