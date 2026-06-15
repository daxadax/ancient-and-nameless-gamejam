require 'lib/helpers/draw'
require 'lib/review'

module UI
  module PayoutPanel
    include Draw

    PANEL = { x: 340, y: 120, w: 600, h: 480 }.freeze
    LABEL_X = 380
    VALUE_X = 760
    BAR_X = 380
    BAR_W = 500
    BAR_H = 18
    TOTAL_SAVED_Y = 328

    def render_payout_cashbox(payout, anim:)
      draw_panel(args, PANEL)
      draw_panel_flash(anim)

      draw_title(
        args,
        { x: 640, y: 540, text: 'CASHBOX', size_px: 48, color: RGB_CREAM }
      )

      draw_title(
        args,
        { x: 640, y: 490, text: Review.star_line(payout[:stars]), size_px: 36, color: RGB_GOLD }
      )

      y = 400
      payout[:lines].each do |line|
        draw_label(
          args,
          { x: LABEL_X, y: y, text: line[:label], size_px: 22 },
          color: RGB_CREAM
        )
        draw_label(
          args,
          { x: VALUE_X, y: y, text: format_amount(line[:amount]), size_px: 22, anchor_x: 1 },
          color: amount_color(line[:amount])
        )
        y -= 36
      end

      draw_label(
        args,
        { x: LABEL_X, y: TOTAL_SAVED_Y, text: 'Total saved', size_px: 24 },
        color: RGB_GOLD
      )
      draw_label(
        args,
        {
          x: VALUE_X,
          y: TOTAL_SAVED_Y,
          text: "#{anim[:credits]} / #{payout[:farm_save_goal]}",
          size_px: 24,
          anchor_x: 1
        },
        color: RGB_GOLD
      )

      draw_floater(anim[:floater]) if anim[:floater]

      bar_top_y = TOTAL_SAVED_Y - 40
      draw_progress_bar(bar_top_y, anim[:bar_ratio], anim[:t])
      draw_bar_sparkle(bar_top_y, anim[:bar_ratio], anim[:t]) unless anim[:in_delay]

      if payout[:farm_saved] && anim[:complete]
        message = payout[:just_saved_farm] ? 'You paid off this month\'s debt!' : 'This month\'s debt has been paid.'
        draw_title(
          args,
          { x: 640, y: bar_top_y - 36, text: message, size_px: 20, color: RGB_GOLD }
        )
      end
    end

    def draw_panel_flash(anim)
      return if anim[:in_delay]
      return if anim[:t] >= 0.35

      pulse = 1.0 - (anim[:t] / 0.35)
      alpha = (pulse * 90).to_i
      return if alpha <= 0

      rect = PANEL.merge(a: alpha, primitive_marker: :solid)
      args.outputs.primitives << rect.merge(RGB_GOLD)
    end

    def draw_floater(floater)
      color = floater[:text].start_with?('-') ? RGB_FAILURE : RGB_SUCCESS
      draw_label(
        args,
        {
          x: VALUE_X - 8,
          y: TOTAL_SAVED_Y + 28 + floater[:y_offset],
          text: floater[:text],
          size_px: 26,
          anchor_x: 1
        },
        color: color.merge(a: floater[:alpha])
      )
    end

    def draw_progress_bar(top_y, ratio, t)
      rect = { x: BAR_X, y: top_y - BAR_H, w: BAR_W, h: BAR_H }

      args.outputs.primitives << rect.merge(RGB_DARK_BROWN).merge(a: 180, primitive_marker: :solid)
      args.outputs.borders << rect.merge(RGB_CREAM).merge(a: 220)

      return if ratio <= 0.0

      fill_w = (BAR_W * ratio).to_i
      fill = rect.merge(w: fill_w)
      fill_alpha = t >= 1.0 ? 220 : 180 + (40 * [t * 2, 1.0].min).to_i
      args.outputs.primitives << fill.merge(RGB_GOLD).merge(a: fill_alpha, primitive_marker: :solid)
    end

    # NOTE: surely there's a better way to this?
    def draw_bar_sparkle(top_y, ratio, t)
      return if t >= 1.0 || ratio <= 0.0

      edge_x = BAR_X + (BAR_W * ratio).to_i
      edge_y = top_y - (BAR_H / 2)
      flicker = (Math.sin(args.state.tick_count * 0.4) * 0.5 + 0.5)

      [-6, 0, 6].each_with_index do |offset, index|
        size = 4 - index
        alpha = (120 + flicker * 80 - index * 30).to_i
        next if alpha <= 0

        args.outputs.primitives << {
          x: edge_x + offset - (size / 2),
          y: edge_y - (size / 2),
          w: size,
          h: size,
          a: alpha,
          primitive_marker: :solid
        }.merge(RGB_CREAM)
      end
    end

    def format_amount(amount)
      sign = amount.negative? ? '-' : '+'
      "#{sign}#{amount.abs} credits"
    end

    def amount_color(amount)
      return RGB_FAILURE if amount.negative?

      RGB_SUCCESS
    end
  end
end
