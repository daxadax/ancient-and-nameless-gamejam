require 'lib/draw'

module UI
  include Draw

  # TODO: this should be the main file for all UI related methods
  def draw_hud(run)
    draw_label(
      args,
      { x: 40, y: 600, text: "Day #{run.day} of #{run.max_days}", size_px: 22 },
      color: RGB_WHITE
    )

    meters = run.meters
    meter_text = "Vibes #{meters.vibes} "
    meter_text += "Food #{meters.food} "
    meter_text += "Cleanliness #{meters.cleanliness} "
    meter_text += "Authenticity #{meters.authenticity}"
    draw_label(args, { x: 40, y: 575, text: meter_text, size_px: 18 }, color: RGB_GRAY)
  end
end
