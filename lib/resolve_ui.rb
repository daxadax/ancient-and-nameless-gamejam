require 'lib/helpers/draw'
require 'lib/helpers/buttons'
require 'lib/outcomes/day_report'
require 'lib/outcomes/evening_outcomes'
require 'lib/run'
require 'lib/ui/narrative_panel'

module ResolveUI
  include Draw
  include Buttons
  include UI::NarrativePanel

  ACTION_BUTTON = { x: 620, y: 80 }

  def handle_resolve_input(run, skip_continue: false)
    return unless resolve_mode?
    return if skip_continue
    return unless continue_pressed?

    ensure_day_report!(run)

    if last_report_step?(run)
      Run.end_day!(args)
    else
      run.resolve_step += 1
    end
  end

  def render_resolve_ui(run)
    ensure_day_report!(run)
    page = run.day_report[run.resolve_step]
    return unless page

    draw_panel(args, PANEL)
    draw_panel_headline(page_headline(page))

    rect = dialog_rect
    draw_dialog_box(rect, border_color: mara_page?(page) ? RGB_CRYSTAL : RGB_INK)

    text_x = rect[:x] + 20
    y = rect[:y] + rect[:h] - 28

    if page[:result]
      result = page[:result]
      draw_label(
        args,
        {
          x: LABEL_X,
          y: PANEL[:y] + PANEL[:h] - 72,
          text: "#{result[:station_label]} — #{result[:cultist_label]}",
          size_px: 22
        },
        color: RGB_YELLOW
      )

      draw_label(
        args,
        {
          x: LABEL_X,
          y: PANEL[:y] + PANEL[:h] - 96,
          text: format_roll(result[:primary]),
          size_px: 16
        },
        color: RGB_PANEL_MUTED
      )

      y -= 18

      draw_label(
        args,
        { x: text_x, y: y, text: result[:cultist_label].upcase, size_px: 20 },
        color: RGB_GOLD
      )

      y = draw_wrapped_lines(
        result[:narrative],
        y - 32,
        size_px: 20,
        color: RGB_INK,
        label_x: text_x
      )
    end

    if page[:mara_asides]
      page[:mara_asides].each do |aside|
        y -= 16
        y = draw_mara_aside(text_x, y, aside)
      end
    end

    page[:beats].each do |beat|
      y -= 16
      y = draw_evening_beat(text_x, y, beat)
    end

    if page[:meter_summary]
      y -= 12
      draw_label(
        args,
        { x: text_x, y: y, text: "Today: #{page[:meter_summary]}", size_px: 14 },
        color: RGB_MUTED
      )
    end

    draw_step_progress(run.resolve_step + 1, run.day_report.length, rect)

    label = last_report_step?(run) ? end_day_label(run) : 'NEXT'
    draw_button(args, label: label, area: ACTION_BUTTON)
  end

  def resolve_mode?
    args.state.run.phase == :resolve
  end

  private

  def ensure_day_report!(run)
    run.day_report ||= DayReport.build(run)
  end

  def page_headline(page)
    return 'OFF THE RECORD' if page[:station_id] == :mara
    return 'EVENING AT THE COMPOUND' if page[:station_id] == :compound

    'HOW DID IT GO?'
  end

  def mara_page?(page)
    page[:station_id] == :mara
  end

  def end_day_label(run)
    Run.last_day?(run) ? 'CHECK OUT' : 'END DAY'
  end

  def last_report_step?(run)
    run.resolve_step >= run.day_report.length - 1
  end

  def draw_mara_aside(text_x, top_y, text)
    draw_label(
      args,
      { x: text_x, y: top_y, text: 'MARA (PRIVATE)', size_px: 16 },
      color: RGB_MUTED
    )

    draw_wrapped_lines(
      text,
      top_y - 22,
      size_px: 18,
      color: RGB_DARK_BROWN,
      label_x: text_x
    )
  end

  def draw_evening_beat(text_x, top_y, beat)
    draw_label(
      args,
      { x: text_x, y: top_y, text: EveningOutcomes.communication_type_for(beat).upcase, size_px: 16 },
      color: RGB_GOLD
    )

    draw_wrapped_lines(
      beat['text'],
      top_y - 22,
      size_px: 18,
      color: RGB_INK,
      label_x: text_x
    )
  end

  def draw_step_progress(current, total, rect)
    draw_label(
      args,
      {
        x: rect[:x] + rect[:w] - 40,
        y: rect[:y] + 16,
        text: "#{current}/#{total}",
        size_px: 14,
        anchor_x: 1
      },
      color: RGB_MUTED
    )
  end

  def format_roll(line)
    mod_str = line[:mod].negative? ? line[:mod].to_s : "+#{line[:mod]}"
    "#{line[:meter].capitalize} d#{line[:die]}: #{line[:roll]}#{mod_str} = #{line[:total]}"
  end

  def continue_pressed?
    clicked_button?(args, ACTION_BUTTON) ||
      args.inputs.keyboard.key_down.enter ||
      args.inputs.keyboard.key_down.space
  end
end
