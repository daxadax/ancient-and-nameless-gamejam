require 'lib/draw'
require 'lib/stations'
require 'lib/cultists'
require 'lib/assignment'

module AssignUI
  include Draw

  PANEL = { x: 25, y: 50, w: 720, h: 500 }.freeze
  ROW_HEIGHT = 90
  STATION_LABEL_X = 40
  CULTIST_BTN_X = 185
  CULTIST_BTN_W = 120
  CULTIST_BTN_H = 34
  CULTIST_BTN_GAP = 12
  CONFIRM_BTN = { x: 245, y: 80, w: 280, h: 44 }.freeze

  def handle_assign_input(run)
    return unless assign_mode?

    station_id, cultist_id = clicked_cultist_pick
    Assignment.pick!(run, station_id, cultist_id) if station_id

    Assignment.confirm!(run) if clicked_confirm?
  end

  def render_assign_ui(run)
    draw_panel

    draw_label(
      args,
      { x: STATION_LABEL_X, y: PANEL[:y] + PANEL[:h] - 45, text: 'ASSIGN CREW', size_px: 26 },
      color: RGB_WHITE
    )

    draw_label(
      args,
      {
        x: STATION_LABEL_X,
        y: PANEL[:y] + PANEL[:h] - 68,
        text: 'Pick one cultist per station. Click confirm when ready.',
        size_px: 16
      },
      color: RGB_GRAY
    )

    Stations::IDS.each_with_index do |station_id, row|
      render_station_row(run, station_id, row)
    end

    draw_confirm_btn(run)
  end

  def assign_mode?
    args.state.run.phase == :assign
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

  def render_station_row(run, station_id, row)
    row_y = row_center_y(row)

    draw_label(
      args,
      { x: STATION_LABEL_X, y: row_y, text: Stations.label(station_id), size_px: 18 },
      anchor_y: 0.5,
      color: RGB_WHITE
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

  def draw_cultist_btn(row, col, cultist_id, selected:, dim:)
    rect = cultist_btn_rect(row, col)
    base = selected ? { r: 90, g: 55, b: 120 } : { r: 45, g: 35, b: 60 }
    alpha = dim && !selected ? 150 : 220

    args.outputs.primitives << base.merge(a: alpha, primitive_marker: :solid).merge(rect)

    draw_title(
      args,
      {
        x: rect[:x] + rect[:w] / 2,
        y: rect[:y] + rect[:h] / 2,
        text: Cultists.label(cultist_id),
        size_px: 16,
        color: RGB_WHITE
      }
    )
  end

  def assigned_elsewhere?(run, station_id, cultist_id)
    Stations::IDS.any? do |sid|
      sid != station_id && Assignment.read(run, sid) == cultist_id
    end
  end

  def draw_confirm_btn(run)
    ready = Resolve.valid_assignments?(run.assignments)
    base = ready ? { r: 60, g: 40, b: 80 } : { r: 40, g: 40, b: 48 }
    alpha = ready ? 220 : 140

    args.outputs.primitives << base.merge(a: alpha, primitive_marker: :solid).merge(CONFIRM_BTN)

    draw_title(
      args,
      {
        x: CONFIRM_BTN[:x] + CONFIRM_BTN[:w] / 2,
        y: CONFIRM_BTN[:y] + CONFIRM_BTN[:h] / 2,
        text: 'CONFIRM ASSIGNMENTS',
        size_px: 18,
        color: RGB_WHITE
      }
    )
  end

  def clicked_cultist_pick
    return unless args.inputs.mouse.up

    Stations::IDS.each_with_index do |station_id, row|
      Cultists::IDS.each_with_index do |cultist_id, col|
        return [station_id, cultist_id] if args.inputs.mouse.inside_rect?(cultist_btn_rect(row, col))
      end
    end

    nil
  end

  def clicked_confirm?
    args.inputs.mouse.up && args.inputs.mouse.inside_rect?(CONFIRM_BTN)
  end
end
