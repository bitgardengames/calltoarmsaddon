local Name, AddOn = ...
local CTA = AddOn.CTA
local L = CTA.L

local SharedMedia = CTA.SharedMedia
local MaxWidgets = 11
local MaxSelections = 8
local BlankTexture = CTA.BlankTexture
local ArrowDown = "Interface\\AddOns\\CallToArms\\Assets\\HydraUIArrowDown.tga"
local ArrowUp = "Interface\\AddOns\\CallToArms\\Assets\\HydraUIArrowUp.tga"

function CTA:ShowPage(name)
	for i = 1, #self.Pages do
		local Page = self.Pages[i]
		Page:SetShown(Page.Name == name)
	end

	local highlight = self.GUI.TabHighlight

	for i = 1, #self.Tabs do
		local Tab = self.Tabs[i]

		if Tab.Name == name then
			local tabTop = Tab:GetTop()
			local parentTop = self.GUI.TabParent:GetTop()

			local currentTop = highlight:GetTop()
			if not currentTop then
				-- First-time placement: set manually
				local yOffset = parentTop - tabTop
				highlight:ClearAllPoints()
				highlight:SetPoint("TOPLEFT", self.GUI.TabParent, "TOPLEFT", 4, -yOffset)
			else
				local yOffset = (currentTop - tabTop)
				highlight.Slide:SetOffset(0, -yOffset)
				highlight.Slide:Play()
			end
		end
	end
end

function CTA:GetPage(name)
	local Pages = self.Pages

	for i = 1, #Pages do
		if (Pages[i].Name == name) then
			return Pages[i]
		end
	end
end

function CTA:PageTabOnEnter()
	self:SetBackdropColor(0.25, 0.266, 0.294)
end

function CTA:PageTabOnLeave()
	self:SetBackdropColor(0.184, 0.192, 0.211)
end

function CTA:PageTabOnMouseUp()
	CTA:ShowPage(self.Name)

	self.Text:ClearAllPoints()
	self.Text:SetPoint("LEFT", self, 5, -0.5)
end

function CTA:PageTabOnMouseDown()
	self.Text:ClearAllPoints()
	self.Text:SetPoint("LEFT", self, 6, -1.5)
end

function CTA:AddPage(name)
	local Tab = CreateFrame("Frame", nil, self.GUI.TabParent, "BackdropTemplate")
	Tab:SetSize(78, 22)
	Tab:SetBackdrop(self.BlankBackdrop)
	Tab:SetBackdropColor(0.184, 0.192, 0.211)
	Tab:SetScript("OnEnter", self.PageTabOnEnter)
	Tab:SetScript("OnLeave", self.PageTabOnLeave)
	Tab:SetScript("OnMouseUp", self.PageTabOnMouseUp)
	Tab:SetScript("OnMouseDown", self.PageTabOnMouseDown)
	Tab.Name = name

	local Text = Tab:CreateFontString(nil, "OVERLAY")
	Text:SetPoint("LEFT", Tab, 5, -0.5)
	Text:SetFont(SharedMedia:Fetch("font", self.Settings.WindowFont), 12, "")
	Text:SetJustifyH("LEFT")
	Text:SetShadowColor(0, 0, 0)
	Text:SetShadowOffset(1, -1)
	Text:SetText(name)

	Tab.Text = Text

	local Page = CreateFrame("Frame", nil, self.GUI.Window)
	Page:SetAllPoints()
	Page.Name = name

	table.insert(self.Tabs, Tab)
	table.insert(self.Pages, Page)

	return Page
end

