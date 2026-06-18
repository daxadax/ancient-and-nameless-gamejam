#!/usr/bin/env ruby
# Replace DragonRuby's branded click-to-play splash with a transparent overlay.
# Browsers still require one click/tap before the game runs (autoplay policy).

DR_ROOT = File.expand_path('../..', __dir__)
BUILD_DIR = Dir.glob(File.join(DR_ROOT, 'builds', 'culty-towers-html5-*')).max
LOADER = BUILD_DIR && File.join(BUILD_DIR, 'dragonruby-html5-loader.js')

MINIMAL_CLICK_TO_PLAY = <<~JS.chomp
  startClickToPlay: function() {
    var div = document.createElement('div');
    div.id = 'clicktoplaydiv';
    div.style.width = '100%';
    div.style.height = '100%';
    div.style.position = 'absolute';
    div.style.top = '0';
    div.style.left = '0';
    div.style.backgroundColor = 'transparent';
    div.style.cursor = 'pointer';
    document.body.appendChild(div);
    div.addEventListener('click', Module.clickToPlayListener);
    document.addEventListener("keydown", Module.enterPressedCallback);
    window.gtk.play = Module.clickToPlayListener;
  }
JS

unless BUILD_DIR && File.exist?(LOADER)
  warn 'No html5 build found; skipping loader patch.'
  exit 0
end

content = File.read(LOADER)
unless content.match?(/startClickToPlay: function\(\)/)
  warn "startClickToPlay not found in #{LOADER}"
  exit 1
end

patched = content.sub(/startClickToPlay: function\(\) \{.*?\n  \},/m, "#{MINIMAL_CLICK_TO_PLAY},")
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
