local awful = require('awful')
local gears = require('gears')
local wibox = require('wibox')
local beautiful = require('beautiful')
local menubar_utils = require('menubar.utils')
local fzy = require('fzy')

local textfield = require('lib/textfield')
local Desktop = require('lib/desktop')

local App = require('src.launcher.app')

return function(s, config)
  local launcher = wibox({
    screen = s,
    visible = false,
    ontop = true,

    width = s.geometry.width,
    height = s.geometry.height,
    x = 0,
    y = 0,

    bg = '#0000003f',
  })

  local list = wibox.widget({
    layout = wibox.layout.grid.vertical,
    forced_num_cols = 8,
    forced_num_rows = 6,
    min_cols_size = 64,
    min_rows_size = 64,
    homogeneous = true,
    spacing = 16,
    expand = true,
  })

  local searchbar

  local function update_name()
    local widget = launcher:get_children_by_id('name')[1]
    if (not launcher.focused_app) then
      widget.markup = ''
      return
    end
    local name = launcher.focused_app.desktop_file:get_display_name()
    if (#searchbar.value <= 0) then
      widget.markup = gears.string.xml_escape(name)
      return
    end
    local positions = fzy.positions(searchbar.value, name)
    local text = ''
    for i, pos in ipairs(positions) do
      if (i ~= 1 and pos - positions[i - 1] == 1) then
        text = text .. gears.string.xml_escape(name:sub(pos, pos))
      else
        if (i ~= 1) then text = text .. '</b>' end
        text = text .. gears.string.xml_escape(name:sub(i ~= 1 and positions[i - 1] + 1 or 1, pos - 1)) .. '<b>' .. gears.string.xml_escape(name:sub(pos, pos))
      end
    end
    text = text .. '</b>' .. gears.string.xml_escape(name:sub(positions[#positions] + 1, #name))
    widget.markup = text
  end

  local function search()
    launcher.keygrabber:stop()
    searchbar:focus()
  end

  local function launch()
    if (launcher.focused_app) then launcher.focused_app.desktop_file:launch() end
  end

  local function navigate()
    searchbar.keygrabber:stop()
    searchbar:unfocus()
    launcher.keygrabber:start()
  end


  local function right()
    local idx = launcher.focused_app and list:index(launcher.focused_app) or 0
    if (launcher.focused_app) then launcher.focused_app:unfocus() end
    launcher.focused_app = list.children[math.min(idx + 1, #list.children)]
    if (launcher.focused_app) then launcher.focused_app:focus() end
    update_name()
  end

  local function left()
    local idx = launcher.focused_app and list:index(launcher.focused_app) or 0
    if (launcher.focused_app) then launcher.focused_app:unfocus() end
    launcher.focused_app = list.children[math.max(idx - 1, 1)]
    if (launcher.focused_app) then launcher.focused_app:focus() end
    update_name()
  end

  local function up()
    local _, cols = list:get_dimension()
    local idx = launcher.focused_app and list:index(launcher.focused_app) or 0
    if (launcher.focused_app) then launcher.focused_app:unfocus() end
    launcher.focused_app = list.children[math.max(idx - cols, 1)]
    if (launcher.focused_app) then launcher.focused_app:focus() end
    update_name()
  end

  local function down()
    local _, cols = list:get_dimension()
    local idx = launcher.focused_app and list:index(launcher.focused_app) or 0
    if (launcher.focused_app) then launcher.focused_app:unfocus() end
    launcher.focused_app = list.children[math.min(idx + cols, #list.children)]
    if (launcher.focused_app) then launcher.focused_app:focus() end
    update_name()
  end

  launcher.keygrabber = awful.keygrabber({
    keybindings = {
      awful.key({}, 'Escape', function()
        launcher:close()
      end),
      awful.key({}, 'Return', function()
        launch()
        launcher:close()
      end),
      awful.key({}, 'Tab', right),
      awful.key({ 'Shift' }, 'Tab', left),
      awful.key({}, 'Right', right),
      awful.key({}, 'Left', left),
      awful.key({}, 'Up', up),
      awful.key({}, 'Down', down),
    },
    keypressed_callback = function (self, mod, key)
      if (key == '/') then search() end
    end
  })

  searchbar = textfield({
    placeholder = 'search...',
    bg = '#00000000',
    font = beautiful.font:sub(1, -3) .. '16',
    keygrabber = awful.keygrabber({
      keybindings = {
        awful.key({}, 'Escape', function()
          launcher:close()
        end),
        awful.key({}, 'Return', function()
          launch()
          launcher:close()
        end),
        awful.key({}, 'Tab', function()
          searchbar.keygrabber:stop()
          navigate()
        end),
      },
    }),
    input_callback = function () launcher:update() end
  })

  function launcher:open()
    launcher.visible = true
    searchbar.value = ''
    launcher:update()
    search()
  end

  function launcher:close()
    searchbar.keygrabber:stop()
    launcher.keygrabber:stop()
    searchbar:unfocus()
    launcher.visible = false
  end

  function launcher:update()
    if (launcher.focused_app) then launcher.focused_app:unfocus() end

    local filtered = {}
    for _, app in ipairs(launcher.apps) do
      if
        app.desktop_file:should_show(menubar_utils.wm_name)
        and (#searchbar.value <= 0 or fzy.has_match(searchbar.value, app.desktop_file:get_display_name()))
      then table.insert(filtered, app) end
    end

    if (#searchbar.value > 0) then
      table.sort(filtered, function (a, b)
        return fzy.score(searchbar.value, a.desktop_file:get_display_name()) > fzy.score(searchbar.value, b.desktop_file:get_display_name())
      end)
    end

    list:reset()
    for i, app in ipairs(filtered) do
      if (i <= 8 * 6) then
        list:add(app)
      end
    end

    launcher.focused_app = filtered[1]
    if (launcher.focused_app) then launcher.focused_app:focus() end
    update_name()
  end

  launcher:setup({
    widget = wibox.container.place,
    {
      widget = wibox.container.background,
      bg = beautiful.bg_normal .. '3f',
      shape = function (c, w, h) gears.shape.rounded_rect(c, w, h, 8) end,
      {
        widget = wibox.container.margin,
        margins = 16,
        {
          layout = wibox.layout.fixed.vertical,
          spacing = 16,
          {
            widget = wibox.container.background,
            bg = beautiful.bg_normal .. '3f',
            shape = function (c, w, h) gears.shape.rounded_rect(c, w, h, 8) end,
            {
              widget = wibox.container.margin,
              margins = 8,
              {
                layout = wibox.layout.fixed.horizontal,
                spacing = 8,
                searchbar,
                {
                  widget = wibox.container.background,
                  fg = '#3f3f3f',
                  {
                    widget = wibox.widget.textbox,
                    font = beautiful.font:sub(1, -3) .. '14',
                    id = 'name',
                  },
                },
              }
            },
          },
          list,
        },
      },
    },
  })

  Desktop.list().next(function (desktop_files)
    launcher.apps = {}
    for _, desktop_file in ipairs(desktop_files) do
      table.insert(launcher.apps, App(desktop_file, {
        click_callback = function (self)
          self.desktop_file:launch()
          launcher:close()
        end,
        hover_callback = function (self)
          if (launcher.focused_app) then launcher.focused_app:unfocus() end
          launcher.focused_app = self
          update_name()
        end,
      }))
    end

    launcher:update()
  end)

  return launcher
end

