require 'lib/cultists'
require 'lib/draw'
require 'lib/buttons'
require 'lib/crew_roster'
require 'lib/crew_select'
require 'lib/campaign'
require 'lib/ui/staff_notes'

module CrewSelectUI
  include Draw
  include Buttons
  include UI::StaffNotes

  DETAIL_PANEL = { x: 33, y: 33, w: 756, h: 656 }.freeze
  DETAIL_TEXT_X = 57
  DETAIL_TEXT_WIDTH = 90
  PORTRAIT_W = 118
  PORTRAIT_H = 108
  READY_BUTTON = { x: 245, y: 80 }

  def handle_crew_select_input(args)
    handle_focus_input(args)
    return unless clicked_button?(args, READY_BUTTON)

    args.state.next_scene = :compound
  end

  def render_crew_select_ui(args)
    focused_id = CrewSelect.focused_id(args)

    # can this be standarized?
    render_detail_panel(focused_id)

    # this should be on the left side of the detail panel
    # and take up the same amount of vert. space
    CrewRoster.ids.each_with_index do |id, index|
      render_crew_slot(id, index)
    end

    draw_button(args, label: 'READY', area: READY_BUTTON)
  end

  private

  def handle_focus_input(args)
    ids = CrewRoster.ids
    return if ids.empty?

    CrewSelect.move_focus!(args, -1) if args.inputs.keyboard.key_down.up
    CrewSelect.move_focus!(args, 1) if args.inputs.keyboard.key_down.down

    ids.each_with_index do |_id, index|
      CrewSelect.select_focus!(args, index) if clicked_slot?(args, index)
    end
  end

  def clicked_slot?(args, index)
    rect = crew_slot_rect(index)
    clicked_button?(args, rect, size: { w: rect[:w], h: rect[:h] })
  end

  def crew_slot_rect(index)
    x = NOTE_X + (index % 2) * 7
    slots_from_bottom = CrewRoster.ids.length - 1 - index
    y = 24 + slots_from_bottom * (NOTE_H + NOTE_GAP)

    { x: x, y: y, w: NOTE_W, h: NOTE_H }
  end

  def render_detail_panel(id)
    entry = CrewRoster.entry(id)
    return unless entry

    draw_wood_panel(args, DETAIL_PANEL)

    draw_label(
      args,
      { x: DETAIL_TEXT_X, y: DETAIL_PANEL[:y] + DETAIL_PANEL[:h] - 42, text: 'MEET THE CREW', size_px: 26 },
      color: RGB_CREAM
    )

    draw_label(
      args,
      {
        x: DETAIL_TEXT_X,
        y: DETAIL_PANEL[:y] + DETAIL_PANEL[:h] - 68,
        text: 'All four are on duty. Select a portrait to read their file.',
        size_px: 16
      },
      color: RGB_PANEL_MUTED
    )

    note_rect = {
      x: DETAIL_TEXT_X,
      y: DETAIL_PANEL[:y] + 24,
      w: DETAIL_PANEL[:w] - (DETAIL_TEXT_X - DETAIL_PANEL[:x]) - 24,
      h: DETAIL_PANEL[:h] - 124
    }

    draw_note_paper(note_rect, assigned: false)
    draw_detail_copy(note_rect, id, entry)
  end

  def draw_detail_copy(rect, id, entry)
    text_x = rect[:x] + NOTE_GAP * 2
    top_y = rect[:y] + rect[:h] - NOTE_GAP * 3
    portrait_rect = {
      x: rect[:x] + rect[:w] - PORTRAIT_W - NOTE_GAP * 2,
      y: rect[:y] + rect[:h] - PORTRAIT_H - NOTE_GAP * 2,
      w: PORTRAIT_W,
      h: PORTRAIT_H
    }

    draw_crew_portrait(args, id, portrait_rect)

    draw_title(
      args,
      { x: text_x, y: top_y, text: Cultists.label(id), size_px: 28, color: NOTE_INK, anchor_x: 0 }
    )

    draw_label(
      args,
      { x: text_x, y: top_y - 28, text: entry['tagline'], size_px: 18 },
      color: NOTE_INK
    )

    stat_lines(id).each_with_index do |line, index|
      draw_label(
        args,
        {
          x: text_x + 4,
          y: top_y - 56 - (index * 20),
          text: line[:text],
          size_px: 16
        },
        color: line[:bad] ? NOTE_BAD : NOTE_GOOD
      )
    end

    y = top_y - 56 - (stat_lines(id).length * 20) - 12
    wrap_text(entry['bio'], DETAIL_TEXT_WIDTH).each do |line|
      draw_label(
        args,
        { x: text_x, y: y, text: line, size_px: 16 },
        color: NOTE_INK
      )
      y -= 18
    end
  end

  def render_crew_slot(id, index)
    rect = crew_slot_rect(index)
    focused = CrewSelect.focus_index(args) == index

    draw_note_paper(rect, assigned: !focused)
    draw_slot_portrait(id, rect, focused: focused)
  end

  def draw_slot_portrait(id, rect, focused: false)
    portrait_rect = {
      x: rect[:x] + (rect[:w] - PORTRAIT_W) / 2,
      y: rect[:y] + 22,
      w: PORTRAIT_W,
      h: PORTRAIT_H
    }

    bob = focused ? (Math.sin(args.state.tick_count * 0.12) * 6).to_i : 0
    draw_crew_portrait(args, id, portrait_rect, bob: bob)
    draw_focus_frame(portrait_rect, bob) if focused
  end

  def draw_crew_portrait(args, id, rect, bob: 0)
    shifted = rect.merge(y: rect[:y] + bob)
    tint = CrewRoster::PLACEHOLDER_COLORS.fetch(id)

    args.outputs.primitives << shifted.merge(tint).merge(a: 220, primitive_marker: :solid)

    draw_title(
      args,
      {
        x: shifted[:x] + shifted[:w] / 2,
        y: shifted[:y] + shifted[:h] / 2,
        text: Cultists.label(id)[0],
        size_px: 64,
        color: RGB_CREAM
      }
    )
  end

  def draw_focus_frame(rect, bob)
    frame = {
      x: rect[:x] - 3,
      y: rect[:y] + bob - 3,
      w: rect[:w] + 6,
      h: rect[:h] + 6
    }

    args.outputs.borders << frame.merge(RGB_GOLD).merge(a: 220)
  end
end
