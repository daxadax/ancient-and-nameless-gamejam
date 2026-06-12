module Traits
  DATA_FILE = 'data/traits/traits.json'.freeze
  DEFAULT_TEXT = 'The shift ended without incident. Probably.'.freeze

  def self.all
    @all ||= $gtk.parse_json_file(DATA_FILE) || []
  end

  def self.by_id(id)
    all.find { |entry| entry['trait'] == id.to_s }
  end

  def self.ids
    all.map { |entry| entry['trait'] }
  end

  def self.tagline_for(trait_id)
    by_id(trait_id)&.fetch('tagline')
  end

  def self.stat_bonuses_for(trait_id)
    bonuses = by_id(trait_id)&.fetch('stat_bonuses', nil)
    return {} unless bonuses

    bonuses.transform_keys(&:to_s).transform_values(&:to_i)
  end

  def self.station_entry(trait_id, station_id)
    by_id(trait_id)&.dig('stations', station_id.to_s)
  end

  def self.first_station_entry(trait_ids, station_id)
    trait_ids.each do |trait_id|
      entry = station_entry(trait_id, station_id)
      return entry if entry
    end

    nil
  end

  def self.band_for_total(total)
    return :fail if total <= 3
    return :mid if total <= 7

    :success
  end

  def self.effects_key(band)
    case band
    when :fail then 'effects_fail'
    when :success then 'effects_success'
    end
  end

  def self.substitute(text, name)
    text.to_s.split('<name>').join(name.to_s)
  end

  def self.build_outcome(entry, primary_total)
    band = band_for_total(primary_total)
    band_key = band.to_s
    text = entry[band_key] || DEFAULT_TEXT
    effects_key = effects_key(band)
    effects = effects_key ? (entry[effects_key] || {}) : {}

    {
      'text' => text,
      'effects' => effects,
      'mara' => mara_for_event(entry, band_key),
      'events' => entry['events'] || {}
    }
  end

  def self.mara_for_event(entry, band_key)
    events = entry['events']
    return nil unless events

    event = events[band_key]
    return nil unless event

    event['mara']
  end
end
