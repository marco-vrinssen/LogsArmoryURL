-- Define regions and get the current region
local regions = {'us', 'kr', 'eu', 'tw', 'cn'}
local currentRegion = regions[GetCurrentRegion()]

-- Function to normalize server names
local function normalizeServerName(serverName)
    if not serverName or serverName == "" then return end

    local isAU = WOW_PROJECT_ID == WOW_PROJECT_CLASSIC and serverName:sub(-3):lower() == "-au"
    if isAU then serverName = serverName:sub(1, -4) end

    serverName = serverName:gsub("'(%u)", function(c) return c:lower() end):gsub("'", "")
    serverName = serverName:gsub("%u", "-%1"):gsub("^[-%s]+", ""):gsub("[^%w%s%-]", "")
    serverName = serverName:gsub("%s", "-"):lower():gsub("%-+", "-")
    serverName = serverName:gsub("([a-zA-Z])of%-", "%1-of-")

    if isAU then serverName = serverName .. "-au" end
    return serverName
end

-- Function to generate the link based on type, character name, and server name
local function generateLink(linkType, characterName, serverName)
    if WOW_PROJECT_ID ~= WOW_PROJECT_CLASSIC then
        print("Error: Cannot determine link type")
        return
    end

    local baseUrl = linkType == "logs" and "https://vanilla.warcraftlogs.com/character/" or "https://www.classic-armory.org/character/"
    local url = baseUrl .. currentRegion .. "/" .. (linkType == "logs" and serverName or "vanilla/" .. serverName) .. "/" .. characterName
    return url
end

-- Define the popup dialog for displaying links
StaticPopupDialogs["PopupLinkDialog"] = {
    text = "Logs & Armory Link",
    button1 = "Close",
    timeout = 0,
    whileDead = true,
    hideOnEscape = true,
    preferredIndex = 3,
    OnShow = function(self, data)
        self.editBox:SetText(data.url)
        self.editBox:HighlightText()
        self.editBox:SetFocus()
        self.editBox:SetScript("OnKeyDown", function(_, key)
            local isMac = IsMacClient()
            if key == "ESCAPE" then
                self:Hide()
            elseif (isMac and IsMetaKeyDown() or IsControlKeyDown()) and key == "C" then
                self:Hide()
            end
        end)
    end,
    hasEditBox = true
}

-- Function to display the popup link
local function displayPopupLink(linkType, characterName, serverName)
    if not characterName or characterName == "" then
        print("Error: Cannot determine character name")
        return
    end

    local normalizedServerName = normalizeServerName(serverName)
    if not normalizedServerName or normalizedServerName == "" then
        print("Error: Cannot determine server name")
        return
    end

    local url = generateLink(linkType, characterName:lower(), normalizedServerName)
    if not url then return end

    StaticPopup_Show("PopupLinkDialog", "", "", {url = url})
end

-- Add menu options if the project is classic
if WOW_PROJECT_ID == WOW_PROJECT_CLASSIC then
    local contextTypes = {
        "SELF", "TARGET", "PLAYER", "PARTY", "RAID", "RAID_PLAYER", "ENEMY_PLAYER", "FOCUS", 
        "FRIEND", "GUILD", "GUILD_OFFLINE", "ARENAENEMY", "BN_FRIEND", "CHAT_ROSTER", 
        "COMMUNITIES_GUILD_MEMBER", "COMMUNITIES_WOW_MEMBER"
    }

    for _, context in ipairs(contextTypes) do
        Menu.ModifyMenu("MENU_UNIT_"..context, function(_, description, data)
            local serverName = data.server or GetNormalizedRealmName()

            description:CreateButton("Logs Link", function()
                displayPopupLink("logs", data.name, serverName)
            end)

            description:CreateButton("Armory Link", function()
                displayPopupLink("armory", data.name, serverName)
            end)
        end)
    end
end