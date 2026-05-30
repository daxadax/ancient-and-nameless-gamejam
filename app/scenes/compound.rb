require 'lib/draw'
require 'lib/buttons'
require 'lib/ui'
require 'lib/day_cycle'
require 'lib/event_resolver'

module Scenes
  class Compound
    include Draw
    include Buttons
    include UI

    # TODO: add resolutions to each event choice
    def tick(args)
      @args = args
      draw_background_color(args)

      handle_input
      render
    end

    private
    attr_reader :args

    def handle_input
      handle_event_input
      handle_hub_input
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

      draw_hud(run)

      if event_mode?
        render_event(args.state.current_event)
      elsif hub_mode?
        draw_end_day_btn
      end
    end

    def handle_hub_input
      return unless hub_mode?

      DayCycle.end_day!(args) if clicked_end_day?
    end

    def handle_event_input
      return unless event_mode?

      event = args.state.current_event
      return unless event

      choice_key = choice_key_from_input(event)
      return unless choice_key

      EventResolver.apply_choice!(args, choice_key)
    end

    def hub_mode?
      args.state.run.phase == :hub
    end

    def event_mode?
      args.state.ui_mode == :event && args.state.current_event
    end
  end
end
