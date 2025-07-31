-- Globals defined by the WoW UI system from BotBuddyUI.xml
---@diagnostic disable: undefined-global

-- Frame references (defined in XML)
-- BotBuddyStateFrame, BotBuddyStateFrameTitleBar, BotBuddyStateFrameText
-- BotBuddyCommandFrame, BotBuddyCommandFrameTitleBar, BotBuddyCommandFrameText  
-- BotBuddyLocationsFrame, BotBuddyLocationsFrameTitleBar, BotBuddyLocationsFrameText
-- BotBuddyPlayersFrame, BotBuddyPlayersFrameTitleBar, BotBuddyPlayersFrameText

-- WoW API globals
-- CreateFrame, UIParent, InterfaceOptions_AddCategory, SlashCmdList, _G

-- Color codes for WoW text formatting
local COLORS = {
    HEADER = "|cFFFFD700",      -- Gold
    LABEL = "|cFF00BFFF",       -- Deep Sky Blue
    VALUE = "|cFFFFFFFF",       -- White
    SUCCESS = "|cFF00FF00",     -- Green
    WARNING = "|cFFFFFF00",     -- Yellow
    ERROR = "|cFFFF0000",       -- Red
    RESET = "|r"                -- Reset color
}

-- Helper function to get character-specific settings
local function GetCharacterSettings()
    local playerName = UnitName("player")
    if not playerName then
        playerName = "Unknown"
    end
    
    -- Ensure the database structure exists
    if not BotBuddyUIDB then
        BotBuddyUIDB = {}
    end
    
    if not BotBuddyUIDB.characters then
        BotBuddyUIDB.characters = {}
    end
    
    if not BotBuddyUIDB.characters[playerName] then
        BotBuddyUIDB.characters[playerName] = {
            showState = true,
            showCommands = true,
            showLocations = true,
            showPlayers = true,
            firstLoad = true
        }
    end
    
    return BotBuddyUIDB.characters[playerName]
end

local function ExpandMultiline(text)
    local lines = {}
    for chunk in string.gmatch(text or "", "([^|]+)") do
        chunk = chunk:gsub("^%s+", ""):gsub("%s+$", "")
        if chunk ~= "" then
            table.insert(lines, chunk)
        end
    end
    return table.concat(lines, "\n")
end

