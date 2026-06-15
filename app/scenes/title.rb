require 'lib/campaign'
require 'lib/draw'
require 'lib/ui'
require 'lib/animations/crystal_glow'

module Scenes
  class Title
    include Draw
    include UI

    TITLE = 'Culty Towers'
    SUBTITLE = 'A struggling-cult-in-the-platform-economy simulator'

    def tick(args)
      @args = args

      handle_input
      render
    end

    private
    attr_reader :args

    def handle_input
      return if settings_open?(args)

      start = args.inputs.keyboard.key_down.enter || args.inputs.keyboard.key_down.space
      return unless start

      args.state.next_scene = Campaign.entry_scene(args)
    end

    def render
      if settings_open?(args)
        draw_background_color(args)
      else
        draw_title_background(args)

        draw_glowing_title(args, { x: 666, y: 666, text: TITLE, size_px: 56, color: RGB_CREAM })

        draw_title(
          args,
          { x: 516, y: 625, text: SUBTITLE, size_px: 24, color: RGB_DARK_BROWN, anchor_x: 0 }
        )

        draw_debt_free_msg(args) if Campaign.farm_note_paid?(args)

        draw_glowing_title(
          args,
          { x: 640, y: 50, text: 'Press ENTER or SPACE to begin', size_px: 22, color: RGB_CREAM },
          glow_alpha: 100
        )
      end

      draw_settings
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
        a: 50,
        primitive_marker: :solid
      }.merge(RGB_BEIGE)

      Animations::CrystalGlow.render(args)
    end

    def draw_debt_free_msg(args)
      draw_glowing_title(
        args,
        { x: 20, y: 0 + 45, text: 'You\'re debt free! ...currently.', size_px: 24, color: RGB_CREAM, anchor_x: 0 }
      )

      line = "You've got #{Campaign.credits(args)} quid stuffed under the mattress"
      draw_glowing_title(
        args,
        { x: 20, y: 0 + 20, text: line, size_px: 20, color: RGB_CREAM, anchor_x: 0 }
      )
    end
  end
end
