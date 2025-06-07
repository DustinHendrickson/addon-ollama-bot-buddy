local function ExpandMultiline(text)
    local lines = {}
    for chunk in string.gmatch(text, "([^|]+)") do
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
        local main, reason = text:match("^(.-)%s*Reasoning:%s*(.+)$")
        if main and reason then
            BotBuddyCommandFrameText:SetText("Last Command:\n" .. ExpandMultiline(main) .. "\n\nReasoning:\n" .. ExpandMultiline(reason))
        else
            BotBuddyCommandFrameText:SetText("Last Command:\n" .. ExpandMultiline(text))
        end
    end
end

local function UpdateBotBuddyReason(text)
    if BotBuddyCommandFrameText then
        local prev = BotBuddyCommandFrameText:GetText() or ""
        if not prev:find(text, 1, true) then
            BotBuddyCommandFrameText:SetText(prev .. "\nReasoning:\n" .. ExpandMultiline(text))
        end
    end
end

local function OnChatMsg(event, msg, author, ...)
    local state = msg:match("^%[BUDDY_STATE%]%s*(.+)")
    if state then UpdateBotBuddyState(state) return end

    local cmd = msg:match("^%[BUDDY_COMMAND%]%s*(.+)")
    if cmd then UpdateBotBuddyCommand(cmd) return end

    local reason = msg:match("^%[BUDDY_REASON%]%s*(.+)")
    if reason then UpdateBotBuddyReason(reason) return end
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
end

local frameLoader = CreateFrame("Frame")
frameLoader:RegisterEvent("PLAYER_ENTERING_WORLD")
frameLoader:SetScript("OnEvent", function()
    SetupBotBuddyPanels()
end)

SetupBotBuddyPanels()
