local awful = require('awful')
local lgi = require('lgi')
local promise = require('lib/promise')
local menubar_utils = require('menubar.utils')

local table = table

local Desktop = { cache = {} }

function Desktop.list()
  return promise.new(function (resolve)
    local list = {}
    awful.spawn.with_line_callback('find /usr/share/applications/', {
      stdout = function (line)
        if line == '/usr/share/applications/' then return end
        table.insert(list, lgi.Gio.DesktopAppInfo.new_from_filename(line))
      end,
      output_done = function ()
        Desktop.cache = list
        resolve(list)
      end,
    })
  end)
end

function Desktop.get_icon(desktop_file)
  local keyfile = lgi.GLib.KeyFile()
  keyfile:load_from_file(desktop_file.filename, lgi.GLib.KeyFileFlags.NONE)
  local icon_name = keyfile:get_locale_string('Desktop Entry', 'Icon')
  return icon_name and menubar_utils.lookup_icon(icon_name), icon_name
end

return Desktop

