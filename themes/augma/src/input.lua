local awful = require('awful')
local gears = require('gears')
local menubar = require('menubar')
local pactl = require('lib.pactl')

local function get_global_keys(config)
  return {
    -- awesome
    awful.key({ config.modkey, 'Control' }, 'r', awesome.restart),
    awful.key({ config.modkey, 'Shift'   }, 'q', awesome.quit),
    awful.key({ config.modkey,           }, 'p', function ()
      local s = awful.screen.focused()
      if s then s.launcher:open() end
    end),

    awful.key({ config.modkey            }, 'w', function ()
      local s = awful.screen.focused()
      if s then s.overlay.ontop = not s.overlay.ontop end
    end),

    -- focus
    awful.key({ config.modkey }, 'j', function () awful.client.focus.byidx( 1) end),
    awful.key({ config.modkey }, 'k', function () awful.client.focus.byidx(-1) end),

    -- layout
    awful.key({ config.modkey          }, 'u',     awful.client.urgent.jumpto),
    awful.key({ config.modkey, 'Shift' }, 'j',     function () awful.client.swap.byidx( 1) end),
    awful.key({ config.modkey, 'Shift' }, 'k',     function () awful.client.swap.byidx(-1) end),
    awful.key({ config.modkey          }, 'Left',  awful.tag.viewprev),
    awful.key({ config.modkey          }, 'Right', awful.tag.viewnext),
    awful.key({ config.modkey,         }, 'space', function () awful.layout.inc( 1) end),
    awful.key({ config.modkey, 'Shift' }, 'space', function () awful.layout.inc(-1) end),

    -- terminal
    awful.key({ config.modkey }, 'Return', function () awful.spawn(config.terminal) end),

    -- un-minimize last-minimized client
    awful.key({ config.modkey, 'Control' }, 'n', function ()
      local c = awful.client.restore()
      -- Focus restored client
      if c then
        c:emit_signal('request::activate', 'key.unminimize', { raise = true })
      end
    end),

    -- system
    awful.key({         }, 'XF86MonBrightnessUp', function () awful.spawn('xbacklight -inc 10') end),
    awful.key({         }, 'XF86MonBrightnessDown', function () awful.spawn('xbacklight -dec 10') end),

    awful.key({         }, 'XF86AudioRaiseVolume', function () pactl.set_default_sink_volume('+5%') end),
    awful.key({         }, 'XF86AudioLowerVolume', function () pactl.set_default_sink_volume('-5%') end),
    awful.key({         }, 'XF86AudioMute', function () pactl.set_default_sink_mute('toggle') end),

    awful.key({         }, 'Print', function () awful.spawn.with_shell('maim ~/pictures/screenshots/"$(date +%s%0N).png"') end),
    awful.key({ "Shift" }, 'Print', function () awful.spawn.with_shell('maim -su ~/pictures/screenshots/"$(date +%s%0N).png"') end),

    awful.key({ config.modkey }, 'l', function () awful.spawn.with_shell(([[
      env
      XSECURELOCK_NO_COMPOSITE=1
      XSECURELOCK_PASSWORD_PROMPT=asterisks                  
      XSECURELOCK_FONT="FiraCode Nerd Font"
      XSECURELOCK_SAVER=/home/leaf/saver.sh                       
      XSECURELOCK_IMAGE_PATH=/home/leaf/pictures/backgrounds/Yuuki/753516.2.png                         
      XSECURELOCK_AUTH_BACKGROUND_COLOR="rgb:62/48/6d"
      xsecurelock
    ]]):gsub('\n', ' ')) end),
  }
end


local function get_tag_keys(config, index)
  return {
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
  }
end


local function get_client_keys(config)
  return {
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
  }
end


local function get_global_buttons(config)
  return {}
end


local function get_client_buttons(config)
  return {
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
  }
end

local input = {}
function input.setup(config)
  input.global_keys = get_global_keys(config);
  input.global_buttons = get_global_buttons(config)

  for index = 1, #config.tags do
    local tag_keys = get_tag_keys(config, index)
    input.global_keys = gears.table.join(input.global_keys, tag_keys)
  end

  input.client_keys = get_client_keys(config)
  input.client_buttons = get_client_buttons(config)

  root.keys = input.global_keys
  root.buttons = input.global_buttons
end

return input

