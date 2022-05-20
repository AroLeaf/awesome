local gears = require('gears')
local awful = require('awful')
local menubar = require('menubar')
local hotkeys_popup = require('awful.hotkeys_popup')

local pamixer = require('lib/pamixer')

local function global_keys(config)
  return gears.table.join(
    -- awesome
    awful.key({ config.modkey, 'Control' }, 'r', awesome.restart,          { description = 'reload awesome', group = 'awesome' }),
    awful.key({ config.modkey, 'Shift'   }, 'q', awesome.quit,             { description = 'quit awesome', group = 'awesome' }),
    awful.key({ config.modkey            }, 'h', hotkeys_popup.show_help,  { description = 'show help', group = 'awesome' }),
    
    -- menu
    awful.key({ config.modkey          }, 'w', function () awful.screen.focused().menu:show() end, { description = 'show main menu', group = 'menu' }),
    awful.key({ config.modkey          }, 'p', function () awful.screen.focused().menu:show(1) end, { description = 'show the launcher', group = 'menu' }),
    awful.key({ config.modkey          }, 'a', function () awful.screen.focused().menu:show(2) end, { description = 'show the audio settings', group = 'menu' }),
    awful.key({ config.modkey, 'Shift' }, 'c', function () awful.screen.focused().menu:show(3) end, { description = 'change color scheme', group = 'menu' }),

    -- focus
    awful.key({ config.modkey }, 'j', function () awful.client.focus.byidx( 1) end, { description = 'focus next by index', group = 'client' }),
    awful.key({ config.modkey }, 'k', function () awful.client.focus.byidx(-1) end, { description = 'focus previous by index', group = 'client' }),

    -- layout
    awful.key({ config.modkey          }, 'u', awful.client.urgent.jumpto,                   { description = 'jump to urgent client', group = 'client' }),
    awful.key({ config.modkey, 'Shift' }, 'j', function () awful.client.swap.byidx(  1) end, { description = 'swap with next client by index', group = 'client' }),
    awful.key({ config.modkey, 'Shift' }, 'k', function () awful.client.swap.byidx( -1) end, { description = 'swap with previous client by index', group = 'client' }),
    awful.key({ config.modkey          }, 'Left',   awful.tag.viewprev,                      { description = 'view previous', group = 'tag' }),
    awful.key({ config.modkey          }, 'Right',  awful.tag.viewnext,                      { description = 'view next', group = 'tag' }),
    awful.key({ config.modkey,         }, 'space', function () awful.layout.inc( 1) end,     { description = 'select next', group = 'layout' }),
    awful.key({ config.modkey, 'Shift' }, 'space', function () awful.layout.inc(-1) end,     { description = 'select previous', group = 'layout' }),

    -- terminal
    awful.key({ config.modkey }, 'Return', function () awful.spawn(config.terminal) end, { description = 'open a terminal', group = 'launcher' }),

    -- un-minimize last-minimized client
    awful.key({ config.modkey, 'Control' }, 'n', function ()
      local c = awful.client.restore()
      -- Focus restored client
      if c then
        c:emit_signal('request::activate', 'key.unminimize', { raise = true })
      end
    end, { description = 'restore minimized', group = 'client' }),

    -- taglist
    awful.key({ config.modkey }, 'i', function()
      awful.screen.focused().taglist.ontop = not awful.screen.focused().taglist.ontop
    end, { description = 'toggle the taglist', group = 'tag' }),

    -- system
    awful.key({         }, 'XF86MonBrightnessUp', function () awful.spawn('xbacklight -inc 10') end,   { description = 'raise screen brightness', group = 'system' }),
    awful.key({         }, 'XF86MonBrightnessDown', function () awful.spawn('xbacklight -dec 10') end, { description = 'lower screen brightness', group = 'system' }),
    awful.key({         }, 'XF86AudioRaiseVolume', function () pamixer.inc(5) end, { description = 'raise volume', group = 'system' }),
    awful.key({         }, 'XF86AudioLowerVolume', function () pamixer.dec(5) end, { description = 'lower volume', group = 'system' }),
    awful.key({         }, 'XF86AudioMute', function () if (pamixer.muted()) then pamixer.unmute() else pamixer.mute() end end, { description = 'mute/unmute volume', group = 'system' }),
    awful.key({         }, 'Print', function () awful.spawn.with_shell('maim ~/pictures/screenshots/"$(date +%s%N).png"') end, { description = 'take a screenshot', group = 'system' }),
    awful.key({ "Shift" }, 'Print', function () awful.spawn.with_shell('maim -s ~/pictures/screenshots/"$(date +%s%N).png"') end, { description = 'take a screenshot of a selected area', group = 'system' })
  )
