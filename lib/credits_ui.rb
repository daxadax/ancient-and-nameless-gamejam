require 'lib/helpers/draw'
require 'lib/helpers/buttons'

module CreditsUI
  include Draw
  include Buttons

  PANEL = { x: 0, y: 0, w: FULL_WIDTH, h: FULL_HEIGHT }.freeze
  DONE_BUTTON = { x: 520, y: 80, w: 240, h: 44 }.freeze
  CONTENT_X = 140
  CONTENT_TOP = 560
  CONTENT_HEIGHT = 420
  LINE_HEIGHT = 20
  WRAP_WIDTH = 120

  JAM_URL = 'https://itch.io/jam/kifass-4'.freeze
  JAM_LINK_LABEL = 'itch.io/jam/kifass-4'.freeze
  LINK_CHAR_WIDTH = 9

  CREDITS_ENTRIES = [
    {
      type: :text,
      text: 'Culty Towers was made for the Ancient & Nameless & Fun & Stupid game jam using DragonRuby.'
    },
    { type: :link, label: JAM_LINK_LABEL, url: JAM_URL },
    {
      type: :text,
      text: "I used to play a lot of tabletop games and make spinoffs when I was a kid, but this is my first time making a game in this format and it's been a lot of fun. It's probably not the most engaging game on earth, but I really do like the concept and it was a great learning experience. Can't wait to make more games!"
    },
    {
      type: :text,
      text: 'Music — Headscratcher (BGM): sounds/headscratcher.ogg. Author: congusbongus. License: CC-BY 4.0 / OGA-BY 4.0. Source: opengameart.org/content/headscratcher. Attribution: "Headscratcher" by congusbongus (CC-BY 4.0), via OpenGameArt.org'
    },
    {
      type: :text,
      text: 'Sounds — Coins rattling on the table: sounds/coins-rattling.ogg. Author: Sounddino. Source: sounddino.com/en/effects/coins/. Attribution: Sounds by Sounddino'
    },
    {
      type: :text,
      text: 'Coin SFX: sounds/coin-4.ogg. Author: Driken Stan. Source: pixabay.com/users/driken5482-45721595. Attribution: Coin sounds by Driken5482 via pixabay.com'
    },
    {
      type: :text,
      text: 'I used AI to generate the title screen and help with some of the specifics of DragonRuby, (particularly sound generation and animations) when I got stuck.'
    }
  ].freeze

  def credits_open?(args)
    args.state.credits_open
  end

  def open_credits!(args)
    args.state.credits_open = true
    args.state.credits_scroll = 0
  end

  def close_credits!(args)
    args.state.credits_open = false
  end

  def handle_credits_input(args)
    return unless credits_open?(args)

    close_credits!(args) if modal_dismissed?(args, DONE_BUTTON)
    handle_credits_link_click!(args)
  end

  def render_credits_ui(args)
    return unless credits_open?(args)

    draw_panel(args, PANEL, alpha: 255)

    draw_label(
      args,
      { x: CONTENT_X, y: CONTENT_TOP + 40, text: 'CREDITS', size_px: 40 },
      color: RGB_CREAM
    )

    render_credits_body(args)

    draw_button(args, label: 'DONE', area: DONE_BUTTON)
  end

  private

  def credits_lines
    CREDITS_ENTRIES.flat_map { |entry| lines_for_entry(entry) }
  end

  def lines_for_entry(entry)
    case entry[:type]
    when :text
      wrap_text(entry[:text], WRAP_WIDTH).map { |line| { text: line, url: nil } } + [{ text: '', url: nil }]
    when :link
      [{ text: entry[:label], url: entry[:url] }, { text: '', url: nil }]
    end
  end

  def handle_credits_link_click!(args)
    return unless args.inputs.mouse.up

    (args.state.credits_link_rects || []).each do |link|
      next unless args.inputs.mouse.inside_rect?(link)

      $gtk.openurl link[:url]
    end
  end

  def render_credits_body(args)
    scroll = args.state.credits_scroll.to_i
    bottom = CONTENT_TOP - CONTENT_HEIGHT
    args.state.credits_link_rects = []

    credits_lines.each_with_index do |line, index|
      y = CONTENT_TOP - index * LINE_HEIGHT + scroll
      next if y > CONTENT_TOP + 10
      next if y < bottom
      next if line[:text].empty?

      if line[:url]
        render_credits_link(args, line, y)
      else
        draw_label(
          args,
          { x: CONTENT_X, y: y, text: line[:text], size_px: 18, anchor_x: 0 },
          color: RGB_CREAM
        )
      end
    end
  end

  def render_credits_link(args, line, y)
    label = line[:text]
    width = label.length * LINK_CHAR_WIDTH
    rect = { x: CONTENT_X, y: y - 14, w: width, h: LINE_HEIGHT, url: line[:url] }
    args.state.credits_link_rects << rect

    hovered = args.inputs.mouse.inside_rect?(rect)
    color = hovered ? RGB_CREAM : RGB_GOLD

    draw_label(
      args,
      { x: CONTENT_X, y: y, text: label, size_px: 16, anchor_x: 0 },
      color: color
    )

    draw_line(
      args,
      { x: CONTENT_X, y: y - 3, x2: CONTENT_X + width, y2: y - 3 },
      color: color
    )
  end
end
