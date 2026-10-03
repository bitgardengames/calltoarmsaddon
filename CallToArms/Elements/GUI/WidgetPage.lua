local Name, AddOn = ...
local CTA = AddOn.CTA
local L = CTA.L
local SharedMedia = CTA.SharedMedia

function CTA:UpdateAllFontSizes()
    local FontSize = self.Settings.FontSize or 12
    local FontPath = SharedMedia:Fetch("font", self.Settings.WindowFont)

    -- Update every relevant element
    if self.Widget and self.Widget.Label then
        self.Widget.Label:SetFont(FontPath, FontSize, "")
    end

    for key, header in next, self.InstanceData do
        if header.Label then
            header.Label:SetFont(FontPath, FontSize, "")
        end
    end

    for key, header in next, self.RecycledHeaders do
        if header.Label then
            header.Label:SetFont(FontPath, FontSize, "")
        end
    end
end

local UpdateWidgetWidth = function(self, width)
	CTA.Widget:SetWidth(width)

	for key, header in next, CTA.InstanceData do
		header:SetWidth(width)
	end

	for key, header in next, CTA.RecycledHeaders do
		header:SetWidth(width)
	end
end

local UpdateWidgetHeight = function(self, height)
	local IconHeight = height - 2

	CTA.Widget:SetHeight(height)

	for key, header in next, CTA.InstanceData do
		header:SetHeight(height)

		for i = 1, 3 do
			header.RoleButtons[i]:SetSize(IconHeight, IconHeight)
		end
	end

	for key, header in next, CTA.RecycledHeaders do
		header:SetHeight(height)

		for i = 1, 3 do
			header.RoleButtons[i]:SetSize(IconHeight, IconHeight)
		end
	end
end

local UpdateWidgetFont = function(self, font)
	local Font = SharedMedia:Fetch("font", font)

	CTA.Widget.Label:SetFont(Font, 12, "")

	for key, header in next, CTA.InstanceData do
		header.Label:SetFont(Font, 12, "")
	end

	for key, header in next, CTA.RecycledHeaders do
		header.Label:SetFont(Font, 12, "")
	end
end

local UpdateFontColor = function()
	local R, G, B = unpack(CTA.Settings.FontColor or {1, 1, 1})

	if CTA.Widget and CTA.Widget.Label then
		CTA.Widget.Label:SetTextColor(R, G, B)
	end

	for key, header in next, CTA.InstanceData do
		if header.Label then
			header.Label:SetTextColor(R, G, B)
		end
	end
end

local UpdateWidgetColor = function()
	local R, G, B = unpack(CTA.Settings.WidgetColor or {1, 1, 1})

	if CTA.Widget then
		CTA.Widget:SetBackdropColor(R, G, B)
	end
end

local UpdateDungeonHeaderColor = function()
	local R, G, B = unpack(CTA.Settings.DungeonColor or {1, 1, 1})

	for key, header in next, CTA.InstanceData do
		header:SetBackdropColor(R, G, B)
	end

	for key, header in next, CTA.RecycledHeaders do
		header:SetBackdropColor(R, G, B)
	end
end

local UpdateGrowthDirection = function()
	CTA:SortQueueHeaders()
end

local UpdateLockWidget = function(self, toggled)
	if toggled then
		CTA:SetScript("OnDragStart", nil)
		CTA:SetScript("OnDragStop", nil)
	else
		CTA:SetScript("OnDragStart", CTA.StartMoving)
		CTA:SetScript("OnDragStop", CTA.StopMovingOrSizing)
	end
end

local UpdateMinimapButton = function(self, toggled)
	local LibDBIcon = LibStub("LibDBIcon-1.0")

	if toggled then
		LibDBIcon:Show(L["Call to Arms"])
	else
		LibDBIcon:Hide(L["Call to Arms"])
	end
end

local UpdateHideInGroup = function()
	CTA:UpdateGroupVisibility()
end

function CTA:CreateWidgetPage(page)
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

	self:CreateHeader(LeftWidgets, L["Set Font"])
	self:CreateFontSelection(LeftWidgets, "WindowFont", "", L["Select a font."], self.Fonts, UpdateWidgetFont)
	self:CreateNumberEditBox(LeftWidgets, "FontSize", L["Font Size"], L["Adjust the font size used throughout the addon UI."], function() CTA:UpdateAllFontSizes() end)
	self:CreateColorPicker(LeftWidgets, "FontColor", L["Font Color"], L["Choose the font color used throughout the UI"], UpdateFontColor)

	self:CreateHeader(LeftWidgets, L["Window Size"])
	self:CreateNumberEditBox(LeftWidgets, "HeaderWidth", L["Set Width"], L["Set the width of the widget."], UpdateWidgetWidth)
	self:CreateNumberEditBox(LeftWidgets, "HeaderHeight", L["Set Height"], L["Set the height of the widget."], UpdateWidgetHeight)

	self:CreateHeader(RightWidgets, COLORS)
	self:CreateColorPicker(RightWidgets, "WidgetColor", L["Widget Color"], L["Choose the background color of the widget"], UpdateWidgetColor)
	self:CreateColorPicker(RightWidgets, "DungeonColor", L["Dungeon Color"], L["Choose the background color of dungeon headers"], UpdateDungeonHeaderColor)

	self:CreateHeader(RightWidgets, MISCELLANEOUS)
	self:CreateCheckbox(RightWidgets, "HideInGroup", L["Hide In Group"], L["Automatically hide the widget when you join a party or raid group."], UpdateHideInGroup)
	self:CreateCheckbox(RightWidgets, "MinimapButton", L["Minimap Button"], L["Toggles the visibility of the minimap button."], UpdateMinimapButton)
	self:CreateCheckbox(RightWidgets, "SortUpwards", L["Grow Upwards"], L["Headers will grow upward from the widget instead of downward."], UpdateGrowthDirection)
	self:CreateCheckbox(RightWidgets, "LeftRoles", L["Left Role Icons"], L["Show role icons on the left side of each queue header instead of the right."], UpdateGrowthDirection)
	self:CreateCheckbox(RightWidgets, "LockWidget", L["Lock Widget"], L["Prevents the widget from being moved unless unlocked."], UpdateLockWidget)

	self:SortWidgets(LeftWidgets)
	self:SortWidgets(RightWidgets)
end
