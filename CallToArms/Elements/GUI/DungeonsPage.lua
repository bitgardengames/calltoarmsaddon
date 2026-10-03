local Name, AddOn = ...
local CTA = AddOn.CTA
local L = CTA.L

local SharedMedia = CTA.SharedMedia
local BlankTexture = CTA.BlankTexture
local DungeonLines = {}
local MaxSelections = 8

function CTA:IsDungeonEnabled(id)
	return not CallToArmsFilters[id]
end

function CTA:SetDungeonEnabled(id, enabled)
	if enabled then
		CallToArmsFilters[id] = nil
	else
		CallToArmsFilters[id] = true
	end

	self:LFG_UPDATE_RANDOM_INFO()
end

local OnMouseUp = function(self)
	local ID = self.ID

	self.Checked = not self.Checked
	CTA:SetDungeonEnabled(ID, self.Checked)

	if self.Checked then
		self.CheckFade:SetChange(1)
		self.CheckFade:Play()
		CTA:debug("Toggled instance " .. self.Name .. " on")
	else
		self.CheckFade:SetChange(0)
		self.CheckFade:Play()
		CTA:debug("Toggled instance " .. self.Name .. " off")
	end
end

local OnEnter = function(self)
	self.Overlay:Show()

	if self.Description then
		local Tooltip = CTA.Tooltip
		Tooltip:SetOwner(self, "ANCHOR_NONE")
		Tooltip:SetPoint("BOTTOM", self, "TOP", 0, 6)
		Tooltip:ClearLines()
		Tooltip:AddLine(self.Description)
		Tooltip:Show()
	end
end

local OnLeave = function(self)
	self.Overlay:Hide()
	CTA.Tooltip:Hide()
end

function CTA:CreateDungeonLine(name, id, minlevel, maxlevel, parent)
	local Line = CreateFrame("Frame", nil, parent)
	Line:SetSize(129, 22)

	local Checkbox = CreateFrame("Frame", nil, Line)
	Checkbox:SetSize(18, 18)
	Checkbox:SetPoint("LEFT", Line, 1, 0)
	Checkbox:SetScript("OnMouseUp", OnMouseUp)
	Checkbox:SetScript("OnEnter", OnEnter)
	Checkbox:SetScript("OnLeave", OnLeave)
	Checkbox.Name = name
	Checkbox.ID = id

	Checkbox.Tex = Checkbox:CreateTexture(nil, "ARTWORK")
	Checkbox.Tex:SetTexture(BlankTexture)
	Checkbox.Tex:SetPoint("TOPLEFT", Checkbox, 1, -1)
	Checkbox.Tex:SetPoint("BOTTOMRIGHT", Checkbox, -1, 1)
	Checkbox.Tex:SetVertexColor(0.125, 0.133, 0.145)

	Checkbox.Check = Checkbox:CreateTexture(nil, "OVERLAY")
	Checkbox.Check:SetTexture("Interface\\Buttons\\UI-CheckBox-Check")
	Checkbox.Check:SetAllPoints()
	Checkbox.Check:SetAlpha(0)

	Checkbox.CheckFade = LibMotion:CreateAnimation(Checkbox.Check, "Fade")
	Checkbox.CheckFade:SetDuration(0.15)
	Checkbox.CheckFade:SetEasing("inout")

	Checkbox.Overlay = Checkbox:CreateTexture(nil, "OVERLAY")
	Checkbox.Overlay:SetTexture(BlankTexture)
	Checkbox.Overlay:SetPoint("TOPLEFT", Checkbox, 1, -1)
	Checkbox.Overlay:SetPoint("BOTTOMRIGHT", Checkbox, -1, 1)
	Checkbox.Overlay:SetAlpha(0.2)
	Checkbox.Overlay:Hide()

	Checkbox.Text = Checkbox:CreateFontString(nil, "OVERLAY")
	Checkbox.Text:SetFont(SharedMedia:Fetch("font", CTA.Settings.WindowFont), 12, "")
	Checkbox.Text:SetPoint("LEFT", Checkbox, "RIGHT", 6, 0)
	Checkbox.Text:SetJustifyH("LEFT")
	Checkbox.Text:SetShadowColor(0, 0, 0)
	Checkbox.Text:SetShadowOffset(1, -1)

	if (minlevel == maxlevel) then
		Checkbox.Text:SetText(format("%s (%s)", name, minlevel))
	else
		Checkbox.Text:SetText(format("%s (%s-%s)", name, minlevel, maxlevel))
	end

	if CallToArmsFilters[id] then
		Checkbox.Checked = false
		Checkbox.Check:SetAlpha(0)
	else
		Checkbox.Checked = true
		Checkbox.Check:SetAlpha(1)
	end

	tinsert(DungeonLines, Line)

	return Line
end

local ScrollSelections = function(self)
	local First = false

	for i = 1, #DungeonLines do
		if (i >= self.Offset) and (i <= self.Offset + MaxSelections - 1) then
			if (not First) then
				DungeonLines[i]:SetPoint("TOPLEFT", CTA.DungeonScrollWidget, 4, -30)
				First = true
			else
				DungeonLines[i]:SetPoint("TOPLEFT", DungeonLines[i-1], "BOTTOMLEFT", 0, -4)
			end

			DungeonLines[i]:Show()
		else
			DungeonLines[i]:Hide()
		end
	end
