require 'lib/draw'
require 'lib/buttons'
require 'lib/resolve'

module ResolveUI
  include Draw
  include Buttons

  PANEL = { x: 25, y: 50, w: FULL_WIDTH * 0.7 - 25, h: FULL_HEIGHT - 100 }.freeze
  LABEL_X = 40
  TEXT_WIDTH = 100
  CONTINUE_BUTTON = { x: 620, y: 80 }

  def handle_resolve_input(run, skip_continue: false)
    return unless resolve_mode?
    return if skip_continue

    run.phase = :hub if clicked_button?(args, CONTINUE_BUTTON)
  end

  def render_resolve_ui(run)
    draw_panel(args, PANEL)

    draw_label(
      args,
      { x: LABEL_X, y: PANEL[:y] + PANEL[:h] - 45, text: 'HOW DID IT GO?', size_px: 26 },
      color: RGB_CREAM
    )

    y = PANEL[:y] + PANEL[:h] - 72

    run.last_resolve.each do |result|
      y = render_result_line(result, y)
    end

    draw_button(args, label: 'CONTINUE', area: CONTINUE_BUTTON)
  end

  def resolve_mode?
    args.state.run.phase == :resolve
  end

  private

  def render_result_line(result, top_y)
    y = top_y

    draw_label(
      args,
      {
        x: LABEL_X,
        y: y,
        text: "#{result[:station_label]} — #{result[:cultist_label]}",
        size_px: 24
      },
      color: RGB_YELLOW
    )

    y -= 26
    draw_label(
      args,
      { x: LABEL_X, y: y, text: format_roll(result[:primary]), size_px: 16 },
      color: RGB_PANEL_MUTED
    )

    y -= 22
    y = draw_wrapped_lines(result[:narrative], y, size_px: 18, color: RGB_CREAM)

    if result[:mara]
      y -= 10
      y = draw_wrapped_lines(result[:mara], y, size_px: 16, color: RGB_WHITE)
    end

    y - 16
  end

  def draw_wrapped_lines(text, top_y, size_px:, color:)
    y = top_y
    line_gap = size_px + 2

    wrap_text(text, TEXT_WIDTH).each do |line|
      draw_label(args, { x: LABEL_X, y: y, text: line, size_px: size_px }, color: color)
      y -= line_gap
    end

    y
  end

  def format_roll(line)
    mod_str = line[:mod].negative? ? line[:mod].to_s : "+#{line[:mod]}"
    "#{line[:meter].capitalize} d#{line[:die]}: #{line[:roll]}#{mod_str} = #{line[:total]}"
  end
end
