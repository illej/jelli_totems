
-- The button configs
local Config = {
    { -- earth totem
        {
            type = "macro",
            macrotext = "/cast Earthbind Totem"
        },
        {
            type = "macro",
            -- macrotext = "/run print('1-2')"
            macrotext = "/cast Strength of Earth Totem"
        },
        {
            type = "macro",
            -- macrotext = "/run print('1-2')"
            macrotext = "/cast Stoneskin Totem"
        },
    },
    { -- fire totem
        {
            type = "macro",
            -- macrotext = "/run print('2-1')"
            macrotext = "/cast Searing Totem"
        },
        {
            type = "macro",
            macrotext = "/cast Fire Nova Totem"
        },
        {
            type = "macro",
            macrotext = "/cast Magma Totem"
        },
    },
    { -- water totem
        {
            type = "macro",
            macrotext = "/cast Healing Stream Totem"
        },
        {
            type = "macro",
            macrotext = "/cast Mana Stream Totem"
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
        print("Register", index, buttons[0]:GetName())
        for i = 1, count do
            buttons[i] = Manager:GetFrameRef("NxtLvlToggle" .. i)
            print("Register", buttons[i]:GetName())
        end
 
        ToggleButtons[index] = buttons
    ]], i, #firstlvl))
 
    -- Bind the key to the second level
    _ManagerFrame:WrapScript(btn, "OnClick", string.format([[Manager:Run(OpenFinalLevel, %d)]], i))
end