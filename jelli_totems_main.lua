
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


-- And so begins the secure death loop

-- CreateFrame("Button", "ElementBinder", UIParent, "SecureHandlerClickTemplate")
-- TotemPanel:SetAttribute("_onclick", [[
--   self:GetChildren():SetAttribute("_type", rebind_phase_1)
-- ]])


-- CreateFrame("Button", "RotateSpellCast", RotateSpellNext, "ecureHandlerClickTemplate")
-- RotateSpellCast:SetAttribute("type", "spell")
-- RotateSpellCast:SetAttribute("spell", "Flame Shock")

-- -- temp

-- local element_binder = CreateFrame("BUTTON", "ElementBinder", UIParent, "SecureHandlerClickTemplate");
-- element_binder:SetAttribute("_onclick", [=[
--     if button == "LeftButton" then    
--         self:SetBindingClick(true, "1", "EarthBtn")
--         self:SetBindingClick(true, "2", "FireBtn")
--         -- etc for water and air
--     end
-- ]=]);

-- local earth_btn = CreateFrame("BUTTON", "EarthBtn", element_binder, "SecureHandlerClickTemplate")
-- earth_btn:SetAttribute("_onclick", [=[
--     if button == "LeftButton" then
--         self:SetBindingSpell(true, "1", "Earthbind Totem")
--         self:SetBindingSpell(true, "2", "Strength of Earth Totem")
--         -- etc for the rest of the earth totems
--     end
-- ]=])

-- local fire = CreateFrame("BUTTON", "fire", panel, "SecureHandlerClickTemplate")
-- fire:SetAttribute("_onclick", [=[
--     if button == "LeftButton" then
--         print('> fire')
--         self:SetBindingSpell(true, "1", "Searing Totem")
--         self:SetBindingSpell(true, "2", "Fire Nova Totem")
--     end
-- ]=])
-- fire:WrapScript(fire, "PostClick", [[
--     print('post')
--     local p = self:GetParent()
--     p:ClearBindings()    
-- ]])

-- dude on forums

-- The button configs
local Config = {
    {
        {
            type = "macro",
            macrotext = "/run print('1-1')"
        },
        {
            type = "macro",
            macrotext = "/run print('1-2')"
        },
    },
    {
        {
            type = "macro",
            macrotext = "/run print('2-1')"
        },
    },
    {
        {
            type = "macro",
            macrotext = "/run print('3-1')"
        },
    },
}
 
-- A mananger frame to control all secure behaviors
local _ManagerFrame = CreateFrame("Frame", "TwoLevelKeyManager", UIParent, "SecureHandlerStateTemplate")
 
_ManagerFrame.Execute = SecureHandlerExecute
_ManagerFrame.WrapScript = function(self, frame, script, preBody, postBody) return SecureHandlerWrapScript(frame, script, self, preBody, postBody) end
_ManagerFrame.SetFrameRef = SecureHandlerSetFrameRef
 
_ManagerFrame:Execute[[
    Manager = self
 
    ToggleButtons = newtable()
    ToggleState = newtable()
 
    -- secure code snippets to be run by manager
    CloseFinalLevel = [==[
        local index = ...
        print("CloseFinalLevel", index)
        if ToggleState[index] then
            ToggleState[index] = false
 
            for i, btn in ipairs(ToggleButtons[index]) do
                print("Clear Bind", btn:GetName())
                btn:ClearBinding("" .. i)
            end
        end
        print("Clear Bind", ToggleButtons[index][0]:GetName())
        ToggleButtons[index][0]:ClearBinding("" .. index)
    ]==]
 
    OpenFinalLevel = [==[
        local index = ...
        print("OpenFinalLevel", index)
        if not ToggleState[index] then
            ToggleState[index] = true
 
            for i, btn in ipairs(ToggleButtons[index]) do
                print("Bind", btn:GetName())
                btn:SetBindingClick(true, "" .. i, btn:GetName(), "LeftButton")
            end
        end
    ]==]
 
    ToggleRoot = [==[
        print("ToggleRoot", not ToggleState[0])
        if ToggleState[0] then
            -- Clear binding for all
            ToggleState[0] = false
 
            for i, buttons in ipairs(ToggleButtons) do
                Manager:Run(CloseFinalLevel, i)
            end
        else
            -- Bind key to first level
            ToggleState[0] = true
 
            for i, buttons in ipairs(ToggleButtons) do
                print("Bind", buttons[0]:GetName())
                buttons[0]:SetBindingClick(true, "" .. i, buttons[0]:GetName(), "LeftButton")
            end
        end
    ]==]
]]
 
