local function client_rules(config)
  return {
    -- floating clients
    {
      rule_any = {
        instance = {
          'DTA',
          'copyq',
          'pinentry',
        },
        class = {
          'Arandr',
          'Blueman-manager',
          'Gpick',
          'Sxiv',
          'Tor Browser', -- Needs a fixed window size to avoid fingerprinting by screen size.
          'Wpa_gui',
          'veromix',
          'xtightvncviewer'
        },
        name = { 'Event Tester' },
        role = { 'pop-up' }
      },
      properties = { floating = true }
    }
  }
end

return {
  client_rules = client_rules,
}

