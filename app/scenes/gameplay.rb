require 'lib/draw'

module Scenes
  class Gameplay
    include Draw

    WORDS = %w[doggaebi gashadokuro penanggalan lamashtu nuckelavee nyarlathotep].freeze
    MAX_WRONG = 6

    def init_game
      args.state.secret = WORDS.sample
      args.state.guessed = {}
      args.state.wrong = 0
      args.state.game_over = false
      args.state.won = false
    end

    def tick(args)
      @args = args
      draw_background_color(args)

      init_game if args.state.secret.nil?
      handle_input
      render
    end

    private
    attr_reader :args

    def handle_input
      # TODO: probably doesn't make sense for long
      if args.inputs.keyboard.key_down.escape
        init_game!(args)
        return
      end

      char = args.inputs.keyboard.key_up.char
      return unless char
      return if char == "\r"

      letter = char.downcase
      return unless letter.length == 1 && letter >= 'a' && letter <= 'z'
      return if args.state.guessed[letter]

      # TODO: show guessed letters
      args.state.guessed[letter] = true

      args.outputs.sounds << "sounds/drip.wav"

      if args.state.secret.include?(letter)
        if args.state.secret.chars.all? { |c| args.state.guessed[c] }
          args.state.game_over = true
          args.state.won = true
          args.state.next_scene = :game_over
        end
      else
        args.state.wrong += 1
        if args.state.wrong >= MAX_WRONG
          args.state.game_over = true
          args.state.won = false
          args.state.next_scene = :game_over
        end
      end
    end

    def render
      text = display_word
      draw_label(args, { x: 640, y: 560, text: text, size_px: 56 })

      text =  "Wrong: #{args.state.wrong} / #{MAX_WRONG}"
      draw_label(args, { x: 640, y: 480, text: text, size_px: 24 })

      render_wounds

      text = 'Type a letter · ESC to restart'
      draw_label(args, { x: 640, y: 40, text: text, size_px: 18 })
    end

    def display_word
      guessed = args.state.guessed
      args.state.secret.chars.map { |c| guessed[c] ? c.upcase : '_' }.join(' ')
    end

    def render_wounds
      wrong = args.state.wrong
      return if wrong.zero?

      ox, oy = 200, 120
      hx, hy = ox + 200, oy + 210

      # draw head
      draw_label(args, {x: hx, y: hy, text: 'O', size_px: 36 }) if wrong >= 1

      # draw body
      draw_line(args, { x: hx, y: hy - 20, x2: hx, y2: hy - 90 }) if wrong >= 2

      # draw arm
      draw_line(args, { x: hx, y: hy - 45, x2: hx - 40, y2: hy - 75 }) if wrong >= 3

      # draw arm
      draw_line(args, { x: hx, y: hy - 45, x2: hx + 40, y2: hy - 75 }) if wrong >= 4

      # draw leg
      draw_line(args, { x: hx, y: hy - 90, x2: hx - 35, y2: hy - 140 }) if wrong >= 5

      # draw leg
      draw_line(args, { x: hx, y: hy - 90, x2: hx + 35, y2: hy - 140 }) if wrong >= 6
    end
  end
end
