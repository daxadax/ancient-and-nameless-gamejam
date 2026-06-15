require 'lib/helpers/draw'
require 'lib/helpers/buttons'
require 'lib/characters/character'
require 'lib/characters/crew_roster'
require 'lib/crew_select'
require 'lib/campaign'
require 'lib/ui/left_side_bar'
require 'lib/ui/stat_block'

module CrewSelectUI
  include Draw
  include Buttons
  include UI::LeftSideBar
  include UI::StatBlock

  PANEL = { x: 183, y: 33, w: 756, h: 656 }
  DETAIL_TEXT_X = 207
  DETAIL_TEXT_WIDTH = 90
  READY_BUTTON = { x: (PANEL[:w] + (PANEL[:x]/2)) / 2, y: 80 }

  def handle_crew_select_input(args)
    handle_focus_input(args)
    return unless clicked_button?(args, READY_BUTTON)

    Campaign.complete_founding!(args)
    args.state.next_scene = :compound
  end

  def render_crew_select_ui(args)
    focused_id = CrewSelect.focused_id(args)

    render_detail_panel(args, focused_id)
    render_crew_select_slots(PANEL)
    draw_button(args, label: 'READY', area: READY_BUTTON)
  end

  private

  def handle_focus_input(args)
    ids = CrewRoster.ids(args)
    return if ids.empty?

    CrewSelect.move_focus!(args, -1) if args.inputs.keyboard.key_down.up
    CrewSelect.move_focus!(args, 1) if args.inputs.keyboard.key_down.down

    slot_count = ids.length
    ids.each_with_index do |_id, index|
      rect = side_bar_rect(PANEL, index, slot_count)
      CrewSelect.select_focus!(args, index) if clicked_button?(args, rect, size: rect)
    end
  end

  def render_detail_panel(args, id)
    character = CrewRoster.character(args, id)
    return unless character

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
        text: 'Mara runs this place. Select a portrait to read their file.',
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
    draw_detail_copy(args, note_rect, character)
  end

  def draw_detail_copy(args, rect, character)
    text_x = rect[:x] + NOTE_GAP * 2
    top_y = rect[:y] + rect[:h] - NOTE_GAP * 3
    portrait_rect = {
      x: rect[:x] + rect[:w] - CREW_SLOT_PORTRAIT_W - NOTE_GAP * 2,
      y: rect[:y] + rect[:h] - CREW_SLOT_PORTRAIT_H - NOTE_GAP * 2,
      w: CREW_SLOT_PORTRAIT_W,
      h: CREW_SLOT_PORTRAIT_H
    }

    draw_crew_portrait(args, character, portrait_rect)

    draw_title(
      args,
      { x: text_x, y: top_y, text: character.display_name, size_px: 28, color: RGB_INK, anchor_x: 0 }
    )

    draw_stat_block(character, text_x, top_y)

    y = top_y - 170
    wrap_text(character.bio, DETAIL_TEXT_WIDTH).each do |line|
      draw_label(
        args,
        { x: text_x, y: y, text: line, size_px: 16 },
        color: RGB_INK
      )
      y -= 18
    end
  end
end
