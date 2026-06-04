require 'lib/draw'
require 'lib/crew_select_ui'

module Scenes
  class CrewSelect
    include Draw
    include CrewSelectUI

    def tick(args)
      @args = args
      draw_background_color(args)
      handle_crew_select_input(args)
      render_crew_select_ui(args)
    end

    private

    attr_reader :args
  end
end
