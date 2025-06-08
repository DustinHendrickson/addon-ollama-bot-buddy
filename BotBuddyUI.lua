local buffers = {
    state = "",
    commands = "",
    locations = "",
    players = ""
}

local function ExpandMultiline(text)
    local lines = {}
    for chunk in string.gmatch(text or "", "([^|]+)") do
        chunk = chunk:gsub("^%s+", ""):gsub("%s+$", "")
        table.insert(lines, chunk)
    end
    return table.concat(lines, "\n")
end

local function UpdateBotBuddyState(text)
    if BotBuddyStateFrameText then
        BotBuddyStateFrameText:SetText(ExpandMultiline(text))
    end
end

local function UpdateBotBuddyCommand(text)
    if BotBuddyCommandFrameText then
        local entries = {}
        for entry in string.gmatch(text, "([^|]+)") do
            table.insert(entries, entry)
        end

        local output = "Last Commands:\n"
        for _, entry in ipairs(entries) do
            output = output .. entry:gsub("^%s+", ""):gsub("%s+$", "") .. "\n"
        end

        BotBuddyCommandFrameText:SetText(output)
    end
end

local function UpdateBotBuddyLocations(text)
    if BotBuddyLocationsFrameText then
        BotBuddyLocationsFrameText:SetText(ExpandMultiline(text))
    end
end

local function UpdateBotBuddyPlayers(text)
    if BotBuddyPlayersFrameText then
        BotBuddyPlayersFrameText:SetText(ExpandMultiline(text))
    end
end

local function UpdateTextBuffer(section, text, updateFunc)
    buffers[section] = buffers[section] .. text .. "|"
    updateFunc(buffers[section])
    buffers[section] = ""
end

local function OnChatMsg(event, msg, author, ...)
    local state = msg:match("^%[BUDDY_STATE%]%s*(.+)")
    if state then
        UpdateTextBuffer("state", state, UpdateBotBuddyState)
        return
    end

    local cmds = msg:match("^%[BUDDY_COMMANDS?%]%s*(.+)")
    if cmds then
        UpdateTextBuffer("commands", cmds, UpdateBotBuddyCommand)
        return
    end

    local locs = msg:match("^%[BUDDY_LOCATIONS%]%s*(.+)")
    if locs then
        UpdateTextBuffer("locations", locs, UpdateBotBuddyLocations)
        return
    end

    local players = msg:match("^%[BUDDY_PLAYERS%]%s*(.+)")
    if players then
        UpdateTextBuffer("players", players, UpdateBotBuddyPlayers)
        return
    end
end

local sysFrame = CreateFrame("Frame")
sysFrame:RegisterEvent("CHAT_MSG_SYSTEM")
sysFrame:SetScript("OnEvent", function(self, event, ...)
    OnChatMsg(event, ...)
end)

local function MakeDragHandle(handle, frame)
    if not handle or not frame then return end
    handle:EnableMouse(true)
    handle:SetScript("OnMouseDown", function(self, btn)
        if btn == "LeftButton" then
            frame:StartMoving()
        end
    end)
    handle:SetScript("OnMouseUp", function(self, btn)
        frame:StopMovingOrSizing()
    end)
end

local function AddResizeGrip(frame)
    local grip = CreateFrame("Frame", nil, frame)
    grip:SetSize(16, 16)
    grip:SetPoint("BOTTOMRIGHT")
    grip:EnableMouse(true)
    grip:SetScript("OnMouseDown", function() frame:StartSizing("BOTTOMRIGHT") end)
    grip:SetScript("OnMouseUp", function() frame:StopMovingOrSizing() end)
    grip:SetBackdrop({
        bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
        tile = true, tileSize = 16,
    })
    grip:SetBackdropColor(0.5, 0.5, 0.5, 0.7)
end

local function HookResizeToText(frame, fontString, padX, padY)
    frame:SetScript("OnSizeChanged", function(self, width, height)
        fontString:SetWidth(width - padX)
        fontString:SetHeight(height - padY)
    end)
end

