require 'lib/draw'
require 'lib/stations'
require 'lib/cultists'
require 'lib/assignment'
require 'lib/ui/staff_notes'

module AssignUI
  include Draw
  include UI::StaffNotes

  PANEL = { x: 25, y: 50, w: 720, h: 500 }.freeze
  ROW_HEIGHT = 90
  STATION_LABEL_X = 40
  CULTIST_BTN_X = 185
  CULTIST_BTN_W = 120
  CULTIST_BTN_H = 34
  CULTIST_BTN_GAP = 12
  CONFIRM_BUTTON = { x: 245, y: 80 }

  def handle_assign_input(run)
    return false unless assign_mode?

    station_id, cultist_id = fetch_selection
    Assignment.pick!(run, station_id, cultist_id) if station_id
    return true if clicked_button?(args, CONFIRM_BUTTON) && Assignment.confirm!(run)

    false
  end

  def render_assign_ui(run)
    draw_wood_panel(args, PANEL)

    draw_label(
      args,
      { x: STATION_LABEL_X, y: PANEL[:y] + PANEL[:h] - 45, text: 'ASSIGN CREW', size_px: 26 },
      color: RGB_CREAM
    )

    draw_label(
      args,
      {
        x: STATION_LABEL_X,
        y: PANEL[:y] + PANEL[:h] - 68,
        text: 'Pick one cultist per station. Click confirm when ready.',
        size_px: 16
      },
      color: RGB_PANEL_MUTED
    )

    Stations::IDS.each_with_index do |station_id, row|
      render_station_row(run, station_id, row)
    end

    draw_confirm_btn(run)
    render_staff_notes(run)
  end

  def assign_mode?
    args.state.run.phase == :assign
  end

  private

  def render_station_row(run, station_id, row)
    draw_label(
      args,
      { x: STATION_LABEL_X, y: row_center_y(row), text: Stations.label(station_id), size_px: 18 },
      anchor_y: 0.5,
      color: RGB_CREAM
    )

    Cultists::IDS.each_with_index do |cultist_id, col|
      selected = Assignment.read(run, station_id) == cultist_id
      elsewhere = assigned_elsewhere?(run, station_id, cultist_id)
      draw_cultist_btn(row, col, cultist_id, selected: selected, dim: elsewhere)
    end
  end

  def row_center_y(row)
    PANEL[:y] + PANEL[:h] - 120 - (row * ROW_HEIGHT)
  end

  def cultist_btn_rect(row, col)
    {
      x: CULTIST_BTN_X + col * (CULTIST_BTN_W + CULTIST_BTN_GAP),
      y: row_center_y(row) - CULTIST_BTN_H / 2,
      w: CULTIST_BTN_W,
      h: CULTIST_BTN_H
    }
  end

  def assigned_elsewhere?(run, station_id, cultist_id)
    Stations::IDS.any? do |sid|
      sid != station_id && Assignment.read(run, sid) == cultist_id
    end
  end

  def draw_confirm_btn(run)
    ready = Resolve.valid_assignments?(run.assignments)
    fill = ready ? BTN_ACTION : BTN_DISABLED
    alpha = ready ? ALPHA_READY : ALPHA_DISABLED
    options = { fill: fill, alpha: alpha }

    draw_button(args, label: 'CONFIRM ASSIGNMENTS', area: CONFIRM_BUTTON, options: options)
  end

  def draw_cultist_btn(row, col, cultist_id, selected:, dim:)
    rect = cultist_btn_rect(row, col)
    fill = selected ? BTN_SELECTED : BTN_IDLE
    alpha = dim && !selected ? ALPHA_DISABLED : ALPHA_READY
    options = { fill: fill, alpha: alpha }

    draw_button(args, label: Cultists.label(cultist_id), area: rect, options: options)
  end

  def fetch_selection
    return unless args.inputs.mouse.up

    Stations::IDS.each_with_index do |station_id, row|
      Cultists::IDS.each_with_index do |cultist_id, col|
        return [station_id, cultist_id] if args.inputs.mouse.inside_rect?(cultist_btn_rect(row, col))
      end
    end

    nil
  end
end
