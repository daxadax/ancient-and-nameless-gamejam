require 'lib/character'
require 'lib/draw'
require 'lib/stations'
require 'lib/campaign'
require 'lib/crew_select'
require 'lib/ui/stat_block'

module UI
  module LeftSideBar
    include Draw
    include UI::StatBlock

    NOTE_GAP = 8
    CREW_SLOTS = 4
    CREW_SLOT_PORTRAIT_W = 118
    CREW_SLOT_PORTRAIT_H = 108

    def render_staff_notes(run, panel)
      Run.crew(run).each_with_index do |character, index|
        render_staff_note(run, character, panel, index)
      end
    end

    def render_crew_select_slots(panel)
      lineup = Campaign.roster(args)
      slot_count = lineup.length

      lineup.each_with_index do |character, index|
        rect = side_bar_rect(panel, index, slot_count)
        focused = CrewSelect.focus_index(args) == index

        draw_note_paper(rect, assigned: !focused)
        draw_slot_portrait(character, rect, focused: focused)
      end
    end

    def side_bar_rect(panel, index, slot_count = CREW_SLOTS)
      side = panel[:h] / slot_count
      slots_from_bottom = slot_count - 1 - index

      x = panel[:x] - side
      y = panel[:y] + slots_from_bottom * side

      { x: x, y: y, w: side, h: side }
    end

    private

    def draw_slot_portrait(character, rect, focused: false)
      portrait_rect = {
        x: rect[:x] + (rect[:w] - CREW_SLOT_PORTRAIT_W) / 2,
        y: rect[:y] + 22,
        w: CREW_SLOT_PORTRAIT_W,
        h: CREW_SLOT_PORTRAIT_H
      }

      bob = focused ? (Math.sin(args.state.tick_count * 0.12) * 6).to_i : 0
      draw_crew_portrait(args, character, portrait_rect, bob: bob)
    end

    def draw_crew_portrait(args, character, rect, bob: 0)
      shifted = rect.merge(y: rect[:y] + bob)
      tint = character.portrait_color

      args.outputs.primitives << shifted.merge(tint).merge(a: 220, primitive_marker: :solid)

      draw_title(
        args,
        {
          x: shifted[:x] + shifted[:w] / 2,
          y: shifted[:y] + shifted[:h] / 2,
          text: character.initial,
          size_px: 64,
          color: RGB_CREAM
        }
      )
    end

    def render_staff_note(run, character, panel, index)
      assigned = cultist_assigned?(run, character.id)
      rect = side_bar_rect(panel, index)

      draw_note_paper(rect, assigned: assigned)
      draw_nametag(rect, character)
      draw_note_copy(rect, character)
    end

    def cultist_assigned?(run, character_id)
      Stations::IDS.any? { |station_id| run.assignments[station_id] == character_id }
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

    def draw_nametag(rect, character)
      x = rect[:x] + NOTE_GAP * 2
      y = rect[:y] + rect[:h] - NOTE_GAP * 3

      draw_title(
        args,
        {
          x: x,
          y: y,
          text: character.display_name,
          size_px: 21,
          color: RGB_INK,
          anchor_x: 0
        }
      )
    end

    def draw_note_copy(rect, character)
      text_x = rect[:x] + NOTE_GAP * 2
      top_y = rect[:y] + rect[:h] - NOTE_GAP

      draw_stat_block(character, text_x, top_y)
    end
  end
end
