require 'lib/draw'
require 'lib/buttons'
require 'lib/ui'
require 'lib/assign_ui'
require 'lib/resolve_ui'
require 'lib/hub_ui'
require 'lib/run'

module Scenes
  class Compound
    include Draw
    include Buttons
    include UI
    include AssignUI
    include ResolveUI
    include HubUI

    def tick(args)
      @args = args
      draw_background_color(args)

      handle_input
      render
    end

    private
    attr_reader :args

    def handle_input
      run = args.state.run
      handle_assign_input(run)
      handle_resolve_input(run)
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

      # TODO: replace later with logo image
      draw_label(
        args,
        { x: 25, y: 625, text: 'EtherStay'.upcase, size_px: 86, a: 150 },
        color: RGB_INK
      )

      draw_hud(run)

      if assign_mode?
        render_assign_ui(run)
      elsif resolve_mode?
        render_resolve_ui(run)
      elsif hub_mode?
        render_hub_ui(run)
      end
    end

    def handle_hub_input
      return unless hub_mode?

      Run.end_day!(args) if clicked_end_day?
    end

    def hub_mode?
      args.state.run.phase == :hub
    end
  end
end
