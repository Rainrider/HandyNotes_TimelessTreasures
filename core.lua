local addonName, TimelessTreasures = ...
TimelessTreasures.points = {}
local L = TimelessTreasures.L

-- our db and defaults
local db
local defaults = { profile = { completed = false, icon_scale = 1.4, icon_alpha = 0.8 } }

local points = TimelessTreasures.points

local moss = L["Moss-Covered Chest"]
local sturdy = L["Sturdy Chest"]
local smoldering = L["Smoldering Chest"]
local skull = L["Skull-Covered Chest"]
local blazing = L["Blazing Chest"]

local default_icon = select(10, GetAchievementInfo(8729))

-- http://www.wowhead.com/achievement=8729/treasure-treasure-everywhere
-- mapFiles 5th or 1st return of GetMapInfo()
-- coord 1st and 2nd return of GetPlayerMapPosition("player") times 10,000
-- 0.12345678 and 0.87654321 -> [12348765]
points["TimelessIsle"] = {
	-- Moss-Covered Chests
	[22204930] = {type = moss, quest = 33175},
	[22246808] = {type = moss, quest = 33178},
	[22423535] = {type = moss, quest = 33174},
	[24623863] = {type = moss, quest = 33200, note = L["On a treestump"]},
	[24755301] = {type = moss, quest = 33176},
	[25522721] = {type = moss, quest = 33171},
	[25664584] = {type = moss, quest = 33177},
	[26016145] = {type = moss, quest = 33199, note = L["On a treestump"]},
	[26856875] = {type = moss, quest = 33179},
	[27363909] = {type = moss, quest = 33172},
	[29683174] = {type = moss, quest = 33202, note = L["On the ramp"]},
	[30603655] = {type = moss, quest = 33173, note = L["On a treestump"]},
	[31007633] = {type = moss, quest = 33180},
	[34858422] = {type = moss, quest = 33184},
	[35367642] = {type = moss, quest = 33181},
	[36703403] = {type = moss, quest = 33170},
	[38737159] = {type = moss, quest = 33182},
	[39797953] = {type = moss, quest = 33183},
	[43568404] = {type = moss, quest = 33185},
	[44136546] = {type = moss, quest = 33198, note = L["On a treestump"]},
	[46764678] = {type = moss, quest = 33187},
	[46955369] = {type = moss, quest = 33186},
	[49716572] = {type = moss, quest = 33195},
	[51174568] = {type = moss, quest = 33188, note = L["In the slump scraps under the broken bridge"]},
	[52756286] = {type = moss, quest = 33197},
	[53097077] = {type = moss, quest = 33196},
	[55524434] = {type = moss, quest = 33189},
	[58015070] = {type = moss, quest = 33190},
	[59913132] = {type = moss, quest = 33201},
	[60176603] = {type = moss, quest = 33194},
	[61648849] = {type = moss, quest = 33227, note = L["In the shipwreck of Cpt. Zvezdan"]},
	[63815915] = {type = moss, quest = 33192},
	[64917559] = {type = moss, quest = 33193},
	[65634783] = {type = moss, quest = 33191},
	-- Sturdy Chests
	[26676495] = {type = sturdy, quest = 33205, note = L["On the top of the cliff. Use the Highwind Albatross"]},
	[28193521] = {type = sturdy, quest = 33204, note = L["On the top of the cliff. Use the Highwind Albatross"]},
	[59254946] = {type = sturdy, quest = 33207, note = L["Inside the Mysterious Den. Use one of objects from Legends of the Past"]},
	[64687047] = {type = sturdy, quest = 33206},
	-- Smoldering Chests
	[53987805] = {type = smoldering, quest = 33209},
	[69573289] = {type = smoldering, quest = 33208},
	-- Skull-Covered Chest
	[46703230] = {type = skull, quest = 33203, note = L["Inside Cavern of Lost Spirits (entrance at 43.2, 41.3)"]},
	-- Blazing Chest
	[47262682] = {type = blazing, quest = 33210},
}

points["CavernofLostSpirits"] = {
	-- Skull-Covered Chest
	[62903480] = {type = skull, quest = 33203},
}

-- HandyNotes handlers
function TimelessTreasures:OnEnter(mapFile, coord)
	local tooltip = self:GetParent() == WorldMapButton and WorldMapTooltip or GameTooltip

	if self:GetCenter() > UIParent:GetCenter() then -- compare X coordinate
		tooltip:SetOwner(self, "ANCHOR_LEFT")
	else
		tooltip:SetOwner(self, "ANCHOR_RIGHT")
	end
	local info = points[mapFile][coord]
	tooltip:SetText(info.type)
	tooltip:AddLine(L["Note: "] .. (info.note or ""), 1, 1, 1, true)
	tooltip:Show()
