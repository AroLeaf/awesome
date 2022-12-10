local gears = require('gears')
local awful = require('awful')
local wibox = require('wibox')
local beautiful = require('beautiful')

local clipboard = ''

return function (options)
  options = options or {}

  local textfield = wibox.widget({
    widget = wibox.container.background,
    bg = options.bg or beautiful.bg_normal,
    {
      fg = options.fg or beautiful.fg_normal,
      font = options.font or beautiful.font,
      widget = wibox.widget.textbox,
      markup = options.placeholder or '...',
    },
  })

  function textfield:update()
    local cursor = '<span foreground="'..gears.color.ensure_pango_color(beautiful.fg_cursor)..'">|</span>'
    local selection = function (text) return
      '<span background="'
      ..gears.color.ensure_pango_color(beautiful.bg_selection)
      ..'">'
      ..gears.string.xml_escape(text)
      ..'</span>'
    end

    local value = #self.value > 0 and self.value or options.placeholder or ''

    if (not self.focused) then
      self.widget.markup = gears.string.xml_escape(value)
    elseif (self.position.head == self.position.tail) then
      self.widget.markup =
        gears.string.xml_escape(value:sub(0, self.position.head))
        ..cursor..
        gears.string.xml_escape(value:sub(self.position.head + 1, -1))
    elseif (self.position.head < self.position.tail) then
      self.widget.markup =
        gears.string.xml_escape(value:sub(0, self.position.head))
        ..cursor..selection(value:sub(self.position.head + 1, self.position.tail))..
        gears.string.xml_escape(value:sub(self.position.tail + 1, -1))
    else
      self.widget.markup =
        gears.string.xml_escape(value:sub(0, self.position.tail))
        ..selection(value:sub(self.position.tail + 1, self.position.head))..cursor..
        gears.string.xml_escape(value:sub(self.position.head + 1, -1))
    end
  end

  function textfield:focus()
    self.focused = true
    self.keygrabber:start()
    self.position = {
      head = #self.value,
      tail = #self.value,
    }
    self:update()
  end

  function textfield:unfocus()
    self.focused = false
    self:update()
  end

  textfield:connect_signal('button::press', function (self, lx, ly, button)
    if (button == 1) then
      textfield:focus()
    end
  end)

  textfield.focused = options.autostart or false
  textfield.value = options.value or ''
  textfield.position = { head = 0, tail = 0 }

  textfield.keygrabber = options.keygrabber or awful.keygrabber({
    stop_key = { 'Escape', 'Return' },
    stop_callback = function (_, key) textfield:unfocus() end,
  })

  local function replaceAt(from, to, text)
    textfield.value = textfield.value:sub(0, math.min(from, to))..text..textfield.value:sub(math.max(from, to) + 1, -1)
    textfield.position.head = math.min(from, to) + #text
    textfield.position.tail = math.min(from, to) + #text
  end

  local function copyAt(from, to)
    local min = math.min(from, to)
    local max = math.max(from, to)
    clipboard = textfield.value:sub(min + 1, max)
  end

  textfield.keygrabber.keypressed_callback = function (_, mod, key)
    if (key == 'BackSpace' and #textfield.value > 0) then
      if (textfield.position.head == textfield.position.tail) then
        replaceAt(textfield.position.head, textfield.position.tail - 1, '')
      else
        replaceAt(textfield.position.head, textfield.position.tail, '')
      end
      if (options.input_callback) then options.input_callback(textfield.value) end

    elseif (key == 'Left') then
      if (not gears.table.hasitem(mod, 'Shift') and textfield.position.head ~= textfield.position.tail) then
        textfield.position.head = math.min(textfield.position.head, textfield.position.tail)
        textfield.position.tail = textfield.position.head
      else
        local pos = gears.table.hasitem(mod, 'Control')
          and textfield.value:sub(0, textfield.position.head):find('[%a%d_]*[^%a%d_]*$')
          or textfield.position.head
        textfield.position.head = math.max(pos - 1, 0)
        if (not gears.table.hasitem(mod, 'Shift')) then textfield.position.tail = textfield.position.head end
      end

    elseif (key == 'Right') then
      if (not gears.table.hasitem(mod, 'Shift') and textfield.position.head ~= textfield.position.tail) then
        textfield.position.head = math.max(textfield.position.head, textfield.position.tail)
        textfield.position.tail = textfield.position.head
      else
        local offset = gears.table.hasitem(mod, 'Control')
          and table.pack(textfield.value:sub(textfield.position.head + 1, -1):find('^[^%a%d_]*[%a%d_]*'))[2] 
          or 1
        textfield.position.head = math.min(textfield.position.head + offset, #textfield.value)
        if (not gears.table.hasitem(mod, 'Shift')) then textfield.position.tail = textfield.position.head end
      end

    elseif (key == 'a' and gears.table.hasitem(mod, 'Control')) then
      textfield.position.head = #textfield.value
      textfield.position.tail = 0

    elseif (key == 'x' and gears.table.hasitem(mod, 'Control')) then
      copyAt(textfield.position.head, textfield.position.tail)
      replaceAt(textfield.position.head, textfield.position.tail, '')
      if (options.input_callback) then options.input_callback(textfield.value) end

    elseif (key == 'c' and gears.table.hasitem(mod, 'Control')) then
      copyAt(textfield.position.head, textfield.position.tail)

    elseif (key == 'v' and gears.table.hasitem(mod, 'Control')) then
      replaceAt(textfield.position.head, textfield.position.tail, clipboard)
      if (options.input_callback) then options.input_callback(textfield.value) end

    elseif (#key == 1) then
      replaceAt(textfield.position.head, textfield.position.tail, key)
      if (options.input_callback) then options.input_callback(textfield.value) end
    end

    textfield:update()
  end

  return textfield
end

