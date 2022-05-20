local gears = require('gears')
local awful = require('awful')
local wibox = require('wibox')
local beautiful = require('beautiful')
require('awful.hotkeys_popup.keys')
require('awful.autofocus')

local __dirname = debug.getinfo(1).source:match('@?(.*/)')
package.path = __dirname..'?.lua;'..package.path

local get_config = require('elegant.config')
local input = require('util/input')
local rules = require('util/rules')
local menu = require('widgets/menu')
local taglist = require('widgets/taglist')


local function init(options)
  local local_config = get_config(__dirname..'config', {
    colors = 'sao',
  })

  local config = gears.table.join(
    local_config, options.config,
    { save_local = local_config.save }
  )

  local themes = options.themes
  local modkey = config.modkey

  -- init theme colors
  beautiful.init(__dirname..'colors/'..config.colors..'.lua')

  -- select available layouts
  awful.layout.layouts = {
    awful.layout.suit.spiral.dwindle,
    awful.layout.suit.fair,
    awful.layout.suit.max,
    awful.layout.suit.floating,
  }

  -- set up screens
  awful.screen.connect_for_each_screen(function(s)
    -- taglist
    s.taglist = taglist(s, config)
    -- menu
    s.menu = menu(s, config)
  end)

  client.connect_signal('manage', function (c)
    -- prevent clients from being unreachable after screen count changes.
    if awesome.startup
      and not c.size_hints.user_position
      and not c.size_hints.program_position
    then
      awful.placement.no_offscreen(c)
    end
  end)

  -- Enable sloppy focus, so that focus follows mouse.
  client.connect_signal('mouse::enter', function(c)
    c:emit_signal('request::activate', 'mouse_enter', {raise = false})
  end)
  
  -- autostart additional programs
  awful.spawn.with_shell(__dirname..'autostart.sh')
end


return gears.table.join(
  input, rules, {
    init = init,
    client_rules = client_rules,
  }
)

