require 'lib/draw'

module Buttons
  include Draw

  END_DAY_BUTTON = { x: 915, y: 40, w: 240, h: 44 }.freeze

  def clicked_end_day?
    mouse = args.inputs.mouse
    mouse.up && mouse.inside_rect?(END_DAY_BUTTON)
  end

  def draw_end_day_btn(label = 'END DAY')
    draw_solid_button(args, END_DAY_BUTTON, BTN_ACTION, alpha: 200)

    draw_title(
      args,
      {
        x: END_DAY_BUTTON[:x] + END_DAY_BUTTON[:w] / 2,
        y: END_DAY_BUTTON[:y] + END_DAY_BUTTON[:h] / 2,
        text: label,
        size_px: 20,
        color: RGB_CREAM
      }
    )
  end
end
