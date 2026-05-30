module Draw
  # Fawlty Towers palette: worn hotel beige, wood browns, faded burgundy.
  DEFAULT_BG = [212, 198, 175].freeze

  RGB_INK         = { r: 62,  g: 45,  b: 32  }.freeze
  RGB_BODY        = { r: 100, g: 78,  b: 62  }.freeze
  RGB_MUTED       = { r: 130, g: 108, b: 88  }.freeze
  RGB_CREAM       = { r: 248, g: 240, b: 228 }.freeze
  RGB_PANEL_MUTED = { r: 205, g: 185, b: 165 }.freeze
  RGB_GOLD        = { r: 176, g: 142, b: 58  }.freeze
  RGB_RED         = { r: 158, g: 68,  b: 58  }.freeze

  RGB_WHITE     = RGB_CREAM
  RGB_GRAY      = RGB_BODY
  RGB_DARK_GRAY = RGB_MUTED
  RGB_GREEN     = RGB_GOLD

  PANEL_FILL   = { r: 92,  g: 68,  b: 52  }.freeze
  BTN_DEFAULT  = { r: 118, g: 88,  b: 68  }.freeze
  BTN_SELECTED = { r: 145, g: 72,  b: 62  }.freeze
  BTN_IDLE     = { r: 88,  g: 72,  b: 58  }.freeze
  BTN_ACTION   = { r: 138, g: 58,  b: 52  }.freeze
  BTN_DISABLED = { r: 100, g: 92,  b: 82  }.freeze

  PANEL_ALPHA = 235

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

  def draw_solid_button(args, rect, fill, alpha: 220)
    args.outputs.primitives << {
      a: alpha,
      primitive_marker: :solid
    }.merge(fill).merge(rect)
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
end
