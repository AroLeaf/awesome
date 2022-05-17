local gears = require('gears')
local menubar = require('menubar')
local beautiful = require('beautiful')
local fs = require('lib/fs')

local DEFAULT_DIRS = { '/usr/share/applications/' }
local json = require('lib/lunajson')

local function parse_desktop_file(path)
  local program = {}
  local data = fs.read(path)
  local lines = gears.string.split(data, '\n')
  local in_entry = false
  for _, line in ipairs(lines) do
    if (in_entry) then
      if (gears.string.startswith(line, '[')) then
        in_entry = false
      else
        local key, value = line:match('^(.-)=(.+)$')
        if (key and value) then program[key] = value end
      end
    elseif (line == '[Desktop Entry]') then
      in_entry = true
    end
  end
  
  if (program.Exec) then
    program.Exec = program.Exec
      :gsub('%%c', program.Name)
      :gsub('%%[fuFUi]', '')
      :gsub('%%k', path)
    if (program.Terminal == 'true') then program.Exec = menubar.utils.terminal..' -e '..program.Exec end
  end
  
  return {
    name = program.Name or program.GenericName,
    description = program.Comment or program.GenericName or '',
    icon = program.Icon and menubar.utils.lookup_icon(program.Icon) or beautiful.icon_not_found,
    exec = program.Exec,
    display = program.NoDisplay ~= 'true',
  }
end

local function find_desktop_files(dirs)
  local files = {}
  for _, dir in ipairs(dirs) do
    for _, file in ipairs(fs.scan(dir)) do
      if (gears.string.endswith(file, '.desktop')) then table.insert(files, dir..file) end
    end
  end
  return files
end

local function load_desktop_files(dirs)
  local files = find_desktop_files(dirs or DEFAULT_DIRS)
  local programs = {}
  for _, file in ipairs(files) do
    local parsed = parse_desktop_file(file)
    if (parsed.display and parsed.name) then table.insert(programs, parsed) end
  end
  return programs
end

return {
  parse = parse_desktop_file,
  find = find_desktop_files,
  load = load_desktop_files,
}

