require 'lib/economy'
require 'lib/outcomes/evening_outcomes'

module StayRefunds
  def self.for_run(run, jitter_seed: 0)
    flags = EveningOutcomes.normalize_flags(run.stay_flags)
    billable_flags(flags).map do |flag|
      entry = refund_entry(flag)
      base = entry.fetch('amount').to_i
      amount = jittered_amount(base, flag, jitter_seed)

      {
        flag: flag,
        label: entry.fetch('label'),
        base: base,
        amount: amount
      }
    end
  end

  def self.total(items)
    items.sum { |item| item[:amount] }
  end

  def self.billable_flags(flags)
    grouped = []
    selected = []

    refund_groups.each do |group|
      triggered = group.map(&:to_sym).select { |flag| flags[flag] }
      next if triggered.empty?

      flag = triggered.max_by { |f| refund_entry(f).fetch('amount').to_i }
      selected << flag
      group.each { |member| grouped << member.to_sym unless grouped.include?(member.to_sym) }
    end

    Economy.event_refunds.each_key do |flag_name|
      flag = flag_name.to_sym
      next if grouped.include?(flag)
      next unless flags[flag]

      selected << flag
    end

    selected.sort_by { |flag| -refund_entry(flag).fetch('amount').to_i }
  end

  def self.jittered_amount(base, flag, jitter_seed)
    return base if base.zero?

    pct = Economy.refund_jitter_pct
    spread = (base * pct).to_i
    return base if spread.zero?

    rng = Random.new(jitter_seed_for(flag, jitter_seed))
    # NOTE: DragonRuby Random#rand does not accept ranges; use integer span instead.
    (base + rng.rand(2 * spread + 1) - spread).clamp(1, base + spread)
  end

  def self.jitter_seed_for(flag, jitter_seed)
    (jitter_seed.to_i * 1_000) + flag.to_s.bytes.sum
  end

  def self.refund_entry(flag)
    Economy.event_refunds.fetch(flag.to_s)
  end

  def self.refund_groups
    Economy.refund_groups
  end
end
