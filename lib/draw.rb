module Draw
  DEFAULT_BG    = [24, 24, 32]
  RGB_WHITE     = { r: 255, g: 255, b: 255 }
  RGB_GRAY      = { r: 180, g: 180, b: 190 }
  RGB_DARK_GRAY = { r: 120, g: 120, b: 130 }
  RGB_GREEN     = { r: 120, g: 200, b: 120 }
  RGB_RED       = { r: 220, g: 100, b: 100 }

  def draw_background_color(args, color = DEFAULT_BG)
    args.outputs.background_color = color
  end

  def draw_line(args, params, color: RGB_GRAY)
    args.outputs.lines << params.merge(color)
  end

  def draw_label(args, params, color: RGB_GRAY, anchor_x: 0.5, anchor_y: 0.5)
    params[:anchor_x] = anchor_x
    params[:anchor_y] = anchor_y

    args.outputs.labels << params.merge(color)
  end
end
