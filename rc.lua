local awful = require('awful')
local naughty = require('naughty')
local elegant = require('elegant')

if awesome.startup_errors then
  naughty.notify({
    preset = naughty.config.presets.critical,
    title = "Oops, there were errors during startup!",
    text = awesome.startup_errors,
  })
end

elegant.load()

awful.layout.layouts = {
  awful.layout.suit.floating,
  awful.layout.suit.fair,
  awful.layout.suit.max,
}

