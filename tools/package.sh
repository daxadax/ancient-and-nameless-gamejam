#!/bin/bash
# Build itch.io packages locally without uploading.
#
# Usage (from game/):
#   ./tools/package.sh

set -euo pipefail

GAME_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
DR_ROOT="$(cd "$GAME_ROOT/.." && pwd)"
LOCAL_CONFIG="$GAME_ROOT/config/publish.local.txt"

ruby "$GAME_ROOT/tools/sync_publish_metadata.rb"

platforms="$(ruby -e "
  config = {}
  File.readlines('$LOCAL_CONFIG').each do |line|
    line = line.strip
    next if line.empty? || line.start_with?('#')
    key, value = line.split('=', 2)
    config[key.strip] = value.strip if key && value
  end
  puts config.fetch('platforms', 'html5,linux-amd64')
")"

cd "$DR_ROOT"
./dragonruby-publish --package --platforms="$platforms" game

echo
echo "Build output: $DR_ROOT/build"
