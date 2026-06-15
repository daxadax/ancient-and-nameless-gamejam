require 'lib/character'
require 'lib/helpers/draw'

module UI
  module StatBlock
    include Draw

    def draw_stat_block(character, x, y)
      stat_lines(character).each_with_index do |line, index|
        draw_label(
          args,
          {
            x: x + 4,
            y: y - 56 - (index * 20),
            text: line[:text].upcase,
            size_px: 16
          },
          color: line[:bad] ? RGB_FAILURE : RGB_SUCCESS
        )
      end
    end

    private

    def stat_lines(character)
      Character::METER_KEYS.map do |meter|
        mod = character.mod(meter)
        sign = mod.negative? ? '-' : '+'

        { text: "#{meter} #{sign}#{mod.abs}", bad: mod.negative? }
      end
    end
  end
end
