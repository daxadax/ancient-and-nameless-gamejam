require 'lib/helpers/draw'
require 'lib/helpers/buttons'
require 'lib/helpers/audio'
require 'lib/campaign'

module SettingsUI
  include Draw
  include Buttons

  PANEL = { x: 0, y: 0, w: FULL_WIDTH, h: FULL_HEIGHT }.freeze
  LABEL_X = 420
  ROW_GAP = 50

  SETTINGS_Y = PANEL[:h] - 100
  AUDIO_Y = SETTINGS_Y - ROW_GAP
  AUDIO_SUBTITLE_Y = AUDIO_Y - 30
  MUSIC_ROW_Y = AUDIO_SUBTITLE_Y - ROW_GAP
  SFX_ROW_Y = MUSIC_ROW_Y - ROW_GAP

  ADJUST_BTN = { w: 44, h: 36 }
  DONE_BUTTON = { x: 520, y: 333 }
  SETTINGS_COG = { x: FULL_WIDTH - 60, y: 10, w: 50, h: 50 }

  def draw_settings
    return if settings_open?(args)
    return if credits_open?(args)

    args.outputs.sprites << SETTINGS_COG.merge(path: 'sprites/settings-cog.png')
    toggle_settings!(args) if clicked_button?(args, SETTINGS_COG)
  end

  def settings_open?(args)
    args.state.settings_open
  end

  def toggle_settings!(args)
    args.state.settings_open = !args.state.settings_open
  end

  def close_settings!(args)
    args.state.settings_open = false
  end

  def handle_settings_input(args)
    return unless settings_open?(args)

    close_settings!(args) if modal_dismissed?(args, DONE_BUTTON)

    handle_volume_row(args, :music, MUSIC_ROW_Y)
    handle_volume_row(args, :sfx, SFX_ROW_Y)
  end

  def render_settings_ui(args)
    return unless settings_open?(args)

    draw_panel(args, PANEL, alpha: 255)

    draw_label(
      args,
      { x: LABEL_X, y: SETTINGS_Y, text: 'SETTINGS', size_px: 40 },
      color: RGB_CREAM
    )

    draw_label(
      args,
      { x: LABEL_X, y: AUDIO_Y, text: 'Audio', size_px: 26 },
      color: RGB_CREAM
    )

    draw_label(
      args,
      { x: LABEL_X, y: AUDIO_SUBTITLE_Y, text: 'Music and sound levels.', size_px: 16 },
      color: RGB_PANEL_MUTED
    )

    render_volume_row(args, 'Music', Campaign.music_volume(args), MUSIC_ROW_Y)
    render_volume_row(args, 'Sound', Campaign.sfx_volume(args), SFX_ROW_Y)

    draw_button(args, label: 'DONE', area: DONE_BUTTON)
  end

  private

  def handle_volume_row(args, kind, y)
    if clicked_button?(args, minus_rect(y))
      kind == :music ? Audio.adjust_music!(args, -Audio::STEP) : Audio.adjust_sfx!(args, -Audio::STEP)
    elsif clicked_button?(args, plus_rect(y))
      kind == :music ? Audio.adjust_music!(args, Audio::STEP) : Audio.adjust_sfx!(args, Audio::STEP)
    end
  end

  def render_volume_row(args, label, volume, y)
    draw_label(
      args,
      { x: LABEL_X, y: y, text: label, size_px: 20 },
      anchor_y: 0.5,
      color: RGB_CREAM
    )

    draw_button(args, label: '-', area: minus_rect(y), options: { text_size: 22 })
    draw_button(args, label: '+', area: plus_rect(y), options: { text_size: 22 })

    draw_title(
      args,
      {
        x: LABEL_X + 200,
        y: y,
        text: Audio.volume_label(volume),
        size_px: 22,
        color: RGB_CREAM
      }
    )
  end

  def minus_rect(y)
    { x: 500, y: y - ADJUST_BTN[:h] / 2 }.merge(ADJUST_BTN)
  end

  def plus_rect(y)
    { x: 720, y: y - ADJUST_BTN[:h] / 2 }.merge(ADJUST_BTN)
  end
end
