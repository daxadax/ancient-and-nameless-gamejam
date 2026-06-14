require 'lib/campaign'
require 'lib/audio'
require 'lib/run'
require 'lib/intro'
require 'lib/ui'
require 'app/scenes/title'
require 'app/scenes/intro'
require 'app/scenes/crew_select'
require 'app/scenes/compound'
require 'app/scenes/review'
require 'app/scenes/payout'

# TODO: generate cultists (later guests?) based on traits & campaign lvl rather than hardcoding
# TODO: can't pick the same occultist twice for the same position?
# TODO: resolve / consider secondary station attributes
# TODO: UI as a journal / notebook?
# TODO: more / different images

module Main
  include UI

  SCENES = {
    title: Scenes::Title.new,
    intro: Scenes::Intro.new,
    crew_select: Scenes::CrewSelect.new,
    compound: Scenes::Compound.new,
    review: Scenes::Review.new,
    payout: Scenes::Payout.new
  }.freeze

  def tick(args)
    Campaign.resume!(args)
    Audio.tick!(args)
    args.state.scene ||= :title

    SCENES.fetch(args.state.scene).tick(args)

    if settings_open?(args)
      handle_settings_input(args)
      render_settings_ui(args)
    end

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
    when :payout
      return unless Run.active?(args)

      args.state.stay_payout = Campaign.complete_run!(args, args.state.run)
      args.state.run = nil
      UI::PayoutAnimation.start!(args)
    end
  end

end

def reset(args)
  DR.reset
end