local function FormatStateText(text)
    if not text or text == "" then
        return COLORS.WARNING .. "No bot state data available" .. COLORS.RESET
    end
    
    local formatted = COLORS.HEADER .. "Bot State Information" .. COLORS.RESET .. "\n"
    formatted = formatted .. string.rep("=", 30) .. "\n\n"
    
    local lines = {}
    for line in string.gmatch(ExpandMultiline(text), "([^\n]+)") do
        line = line:gsub("^%s+", ""):gsub("%s+$", "")
        if line ~= "" then
            -- Handle bot name (first line without colon)
            if not line:match(":") then
                table.insert(lines, COLORS.SUCCESS .. line .. COLORS.RESET)
            else
                -- Try to identify key-value pairs
                local key, value = line:match("^([^:]+):%s*(.+)$")
                if key and value then
                    -- Color the key
                    local coloredKey = COLORS.LABEL .. key .. ":" .. COLORS.RESET
                    
                    -- Apply special coloring for different value types
                    local coloredValue
                    if key:match("Level") then
                        -- Level numbers - color in yellow
                        coloredValue = COLORS.WARNING .. value .. COLORS.RESET
                    elseif key:match("Class") then
                        -- Class names - color in green
                        coloredValue = COLORS.SUCCESS .. value .. COLORS.RESET
                    elseif key:match("Race") then
                        -- Race names - color in green
                        coloredValue = COLORS.SUCCESS .. value .. COLORS.RESET
                    elseif key:match("Gender") then
                        -- Gender - color in white
                        coloredValue = COLORS.VALUE .. value .. COLORS.RESET
                    elseif key:match("Faction") then
                        -- Faction - color in green
                        coloredValue = COLORS.SUCCESS .. value .. COLORS.RESET
                    elseif key:match("Gold") then
                        -- Gold amount - color in yellow
                        coloredValue = COLORS.WARNING .. value .. COLORS.RESET
                    elseif key:match("Area") then
                        -- Area names - color in white
                        coloredValue = COLORS.VALUE .. value .. COLORS.RESET
                    elseif key:match("Zone") then
                        -- Zone names - color in white
                        coloredValue = COLORS.VALUE .. value .. COLORS.RESET
                    elseif key:match("Map") then
                        -- Map names - color in white
                        coloredValue = COLORS.VALUE .. value .. COLORS.RESET
                    elseif key:match("Position") then
                        -- Coordinates - color each number individually in yellow
                        coloredValue = value:gsub("([%d%.%-]+)", COLORS.WARNING .. "%1" .. COLORS.VALUE)
                        coloredValue = COLORS.VALUE .. coloredValue .. COLORS.RESET
                    elseif line:match("NOT IN COMBAT") then
                        -- Combat status - color in red for visibility
                        coloredValue = COLORS.ERROR .. value .. COLORS.RESET
                    elseif key:match("Quest") and value:match("status") then
                        -- Quest status - color in white
                        coloredValue = COLORS.VALUE .. value .. COLORS.RESET
                    elseif key:match("NOT IN COMBAT") then
                        -- Special case: "NOT IN COMBAT. Your HP: 60/60, Mana: 0/0, Energy: 100/100"
                        coloredValue = value:gsub("(%d+)/(%d+)", COLORS.WARNING .. "%1" .. COLORS.VALUE .. "/" .. COLORS.WARNING .. "%2" .. COLORS.VALUE)
                        coloredValue = COLORS.VALUE .. coloredValue .. COLORS.RESET
                    elseif value:match("^[%d%.]+/[%d%.]+$") then
                        -- Simple HP/Energy/Mana ratios (e.g., "60/60") - color numbers in yellow, slash in white
                        coloredValue = value:gsub("([%d%.]+)", COLORS.WARNING .. "%1" .. COLORS.VALUE)
                        coloredValue = COLORS.VALUE .. coloredValue .. COLORS.RESET
                    elseif key:match("Battle") and value:match("Applies an aura") then
                        -- Battle Stance line - don't color the ID, just the description
                        coloredValue = value:gsub("(ID:%s*%d+)(.+)", COLORS.VALUE .. "%1" .. COLORS.SUCCESS .. "%2" .. COLORS.RESET)
                        coloredValue = COLORS.VALUE .. coloredValue .. COLORS.RESET
                    elseif value:match("^[%d%.]+$") then
                        -- Pure numbers - color in yellow
                        coloredValue = COLORS.WARNING .. value .. COLORS.RESET
                    else
                        -- Default: white for other text values
                        coloredValue = COLORS.VALUE .. value .. COLORS.RESET
                    end
                    
                    table.insert(lines, coloredKey .. " " .. coloredValue)
                else
                    -- Lines without colons - check for special formatting
                    if line:match("NOT IN COMBAT") then
                        -- Special status line - make it prominent
                        table.insert(lines, COLORS.ERROR .. line .. COLORS.RESET)
                    else
                        -- Regular text
                        table.insert(lines, COLORS.VALUE .. line .. COLORS.RESET)
                    end
                end
            end
        end
    end
    
    return formatted .. table.concat(lines, "\n")
end

