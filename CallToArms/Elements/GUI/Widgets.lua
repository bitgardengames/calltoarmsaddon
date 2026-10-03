local Name, AddOn = ...
local CTA = AddOn.CTA
local L = CTA.L

local SharedMedia = CTA.SharedMedia
local MaxWidgets = 11
local MaxSelections = 8
local BlankTexture = CTA.BlankTexture
local Outline = {bgFile = BlankTexture}
local ArrowDown = "Interface\\AddOns\\CallToArms\\Assets\\HydraUIArrowDown.tga"
local ArrowUp = "Interface\\AddOns\\CallToArms\\Assets\\HydraUIArrowUp.tga"

function CTA:CreateHeader(page, text)
	local Header = CreateFrame("Frame", nil, page, "BackdropTemplate")
	Header:SetSize(page:GetWidth() - 8, 22)
	Header:SetBackdrop(Outline)
	Header:SetBackdropColor(0.25, 0.266, 0.294)

	local Text = Header:CreateFontString(nil, "OVERLAY")
	Text:SetFont(SharedMedia:Fetch("font", self.Settings.WindowFont), 12, "")
	Text:SetPoint("LEFT", Header, 5, -1)
	Text:SetJustifyH("LEFT")
	Text:SetShadowColor(0, 0, 0)
	Text:SetShadowOffset(1, -1)
	Text:SetText(format("|cffFFC44D%s|r", text))

	tinsert(page, Header)
end

function CTA:CheckBoxOnMouseUp()
	if (CTA.Settings[self.Setting] == true) then
		self.CheckFade:SetChange(0)
		self.CheckFade:Play()

		CTA:UpdateSettingValue(self.Setting, false)

		if self.Hook then
			self:Hook(false)
		end
	else
		self.CheckFade:SetChange(1)
		self.CheckFade:Play()

		CTA:UpdateSettingValue(self.Setting, true)

		if self.Hook then
			self:Hook(true)
		end
	end
end

function CTA:CheckBoxOnEnter()
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

function CTA:CheckBoxOnLeave()
	self.Overlay:Hide()
	CTA.Tooltip:Hide()
end

function CTA:CreateCheckbox(page, key, text, tooltip, func)
	local Line = CreateFrame("Frame", nil, page)
	Line:SetSize(129, 22)

	local Checkbox = CreateFrame("Frame", nil, Line)
	Checkbox:SetSize(18, 18)
	Checkbox:SetPoint("LEFT", Line, 1, 0)
	Checkbox:SetScript("OnMouseUp", self.CheckBoxOnMouseUp)
	Checkbox:SetScript("OnEnter", self.CheckBoxOnEnter)
	Checkbox:SetScript("OnLeave", self.CheckBoxOnLeave)
	Checkbox.Setting = key
	Checkbox.Description = tooltip

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
	Checkbox.Text:SetFont(SharedMedia:Fetch("font", self.Settings.WindowFont), 12, "")
	Checkbox.Text:SetPoint("LEFT", Checkbox, "RIGHT", 6, 0)
	Checkbox.Text:SetJustifyH("LEFT")
	Checkbox.Text:SetShadowColor(0, 0, 0)
	Checkbox.Text:SetShadowOffset(1, -1)
	Checkbox.Text:SetText(text)

	if self.Settings[key] then
		Checkbox.Check:SetAlpha(1)
	end

	if func then
		Checkbox.Hook = func
	end

	tinsert(page, Line)
end

local ListOnEnter = function(self)
	self.Tex:SetVertexColor(0.3, 0.3, 0.34)
end

local ListOnLeave = function(self)
	self.Tex:SetVertexColor(0.184, 0.192, 0.211)
end

local WidgetOnLeave = function(self)
	self.Tex:SetVertexColor(0.125, 0.133, 0.145)
end

