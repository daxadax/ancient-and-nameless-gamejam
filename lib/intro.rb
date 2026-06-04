require 'lib/campaign'

module Intro
  DATA_FILE = 'data/intro/beats.json'.freeze

  def self.beats
    @beats ||= $gtk.parse_json_file(DATA_FILE) || []
  end

  def self.reset!(args)
    args.state.intro = { step: 0 }
  end

  def self.complete!(args)
    Campaign.mark_intro_seen!(args)
    args.state.next_scene = :crew_select
  end

  def self.active?(args)
    !args.state.intro.nil?
  end

  def self.current(args)
    beats[args.state.intro[:step]]
  end

  def self.last?(args)
    args.state.intro[:step] >= beats.length - 1
  end

  def self.advance!(args)
    next_step = args.state.intro[:step] + 1
    return :done if next_step >= beats.length

    args.state.intro[:step] = next_step
    :more
  end
end
