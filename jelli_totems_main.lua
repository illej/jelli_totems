
local panel = {
    state = 'closed'
}

local timer = nil

local earth_totems_learned = {}
local fire_totems_learned = {}
local water_totems_learned = {}
local air_totems_learned = {}

local btn = CreateFrame("BUTTON", "my_button", UIParent, "SecureActionButtonTemplate")
btn:RegisterEvent("COMBAT_LOG_EVENT")
btn:RegisterEvent("SPELLS_CHANGED")
btn:SetScript("OnEvent", function(self, event, ...)
    if event == "SPELLS_CHANGED" then
        load_spells(self)
    else
        eventHandler(self, event, CombatLogGetCurrentEventInfo())
    end
end)

function load_totems(totems)
    local learned = {}
    local idx = 1

    for _, t in pairs(totems) do
        local name, rank, icon, castTime, minRange, maxRange, spellId = GetSpellInfo(t)
        if name then
            learned[idx] = name
            idx = idx + 1
        end
    end

    return learned
end

function load_spells(self)
    local earth_totems = {
        "Stoneskin Totem",
        "Earthbind Totem",
        "Stoneclaw Totem",
        "Strength of Earth Totem",
        "Tremor Totem",
    }
    local fire_totems = {
        "Searing Totem",
        "Fire Nova Totem",
        "Frost Resistance Totem",
        "Magma Totem",
        "Flametongue Totem",
    }
    local water_totems = {
        "Healing Stream Totem",
        "Poison Cleansing Totem",
        "Mana Spring Totem",
        "Fire Resistance Totem",
        "Disease Cleansing Totem"
    }
    local air_totems = {
        -- TODO
    }

    earth_totems_learned = load_totems(earth_totems)
    fire_totems_learned = load_totems(fire_totems)
    water_totems_learned = load_totems(water_totems)
    air_totems_learned = load_totems(air_totems)
end

function eventHandler(self, event, ...)
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

function jelli_open(keystate)
    if panel.state == 'closed' then
        panel.state = 'open'

        SetOverrideBinding(btn, true, "1", "Earth Totem")
        SetOverrideBinding(btn, true, "2", "Fire Totem")
        SetOverrideBinding(btn, true, "3", "Water Totem")
        SetOverrideBinding(btn, true, "4", "Air Totem")

        print('[1: Earth]')
        print('[2: Fire]')
        print('[3. Water]')
        print('[4. Air]')
        print(' ')

        timer = C_Timer.NewTimer(3, jelli_finish)
    elseif panel.state == 'open' then
        jelli_finish()
    end
end

function jelli_finish()
    panel.state = 'closed'
    ClearOverrideBindings(btn)

    if timer then
        timer:Cancel()
        timer = nil
    end
end

function process_key(keystate, element)
    local bindings = {}
    bindings["earth"] = earth_totems_learned
    bindings["fire"] = fire_totems_learned
    bindings["water"] = water_totems_learned
    bindings["air"] = air_totems_learned
    
    if keystate == "up" then
        bind_elements(bindings[element])
    end
end

function bind_elements(totems)
    for i, totem in pairs(totems) do
        SetOverrideBindingSpell(btn, true, i, totem)
        print('['..i..': '..totem..']')
    end
    print(' ')
end