#!/usr/bin/env ruby
# Sync config/publish.local.txt into metadata/game_metadata.txt for packaging.

GAME_ROOT = File.expand_path('..', __dir__)
LOCAL_CONFIG = File.join(GAME_ROOT, 'config', 'publish.local.txt')
EXAMPLE_CONFIG = File.join(GAME_ROOT, 'config', 'publish.example.txt')
METADATA_FILE = File.join(GAME_ROOT, 'metadata', 'game_metadata.txt')

METADATA_KEYS = %w[
  devid
  devtitle
  gameid
  gametitle
  version
  icon
  ignore_directories
  ignore_directories_recursively
].freeze

def load_config(path)
  File.readlines(path).each_with_object({}) do |line, config|
    line = line.strip
    next if line.empty? || line.start_with?('#')

    key, value = line.split('=', 2)
    next unless key && value

    config[key.strip] = value.strip
  end
end

def upsert_metadata_line(lines, key, value)
  pattern = /^#?\s*#{Regexp.escape(key)}=/
  replacement = "#{key}=#{value}"

  lines.each_with_index do |line, index|
    next unless line.match?(pattern)

    lines[index] = "#{replacement}\n"
    return lines
  end

  insert_at = lines.index { |line| line.match?(/^orientation=/) } || lines.length
  lines.insert(insert_at, "#{replacement}\n")
  lines
end

def sync!
  unless File.exist?(LOCAL_CONFIG)
    warn "Missing #{LOCAL_CONFIG}"
    warn "Copy #{EXAMPLE_CONFIG} to config/publish.local.txt and fill in your values."
    exit 1
  end

  unless File.exist?(METADATA_FILE)
    warn "Missing #{METADATA_FILE}"
    exit 1
  end

  config = load_config(LOCAL_CONFIG)
  missing = METADATA_KEYS.reject { |key| config.key?(key) }
  unless missing.empty?
    warn "Missing keys in publish.local.txt: #{missing.join(', ')}"
    exit 1
  end

  lines = File.readlines(METADATA_FILE)
  METADATA_KEYS.each do |key|
    lines = upsert_metadata_line(lines, key, config.fetch(key))
  end

  File.write(METADATA_FILE, lines.join)
  puts "Synced publish config into #{METADATA_FILE}"
end

sync!
