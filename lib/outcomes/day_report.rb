require 'lib/outcomes/evening_outcomes'

module DayReport
  def self.build(run)
    used_beat_ids = Array(run.used_evening_beat_ids).dup
    pages = []

    run.last_resolve.each do |result|
      station_flags = EveningOutcomes.normalize_flags(result[:effects])
      beats = EveningOutcomes.beats_for_station(
        result[:station],
        station_flags,
        result[:station_meters],
        exclude_ids: used_beat_ids
      )

      beats.each { |beat| used_beat_ids << beat['id'] }

      pages << {
        station_id: result[:station],
        station_label: result[:station_label],
        result: result,
        beats: beats
      }
    end

    compound_beats = EveningOutcomes.compound_page_beats(run, exclude_ids: used_beat_ids)
    compound_beats.each { |beat| used_beat_ids << beat['id'] }

    run.used_evening_beat_ids = used_beat_ids

    pages << mara_page(run) if run.mara_asides&.any?

    pages << {
      station_id: :compound,
      station_label: 'Evening',
      result: nil,
      beats: compound_beats,
      meter_summary: EveningOutcomes.format_meter_summary(EveningOutcomes.meter_deltas(run))
    }

    pages
  end

  def self.mara_page(run)
    {
      station_id: :mara,
      station_label: 'Mara',
      result: nil,
      beats: [],
      mara_asides: run.mara_asides.dup
    }
  end
end
