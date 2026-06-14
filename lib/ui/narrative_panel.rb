require 'lib/draw'

module UI
  module NarrativePanel
    include Draw

    PANEL = { x: 25, y: 50, w: FULL_WIDTH * 0.7 - 25, h: FULL_HEIGHT - 100 }.freeze
    LABEL_X = 40
    TEXT_WIDTH = 88
    DIALOG_INSET = 28

    def draw_panel_headline(text, panel: PANEL, inset: 45, size_px: 26, color: RGB_CREAM)
      draw_label(
        args,
        { x: LABEL_X, y: panel[:y] + panel[:h] - inset, text: text, size_px: size_px },
        color: color
      )
    end

    def dialog_rect(panel: PANEL)
      {
        x: panel[:x] + DIALOG_INSET,
        y: panel[:y] + 110,
        w: panel[:w] - DIALOG_INSET * 2,
        h: panel[:h] - 210
      }
    end

    def draw_dialog_box(rect, border_color: RGB_INK)
      args.outputs.primitives << rect.merge(RGB_CREAM).merge(a: ALPHA_READY, primitive_marker: :solid)
      args.outputs.borders << rect.merge(border_color).merge(a: 230)
    end

    def draw_wrapped_lines(text, top_y, size_px:, color:, label_x: LABEL_X, text_width: TEXT_WIDTH)
      y = top_y
      line_gap = size_px + 4

      wrap_text(text, text_width).each do |line|
        draw_label(args, { x: label_x, y: y, text: line, size_px: size_px }, color: color)
        y -= line_gap
      end

      y
    end
  end
end