function CTA:NumberEditBoxOnEnterPressed()
	local Text = self:GetText()

	self:SetAutoFocus(false)
	self:ClearFocus()

	CTA:UpdateSettingValue(self.Setting, tonumber(Text))

	if self.Hook then
		self:Hook(tonumber(Text))
	end
end

function CTA:NumberOnEscapePressed()
	self:SetAutoFocus(false)
	self:ClearFocus()
end

function CTA:NumberEditBoxOnMouseDown()
	self:SetAutoFocus(true)
end

function CTA:NumberOnEnter()
	self.Tex:SetVertexColor(0.3, 0.3, 0.34)

	if self.Description then
		local Tooltip = CTA.Tooltip
		Tooltip:SetOwner(self, "ANCHOR_NONE")
		Tooltip:SetPoint("BOTTOM", self, "TOP", 0, 5)
		Tooltip:ClearLines()
		Tooltip:AddLine(self.Description)
		Tooltip:Show()
	end
end

function CTA:NumberOnLeave()
	self.Tex:SetVertexColor(0.125, 0.133, 0.145)
	CTA.Tooltip:Hide()
end

function CTA:CreateNumberEditBox(page, key, text, tooltip, func)
	local Line = CreateFrame("Frame", nil, page)
	Line:SetSize(page:GetWidth() - 8, 22)

	local EditBox = CreateFrame("EditBox", nil, Line)
	EditBox:SetSize(60, 22)
	EditBox:SetPoint("LEFT", Line, 0, 0)
	EditBox:SetFont(SharedMedia:Fetch("font", self.Settings.WindowFont), 12, "")
	EditBox:SetShadowColor(0, 0, 0)
	EditBox:SetShadowOffset(1, -1)
	EditBox:SetJustifyH("LEFT")
	EditBox:SetAutoFocus(false)
	EditBox:EnableKeyboard(true)
	EditBox:EnableMouse(true)
	EditBox:SetMaxLetters(3)
	EditBox:SetNumeric(true)
	EditBox:SetTextInsets(5, 0, 0, 0)
	EditBox:SetText(self.Settings[key])
	EditBox:SetScript("OnEnterPressed", self.NumberEditBoxOnEnterPressed)
	EditBox:SetScript("OnEscapePressed", self.NumberOnEscapePressed)
	EditBox:SetScript("OnMouseDown", self.NumberEditBoxOnMouseDown)
	EditBox:SetScript("OnEnter", self.NumberOnEnter)
	EditBox:SetScript("OnLeave", self.NumberOnLeave)
	EditBox.Setting = key
	EditBox.Description = tooltip

	EditBox.Tex = EditBox:CreateTexture(nil, "ARTWORK")
	EditBox.Tex:SetTexture(BlankTexture)
	EditBox.Tex:SetPoint("TOPLEFT", EditBox, 1, -1)
	EditBox.Tex:SetPoint("BOTTOMRIGHT", EditBox, -1, 1)
	EditBox.Tex:SetVertexColor(0.125, 0.133, 0.145)

	EditBox.Text = EditBox:CreateFontString(nil, "OVERLAY")
	EditBox.Text:SetFont(SharedMedia:Fetch("font", self.Settings.WindowFont), 12, "")
	EditBox.Text:SetPoint("LEFT", EditBox, "RIGHT", 6, 0)
	EditBox.Text:SetJustifyH("LEFT")
	EditBox.Text:SetShadowColor(0, 0, 0)
	EditBox.Text:SetShadowOffset(1, -1)
	EditBox.Text:SetText(text)

	if func then
		EditBox.Hook = func
	end

	tinsert(page, Line)
end

local ScrollSelections = function(self)
	local First = false

	for i = 1, #self do
		if (i >= self.Offset) and (i <= self.Offset + MaxSelections - 1) then
			if (not First) then
				self[i]:SetPoint("TOPLEFT", self, -1, 1)
				First = true
			else
				self[i]:SetPoint("TOPLEFT", self[i-1], "BOTTOMLEFT", 0, 0)
			end

			self[i]:Show()
		else
			self[i]:Hide()
		end
	end

	if self.ScrollBar then
		self.ScrollBar:SetValue(self.Offset)
	end
