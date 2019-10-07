print('hello!')

local panel = {
    state = 'closed'
}

local btn, evts = CreateFrame("BUTTON", "my_button", UIParent, "SecureActionButtonTemplate")
btn:RegisterEvent("COMBAT_LOG_EVENT")
btn:SetScript("OnEvent", function(self, event, ...)
    eventHandler(self, event, CombatLogGetCurrentEventInfo())
end)

function eventHandler(self, event, ...)
    -- print('event: '..event)
    if event == "COMBAT_LOG_EVENT" then
     local timestamp, combatEvent, hideCaster, sourceGUID, sourceName, sourceFlags, sourceRaidFlags, destGUID, destName, destFlags, destRaidFlags = 
      ...; -- Those arguments appear for all combat event variants.
     local eventPrefix, eventSuffix = combatEvent:match("^(.-)_?([^_]*)$");
    --  print('> '..eventPrefix..' - '..eventSuffix..'('..combatEvent..')')
     if eventSuffix == "DAMAGE" then
      -- Something dealt damage. The last 9 arguments in ... describe how much damage was dealt.
      -- To extract those, we can use the select function:
      local numArgumentsInVarArg = select("#", ...)
      local amount, overkill, school, resisted, blocked, absorbed, critical, glancing, crushing = 
       select(numArgumentsInVarArg - 8, ...);
      -- Do something with the damage details ... 
      if eventPrefix == "RANGE" or eventPrefix:match("^SPELL") then
       -- The first three arguments for these prefixes (appearing after the 11 common to all COMBAT_LOG_EVENTs) 
       --  describe the spell or ability dealing damage. Extract these using select:
       local spellId, spellName, spellSchool = select(12, ...); -- Everything from 12th argument in ... onward
       -- Do something with the spell details ...
    --    print('spell cast: '..spellName)
      end


      
     end

     if combatEvent == 'SPELL_SUMMON' then
        jelli_finish()
      end
    end
end

local timer = nil

function jelli_open(keystate)
    if panel.state == 'closed' then
        panel.state = 'open'

        SetOverrideBinding(btn, true, "Q", "Earth Totem")
        SetOverrideBinding(btn, true, "W", "Fire Totem")
        SetOverrideBinding(btn, true, "E", "Water Totem")
        SetOverrideBinding(btn, true, "R", "Air Totem")

        print("[Q: Earth][W: Fire][E. Water][R. Air]")
        timer = C_Timer.NewTimer(1, jelli_finish)
    elseif panel.state == 'open' then
        panel.state = 'closed'

        ClearOverrideBindings(btn);
        if timer then
            timer:Cancel()
            timer = nil
        end
    end
end

function jelli_finish()
    panel.state = 'closed'
    ClearOverrideBindings(btn)
    print(panel.state)
    if timer then
        timer:Cancel()
        timer = nil
    end
end

function jelli_earth_select(keystate)
    SetOverrideBindingSpell(btn, true, "1", "Strength of Earth Totem")
    SetOverrideBindingSpell(btn, true, "2", "Earthbind Totem")

    print("[1. Strength][2. Earthbind]")
end

function jelli_fire_select(keystate)
    SetOverrideBinding(btn, true, "1", "SPELL Searing Totem")
    SetOverrideBindingSpell(btn, true, "2", "Fire Nova Totem")

    print('[1. Searing][2: Fire Nove]')
end