-- Create buttons
local rootbtn = CreateFrame("CheckButton", "RootToggle", UIParent, "SecureActionButtonTemplate")
 
-- Bind the root key
SetOverrideBindingClick(rootbtn, true, "F", "RootToggle", "LeftButton")
 
-- Toggle the first level button's key binding
_ManagerFrame:WrapScript(rootbtn, "OnClick", [[Manager:Run(ToggleRoot)]])
 
-- Generate the first and second level buttons and register them to the mananger
for i, firstlvl in ipairs(Config) do
    local btn = CreateFrame("CheckButton", "FirstLvlToggle" .. i, UIParent, "SecureActionButtonTemplate")
    _ManagerFrame:SetFrameRef("FirstLvlToggle", btn)
 
    for j, nxtlvl in ipairs(firstlvl) do
        local fbtn = CreateFrame("CheckButton", "NxtLvlToggle" .. i .. "_" .. j, UIParent, "SecureActionButtonTemplate")
        _ManagerFrame:SetFrameRef("NxtLvlToggle" .. j, fbtn)
 
        for k, v in pairs(nxtlvl) do
            fbtn:SetAttribute(k, v) -- Bind marco
        end
 
        -- Clear all key bindings after click the second level button
        _ManagerFrame:WrapScript(fbtn, "OnClick", [[return button, true]], [[Manager:Run(ToggleRoot)]])
    end
 
    _ManagerFrame:Execute(string.format([[
        local index, count = %d, %d
        local buttons = newtable()
        buttons[0] = Manager:GetFrameRef("FirstLvlToggle")
        print("Register: ", index, buttons[0]:GetName())
        for i = 1, count do
            buttons[i] = Manager:GetFrameRef("NxtLvlToggle" .. i)
            print("Register: ", buttons[i]:GetName())
        end
 
        ToggleButtons[index] = buttons
    ]], i, #firstlvl))
 
    -- Bind the key to the second level
    _ManagerFrame:WrapScript(btn, "OnClick", string.format([[Manager:Run(OpenFinalLevel, %d)]], i))
end
local panel = CreateFrame("BUTTON", "TotemPanel", UIParent, "SecureHandlerClickTemplate");
panel:SetAttribute("_onclick", [=[
    if button == "LeftButton" then    
        print('> TotemPanel')
        self:SetBindingClick(true, "1", "earth")
        self:SetBindingClick(true, "2", "fire")
    end
]=]); 

local earth = CreateFrame("BUTTON", "earth", panel, "SecureHandlerClickTemplate")
earth:SetAttribute("_onclick", [=[
    if button == "LeftButton" then
        print('> earth')
        self:SetBindingSpell(true, "1", "Earthbind Totem")
        self:SetBindingSpell(true, "2", "Strength of Earth Totem")
    end
]=])

local fire = CreateFrame("BUTTON", "fire", panel, "SecureHandlerClickTemplate")
fire:SetAttribute("_onclick", [=[
    if button == "LeftButton" then
        print('> fire')
        self:SetBindingSpell(true, "1", "Searing Totem")
        self:SetBindingSpell(true, "2", "Fire Nova Totem")
    end
]=])
fire:WrapScript(fire, "PostClick", [[
    print('post')
    local p = self:GetParent()
    p:ClearBindings()    
]])