local gears = require('gears')
local awful = require('awful')
local wibox = require('wibox')
local beautiful = require('beautiful')

local fs = require('elegant.fs')
local apps = require('lib/apps')
local programlist = require('components/programlist')
local textfield = require('lib/textfield')

return function (s, config)
  local programs = apps.load()
  
  local list = programlist({ programs = programs, max = 12 })

  local launcher = awful.popup({
    widget = {
      widget = wibox.container.background,
      bg = beautiful.bg_normal,
      forced_width = 384,
      {
        layout = wibox.layout.fixed.vertical,
        {
          widget = wibox.container.margin,
          margins = 8,
        },
        list,
      },
    },
    ontop = true,
    placement = function (c) awful.placement.left(c, { offset = { x = 304, y = 0 } }) end,
    visible = false,
  })
  
  function launcher:show(close_callback)
    self.close_callback = close_callback
    list.selected = 1
    list:update(programs)
    self.searchbar.value = ''
    self.searchbar.position = { head = 0, tail = 0 }
    self.keygrabber:start()
    self.searchbar:focus()
    self.visible = true
  end
  
  function launcher:close(again)
    self.visible = false
    self.searchbar:unfocus()
    self.keygrabber:stop()
    self.close_callback(again)
  end
  
  local function launch()
    cmd = list.programs[list.selected] and list.programs[list.selected].exec or launcher.searchbar.value
    awful.spawn.with_shell(cmd)
    launcher:close(false)
  end
  
  local function close()
    launcher:close(true)
  end
  
  local function change_selection(by)
    list.selected = math.min(math.max(list.selected + by, 1), #list.programs)
    list:update(list.programs)
  end
  
  launcher.keygrabber = awful.keygrabber({
    keybindings = {
      {{}, 'Return', launch },
      {{}, 'Escape', close },
      {{}, 'Down', function () change_selection(1) end },
      {{}, 'Up', function () change_selection(-1) end },
    },
  })
  
  local function input_callback(value)
    local filtered = {}
    for _, program in ipairs(programs) do
      if (program.name:lower():find(value:lower(), 1, true)) then table.insert(filtered, program) end
    end
    list.selected = math.min(list.selected, math.max(#filtered, 1))
    list:update(filtered)
  end
  
  launcher.searchbar = textfield({
    keygrabber = launcher.keygrabber,
    placeholder = 'search',
    input_callback = input_callback,
    font = beautiful.font:sub(1, -3)..'16',
  })
  
  launcher.widget.widget.children[1].widget = launcher.searchbar
  
  return {
    name = 'Launcher',
    icon = beautiful.icon_launcher,
    run = function (close_callback) launcher:show(close_callback) end,
  }
end

