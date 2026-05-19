require 'app/scenes/title'
require 'app/scenes/gameplay'
require 'app/scenes/game_over'

module Main
  SCENES = {
    title: Scenes::Title.new,
    gameplay: Scenes::Gameplay.new,
    game_over: Scenes::GameOver.new
  }.freeze

  def tick(args)
    # default to title screen
    args.state.scene ||= :title

    # tick the current scene
    SCENES.fetch(args.state.scene).tick(args)

    # if the current scene passes the torch, update that here
    if args.state.next_scene
      args.state.scene = args.state.next_scene
      args.state.next_scene = nil
    end
  end
end
