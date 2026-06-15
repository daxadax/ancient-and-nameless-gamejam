require 'lib/helpers/draw'
require 'lib/helpers/audio'

module Buttons
  include Draw

  DEFAULT_BTN_SIZE = { w: 240, h: 44 }

  def clicked_button?(args, area, size: DEFAULT_BTN_SIZE)
    mouse = args.inputs.mouse
    clicked = mouse.up && mouse.inside_rect?(size.merge(area))
    Audio.play_click!(args) if clicked
    clicked
  end

  def draw_button(args, label:, area:, options: {})
    area[:w] ||= DEFAULT_BTN_SIZE[:w]
    area[:h] ||= DEFAULT_BTN_SIZE[:h]
    fill = options[:fill] || BTN_ACTION
    alpha = options[:alpha] || ALPHA_READY
    text_size = options[:text_size] || 18

    draw_solid_button(args, area, fill, alpha)

    draw_title(
      args,
      {
        x: area[:x] + area[:w] / 2,
        y: area[:y] + area[:h] / 2,
        text: label,
        size_px: text_size,
        color: RGB_CREAM
      }
    )
  end

  private

  def draw_solid_button(args, rect, fill, alpha)
    args.outputs.primitives << {
      a: alpha,
      primitive_marker: :solid
    }.merge(fill).merge(rect)
  end
end
