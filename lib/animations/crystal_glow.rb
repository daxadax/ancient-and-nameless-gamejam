module Animations
  module CrystalGlow
    TILE_COUNT = 18
    CENTER_X = 806
    CENTER_Y = 185
    IMG_W = 36
    IMG_H = 52

    def self.render(args)
      tick = args.state.tick_count
      args.state.title_crystal_glow_index ||= 0

      # change the tile every TILE_COUNT ticks
      if tick % TILE_COUNT == 0
        args.state.title_crystal_glow_index += 1
        if args.state.title_crystal_glow_index >= TILE_COUNT
          args.state.title_crystal_glow_index = 0
        end
      end

      args.outputs.sprites << draw_sprite(args)
    end

    def self.draw_sprite(args)
      tile = build_current_tile(args.state.title_crystal_glow_index)

      { path: 'sprites/crystal_glow.jpg',
        x: CENTER_X,
        y: CENTER_Y,
        w: IMG_W,
        h: IMG_H,
      }.merge(tile)
    end

    def self.build_current_tile(index)
      if index.zero? || index == TILE_COUNT - 1
        { tile_x: 0, tile_y: 0, tile_w: IMG_W, tile_h: IMG_H }
      else
        { tile_x: IMG_W * index, tile_y: 0, tile_w: IMG_W, tile_h: IMG_H }
      end
    end
  end
end
