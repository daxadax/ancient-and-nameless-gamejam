require 'lib/helpers/draw'
require 'lib/helpers/buttons'
require 'lib/helpers/tooltip'
require 'lib/campaign'
require 'lib/ui'
require 'lib/animations/crystal_glow'

module Scenes
  class Title
    include Draw
    include Buttons
    include Tooltip
    include UI

    TITLE = 'Culty Towers'
    SUBTITLE = 'A struggling-cult-in-the-platform-economy simulator'

    NEW_GAME_TOOLTIP = 'Start a new run with a randomly generated crew'.freeze
    CONTINUE_TOOLTIP = 'Prepare for the next stay with your current crew'.freeze

    BUTTON = { w: 220, h: 64 }.freeze
    CONTINUE_BUTTON = { x: 1000, y: 375, w: BUTTON[:w], h: BUTTON[:h] }.freeze
    NEW_GAME_BUTTON = { x: 1000, y: 300, w: BUTTON[:w], h: BUTTON[:h] }.freeze
    CREDITS_BUTTON = { x: 1000, y: 225, w: BUTTON[:w], h: BUTTON[:h] }.freeze

    def tick(args)
      @args = args

      handle_input
      render
    end

    private

    attr_reader :args

    def handle_input
      return if settings_open?(args)
      return if credits_open?(args)

      if clicked_button?(args, CREDITS_BUTTON)
        open_credits!(args)
        return
      end

      if clicked_button?(args, NEW_GAME_BUTTON)
        start_new_game
        return
      end

      return unless Campaign.continue_available?(args)
      return unless clicked_button?(args, CONTINUE_BUTTON)

      continue_game
    end

    def start_new_game
      Campaign.start_new_game!(args)
      args.state.next_scene = Campaign.new_game_scene(args)
    end

    def continue_game
      args.state.run = nil
      args.state.next_scene = :compound
    end

    def render
      if settings_open?(args) || credits_open?(args)
        draw_background_color(args)
      else
        draw_title_background(args)

        draw_glowing_title(args, { x: 666, y: 666, text: TITLE, size_px: 56, color: RGB_CREAM })

        draw_title(
          args,
          { x: 516, y: 625, text: SUBTITLE, size_px: 24, color: RGB_DARK_BROWN, anchor_x: 0 }
        )

        draw_debt_free_msg(args) if Campaign.farm_note_paid?(args)
        draw_title_buttons(args)
      end

      draw_settings
    end

    def draw_title_buttons(args)
      draw_button(args, label: 'NEW GAME', area: NEW_GAME_BUTTON)
      draw_tooltip(args, NEW_GAME_TOOLTIP) if mouse_over?(args, NEW_GAME_BUTTON)

      draw_button(args, label: 'CREDITS', area: CREDITS_BUTTON)

      return unless Campaign.continue_available?(args)

      draw_button(args, label: 'CONTINUE', area: CONTINUE_BUTTON)
      draw_tooltip(args, CONTINUE_TOOLTIP) if mouse_over?(args, CONTINUE_BUTTON)
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
