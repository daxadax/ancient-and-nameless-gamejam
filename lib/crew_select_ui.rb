require 'lib/cultists'
require 'lib/draw'
require 'lib/buttons'
require 'lib/crew_roster'
require 'lib/crew_select'
require 'lib/campaign'
require 'lib/ui/left_side_bar'
require 'lib/ui/stat_block'

module CrewSelectUI
  include Draw
  include Buttons
  include UI::LeftSideBar
  include UI::StatBlock

  PANEL = { x: 183, y: 33, w: 756, h: 656 }.freeze
  DETAIL_TEXT_X = 207
  DETAIL_TEXT_WIDTH = 90
  READY_BUTTON = { x: (PANEL[:w] + (PANEL[:x]/2)) / 2, y: 80 }

  def handle_crew_select_input(args)
    handle_focus_input(args)
    return unless clicked_button?(args, READY_BUTTON)

    args.state.next_scene = :compound
  end

  def render_crew_select_ui(args)
    focused_id = CrewSelect.focused_id(args)

    # can this be standarized?
    render_detail_panel(focused_id)

    render_crew_select_slots(PANEL)

    draw_button(args, label: 'READY', area: READY_BUTTON)
  end

  private

  def handle_focus_input(args)
    ids = CrewRoster.ids
    return if ids.empty?

    # keyboard input
    CrewSelect.move_focus!(args, -1) if args.inputs.keyboard.key_down.up
    CrewSelect.move_focus!(args, 1) if args.inputs.keyboard.key_down.down

    # mouse input
    ids.each_with_index do |_id, index|
      rect = side_bar_rect(PANEL, index)
      CrewSelect.select_focus!(args, index) if clicked_button?(args, rect, size: rect)
    end
  end


  def render_detail_panel(id)
    entry = CrewRoster.entry(id)
    return unless entry

    draw_panel(args, PANEL)

    draw_label(
      args,
      { x: DETAIL_TEXT_X, y: PANEL[:y] + PANEL[:h] - 42, text: 'MEET THE CREW', size_px: 26 },
      color: RGB_CREAM
    )

    draw_label(
      args,
      {
        x: DETAIL_TEXT_X,
        y: PANEL[:y] + PANEL[:h] - 68,
        text: 'All four are on duty. Select a portrait to read their file.',
        size_px: 16
      },
      color: RGB_PANEL_MUTED
    )

    note_rect = {
      x: DETAIL_TEXT_X,
      y: PANEL[:y] + 24,
      w: PANEL[:w] - (DETAIL_TEXT_X - PANEL[:x]) - 24,
      h: PANEL[:h] - 124
    }

    draw_note_paper(note_rect, assigned: false)
    draw_detail_copy(note_rect, id, entry)
  end

  def draw_detail_copy(rect, name, entry)
    text_x = rect[:x] + NOTE_GAP * 2
    top_y = rect[:y] + rect[:h] - NOTE_GAP * 3
    portrait_rect = {
      x: rect[:x] + rect[:w] - CREW_SLOT_PORTRAIT_W - NOTE_GAP * 2,
      y: rect[:y] + rect[:h] - CREW_SLOT_PORTRAIT_H - NOTE_GAP * 2,
      w: CREW_SLOT_PORTRAIT_W,
      h: CREW_SLOT_PORTRAIT_H
    }

    draw_crew_portrait(args, name, portrait_rect)

    draw_title(
      args,
      { x: text_x, y: top_y, text: Cultists.label(name), size_px: 28, color: RGB_INK, anchor_x: 0 }
    )

    draw_label(
      args,
      { x: text_x, y: top_y - 28, text: entry['tagline'], size_px: 18 },
      color: RGB_INK
    )

    draw_stat_block(name, text_x, top_y)

    y = top_y - 170
    wrap_text(entry['bio'], DETAIL_TEXT_WIDTH).each do |line|
      draw_label(
        args,
        { x: text_x, y: y, text: line, size_px: 16 },
        color: RGB_INK
      )
      y -= 18
    end
  end
end


