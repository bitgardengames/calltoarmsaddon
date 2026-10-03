local Name, AddOn = ...
local CTA = AddOn.CTA

local Locale = GetLocale()
local DefaultFont = "PT Sans"

if (Locale == "koKR") then
	DefaultFont = "2002"
elseif (Locale == "zhCN" or Locale == "zhTW") then
	DefaultFont = "AR CrystalzcuheiGBK Demibold"
end

CTA.DefaultSettings = {
	-- Widget settings
	HeaderWidth = 160,
	HeaderHeight = 24,
	WindowFont = DefaultFont,
	FontSize = 12,
	FontColor = {1, 0.768, 0.301},
	WidgetColor = {0.125, 0.133, 0.145},
	DungeonColor = {0.125, 0.133, 0.145},
	LockWidget = false,
	HideInGroup = true,
	SortUpwards = false,
	LeftRoles = false,

	CustomTooltip = false,

	-- Role filters
	IgnoreTank = false, -- legacy
	IgnoreHeal = false,
	IgnoreDamage = false,

	ShowTank = true,
	ShowHealer = true,
	ShowDamage = true,

	-- General
	FilterRoles = true,
	MinimapButton = true,

	-- Announcements
	AnnounceStart = true,
	AnnounceEnd = true,
	PlaySound = true,
	AlertSound = "CTA Beep 1",

	Debug = false,
}

function CTA:UpdateSettingValue(key, value)
	if (value == self.Settings[key]) then
		CallToArmsDB[key] = nil
	else
		CallToArmsDB[key] = value
	end

	self.Settings[key] = value
end
