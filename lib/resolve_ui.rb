require 'lib/draw'
require 'lib/resolve'

module ResolveUI
  include Draw

  PANEL = { x: 25, y: 50, w: 720, h: 500 }.freeze
  LABEL_X = 40
  CONTINUE_BTN = { x: 245, y: 80, w: 280, h: 44 }.freeze

  METER_LABELS = {
    vibes: 'Vibes',
    food: 'Food',
    cleanliness: 'Clean',
    authenticity: 'Auth'
  }.freeze

  def handle_resolve_input(run)
    return unless resolve_mode?

    run.phase = :hub if clicked_continue?
  end

  def render_resolve_ui(run)
    draw_panel

    draw_label(
      args,
      { x: LABEL_X, y: PANEL[:y] + PANEL[:h] - 45, text: 'HOW DID IT GO?', size_px: 26 },
      color: RGB_CREAM
    )

    run.last_resolve.each_with_index do |result, index|
      render_result_line(result, index)
    end

    draw_continue_btn
  end

  def resolve_mode?
    args.state.run.phase == :resolve
  end

  private

  def draw_panel
    draw_wood_panel(args, PANEL)
  end

  def render_result_line(result, index)
    base_y = PANEL[:y] + PANEL[:h] - 100 - (index * 88)

    draw_label(
      args,
      {
        x: LABEL_X,
        y: base_y,
        text: "#{result[:station_label]} — #{result[:cultist_label]}",
        size_px: 18
      },
      color: RGB_CREAM
    )

    draw_label(
      args,
      { x: LABEL_X, y: base_y - 24, text: format_roll(result[:primary]), size_px: 16 },
      color: RGB_PANEL_MUTED
    )

    draw_label(
      args,
      { x: LABEL_X, y: base_y - 46, text: format_roll(result[:secondary]), size_px: 16 },
      color: RGB_PANEL_MUTED
    )
  end

  def format_roll(line)
    mod_str = line[:mod].negative? ? line[:mod].to_s : "+#{line[:mod]}"
    label = METER_LABELS.fetch(line[:meter])
    "#{label} d#{line[:die]}: #{line[:roll]}#{mod_str} = #{line[:total]}"
  end

  def draw_continue_btn
    draw_solid_button(args, CONTINUE_BTN, BTN_ACTION, alpha: 220)

    draw_title(
      args,
      {
        x: CONTINUE_BTN[:x] + CONTINUE_BTN[:w] / 2,
        y: CONTINUE_BTN[:y] + CONTINUE_BTN[:h] / 2,
        text: 'CONTINUE',
        size_px: 18,
        color: RGB_CREAM
      }
    )
  end

  def clicked_continue?
    args.inputs.mouse.up && args.inputs.mouse.inside_rect?(CONTINUE_BTN)
  end
end
