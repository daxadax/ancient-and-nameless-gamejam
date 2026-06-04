require 'lib/cultists'

module CrewRoster
  DATA_FILE = 'data/crew/roster.json'.freeze

  PLACEHOLDER_COLORS = {
    aldous: { r: 196, g: 168, b: 118 },
    jules: { r: 168, g: 148, b: 188 },
    dmitros: { r: 72, g: 68, b: 82 },
    mara: { r: 118, g: 58, b: 72 }
  }.freeze

  def self.entries
    @entries ||= $gtk.parse_json_file(DATA_FILE) || {}
  end

  def self.ids
    Cultists::IDS
  end

  def self.entry(id)
    entries[id.to_s]
  end

  def self.portrait_path(_id)
    nil
  end
end
