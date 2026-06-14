require 'lib/game_config'

module Economy
  def self.config
    @config ||= GameConfig.section('economy')
  end

  def self.base_payout_per_stay
    config.fetch('base_payout_per_stay').to_i
  end

  def self.farm_save_goal
    config.fetch('farm_save_goal').to_i
  end

  def self.star_bonus(stars)
    config.fetch('star_bonuses', {}).fetch(stars.to_s, 0).to_i
  end

  def self.star_penalty(stars)
    config.fetch('star_penalties', {}).fetch(stars.to_s, 0).to_i
  end
end
