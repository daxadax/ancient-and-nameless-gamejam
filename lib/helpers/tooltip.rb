require 'lib/helpers/buttons'
require 'lib/helpers/draw'

module Tooltip
  include Draw

  TOOLTIP_WIDTH = 24
  LINE_HEIGHT = 18
  PADDING = 20
  GAP = 12

  def mouse_over?(args, area, size: Buttons::DEFAULT_BTN_SIZE)
    args.inputs.mouse.inside_rect?(size.merge(area))
  end

  def draw_tooltip(args, text)
    lines = wrap_text(text, TOOLTIP_WIDTH)
    return if lines.empty?

    box_w = 220
    box_h = 100
    box_x = 1000
    box_y = 100

    draw_panel(args, { x: box_x, y: box_y, w: box_w, h: box_h }, alpha: 245)

    y = box_y + box_h - PADDING * 2
    lines.each do |line|
      draw_label(
        args,
        { x: box_x + PADDING, y: y, text: line, size_px: 18, anchor_x: 0 },
        color: RGB_CREAM
      )
      y -= LINE_HEIGHT
    end
  end
end
