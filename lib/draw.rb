module Draw
  DEFAULT_BG = [212, 198, 175].freeze

  RGB_DARK_BROWN  = { r: 62,  g: 45,  b: 32  }.freeze
  RGB_LIGHT_BROWN = { r: 130, g: 108, b: 88  }.freeze
  RGB_BROWN       = { r: 100, g: 78,  b: 62  }.freeze
  RGB_CREAM       = { r: 248, g: 240, b: 228 }.freeze
  RGB_BEIGE       = { r: 205, g: 185, b: 165 }.freeze
  RGB_GOLD        = { r: 176, g: 142, b: 58  }.freeze
  RGB_YELLOW      = { r: 176, g: 172, b: 58  }.freeze
  RGB_RED         = { r: 158, g: 68,  b: 58  }.freeze
  RGB_CRYSTAL     = { r: 155, g: 105, b: 195 }.freeze
  RGB_PINK        = { r: 176, g: 102, b: 158  }.freeze

  RGB_BODY          = RGB_BROWN
  RGB_MUTED         = RGB_LIGHT_BROWN
  RGB_INK           = RGB_DARK_BROWN
  RGB_PANEL_MUTED   = RGB_BEIGE

  PANEL_FILL   = { r: 92,  g: 68,  b: 52  }.freeze
  BTN_DEFAULT  = { r: 118, g: 88,  b: 68  }.freeze
  BTN_SELECTED = { r: 145, g: 72,  b: 62  }.freeze
  BTN_IDLE     = { r: 88,  g: 72,  b: 58  }.freeze
  BTN_ACTION   = { r: 138, g: 58,  b: 52  }.freeze
  BTN_DISABLED = { r: 100, g: 92,  b: 82  }.freeze

  PANEL_ALPHA = 235
  ALPHA_READY = 220
  ALPHA_DISABLED = 150

  def draw_background_color(args, color = DEFAULT_BG)
    args.outputs.background_color = color
  end

  def draw_wood_panel(args, rect)
    args.outputs.primitives << {
      x: rect[:x],
      y: rect[:y],
      w: rect[:w],
      h: rect[:h],
      a: PANEL_ALPHA,
      primitive_marker: :solid
    }.merge(PANEL_FILL)
  end

  def draw_line(args, params, color: RGB_BODY)
    args.outputs.lines << params.merge(color)
  end

  def draw_label(args, params, color: RGB_BODY, anchor_x: 0, anchor_y: 0)
    params[:anchor_x] = anchor_x
    params[:anchor_y] = anchor_y

    args.outputs.labels << params.merge(color)
  end

  def draw_title(args, params)
    color = params.fetch(:color) { RGB_INK }
    anchor_x = params.fetch(:anchor_x) { 0.5 }
    anchor_y = params.fetch(:anchor_y) { 0.5 }

    draw_label(args, params, color: color, anchor_x: anchor_x, anchor_y: anchor_y)
  end

  def draw_glowing_title(args, params, glow_alpha: 210)
    x = params[:x]
    y = params[:y]
    glow = RGB_CRYSTAL.merge(a: glow_alpha)

    [[2, 0], [-2, 0], [0, 2], [0, -2]].each do |ox, oy|
      draw_title(args, params.merge(x: x + ox, y: y + oy, color: glow))
    end

    draw_title(args, params)
  end

  def wrap_text(text, max_chars)
    text.to_s.split("\n", -1).flat_map do |paragraph|
      paragraph.strip.empty? ? [''] : wrap_paragraph(paragraph, max_chars)
    end
  end

  def wrap_paragraph(text, max_chars)
    words = text.split
    lines = []
    line = ''

    words.each do |word|
      if line.empty?
        line = word
      elsif line.length + 1 + word.length <= max_chars
        line = "#{line} #{word}"
      else
        lines << line
        line = word
      end
    end

    lines << line unless line.empty?
    lines
  end
end
