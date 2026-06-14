require 'lib/economy'
require 'lib/review'

module StayPayout
  def self.for_run(run)
    stars = Review.stars_for(run)
    base = Economy.base_payout_per_stay
    bonus = Economy.star_bonus(stars)
    penalty = Economy.star_penalty(stars)
    total = [base + bonus - penalty, 0].max

    {
      stars: stars,
      base: base,
      bonus: bonus,
      penalty: penalty,
      total: total,
      lines: line_items(base, bonus, penalty)
    }
  end

  def self.line_items(base, bonus, penalty)
    items = [{ label: 'Stay payout', amount: base }]
    items << { label: 'Star bonus', amount: bonus } if bonus.positive?
    items << { label: 'Guest refund', amount: -penalty } if penalty.positive?
    items
  end
end
