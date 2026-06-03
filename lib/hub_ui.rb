require 'lib/buttons'
require 'lib/draw'
require 'lib/evening_outcomes'
require 'lib/run'

module HubUI
  include Draw
  include Buttons

  END_DAY_BUTTON = { x: 975, y: 80 }
  PANEL = { x: 25, y: 50, w: 1230, h: 500 }.freeze
  LABEL_X = 40

  def handle_hub_input
    return unless hub_mode?

    Run.end_day!(args) if clicked_button?(args, END_DAY_BUTTON)
  end

  def hub_mode?
    args.state.run.phase == :hub
  end

  def render_hub_ui(run)
    evening = EveningOutcomes.build(run)
    draw_wood_panel(args, PANEL)

    if Run.last_day?(run)
      headline = 'Last night at the compound'
      button_label = 'CHECK OUT'
    else
      headline = 'Evening at the compound'
      button_label = 'END DAY'
    end

    # TODO: this should match the rendering in resolve
    # and then ideally be extracted to a common helper
    draw_label(
      args,
      { x: LABEL_X, y: PANEL[:y] + PANEL[:h] - 45, text: headline.upcase, size_px: 26 },
      color: RGB_CREAM
    )

    y = PANEL[:y] + PANEL[:h] - 72
    evening[:beats].each do |beat|
      y = render_evening_beat(beat, y)
    end

    draw_label(
      args,
      { x: LABEL_X, y: y, text: "Today: #{evening[:meter_summary]}", size_px: 14 },
      color: RGB_PANEL_MUTED
    )

    draw_button(args, label: button_label, area: END_DAY_BUTTON)
  end

  private

  def render_evening_beat(beat, top_y)
    y = top_y

    wrap_text(beat['text'], 120).each do |line|
      draw_label(
        args,
        { x: LABEL_X, y: y, text: line, size_px: 18 },
        color: RGB_CREAM
      )
      y -= 16
    end

    y - 8
  end
end
