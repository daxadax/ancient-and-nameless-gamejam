require 'lib/draw'
require 'lib/run'

module UI
  include Draw

  EVENT_PANEL = { x: 25, y: 25, w: 700, h: 480 }.freeze
  EVENT_BODY_MAX_CHARS = 64
  CHOICE_KEYS = %i[one two three].freeze
  CHOICE_LABELS = { one: '1', two: '2', three: '3' }.freeze

  def draw_hud(run)
    draw_label(
      args,
      { x: 40, y: 600, text: "Day #{run.day} of #{run.max_days} — #{run.phase}".upcase, size_px: 22 },
      color: RGB_WHITE
    )

    meters = run.meters
    meter_text = "Vibes #{meters.vibes} "
    meter_text += "Food #{meters.food} "
    meter_text += "Hygiene #{meters.cleanliness} "
    meter_text += "Authenticity #{meters.authenticity}"
    draw_label(args, { x: 40, y: 575, text: meter_text, size_px: 18 }, color: RGB_GRAY)
  end

  def choice_key_from_input(_event)
    CHOICE_KEYS.each do |key|
      return key if args.inputs.keyboard.key_down.send(key)
    end

    CHOICE_KEYS.each_with_index do |key, index|
      return key if clicked_choice?(index)
    end

    nil
  end

  def render_event(event)
    args.outputs.primitives << {
      x: EVENT_PANEL[:x],
      y: EVENT_PANEL[:y],
      w: EVENT_PANEL[:w],
      h: EVENT_PANEL[:h],
      r: 12,
      g: 12,
      b: 18,
      a: 230,
      path: :solid,
      primitive_marker: :solid
    }

    draw_label(
      args,
      {
        x: EVENT_PANEL[:x] + 40,
        y: EVENT_PANEL[:y] + EVENT_PANEL[:h] - 50,
        text: event.title.upcase,
        size_px: 28
      },
      color: RGB_WHITE
    )

    draw_event_body(event)

    CHOICE_KEYS.each_with_index do |key, index|
      draw_choice_button(event, key, index)
    end

    draw_label(
      args,
      { x: EVENT_PANEL[:x] + 40, y: 50, text: '1 / 2 / 3 or click a choice', size_px: 16 },
      color: RGB_DARK_GRAY
    )
  end

  def draw_event_body(event)
    split_string_at_max_length(event.body).split("\n").each_with_index do |line, index|
      draw_label(
        args,
        {
          x: EVENT_PANEL[:x] + 40,
          y: EVENT_PANEL[:y] + EVENT_PANEL[:h] - 100 - (index * 28),
          text: line,
          size_px: 20
        },
        color: RGB_GRAY
      )
    end
  end

  def split_string_at_max_length(string)
    words = string.split(' ')
    lines = []
    current_line = ''

    until words.empty?
      current_line += " #{words.shift}"
      if current_line.length >= EVENT_BODY_MAX_CHARS
        lines << current_line
        current_line = ''
      end
    end

    lines.push(current_line).join("\n")
  end

  def draw_choice_button(event, key, index)
    rect = draw_choices_wrapper(index)
    choice = event.choices[key]

    args.outputs.primitives << {
      r: 50,
      g: 35,
      b: 70,
      a: 220,
      primitive_marker: :solid
    }.merge(rect)

    prefix = CHOICE_LABELS.fetch(key)
    draw_label(
      args,
      {
        x: rect[:x] + 16,
        y: rect[:y] + rect[:h] / 2,
        text: "#{prefix}) #{choice.text}",
        size_px: 18
      },
      anchor_y: 0.5,
      color: RGB_WHITE
    )
  end

  def draw_choices_wrapper(index)
    {
      x: EVENT_PANEL[:x] + 40,
      y: 200 - (index * 56),
      w: EVENT_PANEL[:w] - 80,
      h: 44
    }
  end
end
