require 'lib/run'
require 'app/scenes/title'
require 'app/scenes/compound'
require 'app/scenes/ritual_space'
require 'app/scenes/game_over'

module Main
  SCENES = {
    title: Scenes::Title.new,
    compound: Scenes::Compound.new,
    ritual_space: Scenes::RitualSpace.new,
    game_over: Scenes::GameOver.new
  }.freeze

  def tick(args)
    args.state.scene ||= :title

    SCENES.fetch(args.state.scene).tick(args)
    apply_scene_transition!(args)
  end

  def apply_scene_transition!(args)
    return unless args.state.next_scene

    prepare_scene!(args, args.state.next_scene)
    args.state.scene = args.state.next_scene
    args.state.next_scene = nil
  end

  def prepare_scene!(args, scene)
    return unless scene == :compound
    return if Run.active?(args)

    Run.start!(args)
  end
end

def reset(args)
  DR.reset
end
