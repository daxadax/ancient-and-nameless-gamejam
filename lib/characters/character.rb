class Character
  METER_KEYS = [:vibes, :food, :cleanliness, :authenticity].freeze
  MARA_DATA_FILE = 'data/characters/mara.json'.freeze

  def self.wrap(data)
    return data if data.is_a?(Character)

    new(data)
  end

  def self.mara_data
    @mara_data ||= $gtk.parse_json_file(MARA_DATA_FILE)
  end

  def self.mara
    wrap(mara_data)
  end

  def initialize(data)
    @data = data
  end

  def id
    @data['id'].to_s
  end

  def display_name
    @data['name']
  end

  def mod(meter)
    stats = @data['stats'] || {}
    stats[meter.to_s].to_i
  end

  def traits
    (@data['traits'] || []).map(&:to_sym)
  end

  def tagline
    @data['tagline']
  end

  def bio
    @data['bio']
  end

  def portrait_color
    @data['portrait_color']
  end

  def initial
    display_name.to_s[0]
  end

  def resolve_file
    @data['resolve_file']
  end

  def bespoke_resolve?
    resolve_file && !resolve_file.empty?
  end

  def to_h
    @data
  end
end
