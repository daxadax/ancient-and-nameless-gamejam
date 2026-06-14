require 'lib/draw'
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

    def render_payout_cashbox(payout)
      draw_panel(args, PANEL)

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

      y -= 12
      draw_label(
        args,
        { x: LABEL_X, y: y, text: 'Total saved', size_px: 24 },
        color: RGB_GOLD
      )
      draw_label(
        args,
        {
          x: VALUE_X,
          y: y,
          text: "#{payout[:credits_after]} / #{payout[:farm_save_goal]}",
          size_px: 24,
          anchor_x: 1
        },
        color: RGB_GOLD
      )

      y -= 40
      draw_progress_bar(y, payout[:credits_after], payout[:farm_save_goal])

      if payout[:farm_saved]
        draw_title(
          args,
          { x: 640, y: y - 36, text: 'The farm note is covered.', size_px: 20, color: RGB_GOLD }
        )
      end
    end

    def draw_progress_bar(top_y, credits, goal)
      progress = goal.positive? ? (credits.to_f / goal).clamp(0.0, 1.0) : 0.0
      rect = { x: BAR_X, y: top_y - BAR_H, w: BAR_W, h: BAR_H }

      args.outputs.primitives << rect.merge(RGB_DARK_BROWN).merge(a: 180, primitive_marker: :solid)
      args.outputs.borders << rect.merge(RGB_CREAM).merge(a: 220)

      return if progress.zero?

      fill = rect.merge(w: (BAR_W * progress).to_i)
      args.outputs.primitives << fill.merge(RGB_GOLD).merge(a: 220, primitive_marker: :solid)
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
