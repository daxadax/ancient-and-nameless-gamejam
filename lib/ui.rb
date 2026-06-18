require 'lib/helpers/draw'
require 'lib/settings_ui'
require 'lib/credits_ui'

module UI
  include Draw
  include SettingsUI
  include CreditsUI

  def draw_hud(run)
    draw_label(
      args,
      {
        x: FULL_WIDTH - 120,
        y: FULL_HEIGHT - 50,
        text: "Day #{run.day} of #{run.max_days}",
        size_px: 22
      },
      color: RGB_INK
    )

    draw_settings
  end
end