end

function TimelessTreasures:OnLeave()
	if self:GetParent() == WorldMapButton then
		WorldMapTooltip:Hide()
	else
		GameTooltip:Hide()
	end
end

local function CreateWaypoint(button, mapFile, coord)
	local c, z = HandyNotes:GetCZ(mapFile)
	local x, y = HandyNotes:getXY(coord)

	if TomTom then
		TomTom:AddZWaypoint(c, z, x * 100, y * 100, "Timeless Treasure")
	elseif Cartographer_Waypoints then
		Cartographer_Waypoints:AddWaypoint( NotePoint:new(HandyNotes:GetCZToZone(c, z), x, y, "Timeless Treasure") )
	end
end

do
	-- context menu generator
	local info = {}
	local currentZone, currentCoord

	local function Close() CloseDropDownMenus() end

	local function GenerateMenu(button, level)
		if not level then return end

		table.wipe(info)

		if level == 1 then
			-- create the title of the menu
			info.isTitle = 1
			info.text = L.ADDON_NAME
			info.notCheckable = 1

			UIDropDownMenu_AddButton(info, level)

			if TomTom or Cartographer_Waypoints then
				-- waypoint menu item
				info.disabled = nil
				info.isTitle = nil
				info.notCheckable = nil
				info.text = L["Create waypoint"]
				info.icon = nil
				info.func = CreateWaypoint
				info.arg1 = currentZone
				info.arg2 = currentCoord

				UIDropDownMenu_AddButton(info, level)
			end

			-- close menu item
			info.disabled = nil
			info.isTitle = nil
			info.notCheckable = 1
			info.text = CLOSE
			info.icon = nil
			info.func = Close
			info.arg1 = nil
			info.arg2 = nil
			UIDropDownMenu_AddButton(info, level)
		end
	end

	local dropdown = CreateFrame("Frame")
	dropdown.displayMode = "MENU"
	dropdown.initialize = GenerateMenu

	function TimelessTreasures:OnClick(button, down, mapFile, coord)
		if button == "RightButton" and not down then
			currentZone = mapFile
			currentCoord = coord

			ToggleDropDownMenu(1, nil, dropdown, self, 0, 0)
		end
	end
end

-- custom iterator we use to iterate over every node in a given zone
local function iter(t, prestate)
	if not t then return nil end

	local state, value = next(t, prestate)

	while state do -- have we reached the end of this zone?
		if value and (db.completed or not IsQuestFlaggedCompleted(value.quest)) then
			return state, nil, default_icon, db.icon_scale, db.icon_alpha
		end

		state, value = next(t, state) -- get next data
	end

	return nil, nil, nil, nil
end

function TimelessTreasures:GetNodes(mapFile)
	mapFile = gsub(mapFile, "_terrain%d+$", "")
	return iter, points[mapFile], nil
end


-- config
local options = {
	type = "group",
	name = L.NAME,
	desc = L["Timeless Treasures locations."],
	get = function(info) return db[info[#info]] end,
	set = function(info, v)
		db[info[#info]] = v
		TimelessTreasures:Refresh()
	end,
	args = {
		desc = {
			name = L["These settings control the look and feel of the icon."],
			type = "description",
			order = 1,
		},
		completed = {
			name = L["Show completed"],
			desc = L["Show icons for treasures you have already got."],
			type = "toggle",
			width = "full",
			arg = "completed",
			order = 2,
		},
		icon_scale = {
			type = "range",
			name = L["Icon Scale"],
			desc = L["Change the size of the icons."],
			min = 0.25, max = 2, step = 0.01,
			arg = "icon_scale",
			order = 3,
		},
		icon_alpha = {
			type = "range",
			name = L["Icon Alpha"],
			desc = L["Change the transparency of the icons."],
			min = 0, max = 1, step = 0.01,
			arg = "icon_alpha",
			order = 4,
		},
	},
}


-- initialise
function TimelessTreasures:OnEnable()
	HandyNotes:RegisterPluginDB("TimelessTreasures", self, options)
	self:RegisterEvent("QUEST_FINISHED", "Refresh")

	db = LibStub("AceDB-3.0"):New("HandyNotes_TimelessTreasuresDB", defaults, "Default").profile
end

function TimelessTreasures:Refresh()
	self:SendMessage("HandyNotes_NotifyUpdate", "TimelessTreasures")
end

-- activate
TimelessTreasures = LibStub("AceAddon-3.0"):NewAddon(TimelessTreasures, addonName, "AceEvent-3.0")

