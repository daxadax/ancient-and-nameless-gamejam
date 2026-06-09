require 'lib/draw'
require 'lib/buttons'
require 'lib/intro'
require 'lib/campaign'

module IntroUI
  include Draw
  include Buttons

  PANEL = { x: 25, y: 50, w: FULL_WIDTH * 0.7 - 25, h: FULL_HEIGHT - 100 }.freeze
  LABEL_X = 40
  TEXT_WIDTH = 100
  CONTINUE_BUTTON = { x: 620, y: 80 }

  def handle_intro_input(args)
    return unless continue_pressed?(args)
    return unless Intro.active?(args)

    Intro.complete!(args) if Intro.advance!(args) == :done
  end

  def render_intro_ui(args)
    beat = Intro.current(args)
    return unless beat

    draw_panel(args, PANEL)
    y = PANEL[:y] + PANEL[:h] - 45

    draw_title(
      args,
      {
        x: LABEL_X,
        y: y,
        text: beat['title'],
        size_px: 26,
        color: RGB_CREAM,
        anchor_x: 0
      }
    )

    y = y - 20
    draw_line(args, { x: LABEL_X, x2: LABEL_X + TEXT_WIDTH * 3, y: y, y2: y }, color: RGB_CREAM)

    y = PANEL[:y] + PANEL[:h] - 100
    wrap_text(beat['text'], TEXT_WIDTH).each do |line|
      draw_label(
        args,
        { x: LABEL_X + 4, y: y, text: line, size_px: 18 },
        color: RGB_CREAM
      )
      y -= 20
    end

    draw_button(args, label: button_label(args, beat), area: CONTINUE_BUTTON)
  end

  private

  def continue_pressed?(args)
    clicked_button?(args, CONTINUE_BUTTON) ||
      args.inputs.keyboard.key_down.enter ||
      args.inputs.keyboard.key_down.space
  end

  def button_label(args, beat)
    return beat['button'] if beat['button']

    Intro.last?(args) ? 'BEGIN' : 'CONTINUE'
  end
end
