require 'lib/campaign'

module CrewRoster
  def self.ids(args)
    Campaign.roster_ids(args)
  end

  def self.character(args, id)
    Campaign.character(args, id)
  end
end
