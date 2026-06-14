require 'lib/economy'
require 'lib/review'

module StayPayout
  def self.for_run(run)
    stars = Review.build(run)[:stars]
    base = Economy.base_payout_per_stay

    {
      stars: stars,
      base: base,
      bonus: 0,
      penalty: 0,
      total: base
    }
  end
end