end

local ScrollBarOnMouseWheel = function(self, delta)
	if (delta == 1) then
		self.Offset = self.Offset - 1

		if (self.Offset <= 1) then
			self.Offset = 1
		end
	else
		self.Offset = self.Offset + 1

		local MaxOffset = math.max(1, #DungeonLines - (MaxSelections - 1))
		self.Offset = math.min(self.Offset, MaxOffset)
	end

	ScrollSelections(self)
end

local ScrollBarOnValueChanged = function(self)
	self.Offset = self:GetValue()

	ScrollSelections(self)
end

local ScrollBarOnEnter = function(self)
	self:GetThumbTexture():SetVertexColor(0.4, 0.4, 0.4)
end

local ScrollBarOnLeave = function(self)
	if (not self.OverrideThumb) then
		self:GetThumbTexture():SetVertexColor(0.25, 0.266, 0.294)
	end
end

local ScrollBarOnMouseDown = function(self)
	self.OverrideThumb = true
	self:GetThumbTexture():SetVertexColor(0.4, 0.4, 0.4)
end

local ScrollBarOnMouseUp = function(self)
	self.OverrideThumb = false
	self:GetThumbTexture():SetVertexColor(0.25, 0.266, 0.294)
end

function CTA:CreateDungeonsPage(page)
	local Widgets = CreateFrame("Frame", nil, page, "BackdropTemplate")
	Widgets:SetSize(page:GetWidth(), 236)
	Widgets:SetPoint("LEFT", page, 0, 0)
	Widgets:EnableMouse(true)
	Widgets:SetBackdrop(self.BlankBackdrop)
	Widgets:SetBackdropColor(0.184, 0.192, 0.211)

	self:CreateHeader(Widgets, L["Toggle alerts for specific dungeons"])
	self:SortWidgets(Widgets)

	local ScrollBar = CreateFrame("Slider", nil, Widgets)
	ScrollBar:SetPoint("TOPRIGHT", Widgets, -4, -31)
	ScrollBar:SetPoint("BOTTOMRIGHT", Widgets, -4, 4)
	ScrollBar:SetWidth(10)
	ScrollBar:SetThumbTexture(BlankTexture)
	ScrollBar:SetOrientation("VERTICAL")
	ScrollBar:SetValueStep(1)
	ScrollBar:SetObeyStepOnDrag(true)
	ScrollBar:EnableMouseWheel(true)
	ScrollBar:SetScript("OnMouseWheel", ScrollBarOnMouseWheel)
	ScrollBar:SetScript("OnValueChanged", ScrollBarOnValueChanged)
	ScrollBar:SetScript("OnEnter", ScrollBarOnEnter)
	ScrollBar:SetScript("OnLeave", ScrollBarOnLeave)
	ScrollBar:SetScript("OnMouseDown", ScrollBarOnMouseDown)
	ScrollBar:SetScript("OnMouseUp", ScrollBarOnMouseUp)
	ScrollBar.Offset = 1

	local Thumb = ScrollBar:GetThumbTexture()
	Thumb:SetSize(10, 18)
	Thumb:SetVertexColor(0.25, 0.266, 0.294)

	self.DungeonScrollWidget = Widgets
	self.DungeonScrollScrollBar = ScrollBar

	-- Initial draw
	self:RefreshDungeonLines()

	-- If no instance data yet, try again after scan delay
	if not next(self.InstanceData) then
		self:debug("InstanceData empty — scheduling deferred refresh")
		C_Timer.After(6, function()
			self:RefreshDungeonLines()
		end)
	end
end

function CTA:RefreshDungeonLines()
	if not self.DungeonScrollWidget then
		return
	end

	local ScrollBar = self.DungeonScrollScrollBar
	local PreviousOffset = ScrollBar and ScrollBar.Offset or 1
	local Headers = {}

	for i, line in ipairs(DungeonLines) do
		line:Hide()
	end

	wipe(DungeonLines)

	for k, Header in pairs(self.InstanceData) do
		table.insert(Headers, Header)
	end

	table.sort(Headers, function(a, b) return a.Name < b.Name end)

	for i, Header in ipairs(Headers) do
		self:CreateDungeonLine(Header.Name, Header.ID, Header.MinLevel, Header.MaxLevel, self.DungeonScrollWidget)
	end

	if ScrollBar then
		local MaxOffset = math.max(1, #DungeonLines - MaxSelections + 1)
		ScrollBar:SetMinMaxValues(1, MaxOffset)
		ScrollBar.Offset = math.min(PreviousOffset, MaxOffset)
		ScrollBar:SetValue(ScrollBar.Offset)

		if MaxOffset <= 1 then
			ScrollBar:Hide()
		else
			ScrollBar:Show()
		end

		ScrollSelections(ScrollBar)
	end
end