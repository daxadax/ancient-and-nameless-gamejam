#!/usr/bin/env ruby
# Skip DragonRuby's click-to-play splash; start the game as soon as data loads.
# Browsers still unlock audio on the first in-game click/tap.

DR_ROOT = File.expand_path('../..', __dir__)
BUILD_DIR = Dir.glob(File.join(DR_ROOT, 'builds', 'culty-towers-html5-*')).max
LOADER = BUILD_DIR && File.join(BUILD_DIR, 'dragonruby-html5-loader.js')

AUTO_START_CALLBACK = <<~JS.chomp
    loadDataFiles(GDragonRubyGameId, 'gamedata/', function() {
      console.log("Game data is sync'd to MEMFS.");
      Module.setStatus("");
      statusElement.style.display='none';
      document.getElementById('progressdiv').style.display='none';
      startGame();
      window.gtk.play = Module.clickToPlayListener;
    });
JS

unless BUILD_DIR && File.exist?(LOADER)
  warn 'No html5 build found; skipping loader patch.'
  exit 0
end

content = File.read(LOADER)
unless content.match?(/loadDataFiles\(GDragonRubyGameId, 'gamedata\/', function\(\)/)
  warn "loadDataFiles callback not found in #{LOADER}"
  exit 1
end

patched = content.sub(
  /loadDataFiles\(GDragonRubyGameId, 'gamedata\/', function\(\) \{.*?\n    \}\);/m,
  AUTO_START_CALLBACK
)

if patched == content
  warn 'Loader patch made no changes.'
  exit 1
end

File.write(LOADER, patched)

zip_path = File.join(DR_ROOT, 'builds', 'culty-towers-html5.zip')
Dir.chdir(BUILD_DIR) do
  system('zip', '-qr', zip_path, '.') || exit(1)
end

puts "Patched #{LOADER} and rebuilt #{zip_path}"
