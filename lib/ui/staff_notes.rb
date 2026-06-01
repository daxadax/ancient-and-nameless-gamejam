require 'lib/cultists'
require 'lib/stations'
require 'lib/draw'

module UI
  module StaffNotes
    include Draw

    NOTE_INK = { r: 72, g: 58, b: 46, a: 210 }.freeze
    NOTE_GOOD = { r: 118, g: 92, b: 38, a: ALPHA_READY }.freeze
    NOTE_BAD = { r: 148, g: 62, b: 52, a: ALPHA_READY }.freeze

    NOTE_W = 150
    NOTE_H = 150
    NOTE_X = 1000
    NOTE_GAP = 8

    def render_staff_notes(run)
      Cultists::IDS.each_with_index do |name, index|
        render_staff_note(run, name, index)
      end
    end

    private

    def render_staff_note(run, name, index)
      assigned = cultist_assigned?(run, name)
      rect = staff_note_rect(index)

      draw_note_paper(rect, assigned: assigned)
      draw_nametag(rect, name)
      draw_note_copy(rect, name)
    end

    def staff_note_rect(index)
      x = NOTE_X + index % 2 * 7
      y = 24 + index * (NOTE_H + NOTE_GAP)

      { x: x, y: y, w: NOTE_W, h: NOTE_H }
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
          color: NOTE_INK,
          anchor_x: 0
        }
      )
    end

    def draw_note_copy(rect, name)
      text_x = rect[:x] + NOTE_GAP * 2
      top_y = rect[:y] + rect[:h] - NOTE_GAP * 5

      stat_lines(name).each_with_index do |line, index|
        draw_label(
          args,
          {
            x: text_x + 4,
            y: top_y - 24 - (index * 18),
            text: line[:text],
            size_px: 16
          },
          color: line[:bad] ? NOTE_BAD : NOTE_GOOD
        )
      end
    end

    def stat_lines(name)
      stats = Cultists.by_name(name)

      Cultists::METER_KEYS.map do |meter|
        mod = stats[meter]
        sign = mod.negative? ? '-' : '+'

        { text: "#{meter} #{sign}#{mod.abs}", bad: mod.positive? }
      end
    end
  end
end
