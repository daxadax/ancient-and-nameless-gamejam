require 'lib/draw'
require 'lib/buttons'
require 'lib/resolve'

module ResolveUI
  include Draw
  include Buttons

  PANEL = { x: 25, y: 50, w: 1230, h: 500 }.freeze
  LABEL_X = 40
  CONTINUE_BUTTON = { x: 975, y: 80 }

  def handle_resolve_input(run, skip_continue: false)
    return unless resolve_mode?
    return if skip_continue

    run.phase = :hub if clicked_button?(args, CONTINUE_BUTTON)
  end

  def render_resolve_ui(run)
    draw_wood_panel(args, PANEL)

    draw_label(
      args,
      { x: LABEL_X, y: PANEL[:y] + PANEL[:h] - 45, text: 'HOW DID IT GO?', size_px: 26 },
      color: RGB_CREAM
    )

    run.last_resolve.each_with_index do |result, index|
      render_result_line(result, index)
    end

    draw_button(args, label: 'CONTINUE', area: CONTINUE_BUTTON)
  end

  def resolve_mode?
    args.state.run.phase == :resolve
  end

  private

  def render_result_line(result, index)
    base_y = PANEL[:y] + PANEL[:h] - 90 - (index * 95)

    draw_label(
      args,
      {
        x: LABEL_X,
        y: base_y,
        text: "#{result[:station_label]} — #{result[:cultist_label]}",
        size_px: 24
      },
      color: RGB_YELLOW
    )

    y = base_y - 20
    draw_label(
      args,
      { x: LABEL_X, y: y, text: format_roll(result[:primary]), size_px: 16 },
      color: RGB_PANEL_MUTED
    )

    y = base_y - 44
    wrap_text(result[:narrative], 120).each do |line|
      draw_label(
        args,
        { x: LABEL_X, y: y, text: line, size_px: 18 },
        color: RGB_CREAM
      )
      y -= 16
    end

    # draw_label(
    #   args,
    #   { x: LABEL_X, y: y - 22, text: format_roll(result[:secondary]), size_px: 16 },
    #   color: RGB_PANEL_MUTED
    # )
  end

  def format_roll(line)
    mod_str = line[:mod].negative? ? line[:mod].to_s : "+#{line[:mod]}"
    "#{line[:meter].capitalize} d#{line[:die]}: #{line[:roll]}#{mod_str} = #{line[:total]}"
  end

  def wrap_text(text, max_chars)
    words = text.to_s.split
    lines = []
    line = ''

    words.each do |word|
      if line.empty?
        line = word
      elsif line.length + 1 + word.length <= max_chars
        line = "#{line} #{word}"
      else
        lines << line
        line = word
      end
    end

    lines << line unless line.empty?
    lines
  end
end
