require 'lib/draw'
require 'lib/run'

module Scenes
  class Compound
    include Draw

    END_DAY_BUTTON = { x: 915, y: 40, w: 240, h: 44 }.freeze

    def tick(args)
      @args = args
      draw_background_color(args)

      handle_input
      render
    end

    private
    attr_reader :args

    def handle_input
      return unless hub_mode?

      Run.advance_day!(args) if clicked_end_day?
    end

    def hub_mode?
      args.state.ui_mode.nil? || args.state.ui_mode == :hub
    end

    def clicked_end_day?
      mouse = args.inputs.mouse
      mouse.up && mouse.inside_rect?(END_DAY_BUTTON)
    end

    def render
      run = args.state.run

      args.outputs.sprites << {
        x: 780,
        y: 0,
        w: 500,
        h: 720,
        path: 'sprites/compound.jpg'
      }

      draw_label(
        args,
        { x: 25, y: 625, text: 'the compound'.upcase, size_px: 86, a: 150 },
        color: RGB_DARK_GRAY
      )

      render_hud(run)
      render_end_day_button
    end

    def render_hud(run)
      draw_label(
        args,
        { x: 40, y: 600, text: "Day #{run.day} — #{run.act}".upcase, size_px: 22 },
        color: RGB_WHITE
      )

      draw_label(
        args,
        { x: 40, y: 575, text: "Outside attention: #{threat_dots(run.threat)}", size_px: 18 },
        color: RGB_GRAY
      )

      meters = run.meters
      meter_text = "Provisions #{meters.provisions} Faith #{meters.faith} Secrecy #{meters.secrecy} Wards #{meters.security}"
      draw_label(args, { x: 40, y: 550, text: meter_text, size_px: 18 }, color: RGB_GRAY)
    end

    def threat_dots(threat)
      filled = '●' * threat
      empty = '○' * (5 - threat)

      "#{filled}#{empty}"
    end

    def render_end_day_button
      args.outputs.primitives << {
        r: 60,
        g: 40,
        b: 80,
        a: 200,
        primitive_marker: :solid
      }.merge(END_DAY_BUTTON)

      draw_title(
        args,
        {
          x: END_DAY_BUTTON[:x] + END_DAY_BUTTON[:w] / 2,
          y: END_DAY_BUTTON[:y] + END_DAY_BUTTON[:h] / 2,
          text: 'END DAY',
          size_px: 20,
          color: RGB_WHITE
        }
      )
    end
  end
end
