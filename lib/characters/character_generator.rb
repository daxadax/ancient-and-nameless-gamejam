require 'lib/characters/character'
require 'lib/characters/traits'

module CharacterGenerator
  STAGES_FILE = 'data/generation/stages.json'.freeze
  NAMES_FILE = 'data/generation/names.json'.freeze

  def self.generate_recruits(seed, stage: 1)
    rng = Random.new(seed)
    count = recruit_count(stage: stage)
    names = name_pool.dup.shuffle(rng).first(count)
    traits = Traits.ids.dup.shuffle(rng).first(count)

    count.times.map do |index|
      trait = traits[index]
      tagline = Traits.tagline_for(trait)

      {
        'id' => "r#{seed}_#{index}",
        'name' => names[index],
        'stats' => generate_stats(rng, trait: trait),
        'traits' => [trait],
        'tagline' => tagline,
        'portrait_color' => portrait_color(rng),
        'bio' => tagline
      }
    end
  end

  def self.generate_stats(rng, trait: nil)
    stats = random_stat_rolls(rng)
    apply_trait_bonuses!(stats, trait)
    stats
  end

  def self.random_stat_rolls(rng)
    keys = Character::METER_KEYS.map(&:to_s)
    stats = keys.to_h { |key| [key, 0] }

    weak = keys[rng.rand(keys.length)]
    stats[weak] = -1

    others = keys.reject { |key| key == weak }
    (rng.rand(2) + 1).times do
      key = others[rng.rand(others.length)]
      stats[key] += 1 if stats[key] < 2
    end

    stats
  end

  def self.apply_trait_bonuses!(stats, trait)
    Traits.stat_bonuses_for(trait).each do |key, bonus|
      stats[key] += bonus
    end
  end

  def self.portrait_color(rng)
    {
      r: 80 + rng.rand(120),
      g: 70 + rng.rand(110),
      b: 60 + rng.rand(100)
    }
  end

  def self.recruit_count(stage: 1)
    stage_config(stage)['recruit_count'].to_i
  end

  def self.stage_config(stage)
    stages = $gtk.parse_json_file(STAGES_FILE) || {}
    stages[stage.to_s] || stages['1'] || { 'recruit_count' => 3 }
  end

  def self.name_pool
    $gtk.parse_json_file(NAMES_FILE) || []
  end
end
