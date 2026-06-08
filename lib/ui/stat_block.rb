require 'lib/cultists'
require 'lib/draw'

module UI
  module StatBlock
    include Draw

    def draw_stat_block(name, x, y)
      stat_lines(name).each_with_index do |line, index|
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

    def stat_lines(name)
      stats = Cultists.by_name(name)

      Cultists::METER_KEYS.map do |meter|
        mod = stats[meter]
        sign = mod.negative? ? '-' : '+'

        { text: "#{meter} #{sign}#{mod.abs}", bad: mod.negative? }
      end
    end
  end
end
