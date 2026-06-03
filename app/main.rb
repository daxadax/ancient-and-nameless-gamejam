require 'lib/run'
require 'app/scenes/title'
require 'app/scenes/compound'
require 'app/scenes/ritual_space'
require 'app/scenes/review'

# TODO: more / different images
# TODO: can't pick the same occultist twice for the same position?
# TODO: resolve / consider secondary station attributes

module Main
  SCENES = {
    title: Scenes::Title.new,
    compound: Scenes::Compound.new,
    ritual_space: Scenes::RitualSpace.new,
    review: Scenes::Review.new
  }.freeze

  def tick(args)
    # set_bg_music(args) if Kernel.tick_count == 1

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

  def set_bg_music(args)
    args.audio[:music] = { input: "sounds/headscratcher.ogg", looping: true }
  end
end

def reset(args)
  DR.reset
end
