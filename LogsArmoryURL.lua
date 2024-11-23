local regionNames = {'us', 'kr', 'eu', 'tw', 'cn'}
local region = regionNames[GetCurrentRegion()]

local function fixServerName(server)
	if server == nil or server == "" then
		return
	end
	local auServer
	if WOW_PROJECT_ID == WOW_PROJECT_CLASSIC and server:sub(-3):lower() == "-au" then
		auServer = true
		server = server:sub(1, -4)
	end
	server = server:gsub("'(%u)", function(c) return c:lower() end):gsub("'", ""):gsub("%u", "-%1"):gsub("^[-%s]+", ""):gsub("[^%w%s%-]", ""):gsub("%s", "-"):lower():gsub("%-+", "-")
	server = server:gsub("([a-zA-Z])of%-", "%1-of-")
	if auServer == true then
		server = server .. "-au"
	end
	return server
end

local function generateURL(type, name, server)
	if WOW_PROJECT_ID == WOW_PROJECT_CLASSIC then
		if type == "logs" then
			url = "https://vanilla.warcraftlogs.com/character/"..region.."/"..server.."/"..name
		elseif type == "armory" then
			url = "https://www.classic-armory.org/character/"..region.."/vanilla/"..server.."/" ..name
		end
	elseif WOW_PROJECT_ID == WOW_PROJECT_CATACLYSM_CLASSIC then
		if type == "logs" then
			url = "https://classic.warcraftlogs.com/character/"..region.."/"..server.."/"..name
		elseif type == "armory" then
			url = "https://www.classic-armory.org/character/"..region.."/cataclysm/"..server.."/" ..name
		end
	elseif WOW_PROJECT_ID == WOW_PROJECT_MAINLINE then
		if type == "logs" then
			url = "https://www.warcraftlogs.com/character/"..region.."/"..server.."/"..name
		elseif type == "armory" then
			url = "https://worldofwarcraft.blizzard.com/character/"..region.."/"..server.."/"..name
		end
	end
	return url
end

local function popupLink(argType, argName, argServer)
	local type = argType
	local name = argName and argName:lower()
	local server = fixServerName(argServer)

	local url = generateURL(type, name, server)
	if not url then return end
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
	StaticPopup_Show("PopupLinkDialog", "", "", {url = url})
end

local chatTypes = {
	"SELF",
	"PLAYER",
	"PARTY",
	"RAID",
	"RAID_PLAYER",
	"ENEMY_PLAYER",
	"FOCUS",
	"FRIEND",
	"GUILD",
	"GUILD_OFFLINE",
	"ARENAENEMY",
	"BN_FRIEND",
	"CHAT_ROSTER",
	"COMMUNITIES_GUILD_MEMBER",
	"COMMUNITIES_WOW_MEMBER",
}
for _, value in ipairs(chatTypes) do
	Menu.ModifyMenu("MENU_UNIT_"..value, function(owner, rootDescription, contextData)
		local server = contextData.server or GetNormalizedRealmName()
		rootDescription:CreateButton("Logs Link", function()
			popupLink("logs", contextData.name, server)
		end)
		rootDescription:CreateButton("Armory Link", function()
			popupLink("armory", contextData.name, server)
		end)
	end)
end