local function SetupBotBuddyPanels()
    if BotBuddyStateFrame and BotBuddyStateFrameTitleBar and BotBuddyStateFrameText then
        BotBuddyStateFrame:SetMovable(true)
        BotBuddyStateFrame:SetResizable(true)
        BotBuddyStateFrame:SetClampedToScreen(true)
        BotBuddyStateFrame:SetMinResize(200, 150)
        MakeDragHandle(BotBuddyStateFrameTitleBar, BotBuddyStateFrame)
        AddResizeGrip(BotBuddyStateFrame)
        HookResizeToText(BotBuddyStateFrame, BotBuddyStateFrameText, 30, 40)
        BotBuddyStateFrame:Show()
    end

    if BotBuddyCommandFrame and BotBuddyCommandFrameTitleBar and BotBuddyCommandFrameText then
        BotBuddyCommandFrame:SetMovable(true)
        BotBuddyCommandFrame:SetResizable(true)
        BotBuddyCommandFrame:SetClampedToScreen(true)
        BotBuddyCommandFrame:SetMinResize(200, 150)
        MakeDragHandle(BotBuddyCommandFrameTitleBar, BotBuddyCommandFrame)
        AddResizeGrip(BotBuddyCommandFrame)
        HookResizeToText(BotBuddyCommandFrame, BotBuddyCommandFrameText, 30, 40)
        BotBuddyCommandFrame:Show()
    end

    if BotBuddyLocationsFrame and BotBuddyLocationsFrameTitleBar and BotBuddyLocationsFrameText then
        BotBuddyLocationsFrame:SetMovable(true)
        BotBuddyLocationsFrame:SetResizable(true)
        BotBuddyLocationsFrame:SetClampedToScreen(true)
        BotBuddyLocationsFrame:SetMinResize(200, 150)
        MakeDragHandle(BotBuddyLocationsFrameTitleBar, BotBuddyLocationsFrame)
        AddResizeGrip(BotBuddyLocationsFrame)
        HookResizeToText(BotBuddyLocationsFrame, BotBuddyLocationsFrameText, 30, 40)
        BotBuddyLocationsFrame:Show()
    end

    if BotBuddyPlayersFrame and BotBuddyPlayersFrameTitleBar and BotBuddyPlayersFrameText then
        BotBuddyPlayersFrame:SetMovable(true)
        BotBuddyPlayersFrame:SetResizable(true)
        BotBuddyPlayersFrame:SetClampedToScreen(true)
        BotBuddyPlayersFrame:SetMinResize(200, 150)
        MakeDragHandle(BotBuddyPlayersFrameTitleBar, BotBuddyPlayersFrame)
        AddResizeGrip(BotBuddyPlayersFrame)
        HookResizeToText(BotBuddyPlayersFrame, BotBuddyPlayersFrameText, 30, 40)
        BotBuddyPlayersFrame:Show()
    end
end

local BotBuddyOptionsPanel
local function TogglePanelVisibility(panelName, isVisible)
    local frame = _G[panelName]
    if frame then
        if isVisible then
            frame:Show()
        else
            frame:Hide()
        end
    end
end

local function CreateCheckbox(name, parent, label, x, y, initialValue, onClick)
    local cb = CreateFrame("CheckButton", name, parent, "InterfaceOptionsCheckButtonTemplate")
    cb:SetPoint("TOPLEFT", x, y)
    local text = _G[cb:GetName() .. "Text"]
    if text then text:SetText(label) end
    cb:SetChecked(initialValue)
    cb:SetScript("OnClick", function(self)
        local checked = self:GetChecked()
        onClick(checked)
    end)
    return cb
end

local function CreateOptionsPanel()
    BotBuddyOptionsPanel = CreateFrame("Frame", "BotBuddyOptionsPanel", UIParent)
    BotBuddyOptionsPanel.name = "BotBuddy UI"

    local title = BotBuddyOptionsPanel:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
    title:SetPoint("TOPLEFT", 16, -16)
    title:SetText("BotBuddy UI Settings")

    CreateCheckbox("BotBuddyShowState", BotBuddyOptionsPanel, "Show Bot State Panel", 16, -50, true, function(checked)
        TogglePanelVisibility("BotBuddyStateFrame", checked)
    end)

    CreateCheckbox("BotBuddyShowCommands", BotBuddyOptionsPanel, "Show Commands Panel", 16, -80, true, function(checked)
        TogglePanelVisibility("BotBuddyCommandFrame", checked)
    end)

    CreateCheckbox("BotBuddyShowLocations", BotBuddyOptionsPanel, "Show Locations Panel", 16, -110, true, function(checked)
        TogglePanelVisibility("BotBuddyLocationsFrame", checked)
    end)

    CreateCheckbox("BotBuddyShowPlayers", BotBuddyOptionsPanel, "Show Players Panel", 16, -140, true, function(checked)
        TogglePanelVisibility("BotBuddyPlayersFrame", checked)
    end)

    InterfaceOptions_AddCategory(BotBuddyOptionsPanel)
end

local frameLoader = CreateFrame("Frame")
frameLoader:RegisterEvent("PLAYER_ENTERING_WORLD")
frameLoader:SetScript("OnEvent", function()
    CreateOptionsPanel()
    SetupBotBuddyPanels()
end)