local function FormatCommandText(text)
    if not text or text == "" then
        return COLORS.WARNING .. "No command history available" .. COLORS.RESET
    end
    
    local formatted = COLORS.HEADER .. "Recent Commands & Reasoning" .. COLORS.RESET .. "\n"
    formatted = formatted .. string.rep("=", 40) .. "\n\n"
    
    -- Split text into lines and process the actual format
    local lines = {}
    for line in string.gmatch(ExpandMultiline(text), "([^\n]+)") do
        line = line:gsub("^%s+", ""):gsub("%s+$", "")
        if line ~= "" then
            table.insert(lines, line)
        end
    end
    
    -- Find command entries (lines starting with "- Command:")
    local commands = {}
    local i = 1
    while i <= #lines do
        local line = lines[i]
        
        -- Look for command line
        local cmdJson = line:match("^%-%s*Command:%s*(.+)$")
        if cmdJson then
            -- Found a command, look for the reasoning on the next line
            local reasoning = ""
            if i + 1 <= #lines then
                local nextLine = lines[i + 1]
                reasoning = nextLine:match("^%s*Reasoning:%s*(.+)$") or ""
                if reasoning ~= "" then
                    i = i + 1 -- Skip the reasoning line since we processed it
                end
            end
            
            table.insert(commands, {
                command = cmdJson,
                reasoning = reasoning
            })
        end
        i = i + 1
    end
    
    -- Display commands (most recent first, limit to 5)
    local numToShow = math.min(#commands, 5)
    for idx = 1, numToShow do
        local cmdData = commands[#commands - idx + 1] -- Reverse order (most recent first)
        
        formatted = formatted .. COLORS.HEADER .. "#" .. idx
        if idx == 1 then
            formatted = formatted .. " (Most Recent Command)"
        end
        formatted = formatted .. COLORS.RESET .. "\n"
        
        -- Parse and color the JSON command
        local cmdJson = cmdData.command
        if cmdJson:match("^%s*{.*}%s*$") then
            -- It's JSON, color individual values inside
            local coloredJson = cmdJson
            -- Color guid values (numbers)
            coloredJson = coloredJson:gsub('"guid"%s*:%s*(%d+)', '"guid":' .. COLORS.WARNING .. '%1' .. COLORS.VALUE)
            -- Color type values (strings)
            coloredJson = coloredJson:gsub('"type"%s*:%s*"([^"]+)"', '"type":"' .. COLORS.WARNING .. '%1' .. COLORS.VALUE .. '"')
            -- Color x, y, z coordinate values (numbers, including decimals)
            coloredJson = coloredJson:gsub('"x"%s*:%s*([%d%.%-]+)', '"x":' .. COLORS.WARNING .. '%1' .. COLORS.VALUE)
            coloredJson = coloredJson:gsub('"y"%s*:%s*([%d%.%-]+)', '"y":' .. COLORS.WARNING .. '%1' .. COLORS.VALUE)
            coloredJson = coloredJson:gsub('"z"%s*:%s*([%d%.%-]+)', '"z":' .. COLORS.WARNING .. '%1' .. COLORS.VALUE)
            
            formatted = formatted .. COLORS.SUCCESS .. "Command: " .. COLORS.RESET .. COLORS.VALUE .. coloredJson .. COLORS.RESET .. "\n"
        else
            -- Regular command text, color it white
            formatted = formatted .. COLORS.SUCCESS .. "Command: " .. COLORS.RESET .. COLORS.VALUE .. cmdJson .. COLORS.RESET .. "\n"
        end
        
        -- Add reasoning if available
        if cmdData.reasoning and cmdData.reasoning ~= "" then
            formatted = formatted .. COLORS.LABEL .. "Reasoning: " .. COLORS.RESET .. COLORS.VALUE .. cmdData.reasoning .. COLORS.RESET .. "\n"
        end
        
        if idx < numToShow then
            formatted = formatted .. "\n"
        end
    end
    
    return formatted
end

local function FormatLocationsText(text)
    if not text or text == "" then
        return COLORS.WARNING .. "No location data available" .. COLORS.RESET
    end
    
    local formatted = COLORS.HEADER .. "Visible Locations & Objects" .. COLORS.RESET .. "\n"
    formatted = formatted .. string.rep("=", 35) .. "\n\n"
    
    local lines = {}
    for line in string.gmatch(ExpandMultiline(text), "([^\n]+)") do
        line = line:gsub("^%s+", ""):gsub("%s+$", "")
        if line ~= "" then
            -- Remove leading dash and trim
            local cleanLine = line:gsub("^%s*%-%s*", "")
            
            -- Check if it has a tag like "FRIENDLY:" at the beginning
            local tag, rest = cleanLine:match("^([A-Z]+):%s*(.+)$")
            if tag and rest then
                -- Format with tag: "FRIENDLY: Deputy Willem [QUEST GIVER] GUID: 1851, Lvl: 18..."
                local coloredTag
                if tag:match("FRIENDLY") then
                    coloredTag = COLORS.SUCCESS .. tag .. COLORS.RESET
                elseif tag:match("NEUTRAL") then
                    coloredTag = COLORS.WARNING .. tag .. COLORS.RESET
                elseif tag:match("HOSTILE") then
                    coloredTag = COLORS.ERROR .. tag .. COLORS.RESET
                else
                    coloredTag = COLORS.LABEL .. tag .. COLORS.RESET
                end
                
                local coloredRest = rest
                -- Apply all the coloring patterns
                coloredRest = coloredRest:gsub("GUID:%s*(%d+)", COLORS.LABEL .. "GUID: " .. COLORS.WARNING .. "%1" .. COLORS.VALUE)
                coloredRest = coloredRest:gsub("Lvl:%s*(%d+)", COLORS.LABEL .. "Lvl: " .. COLORS.WARNING .. "%1" .. COLORS.VALUE)
                coloredRest = coloredRest:gsub("HP:%s*([%d/]+)", COLORS.LABEL .. "HP: " .. COLORS.WARNING .. "%1" .. COLORS.VALUE)
                coloredRest = coloredRest:gsub("Pos:%s*([%d%.%-]+%s+[%d%.%-]+%s+[%d%.%-]+)", function(coords)
                    local coloredCoords = coords:gsub("([%d%.%-]+)", COLORS.WARNING .. "%1" .. COLORS.VALUE)
                    return COLORS.LABEL .. "Pos: " .. coloredCoords
                end)
                coloredRest = coloredRest:gsub("Dist:%s*([%d%.]+)", COLORS.LABEL .. "Dist: " .. COLORS.WARNING .. "%1" .. COLORS.VALUE)
                coloredRest = coloredRest:gsub("%[([^%]]+)%]", COLORS.SUCCESS .. "[%1]" .. COLORS.VALUE)
                
                table.insert(lines, "- " .. coloredTag .. ": " .. COLORS.VALUE .. coloredRest .. COLORS.RESET)
            else
                -- No tag format - just object name with parameters: "Campfire (guid: 390, Type: 8, Position: -8768.92...)"
                local name, params = cleanLine:match("^([^%(]+)%s*%((.+)%)$")
                if name and params then
                    name = name:gsub("%s+$", "")
                    
                    -- Color the object name based on type or default to white
                    local coloredName = COLORS.VALUE .. name .. COLORS.RESET
                    
                    -- Color all the parameters
                    local coloredParams = params
                    -- Color guid values
                    coloredParams = coloredParams:gsub("guid:%s*(%d+)", COLORS.LABEL .. "guid: " .. COLORS.WARNING .. "%1" .. COLORS.VALUE)
                    -- Color Type values
                    coloredParams = coloredParams:gsub("Type:%s*(%d+)", COLORS.LABEL .. "Type: " .. COLORS.WARNING .. "%1" .. COLORS.VALUE)
                    -- Color Position values
                    coloredParams = coloredParams:gsub("Position:%s*([%d%.%-]+%s+[%d%.%-]+%s+[%d%.%-]+)", function(coords)
                        local coloredCoords = coords:gsub("([%d%.%-]+)", COLORS.WARNING .. "%1" .. COLORS.VALUE)
                        return COLORS.LABEL .. "Position: " .. coloredCoords
                    end)
                    -- Color Distance values
                    coloredParams = coloredParams:gsub("Distance:%s*([%d%.]+)", COLORS.LABEL .. "Distance: " .. COLORS.WARNING .. "%1" .. COLORS.VALUE)
                    -- Color Level values
                    coloredParams = coloredParams:gsub("Lvl:%s*(%d+)", COLORS.LABEL .. "Lvl: " .. COLORS.WARNING .. "%1" .. COLORS.VALUE)
                    -- Color HP values
                    coloredParams = coloredParams:gsub("HP:%s*([%d/]+)", COLORS.LABEL .. "HP: " .. COLORS.WARNING .. "%1" .. COLORS.VALUE)
                    -- Color special tags
                    coloredParams = coloredParams:gsub("%[([^%]]+)%]", COLORS.SUCCESS .. "[%1]" .. COLORS.VALUE)
                    
                    table.insert(lines, "- " .. coloredName .. " (" .. coloredParams .. COLORS.RESET .. ")")
                else
                    -- Fallback: just color the whole line
                    local coloredLine = cleanLine
                    coloredLine = coloredLine:gsub("guid:%s*(%d+)", COLORS.LABEL .. "guid: " .. COLORS.WARNING .. "%1" .. COLORS.VALUE)
                    coloredLine = coloredLine:gsub("Type:%s*(%d+)", COLORS.LABEL .. "Type: " .. COLORS.WARNING .. "%1" .. COLORS.VALUE)
                    coloredLine = coloredLine:gsub("Position:%s*([%d%.%-]+%s+[%d%.%-]+%s+[%d%.%-]+)", function(coords)
                        local coloredCoords = coords:gsub("([%d%.%-]+)", COLORS.WARNING .. "%1" .. COLORS.VALUE)
                        return COLORS.LABEL .. "Position: " .. coloredCoords
                    end)
                    coloredLine = coloredLine:gsub("Distance:%s*([%d%.]+)", COLORS.LABEL .. "Distance: " .. COLORS.WARNING .. "%1" .. COLORS.VALUE)
                    
                    table.insert(lines, "- " .. COLORS.VALUE .. coloredLine .. COLORS.RESET)
                end
            end
        end
    end
    
    return formatted .. table.concat(lines, "\n")
end

local function FormatPlayersText(text)
    if not text or text == "" then
        return COLORS.WARNING .. "No players visible" .. COLORS.RESET
    end
    
    local formatted = COLORS.HEADER .. "Visible Players" .. COLORS.RESET .. "\n"
    formatted = formatted .. string.rep("=", 25) .. "\n\n"
    
    local lines = {}
    local playerCount = 0
    for line in string.gmatch(ExpandMultiline(text), "([^\n]+)") do
        line = line:gsub("^%s+", ""):gsub("%s+$", "")
        if line ~= "" then
            playerCount = playerCount + 1
            
            -- Remove leading dash and trim
            local cleanLine = line:gsub("^%s*%-%s*", "")
            
            -- Try to parse format: Player: Name (guid: X, Level: Y, Class: Z, Race: W, Faction: V, Position: X Y Z, Distance: D)
            local playerLabel, nameAndRest = cleanLine:match("^(Player):%s*(.+)$")
            if playerLabel and nameAndRest then
                -- Extract name (everything before the first opening parenthesis)
                local name, params = nameAndRest:match("^([^%(]+)%s*%((.+)%)$")
                if name and params then
                    name = name:gsub("%s+$", "") -- trim trailing space
                    
                    -- Color the "Player:" label
                    local coloredLabel = COLORS.SUCCESS .. playerLabel .. ":" .. COLORS.RESET
                    
                    -- Color the name
                    local coloredName = COLORS.VALUE .. name .. COLORS.RESET
                    
                    -- Color the parameters inside parentheses
                    local coloredParams = params
                    -- Color guid values
                    coloredParams = coloredParams:gsub("guid:%s*(%d+)", "guid: " .. COLORS.WARNING .. "%1" .. COLORS.VALUE)
                    -- Color level values
                    coloredParams = coloredParams:gsub("Level:%s*(%d+)", "Level: " .. COLORS.WARNING .. "%1" .. COLORS.VALUE)
                    -- Color class values
                    coloredParams = coloredParams:gsub("Class:%s*(%d+)", "Class: " .. COLORS.WARNING .. "%1" .. COLORS.VALUE)
                    -- Color race values
                    coloredParams = coloredParams:gsub("Race:%s*(%d+)", "Race: " .. COLORS.WARNING .. "%1" .. COLORS.VALUE)
                    -- Color faction values (strings)
                    coloredParams = coloredParams:gsub("Faction:%s*([^,]+)", "Faction: " .. COLORS.WARNING .. "%1" .. COLORS.VALUE)
                    -- Color position coordinates (format: -8908.9 -106.1 81.8)
                    coloredParams = coloredParams:gsub("Position:%s*([%d%.%-%s]+)", function(coords)
                        local coloredCoords = coords:gsub("([%d%.%-]+)", COLORS.WARNING .. "%1" .. COLORS.VALUE)
                        return "Position: " .. coloredCoords
                    end)
                    -- Color distance values
                    coloredParams = coloredParams:gsub("Distance:%s*([%d%.]+)", "Distance: " .. COLORS.WARNING .. "%1" .. COLORS.VALUE)
                    
                    local formattedLine = "- " .. coloredLabel .. " " .. coloredName .. " (" .. COLORS.LABEL .. coloredParams .. COLORS.RESET .. ")"
                    table.insert(lines, formattedLine)
                else
                    -- Fallback: just color the label and the rest
                    local coloredLabel = COLORS.SUCCESS .. playerLabel .. ":" .. COLORS.RESET
                    local coloredRest = COLORS.VALUE .. nameAndRest .. COLORS.RESET
                    table.insert(lines, "- " .. coloredLabel .. " " .. coloredRest)
                end
            else
                -- No standard format, just color the whole line
                table.insert(lines, COLORS.VALUE .. "- " .. cleanLine .. COLORS.RESET)
            end
        end
    end
    
    if playerCount > 0 then
        formatted = formatted .. COLORS.LABEL .. "Total Players: " .. COLORS.RESET .. COLORS.SUCCESS .. playerCount .. COLORS.RESET .. "\n\n"
    end
    
    return formatted .. table.concat(lines, "\n")
end

local function UpdateBotBuddyState(text)
    if BotBuddyStateFrameText then
        -- CRITICAL SAFEGUARD: Only display state data, reject command/location data
        if text and (text:match("Command:") or text:match("Reasoning:") or text:match("FRIENDLY:") or text:match("Distance:.*yards")) then
            -- This appears to be command or location data, ignore it
            return
        end
        BotBuddyStateFrameText:SetText(FormatStateText(text))
    end
end

local function UpdateBotBuddyCommand(text)
    if BotBuddyCommandFrameText then
        -- CRITICAL SAFEGUARD: Only display command data, reject location data
        if text and (text:match("FRIENDLY:") or text:match("NEUTRAL:") or text:match("HOSTILE:") or text:match("Distance:.*yards")) then
            -- This appears to be location data, ignore it
            return
        end
        BotBuddyCommandFrameText:SetText(FormatCommandText(text))
    end
end

local function UpdateBotBuddyLocations(text)
    if BotBuddyLocationsFrameText then
        -- CRITICAL SAFEGUARD: Only display location data, reject command data
        if text and (text:match("Command:") or text:match("Reasoning:") or text:match("params") or text:match("guid.*500")) then
            -- This appears to be command data, ignore it
            return
        end
        BotBuddyLocationsFrameText:SetText(FormatLocationsText(text))
    end
end

local function UpdateBotBuddyPlayers(text)
    if BotBuddyPlayersFrameText then
        -- CRITICAL SAFEGUARD: Only display player data, reject command/location data
        if text and (text:match("Command:") or text:match("Reasoning:") or text:match("FRIENDLY:") or text:match("NEUTRAL:")) then
            -- This appears to be command or location data, ignore it
            return
        end
        BotBuddyPlayersFrameText:SetText(FormatPlayersText(text))
    end
end

local function UpdateTextBuffer(section, text, updateFunc)
    -- Ensure text is a string
    if not text or type(text) ~= "string" then
        text = ""
    end
    
    -- Ensure updateFunc is callable
    if not updateFunc or type(updateFunc) ~= "function" then
        return
    end
    
    -- Call update function directly with the text - no buffering to prevent contamination
    updateFunc(text)
end

local function OnChatMsg(event, msg, author, ...)
    -- Only process messages if they exist and are strings
    if not msg or type(msg) ~= "string" then
        return
    end
    
    -- PROFESSIONAL MESSAGE ROUTING: Extract content properly after headers
    
    -- STATE PANEL: Handle [BUDDY_STATE] messages
    if msg:sub(1, 13) == "[BUDDY_STATE]" then
        local content = msg:sub(14):gsub("^%s+", "") -- Remove header and leading whitespace
        if content and content ~= "" then
            UpdateTextBuffer("state", content, UpdateBotBuddyState)
        end
        return
    end
    
    -- COMMANDS PANEL: Handle [BUDDY_COMMANDS] messages  
    if msg:sub(1, 16) == "[BUDDY_COMMANDS]" then
        local content = msg:sub(17):gsub("^%s+", "") -- Remove header and leading whitespace
        if content and content ~= "" then
            UpdateTextBuffer("commands", content, UpdateBotBuddyCommand)
        end
        return
    end
    
    -- LOCATIONS PANEL: Handle [BUDDY_LOCATIONS] messages
    if msg:sub(1, 17) == "[BUDDY_LOCATIONS]" then
        local content = msg:sub(18):gsub("^%s+", "") -- Remove header and leading whitespace
        if content and content ~= "" then
            UpdateTextBuffer("locations", content, UpdateBotBuddyLocations)
        end
        return
    end
    
    -- PLAYERS PANEL: Handle [BUDDY_PLAYERS] messages
    if msg:sub(1, 15) == "[BUDDY_PLAYERS]" then
        local content = msg:sub(16):gsub("^%s+", "") -- Remove header and leading whitespace
        if content and content ~= "" then
            UpdateTextBuffer("players", content, UpdateBotBuddyPlayers)
        end
        return
    end
end

local sysFrame = CreateFrame("Frame")
sysFrame:RegisterEvent("CHAT_MSG_ADDON")
sysFrame:RegisterEvent("CHAT_MSG_WHISPER")
sysFrame:RegisterEvent("CHAT_MSG_SAY")
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
    local charSettings = GetCharacterSettings()

    if BotBuddyStateFrame and BotBuddyStateFrameTitleBar and BotBuddyStateFrameText then
        BotBuddyStateFrame:SetMovable(true)
        BotBuddyStateFrame:SetResizable(true)
        BotBuddyStateFrame:SetClampedToScreen(true)
        BotBuddyStateFrame:SetMinResize(200, 150)
        MakeDragHandle(BotBuddyStateFrameTitleBar, BotBuddyStateFrame)
        AddResizeGrip(BotBuddyStateFrame)
        HookResizeToText(BotBuddyStateFrame, BotBuddyStateFrameText, 30, 40)
        
        -- Respect saved visibility setting
        if charSettings.showState then
            BotBuddyStateFrame:Show()
        else
            BotBuddyStateFrame:Hide()
        end
    end

    if BotBuddyCommandFrame and BotBuddyCommandFrameTitleBar and BotBuddyCommandFrameText then
        BotBuddyCommandFrame:SetMovable(true)
        BotBuddyCommandFrame:SetResizable(true)
        BotBuddyCommandFrame:SetClampedToScreen(true)
        BotBuddyCommandFrame:SetMinResize(200, 150)
        MakeDragHandle(BotBuddyCommandFrameTitleBar, BotBuddyCommandFrame)
        AddResizeGrip(BotBuddyCommandFrame)
        HookResizeToText(BotBuddyCommandFrame, BotBuddyCommandFrameText, 30, 40)
        
        -- Respect saved visibility setting
        if charSettings.showCommands then
            BotBuddyCommandFrame:Show()
        else
            BotBuddyCommandFrame:Hide()
        end
    end

    if BotBuddyLocationsFrame and BotBuddyLocationsFrameTitleBar and BotBuddyLocationsFrameText then
        BotBuddyLocationsFrame:SetMovable(true)
        BotBuddyLocationsFrame:SetResizable(true)
        BotBuddyLocationsFrame:SetClampedToScreen(true)
        BotBuddyLocationsFrame:SetMinResize(200, 150)
        MakeDragHandle(BotBuddyLocationsFrameTitleBar, BotBuddyLocationsFrame)
        AddResizeGrip(BotBuddyLocationsFrame)
        HookResizeToText(BotBuddyLocationsFrame, BotBuddyLocationsFrameText, 30, 40)
        
        -- Respect saved visibility setting
        if charSettings.showLocations then
            BotBuddyLocationsFrame:Show()
        else
            BotBuddyLocationsFrame:Hide()
        end
    end

    if BotBuddyPlayersFrame and BotBuddyPlayersFrameTitleBar and BotBuddyPlayersFrameText then
        BotBuddyPlayersFrame:SetMovable(true)
        BotBuddyPlayersFrame:SetResizable(true)
        BotBuddyPlayersFrame:SetClampedToScreen(true)
        BotBuddyPlayersFrame:SetMinResize(200, 150)
        MakeDragHandle(BotBuddyPlayersFrameTitleBar, BotBuddyPlayersFrame)
        AddResizeGrip(BotBuddyPlayersFrame)
        HookResizeToText(BotBuddyPlayersFrame, BotBuddyPlayersFrameText, 30, 40)
        
        -- Respect saved visibility setting
        if charSettings.showPlayers then
            BotBuddyPlayersFrame:Show()
        else
            BotBuddyPlayersFrame:Hide()
        end
    end
end

local BotBuddyOptionsPanel
local function TogglePanelVisibility(panelName, isVisible)
    local charSettings = GetCharacterSettings()

    local frame = _G[panelName]
    if frame then
        if isVisible then
            frame:Show()
        else
            frame:Hide()
        end
        
        -- Save the visibility state for this character
        if panelName == "BotBuddyStateFrame" then
            charSettings.showState = isVisible
        elseif panelName == "BotBuddyCommandFrame" then
            charSettings.showCommands = isVisible
        elseif panelName == "BotBuddyLocationsFrame" then
            charSettings.showLocations = isVisible
        elseif panelName == "BotBuddyPlayersFrame" then
            charSettings.showPlayers = isVisible
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
    local charSettings = GetCharacterSettings()

    BotBuddyOptionsPanel = CreateFrame("Frame", "BotBuddyOptionsPanel", UIParent)
    BotBuddyOptionsPanel.name = "BotBuddy UI"

    local title = BotBuddyOptionsPanel:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
    title:SetPoint("TOPLEFT", 16, -16)
    title:SetText("BotBuddy UI Settings")
    
    -- Add character name indicator
    local charName = BotBuddyOptionsPanel:CreateFontString(nil, "ARTWORK", "GameFontNormal")
    charName:SetPoint("TOPLEFT", 16, -40)
    charName:SetText("Settings for: " .. (UnitName("player") or "Unknown"))

    CreateCheckbox("BotBuddyShowState", BotBuddyOptionsPanel, "Show Bot State Panel", 16, -70, charSettings.showState, function(checked)
        TogglePanelVisibility("BotBuddyStateFrame", checked)
    end)

    CreateCheckbox("BotBuddyShowCommands", BotBuddyOptionsPanel, "Show Commands Panel", 16, -100, charSettings.showCommands, function(checked)
        TogglePanelVisibility("BotBuddyCommandFrame", checked)
    end)

    CreateCheckbox("BotBuddyShowLocations", BotBuddyOptionsPanel, "Show Locations Panel", 16, -130, charSettings.showLocations, function(checked)
        TogglePanelVisibility("BotBuddyLocationsFrame", checked)
    end)

    CreateCheckbox("BotBuddyShowPlayers", BotBuddyOptionsPanel, "Show Players Panel", 16, -160, charSettings.showPlayers, function(checked)
        TogglePanelVisibility("BotBuddyPlayersFrame", checked)
    end)

    InterfaceOptions_AddCategory(BotBuddyOptionsPanel)
end

local frameLoader = CreateFrame("Frame")
frameLoader:RegisterEvent("PLAYER_ENTERING_WORLD")
frameLoader:RegisterEvent("ADDON_LOADED")
local panelsInitialized = false
frameLoader:SetScript("OnEvent", function(self, event, addonName)
    if event == "ADDON_LOADED" and addonName == "BotBuddyUI" then
        -- Initialize saved variables database structure
        BotBuddyUIDB = BotBuddyUIDB or {}
        BotBuddyUIDB.characters = BotBuddyUIDB.characters or {}
    elseif event == "PLAYER_ENTERING_WORLD" then
        -- Only create the options panel once, but setup panels every time
        if not panelsInitialized then
            CreateOptionsPanel()
            panelsInitialized = true
        end
        SetupBotBuddyPanels()
    end
end)

-- Slash commands for debugging and manual testing
SLASH_BOTBUDDY1 = "/botbuddy"
SLASH_BOTBUDDY2 = "/bb"
SlashCmdList["BOTBUDDY"] = function(msg)
    local charSettings = GetCharacterSettings()

    local command = msg:lower()
    if command == "show" then
        charSettings.showState = true
        charSettings.showCommands = true
        charSettings.showLocations = true
        charSettings.showPlayers = true
        SetupBotBuddyPanels()
        print(COLORS.SUCCESS .. "BotBuddy UI: All panels shown" .. COLORS.RESET)
    elseif command == "hide" then
        charSettings.showState = false
        charSettings.showCommands = false
        charSettings.showLocations = false
        charSettings.showPlayers = false
        SetupBotBuddyPanels()
        print(COLORS.WARNING .. "BotBuddy UI: All panels hidden" .. COLORS.RESET)
    elseif command == "toggle" then
        local anyVisible = charSettings.showState or charSettings.showCommands or charSettings.showLocations or charSettings.showPlayers
        if anyVisible then
            charSettings.showState = false
            charSettings.showCommands = false
            charSettings.showLocations = false
            charSettings.showPlayers = false
            print(COLORS.WARNING .. "BotBuddy UI: All panels hidden" .. COLORS.RESET)
        else
            charSettings.showState = true
            charSettings.showCommands = true
            charSettings.showLocations = true
            charSettings.showPlayers = true
            print(COLORS.SUCCESS .. "BotBuddy UI: All panels shown" .. COLORS.RESET)
        end
        SetupBotBuddyPanels()
    elseif command == "status" then
        print(COLORS.HEADER .. "BotBuddy UI Status for " .. (UnitName("player") or "Unknown") .. ":" .. COLORS.RESET)
        print(COLORS.LABEL .. "State Panel: " .. COLORS.RESET .. (charSettings.showState and COLORS.SUCCESS .. "Visible" or COLORS.WARNING .. "Hidden") .. COLORS.RESET)
        print(COLORS.LABEL .. "Commands Panel: " .. COLORS.RESET .. (charSettings.showCommands and COLORS.SUCCESS .. "Visible" or COLORS.WARNING .. "Hidden") .. COLORS.RESET)
        print(COLORS.LABEL .. "Locations Panel: " .. COLORS.RESET .. (charSettings.showLocations and COLORS.SUCCESS .. "Visible" or COLORS.WARNING .. "Hidden") .. COLORS.RESET)
        print(COLORS.LABEL .. "Players Panel: " .. COLORS.RESET .. (charSettings.showPlayers and COLORS.SUCCESS .. "Visible" or COLORS.WARNING .. "Hidden") .. COLORS.RESET)
    elseif command == "test" then
        print(COLORS.HEADER .. "BotBuddy Test Mode:" .. COLORS.RESET)
        
        -- Test each message type
        OnChatMsg("TEST", "[BUDDY_STATE] Test bot state data")
        OnChatMsg("TEST", "[BUDDY_COMMANDS] - Command: test command|Reasoning: test reasoning")
        OnChatMsg("TEST", "[BUDDY_LOCATIONS] - FRIENDLY: Test NPC (guid: 123, Level: 80)")
        OnChatMsg("TEST", "[BUDDY_PLAYERS] - Player: TestPlayer (guid: 456, Level: 80)")
        
        print(COLORS.SUCCESS .. "Test messages sent. Check panels for content." .. COLORS.RESET)
    else
        print(COLORS.HEADER .. "BotBuddy UI Commands:" .. COLORS.RESET)
        print(COLORS.LABEL .. "/botbuddy show" .. COLORS.RESET .. " - " .. COLORS.VALUE .. "Show all panels" .. COLORS.RESET)
        print(COLORS.LABEL .. "/botbuddy hide" .. COLORS.RESET .. " - " .. COLORS.VALUE .. "Hide all panels" .. COLORS.RESET)
        print(COLORS.LABEL .. "/botbuddy toggle" .. COLORS.RESET .. " - " .. COLORS.VALUE .. "Toggle all panels" .. COLORS.RESET)
        print(COLORS.LABEL .. "/botbuddy status" .. COLORS.RESET .. " - " .. COLORS.VALUE .. "Show panel status" .. COLORS.RESET)
        print(COLORS.WARNING .. "Tip: Use Interface Options menu for individual panel control" .. COLORS.RESET)
    end
end
