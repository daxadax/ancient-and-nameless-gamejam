require 'lib/traits'

module StationOutcomes
  DATA_DIR = 'data/resolve/stations'.freeze

  def self.entry(station_id)
    load(station_id.to_sym)
  end

  FALLBACK = {
    'text' => Traits::DEFAULT_TEXT,
    'effects' => {},
    'mara' => nil,
    'events' => {}
  }.freeze

  def self.pick(station_id, primary_total)
    entry = entry(station_id)
    return FALLBACK unless entry

    Traits.build_outcome(entry, primary_total)
  end

  def self.load(station_id)
    @cache ||= {}
    return @cache[station_id] if @cache.key?(station_id)

    path = "#{DATA_DIR}/#{station_id}.json"
    @cache[station_id] = $gtk.parse_json_file(path)
  end
end
