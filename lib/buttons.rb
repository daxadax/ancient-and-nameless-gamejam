require 'lib/draw'

module Buttons
  include Draw

  END_DAY_BUTTON = { x: 915, y: 40, w: 240, h: 44 }.freeze

  def clicked_end_day?
    mouse = args.inputs.mouse
    mouse.up && mouse.inside_rect?(END_DAY_BUTTON)
  end

  def draw_end_day_btn(label = 'END DAY')
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
        text: label,
        size_px: 20,
        color: RGB_WHITE
      }
    )
  end
end
