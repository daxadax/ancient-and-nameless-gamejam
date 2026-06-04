require 'lib/cultists'

module CrewRolls
  MIN_SPREAD = 4

  def self.default_stats
    Cultists::IDS.to_h { |id| [id, { primary_sum: 0, roll_count: 0 }] }
  end

  def self.record!(run, cultist_id, primary_total)
    entry = run.crew_rolls[cultist_id]
    entry.primary_sum += primary_total.to_i
    entry.roll_count += 1
  end

  def self.summary(run)
    stats = run.crew_rolls
    ranked = Cultists::IDS
      .select { |id| stats[id].roll_count.positive? }
      .sort_by { |id| stats[id].primary_sum }

    return nil if ranked.length < 2

    worst_id = ranked.first
    best_id = ranked.last
    spread = stats[best_id].primary_sum - stats[worst_id].primary_sum

    {
      best_id: best_id,
      best_sum: stats[best_id].primary_sum,
      worst_id: worst_id,
      worst_sum: stats[worst_id].primary_sum,
      spread: spread
    }
  end

  def self.callout?(run)
    summary = summary(run)
    summary && summary[:spread] >= MIN_SPREAD
  end
end
