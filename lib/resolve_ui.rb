require 'lib/draw'
require 'lib/buttons'
require 'lib/resolve'

module ResolveUI
  include Draw
  include Buttons

  PANEL = { x: 25, y: 50, w: 720, h: 500 }.freeze
  LABEL_X = 40
  CONTINUE_BUTTON = { x: 245, y: 80 }

  # TODO: just write the full thing
  METER_LABELS = {
    vibes: 'Vibes',
    food: 'Food',
    cleanliness: 'Clean',
    authenticity: 'Auth'
  }.freeze

  def handle_resolve_input(run)
    return unless resolve_mode?

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
end
