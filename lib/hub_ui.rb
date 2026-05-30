require 'lib/draw'
require 'lib/run'

module HubUI
  include Draw

  PANEL = { x: 25, y: 50, w: 720, h: 500 }.freeze
  LABEL_X = 40

  def render_hub_ui(run)
    draw_panel

    if Run.last_day?(run)
      headline = 'Last night of the stay.'
      body = 'Send the guest on their way when you are ready.'
      button_label = 'CHECK OUT'
    else
      headline = 'Evening at the compound.'
      body = 'The guests head back to their rooms. End the day when you are ready.'
      button_label = 'END DAY'
    end

    draw_label(
      args,
      { x: LABEL_X, y: PANEL[:y] + PANEL[:h] - 45, text: headline.upcase, size_px: 26 },
      color: RGB_WHITE
    )

    draw_label(
      args,
      { x: LABEL_X, y: PANEL[:y] + PANEL[:h] - 78, text: body, size_px: 16 },
      color: RGB_GRAY
    )

    draw_end_day_btn(button_label)
  end

  private

  def draw_panel
    args.outputs.primitives << {
      x: PANEL[:x],
      y: PANEL[:y],
      w: PANEL[:w],
      h: PANEL[:h],
      r: 12,
      g: 12,
      b: 18,
      a: 230,
      primitive_marker: :solid
    }
  end
end
