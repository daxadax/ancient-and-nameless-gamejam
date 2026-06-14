module GameConfig
  CONFIG_FILE = 'data/config.json'.freeze

  def self.data
    @data ||= $gtk.parse_json_file(CONFIG_FILE)
  end

  def self.section(name)
    data.fetch(name.to_s, {})
  end

  def self.merge_sections(defaults, file)
    defaults.merge(file) do |_key, default_val, file_val|
      next file_val unless default_val.is_a?(Hash) && file_val.is_a?(Hash)

      default_val.merge(file_val)
    end
  end
end