end

local SelectionOnMouseWheel = function(self, delta)
	if (delta == 1) then
		self.Offset = self.Offset - 1

		if (self.Offset <= 1) then
			self.Offset = 1
		end
	else
		self.Offset = self.Offset + 1

		if (self.Offset > (#self - (MaxSelections - 1))) then
			self.Offset = self.Offset - 1
		end
	end

	ScrollSelections(self)
end

local SelectionScrollBarOnValueChanged = function(self)
	local Parent = self:GetParent()
	Parent.Offset = self:GetValue()

	ScrollSelections(Parent)
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

local SelectionScrollBarOnMouseWheel = function(self, delta)
	SelectionOnMouseWheel(self:GetParent(), delta)
end

local FontListOnMouseUp = function(self)
	local Selection = self:GetParent():GetParent()

	Selection.Current:SetFont(SharedMedia:Fetch("font", self.Key), 12, "")
	Selection.Current:SetText(self.Key)

	Selection.List:Hide()

	CTA:UpdateSettingValue(Selection.Setting, self.Key)

	if Selection.Hook then
		Selection:Hook(self.Key)
	end

	Selection.Arrow:SetTexture(ArrowDown)
end

local FontSelectionOnMouseUp = function(self)
	if (not self.List) then
		local List = CreateFrame("Frame", nil, self)
		List:SetSize(186, (20 * MaxSelections) - 2) -- 128
		List:SetPoint("TOP", self, "BOTTOM", 0, -1)
		List.Offset = 1
		List:EnableMouseWheel(true)
		List:SetScript("OnMouseWheel", SelectionOnMouseWheel)
		List:SetFrameStrata("TOOLTIP")
		List:SetFrameLevel(20)
		List:Hide()

		local Tex = List:CreateTexture(nil, "ARTWORK")
		Tex:SetTexture(BlankTexture)
		Tex:SetPoint("TOPLEFT", List, -2, 2)
		Tex:SetPoint("BOTTOMRIGHT", List, 2, -2)
		Tex:SetVertexColor(0.125, 0.133, 0.145)

		List.Tex = Tex
		self.List = List

		for Key, Path in next, self.Selections do
			local Selection = CreateFrame("Frame", nil, List)
			Selection:SetSize(176, 20)
			Selection.Key = Key
			Selection.Path = Path
			Selection:SetScript("OnMouseUp", FontListOnMouseUp)
			Selection:SetScript("OnEnter", ListOnEnter)
			Selection:SetScript("OnLeave", ListOnLeave)

			local Tex = Selection:CreateTexture(nil, "ARTWORK")
			Tex:SetTexture(BlankTexture)
			Tex:SetPoint("TOPLEFT", Selection, 1, -1)
			Tex:SetPoint("BOTTOMRIGHT", Selection, -1, 1)
			Tex:SetVertexColor(0.184, 0.192, 0.211)

			local Text = Selection:CreateFontString(nil, "OVERLAY")
			Text:SetFont(Path, 12)
			Text:SetSize(170, 18)
			Text:SetPoint("LEFT", Selection, 5, 0)
			Text:SetJustifyH("LEFT")
			Text:SetShadowColor(0, 0, 0)
			Text:SetShadowOffset(1, -1)
			Text:SetText(Key)

			Selection.Tex = Tex
			Selection.Text = Text

			tinsert(List, Selection)
		end

		table.sort(List, function(a, b)
			return a.Key < b.Key
		end)

		local ScrollBar = CreateFrame("Slider", nil, List)
		ScrollBar:SetPoint("TOPRIGHT", List, 0, 0)
		ScrollBar:SetPoint("BOTTOMRIGHT", List, 0, 0)
		ScrollBar:SetWidth(10)
		ScrollBar:SetThumbTexture(BlankTexture)
		ScrollBar:SetOrientation("VERTICAL")
		ScrollBar:SetValueStep(1)
		ScrollBar:SetMinMaxValues(1, (#List - (MaxSelections - 1)))
		ScrollBar:SetValue(1)
		ScrollBar:SetObeyStepOnDrag(true)
		ScrollBar:EnableMouseWheel(true)
		ScrollBar:SetScript("OnMouseWheel", SelectionScrollBarOnMouseWheel)
		ScrollBar:SetScript("OnValueChanged", SelectionScrollBarOnValueChanged)
		ScrollBar:SetScript("OnEnter", ScrollBarOnEnter)
		ScrollBar:SetScript("OnLeave", ScrollBarOnLeave)
		ScrollBar:SetScript("OnMouseDown", ScrollBarOnMouseDown)
		ScrollBar:SetScript("OnMouseUp", ScrollBarOnMouseUp)

		local Thumb = ScrollBar:GetThumbTexture()
		Thumb:SetSize(10, 18)
		Thumb:SetVertexColor(0.25, 0.266, 0.294)

		List.ScrollBar = ScrollBar

		ScrollSelections(List)
	end

	local List = self.List

	if List:IsShown() then
		List:Hide()
		self.Arrow:SetTexture(ArrowDown)
	else
		List:Show()
		self.Arrow:SetTexture(ArrowUp)
	end
end

function CTA:SelectionOnEnter()
	self.Tex:SetVertexColor(0.3, 0.3, 0.34)

	if self.Description then
		local Tooltip = CTA.Tooltip
		Tooltip:SetOwner(self, "ANCHOR_NONE")
		Tooltip:SetPoint("BOTTOM", self, "TOP", 0, 5)
		Tooltip:ClearLines()
		Tooltip:AddLine(self.Description)
		Tooltip:Show()
	end
end

function CTA:SelectionOnLeave()
	self.Tex:SetVertexColor(0.125, 0.133, 0.145)
	CTA.Tooltip:Hide()
end

function CTA:CreateFontSelection(page, key, text, tooltip, selections, func)
	local Line = CreateFrame("Frame", nil, page)
	Line:SetSize(page:GetWidth() - 8, 22)

	local Selection = CreateFrame("Frame", nil, Line)
	Selection:SetSize(Line:GetWidth(), 22)
	Selection:SetPoint("LEFT", Line, 0, 0)
	Selection:SetScript("OnMouseUp", FontSelectionOnMouseUp)
	Selection:SetScript("OnEnter", self.SelectionOnEnter)
	Selection:SetScript("OnLeave", self.SelectionOnLeave)
	Selection.Selections = selections
	Selection.Setting = key
	Selection.Description = tooltip

	Selection.Tex = Selection:CreateTexture(nil, "ARTWORK")
	Selection.Tex:SetTexture(BlankTexture)
	Selection.Tex:SetPoint("TOPLEFT", Selection, 1, -1)
	Selection.Tex:SetPoint("BOTTOMRIGHT", Selection, -1, 1)
	Selection.Tex:SetVertexColor(0.125, 0.133, 0.145)

	Selection.Arrow = Selection:CreateTexture(nil, "OVERLAY")
	Selection.Arrow:SetTexture(ArrowDown)
	Selection.Arrow:SetPoint("RIGHT", Selection, -3, 0)
	Selection.Arrow:SetVertexColor(1, 0.7686, 0.3019)

	Selection.Current = Selection:CreateFontString(nil, "OVERLAY")
	Selection.Current:SetFont(SharedMedia:Fetch("font", self.Settings[key]), 12, "")
	Selection.Current:SetSize(122, 18)
	Selection.Current:SetPoint("LEFT", Selection, 5, -0.5)
	Selection.Current:SetJustifyH("LEFT")
	Selection.Current:SetShadowColor(0, 0, 0)
	Selection.Current:SetShadowOffset(1, -1)
	Selection.Current:SetText(self.Settings[key])

	Selection.Text = Selection:CreateFontString(nil, "OVERLAY")
	Selection.Text:SetFont(SharedMedia:Fetch("font", self.Settings.WindowFont), 12, "")
	Selection.Text:SetPoint("LEFT", Selection, "RIGHT", 3, 0)
	Selection.Text:SetJustifyH("LEFT")
	Selection.Text:SetShadowColor(0, 0, 0)
	Selection.Text:SetShadowOffset(1, -1)
	Selection.Text:SetText(text)

	if func then
		Selection.Hook = func
	end

	tinsert(page, Line)
end

local ListOnMouseUp = function(self)
	local Selection = self:GetParent():GetParent()

	Selection.Current:SetText(self.Key)
	Selection.List:Hide()
	CTA:UpdateSettingValue(Selection.Setting, self.Value)

	if Selection.Hook then
		Selection:Hook(self.Value, self.Key)
	end

	Selection.Arrow:SetTexture(ArrowDown)
end

local SelectionOnMouseUp = function(self)
	if (not self.List) then
		local List = CreateFrame("Frame", nil, self)
		List:SetSize(186, 22 * MaxSelections) -- 128
		List:SetPoint("TOP", self, "BOTTOM", 0, -1)
		List.Offset = 1
		List:EnableMouseWheel(true)
		List:SetScript("OnMouseWheel", SelectionOnMouseWheel)
		List:SetFrameStrata("TOOLTIP")
		List:SetFrameLevel(20)
		List:Hide()

		local Tex = List:CreateTexture(nil, "ARTWORK")
		Tex:SetTexture(BlankTexture)
		Tex:SetPoint("TOPLEFT", List, -2, 2)
		Tex:SetPoint("BOTTOMRIGHT", List, 2, -2)
		Tex:SetVertexColor(0.125, 0.133, 0.145)

		List.Text = Tex
		self.List = List

		for Key, Value in next, self.Selections do
			local Selection = CreateFrame("Frame", nil, List)
			Selection:SetSize(188, 22)
			Selection.Key = Key
			Selection.Value = Value
			Selection:SetScript("OnMouseUp", ListOnMouseUp)
			Selection:SetScript("OnEnter", ListOnEnter)
			Selection:SetScript("OnLeave", ListOnLeave)

			Selection.Tex = Selection:CreateTexture(nil, "ARTWORK")
			Selection.Tex:SetTexture(BlankTexture)
			Selection.Tex:SetPoint("TOPLEFT", Selection, 1, -1)
			Selection.Tex:SetPoint("BOTTOMRIGHT", Selection, -1, 1)
			Selection.Tex:SetVertexColor(0.184, 0.192, 0.211)

			Selection.Text = Selection:CreateFontString(nil, "OVERLAY")
			Selection.Text:SetFont(SharedMedia:Fetch("font", CTA.Settings["WindowFont"]), 12, "")
			Selection.Text:SetSize(170, 18)
			Selection.Text:SetPoint("LEFT", Selection, 5, 0)
			Selection.Text:SetJustifyH("LEFT")
			Selection.Text:SetShadowColor(0, 0, 0)
			Selection.Text:SetShadowOffset(1, -1)
			Selection.Text:SetText(Key)

			tinsert(List, Selection)
		end

		table.sort(List, function(a, b)
			return a.Key < b.Key
		end)

		if #List > (MaxSelections - 1) then
			local ScrollBar = CreateFrame("Slider", nil, List)
			ScrollBar:SetPoint("TOPLEFT", List, "TOPRIGHT", 0, 0)
			ScrollBar:SetPoint("BOTTOMLEFT", List, "BOTTOMRIGHT", 0, 0)
			ScrollBar:SetWidth(10)
			ScrollBar:SetThumbTexture(BlankTexture)
			ScrollBar:SetOrientation("VERTICAL")
			ScrollBar:SetValueStep(1)
			ScrollBar:SetMinMaxValues(1, (#List - (MaxSelections - 1)))
			ScrollBar:SetValue(1)
			ScrollBar:SetObeyStepOnDrag(true)
			ScrollBar:EnableMouseWheel(true)
			ScrollBar:SetScript("OnMouseWheel", SelectionScrollBarOnMouseWheel)
			ScrollBar:SetScript("OnValueChanged", SelectionScrollBarOnValueChanged)
			ScrollBar:SetScript("OnEnter", ScrollBarOnEnter)
			ScrollBar:SetScript("OnLeave", ScrollBarOnLeave)
			ScrollBar:SetScript("OnMouseDown", ScrollBarOnMouseDown)
			ScrollBar:SetScript("OnMouseUp", ScrollBarOnMouseUp)

			local Thumb = ScrollBar:GetThumbTexture()
			Thumb:SetSize(10, 18)
			Thumb:SetVertexColor(0.25, 0.266, 0.294)

			List.ScrollBar = ScrollBar
		else
			List:SetHeight((22 * #List) - 2)
			List:SetWidth(186)
		end

		ScrollSelections(List)
	end

	if self.List:IsShown() then
		self.List:Hide()
		self.Arrow:SetTexture(ArrowDown)
	else
		self.List:Show()
		self.Arrow:SetTexture(ArrowUp)
	end
end

function CTA:CreateSelection(page, key, text, tooltip, selections, func)
	local Line = CreateFrame("Frame", nil, page)
	Line:SetSize(page:GetWidth() - 8, 22)

	local Selection = CreateFrame("Frame", nil, Line)
	Selection:SetSize(Line:GetWidth(), 22)
	Selection:SetPoint("LEFT", Line, 0, 0)
	Selection:SetScript("OnMouseUp", SelectionOnMouseUp)
	Selection:SetScript("OnEnter", self.SelectionOnEnter)
	Selection:SetScript("OnLeave", self.SelectionOnLeave)
	Selection.Selections = selections
	Selection.Setting = key
	Selection.Description = tooltip

	local Name

	for k, v in next, selections do
		if (v == self.Settings[key]) then
			Name = k
		end
	end

	Selection.Tex = Selection:CreateTexture(nil, "ARTWORK")
	Selection.Tex:SetTexture(BlankTexture)
	Selection.Tex:SetPoint("TOPLEFT", Selection, 1, -1)
	Selection.Tex:SetPoint("BOTTOMRIGHT", Selection, -1, 1)
	Selection.Tex:SetVertexColor(0.125, 0.133, 0.145)

	Selection.Arrow = Selection:CreateTexture(nil, "OVERLAY")
	Selection.Arrow:SetTexture(ArrowDown)
	Selection.Arrow:SetPoint("RIGHT", Selection, -3, 0)
	Selection.Arrow:SetVertexColor(1, 0.7686, 0.3019)

	Selection.Current = Selection:CreateFontString(nil, "OVERLAY")
	Selection.Current:SetFont(SharedMedia:Fetch("font", self.Settings.WindowFont), 12, "")
	Selection.Current:SetSize(122, 18)
	Selection.Current:SetPoint("LEFT", Selection, 5, -0.5)
	Selection.Current:SetJustifyH("LEFT")
	Selection.Current:SetShadowColor(0, 0, 0)
	Selection.Current:SetShadowOffset(1, -1)
	Selection.Current:SetText(Name)

	Selection.Text = Selection:CreateFontString(nil, "OVERLAY")
	Selection.Text:SetFont(SharedMedia:Fetch("font", self.Settings.WindowFont), 12, "")
	Selection.Text:SetPoint("LEFT", Selection, "RIGHT", 3, 0)
	Selection.Text:SetJustifyH("LEFT")
	Selection.Text:SetShadowColor(0, 0, 0)
	Selection.Text:SetShadowOffset(1, -1)
	Selection.Text:SetText(text)

	if func then
		Selection.Hook = func
	end

	tinsert(page, Line)
end

function CTA:CreateColorPicker(page, key, text, tooltip, func)
	local Line = CreateFrame("Frame", nil, page)
	Line:SetSize(129, 22)

	local Swatch = CreateFrame("Button", nil, Line, "BackdropTemplate")
	Swatch:SetSize(16, 16)
	Swatch:SetPoint("LEFT", Line, 1, 0)
	local r, g, b = unpack(self.Settings[key] or {1, 1, 1})
	Swatch:SetBackdrop({bgFile = BlankTexture, edgeFile = BlankTexture, edgeSize = 1})
	Swatch:SetBackdropColor(r, g, b)
	Swatch:SetBackdropBorderColor(0, 0, 0, 0)
	Swatch.Description = tooltip
	Swatch.Setting = key

	-- Hover Overlay
	local Overlay = Swatch:CreateTexture(nil, "OVERLAY")
	Overlay:SetTexture(BlankTexture)
	Overlay:SetAllPoints()
	Overlay:SetVertexColor(1, 1, 1, 0.2)
	Overlay:Hide()
	Swatch.Overlay = Overlay

	Swatch:SetScript("OnEnter", CTA.CheckBoxOnEnter)
	Swatch:SetScript("OnLeave", CTA.CheckBoxOnLeave)
	Swatch:SetScript("OnMouseUp", function(self)
		local r, g, b = unpack(CTA.Settings[key] or {1, 1, 1})

		local function SetColor(restore)
			local newR, newG, newB
			if restore and restore.r then
				-- Retail cancel passes {r,g,b}
				newR, newG, newB = restore.r, restore.g, restore.b
			else
				newR, newG, newB = ColorPickerFrame:GetColorRGB()
			end

			CTA.Settings[key] = {newR, newG, newB}
			self:SetBackdropColor(newR, newG, newB)
			CTA:UpdateSettingValue(key, {newR, newG, newB})

			if func then
				func(newR, newG, newB)
			end
		end

		-- Retail Dragonflight/TWW path
		if ColorPickerFrame.OpenColorPicker then
			ColorPickerFrame:OpenColorPicker({
				hasOpacity = false,
				r = r, g = g, b = b,
				func = SetColor,
				cancelFunc = SetColor,
			})
			return
		elseif ColorPickerFrame.SetupColorPickerAndShow then
			-- Older DF builds used this name
			ColorPickerFrame:SetupColorPickerAndShow({
				hasOpacity = false,
				r = r, g = g, b = b,
				swatchFunc = function()
					SetColor()
				end,
				cancelFunc = function(prev)
					SetColor(prev)
				end,
			})
			return
		end

		-- Classic fallback
		ColorPickerFrame.swatchFunc = SetColor
		ColorPickerFrame.func = SetColor
		ColorPickerFrame.hasOpacity = false
		ColorPickerFrame.opacityFunc = nil

		ColorPickerFrame.previousValues = {r, g, b}
		ColorPickerFrame.cancelFunc = function()
			SetColor({r = r, g = g, b = b})
		end

		ColorPickerFrame:SetColorRGB(r, g, b)
		ColorPickerFrame:Hide()
		ColorPickerFrame:Show()
	end)

	-- Label
	local Text = Swatch:CreateFontString(nil, "OVERLAY")
	Text:SetFont(SharedMedia:Fetch("font", self.Settings.WindowFont), 12, "")
	Text:SetPoint("LEFT", Swatch, "RIGHT", 6, 0)
	Text:SetJustifyH("LEFT")
	Text:SetShadowColor(0, 0, 0)
	Text:SetShadowOffset(1, -1)
	Text:SetTextColor(1, 1, 1)
	Text:SetText(text)

	tinsert(page, Line)
end