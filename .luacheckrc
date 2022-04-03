std = 'lua51'

quiet = 1 -- suppress report output for files without warnings

-- see https://luacheck.readthedocs.io/en/stable/warnings.html#list-of-warnings
-- and https://luacheck.readthedocs.io/en/stable/cli.html#patterns
ignore = {
	'212/self', -- unused argument self
}

files['localization.lua'] = {ignore = {'631'}}

read_globals = {
	table = {fields = {'wipe'}},
	C_QuestLog = {fields = {'IsQuestFlaggedCompleted'}},

	'CloseDropDownMenus',
	'CreateFrame',
	'GameTooltip',
	'GetAchievementCriteriaInfo',
	'GetLocale',
	'ToggleDropDownMenu',
	'UIDropDownMenu_AddButton',
	'UIParent',

	'HandyNotes',
	'LibStub',
	'TomTom',
}