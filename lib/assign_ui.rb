require 'lib/helpers/draw'
require 'lib/helpers/audio'
require 'lib/stations'
require 'lib/character'
require 'lib/assignment'
require 'lib/resolve'
require 'lib/run'
require 'lib/ui/left_side_bar'

module AssignUI
  include Draw
  include UI::LeftSideBar

  PANEL = { x: 183, y: 33, w: 756, h: 656 }.freeze
  ROW_HEIGHT = 90
  STATION_LABEL_X = 207
  CULTIST_BTN_X = 352
  CULTIST_BTN_W = 120
  CULTIST_BTN_H = 34
  CULTIST_BTN_GAP = 12
  CONFIRM_BUTTON = { x: (PANEL[:w] + (PANEL[:x]/2)) / 2, y: 80 }

  def handle_assign_input(run)
    return false unless assign_mode?

    station_id, cultist_id = fetch_selection(run)
    Assignment.pick!(run, station_id, cultist_id) if station_id
    return true if clicked_button?(args, CONFIRM_BUTTON) && Assignment.confirm!(run)

    false
  end

  def render_assign_ui(run)
    draw_panel(args, PANEL)

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
    render_staff_notes(run, PANEL)
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

    Run.crew_ids(run).each_with_index do |character_id, col|
      selected = Assignment.read(run, station_id) == character_id
      elsewhere = assigned_elsewhere?(run, station_id, character_id)
      draw_cultist_btn(run, row, col, character_id, selected: selected, dim: elsewhere)
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

  def assigned_elsewhere?(run, station_id, character_id)
    Stations::IDS.any? do |sid|
      sid != station_id && Assignment.read(run, sid) == character_id
    end
  end

  def draw_confirm_btn(run)
    ready = Resolve.valid_assignments?(run.assignments, Run.crew_ids(run))
    fill = ready ? BTN_ACTION : BTN_DISABLED
    alpha = ready ? ALPHA_READY : ALPHA_DISABLED
    options = { fill: fill, alpha: alpha }

    draw_button(args, label: 'CONFIRM ASSIGNMENTS', area: CONFIRM_BUTTON, options: options)
  end

  def draw_cultist_btn(run, row, col, character_id, selected:, dim:)
    rect = cultist_btn_rect(row, col)
    fill = selected ? BTN_SELECTED : BTN_IDLE
    alpha = dim && !selected ? ALPHA_DISABLED : ALPHA_READY
    options = { fill: fill, alpha: alpha }
    character = Run.character(run, character_id)

    draw_button(args, label: character.display_name, area: rect, options: options)
  end

  def fetch_selection(run)
    return unless args.inputs.mouse.up

    Stations::IDS.each_with_index do |station_id, row|
      Run.crew_ids(run).each_with_index do |character_id, col|
        next unless args.inputs.mouse.inside_rect?(cultist_btn_rect(row, col))

        Audio.play_click!(args)
        return [station_id, character_id]
      end
    end

    nil
  end
end