function CTA:CreateGUI()
	self.Pages = {}
	self.Tabs = {}

	-- Window
	local GUI = CreateFrame("Frame", "CTA Settings", UIParent, "BackdropTemplate")
	GUI:SetSize(496, 24)
	GUI:SetPoint("CENTER", UIParent, 0, 160)
	GUI:SetMovable(true)
	GUI:EnableMouse(true)
	GUI:SetUserPlaced(true)
	GUI:SetClampedToScreen(true)
	GUI:RegisterForDrag("LeftButton")
	GUI:SetScript("OnDragStart", GUI.StartMoving)
	GUI:SetScript("OnDragStop", GUI.StopMovingOrSizing)
	GUI:SetBackdrop(self.BlankBackdrop)
	GUI:SetBackdropColor(0.184, 0.192, 0.211)
	GUI:SetFrameStrata("DIALOG")
	GUI:SetFrameLevel(20)

	local HeaderText = GUI:CreateFontString(nil, "OVERLAY")
	HeaderText:SetPoint("LEFT", GUI, 6, -0.5)
	HeaderText:SetFont(SharedMedia:Fetch("font", self.Settings.WindowFont), 12, "")
	HeaderText:SetJustifyH("LEFT")
	HeaderText:SetShadowColor(0, 0, 0)
	HeaderText:SetShadowOffset(1, -1)
	HeaderText:SetText("|cffFFC44D" .. L["Call to Arms"] .. "|r " .. (C_AddOns and C_AddOns.GetAddOnMetadata or GetAddOnMetadata)("CallToArms", "Version"))

	local CloseButton = CreateFrame("Frame", nil, GUI)
	CloseButton:SetPoint("RIGHT", GUI, 0, 0)
	CloseButton:SetSize(24, 24)
	CloseButton:SetScript("OnEnter", function(self) self.Texture:SetVertexColor(1, 0, 0) end)
	CloseButton:SetScript("OnLeave", function(self) self.Texture:SetVertexColor(1, 1, 1) end)
	CloseButton:SetScript("OnMouseUp", function() GUI:Hide() end)

	local CloseTexture = CloseButton:CreateTexture(nil, "OVERLAY")
	CloseTexture:SetPoint("CENTER", CloseButton, 0, -0.5)
	CloseTexture:SetTexture("Interface\\AddOns\\CallToArms\\Assets\\HydraUIClose.tga")

	local TabParent = CreateFrame("Frame", nil, GUI, "BackdropTemplate")
	TabParent:SetSize(86, 236)
	TabParent:SetPoint("TOPLEFT", GUI, "BOTTOMLEFT", 0, -6)
	TabParent:SetBackdrop(self.BlankBackdrop)
	TabParent:SetBackdropColor(0.184, 0.192, 0.211)

	local TabHighlight = CreateFrame("Frame", nil, TabParent, "BackdropTemplate")
	TabHighlight:SetPoint("TOPLEFT", TabParent, "TOPLEFT", 4, -4)
	TabHighlight:SetSize(2, 22)
	TabHighlight:SetBackdrop(self.BlankBackdrop)
	TabHighlight:SetBackdropColor(1, 0.7, 0.3)

	local Slide = LibMotion:CreateAnimation(TabHighlight, "Move")
	Slide:SetDuration(0.15)
	Slide:SetEasing("outsinusoidal")

	local Window = CreateFrame("Frame", nil, GUI)
	Window:SetSize(403, 236)
	Window:SetPoint("LEFT", TabParent, "RIGHT", 6, 0)

	local Backdrop = CreateFrame("Frame", nil, Window, "BackdropTemplate")
	Backdrop:SetPoint("TOPLEFT", GUI, -6, 6)
	Backdrop:SetPoint("BOTTOMRIGHT", Window, 6, -6)
	Backdrop:SetBackdrop(self.BlankBackdrop)
	Backdrop:SetBackdropColor(0.125, 0.133, 0.145)
	Backdrop:SetFrameStrata("BACKGROUND")
	Backdrop:SetFrameLevel(0)

	CloseButton.Texture = CloseTexture
	TabHighlight.Slide = Slide
	GUI.TabParent = TabParent
	GUI.TabHighlight = TabHighlight
	GUI.Window = Window
	self.GUI = GUI

	local SettingsPage = self:AddPage(L["Settings"])
	self:CreateSettingsPage(SettingsPage)

	local WidgetPage = self:AddPage(L["Widget"])
	self:CreateWidgetPage(WidgetPage)

	local DungeonsPage = self:AddPage(L["Dungeons"])
	self:CreateDungeonsPage(DungeonsPage)

	local HistoryPage = self:AddPage(L["History"])
	self:CreateHistoryPage(HistoryPage)

	for i = 1, #self.Tabs do
		if (i == 1) then
			self.Tabs[i]:SetPoint("TOPLEFT", TabParent, 4, -4)
		else
			self.Tabs[i]:SetPoint("TOPLEFT", self.Tabs[i-1], "BOTTOMLEFT", 0, -4)
		end
	end

	self:ShowPage(L["Settings"])
end

function CTA:SortWidgets(widgets)
	for i = 1, #widgets do
		if (i == 1) then
			widgets[i]:SetPoint("TOPLEFT", widgets, 4, -4)
		else
			widgets[i]:SetPoint("TOPLEFT", widgets[i-1], "BOTTOMLEFT", 0, -4)
		end
	end
end

SLASH_CALLTOARMSADDON1 = "/cta"
SLASH_CALLTOARMSADDON2 = "/calltoarms"
SlashCmdList.CALLTOARMSADDON = function(cmd)
	if (not CTA.GUI) then
		CTA:CreateGUI()

		return
	end

	if CTA.GUI:IsShown() then
		CTA.GUI:Hide()
	else
		CTA.GUI:Show()
	end
end