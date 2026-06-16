require 'lib/economy'
require 'lib/review'
require 'lib/stay/refunds'

module StayPayout
  def self.for_run(run, jitter_seed: 0)
    stars = Review.stars_for(run)
    base = Economy.base_payout_per_stay
    bonus = Economy.star_bonus(stars)
    star_penalty = Economy.star_penalty(stars)
    refunds = StayRefunds.for_run(run, jitter_seed: jitter_seed)
    refund_total = StayRefunds.total(refunds)
    total = [base + bonus - star_penalty - refund_total, 0].max

    {
      stars: stars,
      base: base,
      bonus: bonus,
      star_penalty: star_penalty,
      refunds: refunds,
      refund_total: refund_total,
      penalty: star_penalty + refund_total,
      total: total,
      lines: line_items(base, bonus, star_penalty, refunds)
    }
  end

  def self.line_items(base, bonus, star_penalty, refunds)
    items = [{ label: 'Stay payout', amount: base }]
    items << { label: 'Star bonus', amount: bonus } if bonus.positive?

    refunds.each do |refund|
      items << { label: refund[:label], amount: -refund[:amount] }
    end

    items << { label: 'Guest refund', amount: -star_penalty } if star_penalty.positive?
    items
  end
end
