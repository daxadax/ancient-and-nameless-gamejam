require 'lib/campaign'
require 'lib/run'
require 'lib/intro'
require 'app/scenes/title'
require 'app/scenes/intro'
require 'app/scenes/crew_select'
require 'app/scenes/compound'
require 'app/scenes/ritual_space'
require 'app/scenes/review'

# TODO: more / different images
# TODO: can't pick the same occultist twice for the same position?
# TODO: resolve / consider secondary station attributes
# TODO: UI as a journal / notebook?
# TODO: generate cultists (later guests?) based on traits & campaign lvl rather than hardcoding

module Main
  SCENES = {
    title: Scenes::Title.new,
    intro: Scenes::Intro.new,
    crew_select: Scenes::CrewSelect.new,
    compound: Scenes::Compound.new,
    ritual_space: Scenes::RitualSpace.new,
    review: Scenes::Review.new
  }.freeze

  def tick(args)
    # set_bg_music(args) if Kernel.tick_count == 1

    Campaign.resume!(args)
    args.state.scene ||= :title

    SCENES.fetch(args.state.scene).tick(args)
    apply_scene_transition!(args)
  end

  def apply_scene_transition!(args)
    target = args.state.next_scene
    return unless target

    prepare_scene!(args, target)
    args.state.scene = target
    args.state.next_scene = nil
  end

  def prepare_scene!(args, scene)
    case scene
    when :intro
      Intro.reset!(args)
    when :crew_select
      CrewSelect.reset!(args)
    when :compound
      Run.start!(args) unless Run.active?(args)
    end
  end

  def set_bg_music(args)
    args.audio[:music] = { input: "sounds/headscratcher.ogg", looping: true }
  end
end

def reset(args)
  DR.reset
end