end


local function tag_keys(config, index)
  return gears.table.join(
    -- Toggle tag display.
    awful.key({ config.modkey, 'Control' }, '#'..index + 9, function ()
      local screen = awful.screen.focused()
      local tag = screen.tags[index]
      if tag then
        awful.tag.viewtoggle(tag)
      end
    end, { description = 'toggle tag #'..index, group = 'tag' }),
    
    -- Toggle tag on focused client.
    awful.key({ config.modkey, 'Control', 'Shift' }, '#'..index + 9, function ()
      if client.focus then
        local tag = client.focus.screen.tags[index]
        if tag then
          client.focus:toggle_tag(tag)
        end
      end
    end, { description = 'toggle focused client on tag #'..index, group = 'tag' }),

    -- View tag only.
    awful.key({ config.modkey }, '#'..index + 9, function ()
      local screen = awful.screen.focused()
      local tag = screen.tags[index]
      if tag then
        tag:view_only()
      end
    end, { description = 'view tag #'..index, group = 'tag' }),
    
    -- Move client to tag.
    awful.key({ config.modkey, 'Shift' }, '#'..index + 9, function ()
      if client.focus then
        local tag = client.focus.screen.tags[index]
        if tag then
          client.focus:move_to_tag(tag)
        end
      end
    end, { description = 'move focused client to tag #'..index, group = 'tag' })
  )
end


local function client_keys(config)
  return gears.table.join(
    awful.key({ config.modkey            }, 'c',     function (c) c:kill() end, { description = 'close', group = 'client' }),
    awful.key({ config.modkey, 'Control' }, 'space', awful.client.floating.toggle,           { description = 'toggle floating', group = 'client' }),
    awful.key({ config.modkey,           }, 't',     function (c) c.ontop = not c.ontop end, { description = 'toggle keep on top', group = 'client' }),
    awful.key({ config.modkey,           }, 'n',     function (c) c.minimized = true end,    { description = 'minimize', group = 'client' }),

    awful.key({ config.modkey }, 'f', function (c)
      c.fullscreen = not c.fullscreen
      c:raise()
    end, { description = 'toggle fullscreen', group = 'client' }),

    awful.key({ config.modkey }, 'm', function (c)
      c.maximized = not c.maximized
      c:raise()
    end, { description = '(un)maximize', group = 'client' }),

    awful.key({ config.modkey, 'Control' }, 'm', function (c)
      c.maximized_vertical = not c.maximized_vertical
      c:raise()
    end, { description = '(un)maximize vertically', group = 'client' }),

    awful.key({ config.modkey, 'Shift' }, 'm', function (c)
      c.maximized_horizontal = not c.maximized_horizontal
      c:raise()
    end, { description = '(un)maximize horizontally', group = 'client' })
  )
end


local function global_buttons()
  -- none rn
end


local function client_buttons(config)
  return gears.table.join(
    awful.button({ }, 1, function (c)
      c:emit_signal('request::activate', 'mouse_click', {raise = true})
    end),
    awful.button({ config.modkey }, 1, function (c)
      c:emit_signal('request::activate', 'mouse_click', {raise = true})
      awful.mouse.client.move(c)
    end),
    awful.button({ config.modkey }, 3, function (c)
      c:emit_signal('request::activate', 'mouse_click', {raise = true})
      awful.mouse.client.resize(c)
    end)
  )
end

return {
  global_keys = global_keys,
  tag_keys = tag_keys,
  client_keys = client_keys,

  global_buttons = global_buttons,
  client_buttons = client_buttons,
}

