require 'lib/helpers/draw'
require 'lib/ui'
require 'lib/assign_ui'
require 'lib/resolve_ui'
require 'lib/run'

module Scenes
  class Compound
    include Draw
    include UI
    include AssignUI
    include ResolveUI

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

      run = args.state.run
      just_confirmed = handle_assign_input(run)
      handle_resolve_input(run, skip_continue: just_confirmed)
    end

    def render
      return if settings_open?(args)

      run = args.state.run

      if assign_mode?
        render_assign_ui(run)
      elsif resolve_mode?
        render_resolve_ui(run)
      end

      draw_hud(run)
    end
  end
end
