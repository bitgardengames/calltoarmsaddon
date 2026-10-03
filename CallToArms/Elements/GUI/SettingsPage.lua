local Name, AddOn = ...
local CTA = AddOn.CTA
local L = CTA.L

local UpdateIgnoredRoles = function()
	CTA:LFG_UPDATE_RANDOM_INFO()
end

local PreviewSound = function(value, key)
	if key then
		PlaySoundFile(key, "Master")
	end
end

function CTA:CreateSettingsPage(page)
	local LeftWidgets = CreateFrame("Frame", nil, page, "BackdropTemplate")
	LeftWidgets:SetSize(199, 236)
	LeftWidgets:SetPoint("LEFT", page, 0, 0)
	LeftWidgets:EnableMouse(true)
	LeftWidgets:SetBackdrop(self.BlankBackdrop)
	LeftWidgets:SetBackdropColor(0.184, 0.192, 0.211)

	local RightWidgets = CreateFrame("Frame", nil, page, "BackdropTemplate")
	RightWidgets:SetSize(198, 236)
	RightWidgets:SetPoint("LEFT", LeftWidgets, "RIGHT", 6, 0)
	RightWidgets:EnableMouse(true)
	RightWidgets:SetBackdrop(self.BlankBackdrop)
	RightWidgets:SetBackdropColor(0.184, 0.192, 0.211)

	page.LeftWidgets = LeftWidgets
	page.RightWidgets = RightWidgets

	self:CreateHeader(LeftWidgets, L["Filter by Role"])
	--self:CreateCheckbox(LeftWidgets, "IgnoreTank", TANK, L["Hide alerts for Tank role bonuses."], UpdateIgnoredRoles)
	--self:CreateCheckbox(LeftWidgets, "IgnoreHeal", HEALER, L["Hide alerts for Healer role bonuses."], UpdateIgnoredRoles)
	--self:CreateCheckbox(LeftWidgets, "IgnoreDamage", DAMAGER, L["Hide alerts for Damage role bonuses."], UpdateIgnoredRoles)
	self:CreateCheckbox(LeftWidgets, "ShowTank", TANK, L["Show bonuses for the Tank role"], UpdateIgnoredRoles)
	self:CreateCheckbox(LeftWidgets, "ShowHealer", HEALER, L["Show bonuses for the Healer role"], UpdateIgnoredRoles)
	self:CreateCheckbox(LeftWidgets, "ShowDamage", DAMAGER, L["Show bonuses for the Damage role"], UpdateIgnoredRoles)

	self:CreateHeader(RightWidgets, L["Announcements"])
	self:CreateCheckbox(RightWidgets, "AnnounceStart", L["Bonuses Beginning"], L["Show a chat message when a role bonus becomes available."], function() end)
	self:CreateCheckbox(RightWidgets, "AnnounceEnd", L["Bonuses Ending"], L["Show a chat message when a role bonus ends."], function() end)
	self:CreateCheckbox(RightWidgets, "PlaySound", L["Play Sound"], L["Play a sound when a bonus appears."], function() end)
	
	self:CreateHeader(RightWidgets, L["Alert Sound"])
	self:CreateSelection(RightWidgets, "AlertSound", "", L["Choose which sound plays when a bonus appears."], CTA.Sounds, PreviewSound)

	self:SortWidgets(LeftWidgets)
	self:SortWidgets(RightWidgets)
end