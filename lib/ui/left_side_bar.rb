require 'lib/cultists'
require 'lib/stations'
require 'lib/draw'
require 'lib/ui/stat_block'

module UI
  module LeftSideBar
    include Draw
    include UI::StatBlock

    NOTE_W = 150
    NOTE_H = 150
    NOTE_X = 1000
    NOTE_GAP = 8

    CREW_SLOTS = 4
    CREW_SLOT_PORTRAIT_W = 118
    CREW_SLOT_PORTRAIT_H = 108

    def render_staff_notes(run, panel)
      Cultists::IDS.each_with_index do |name, index|
        render_staff_note(run, name, panel, index)
      end
    end

    def render_crew_select_slots(panel)
      CrewRoster.ids.each_with_index do |id, index|
        rect = side_bar_rect(panel, index)
        focused = CrewSelect.focus_index(args) == index

        draw_note_paper(rect, assigned: !focused)
        draw_slot_portrait(id, rect, focused: focused)
      end
    end

    def side_bar_rect(panel, index)
      side = panel[:h] / CREW_SLOTS
      slots_from_bottom = CREW_SLOTS - 1 - index

      x = panel[:x] - side
      y = panel[:y] + slots_from_bottom * side

      { x: x, y: y, w: side, h: side }
    end

    private

    # start crew select
    def draw_slot_portrait(id, rect, focused: false)
      portrait_rect = {
        x: rect[:x] + (rect[:w] - CREW_SLOT_PORTRAIT_W) / 2,
        y: rect[:y] + 22,
        w: CREW_SLOT_PORTRAIT_W,
        h: CREW_SLOT_PORTRAIT_H
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
    # end crew select

    # start staff notes
    def render_staff_note(run, name, panel, index)
      assigned = cultist_assigned?(run, name)
      rect = side_bar_rect(panel, index)

      draw_note_paper(rect, assigned: assigned)
      draw_nametag(rect, name)
      draw_note_copy(rect, name)
    end

    def cultist_assigned?(run, name)
      Stations::IDS.any? { |station_id| run.assignments[station_id] == name }
    end

    def draw_note_paper(rect, assigned: false)
      args.outputs.primitives << {
        x: rect[:x],
        y: rect[:y],
        w: rect[:w],
        h: rect[:h],
        a: assigned ? ALPHA_DISABLED : ALPHA_READY,
        primitive_marker: :solid
      }.merge(RGB_CREAM)
    end

    def draw_nametag(rect, name)
      x = rect[:x] + NOTE_GAP * 2
      y = rect[:y] + rect[:h] - NOTE_GAP * 3

      draw_title(
        args,
        {
          x: x,
          y: y,
          text: Cultists.label(name),
          size_px: 21,
          color: RGB_INK,
          anchor_x: 0
        }
      )
    end

    def draw_note_copy(rect, name)
      text_x = rect[:x] + NOTE_GAP * 2
      top_y = rect[:y] + rect[:h] - NOTE_GAP

      draw_stat_block(name, text_x, top_y)
    end
    # end staff_notes
  end
end
