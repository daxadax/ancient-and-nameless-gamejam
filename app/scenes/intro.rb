require 'lib/draw'
require 'lib/intro_ui'

module Scenes
  class Intro
    include Draw
    include IntroUI

    def tick(args)
      draw_background_color(args)
      handle_intro_input(args)
      render_intro_ui(args)
    end
  end
end
