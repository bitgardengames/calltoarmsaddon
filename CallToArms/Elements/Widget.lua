local Name, AddOn = ...
local CTA = AddOn.CTA
local L = CTA.L

local SharedMedia = CTA.SharedMedia
local RoleIcons = {"Interface\\Icons\\Ability_warrior_defensivestance", "Interface\\Icons\\spell_chargepositive", "Interface\\Icons\\ability_throw"}
local Class = select(2, UnitClass("player"))
local FreeQueueWidgets = {}
local QueueHighlight = "Interface\\AddOns\\CallToArms\\Assets\\RenHorizonUp.tga"

function CTA:RoleButtonOnEnter()
	self.MouseOver:Show()
	CTA:ShowShortageRewardTooltip(self)
end

function CTA:RoleButtonOnLeave()
	self.MouseOver:Hide()

	CTA.Tooltip:Hide()
end

function CTA:CreateRoleButton(parent, index)
	local Role = CreateFrame("Frame", nil, parent)
	Role:SetSize(self.Settings.HeaderHeight - 2, self.Settings.HeaderHeight - 2)
	Role:SetScript("OnEnter", self.RoleButtonOnEnter)
	Role:SetScript("OnLeave", self.RoleButtonOnLeave)
	Role:SetScript("OnMouseUp", self.QueueForDungeon)
	Role:Hide()

	local IconBG = Role:CreateTexture(nil, "BACKGROUND")
	IconBG:SetPoint("TOPLEFT", Role, -1, 1)
	IconBG:SetPoint("BOTTOMRIGHT", Role, 1, -1)
	IconBG:SetTexture(self.BlankTexture)
	IconBG:SetVertexColor(0, 0, 0)

	local Icon = Role:CreateTexture(nil, "ARTWORK")
	Icon:SetAllPoints()
	Icon:SetTexture(RoleIcons[index])
	Icon:SetTexCoord(0.08, 0.92, 0.08, 0.92)

	local MouseOver = Role:CreateTexture(nil, "OVERLAY")
	MouseOver:SetAllPoints()
	MouseOver:SetTexture(self.BlankTexture)
	MouseOver:SetVertexColor(0.8, 0.8, 0.8)
	MouseOver:SetAlpha(0.3)
	MouseOver:Hide()

	Role.RoleID = index
	Role.IconBG = IconBG
	Role.Icon = Icon
	Role.MouseOver = MouseOver

	return Role
end

function CTA:UpdateQueueIndicators()
	for _, Header in pairs(self.InstanceData) do
		if self:IsQueued(Header.ID) then
			Header.QueueFadeOut:Stop()

			if (not Header.QueueFadeIn:IsPlaying()) then
				Header.QueuedOverlay:Show()
				Header.QueueFadeIn:Play()
			end
		else
			Header.QueueFadeIn:Stop()

			if (not Header.QueueFadeOut:IsPlaying()) then
				Header.QueueFadeOut:Play()
			end
		end
	end
end

function CTA:QueueForDungeon()
	local Parent = self:GetParent()

	ClearAllLFGDungeons(Parent.Type)

	local Eligable, ForTank, ForHealer, ForDamage = GetLFGRoleShortageRewards(Parent.ID, LFG_ROLE_SHORTAGE_RARE)
	local Leader = GetLFGRoles()

	-- Check if we can perform this role. A generic error message would come up anyways, but we'll add our own.
	if (self.RoleID == 1) then
		if (ForTank and not CTA.ClassRoleMap[Class][self.RoleID]) then
			CTA:print(YOUR_CLASS_MAY_NOT_PERFORM_ROLE)

			return
		end
	elseif (self.RoleID == 2) then
		if (ForHealer and not CTA.ClassRoleMap[Class][self.RoleID]) then
			CTA:print(YOUR_CLASS_MAY_NOT_PERFORM_ROLE)

			return
		end
	end

	SetLFGDungeon(Parent.Type, Parent.ID)
	SetLFGRoles(Leader, self.RoleID == 1, self.RoleID == 2, self.RoleID == 3)

	if (Parent.Type == LE_LFG_CATEGORY_LFD) then
		LFDFrame_DisplayDungeonByID(Parent.ID)
		LFDQueueFrame_UpdateRoleButtons()
	elseif (Parent.Type == LE_LFG_CATEGORY_RF) then
		LFG_UpdateQueuedList()
		LFG_UpdateAllRoleCheckboxes()
	end

	JoinLFG(Parent.Type)

	CTA:UpdateQueueIndicators()
end

local HeaderOnEnter = function(self)
	CTA:ShowHeaderTooltip(self)
end

local HeaderOnLeave = function(self)
	CTA.Tooltip:Hide()
end

function CTA:CreateHeaderFrame(name)
	local Header = CreateFrame("Frame", nil, self.Widget, "BackdropTemplate")
	Header:SetSize(self.Settings.HeaderWidth, self.Settings.HeaderHeight)
	Header:SetPoint("CENTER", UIParent)
	Header:SetBackdrop(self.Backdrop)
	Header:SetBackdropColor(unpack(self.Settings.DungeonColor))
	Header:SetBackdropBorderColor(0, 0, 0)
	Header:SetScript("OnEnter", HeaderOnEnter)
	Header:SetScript("OnLeave", HeaderOnLeave)
	Header:SetAlpha(0)
	Header:Hide()

	local FadeIn = LibMotion:CreateAnimation(Header, "fade")
	FadeIn:SetDuration(0.15)
	FadeIn:SetEasing("in")
	FadeIn:SetChange(1)

	local FadeOut = LibMotion:CreateAnimation(Header, "fade")
	FadeOut:SetDuration(0.15)
	FadeOut:SetChange(0)
	FadeOut:SetEasing("out")
	FadeOut:SetScript("OnFinished", function(self)
		Header:Hide()
	end)

	local Move = LibMotion:CreateAnimation(Header, "move")
	Move:SetDuration(0.15)
	Move:SetEasing("inout")

	local QueuedOverlay = Header:CreateTexture(nil, "ARTWORK")
	QueuedOverlay:SetPoint("TOPLEFT", Header, 1, -1)
	QueuedOverlay:SetPoint("BOTTOMRIGHT", Header, -1, 1)
	QueuedOverlay:SetTexture(QueueHighlight)
	QueuedOverlay:SetVertexColor(0.7686, 0.7686, 0.3019, 0.25)
	QueuedOverlay:SetAlpha(0)
	QueuedOverlay:Hide()

	local QueueFadeIn = LibMotion:CreateAnimation(QueuedOverlay, "fade")
	QueueFadeIn:SetDuration(0.15)
	QueueFadeIn:SetEasing("in")
	QueueFadeIn:SetChange(0.3)

	local QueueFadeOut = LibMotion:CreateAnimation(QueuedOverlay, "fade")
	QueueFadeOut:SetDuration(0.15)
	QueueFadeOut:SetChange(0)
	QueueFadeOut:SetEasing("out")
	QueueFadeOut:SetScript("OnFinished", function(self)
		QueuedOverlay:Hide()
	end)

	local Label = Header:CreateFontString(nil, "OVERLAY")
	Label:SetPoint("LEFT", Header, 5, -0.5)
	Label:SetFont(SharedMedia:Fetch("font", self.Settings.WindowFont), self.Settings.FontSize)
	Label:SetJustifyH("LEFT")
	Label:SetText(name)
	Label:SetTextColor(unpack(self.Settings.FontColor or {1, 1, 1}))
	Label:SetSize(self.Settings.HeaderWidth - 12, self.Settings.HeaderHeight)
	Label:SetShadowColor(0.01, 0.01, 0.01)
	Label:SetShadowOffset(0, -1)

	Header.FadeIn = FadeIn
	Header.FadeOut = FadeOut
	Header.Move = Move
	Header.QueueFadeIn = QueueFadeIn
	Header.QueueFadeOut = QueueFadeOut
	Header.QueuedOverlay = QueuedOverlay
	Header.Label = Label
	Header.RoleButtons = {}
	Header.Visible = false
	Header.LastAnchor = nil

	for i = 1, 3 do
		local Role = self:CreateRoleButton(Header, i)

		if (i == 1) then
			Role:SetPoint("LEFT", Header, "RIGHT", 0, 0)
		else
			Role:SetPoint("LEFT", Header.RoleButtons[i-1], "RIGHT", 1, 0)
		end

		Header.RoleButtons[i] = Role
	end

	return Header
end

function CTA:SetHeaderVisible(header, visible)
	if (visible and not header.Visible) then
		header.Visible = true
		header:Show()
		header.FadeIn:Play()
	elseif (not visible and header.Visible) then
		header.Visible = false
		header.FadeOut:Play()
	end
end

function CTA:SetHeaderPositionAnimated(header, point, relativeTo, relativePoint, x, y)
	if (header == relativeTo) then
		return
	end

	-- Temporarily snap to new position to get target coords
	header:ClearAllPoints()
	header:SetPoint(point, relativeTo, relativePoint, x, y)

	local NewX, NewY = header:GetLeft(), header:GetTop()

	if (not NewX or not NewY) then
		-- Fallback to just anchoring if coordinates are missing
		header:ClearAllPoints()
		header:SetPoint(point, relativeTo, relativePoint, x, y)

		return
	end

	-- Try getting old position
	local OldX, OldY = header.OldX, header.OldY

	-- Default to no animation if this is the very first time
	if (not OldX or not OldY) then
		OldX, OldY = NewX, NewY
	end

	-- Reset to old screen space position
	header:ClearAllPoints()
	header:SetPoint("TOPLEFT", UIParent, "BOTTOMLEFT", OldX, OldY)

	local DX = NewX - OldX
	local DY = NewY - OldY

	header.Move:SetOffset(DX, DY)
	header.Move:Stop()
	header.Move:Play()

	-- After anim, snap to correct anchored position
	header.Move:SetScript("OnFinished", function()
		header:ClearAllPoints()
		header:SetPoint(point, relativeTo, relativePoint, x, y)
	end)

	-- Save for next time
	header.OldX = NewX
	header.OldY = NewY
end

function CTA:SortQueueHeaders()
	local SortUpwards = self.Settings.SortUpwards
	local Previous

	-- Gather headers in a flat list for sorting
	local Headers = {}

	for _, Header in pairs(self.InstanceData) do
		if Header.Visible then
			table.insert(Headers, Header)
		end
	end

	-- Reverse the order if growing upward
	if SortUpwards then
		table.sort(Headers, function(a, b) return a.ID > b.ID end)
	else
		table.sort(Headers, function(a, b) return a.ID < b.ID end)
	end

	for _, Header in ipairs(Headers) do
		if not Previous then
			-- Anchor first header to the main widget
			if SortUpwards then
				self:SetHeaderPositionAnimated(Header, "BOTTOMLEFT", self.Widget, "TOPLEFT", 0, 3)
			else
				self:SetHeaderPositionAnimated(Header, "TOPLEFT", self.Widget, "BOTTOMLEFT", 0, -3)
			end
		else
			-- Anchor to the previous visible header
			if SortUpwards then
				self:SetHeaderPositionAnimated(Header, "BOTTOMLEFT", Previous, "TOPLEFT", 0, 3)
			else
				self:SetHeaderPositionAnimated(Header, "TOPLEFT", Previous, "BOTTOMLEFT", 0, -3)
			end
		end

		Previous = Header
		self:SortQueueRoles(Header)
	end
end

function CTA:SortQueueRoles(header)
	local Previous

	if self.Settings.LeftRoles then
		for i = 3, 1, -1 do
			local Role = header.RoleButtons[i]

			if Role:IsShown() then
				Role:ClearAllPoints()

				if (not Previous) then
					Role:SetPoint("RIGHT", header, "LEFT", 0, 0)
				else
					Role:SetPoint("RIGHT", Previous, "LEFT", -1, 0)
				end

				Previous = Role
			end
		end
	else
		for i = 1, 3 do
			local Role = header.RoleButtons[i]

			if Role:IsShown() then
				Role:ClearAllPoints()

				if (not Previous) then
					Role:SetPoint("LEFT", header, "RIGHT", 0, 0)
				else
					Role:SetPoint("LEFT", Previous, "RIGHT", 1, 0)
				end

				Previous = Role
			end
		end
	end
end

function CTA:CloseButtonOnEnter()
	self.Texture:SetVertexColor(0.9, 0.1, 0.1)
end

function CTA:CloseButtonOnLeave()
	self.Texture:SetVertexColor(1, 1, 1)
end

function CTA:CloseButtonMouseUp()
	CTA:ToggleWidget()
end

function CTA:CreateWidget()
	-- Header
	self:SetSize(self.Settings.HeaderWidth, self.Settings.HeaderHeight)
	self:SetBackdrop(self.Backdrop)
	self:SetBackdropColor(unpack(self.Settings.WidgetColor))
	self:SetBackdropBorderColor(0, 0, 0)
	self:RegisterForDrag("LeftButton")
	self:SetClampedToScreen(true)

	local Label = self:CreateFontString(nil, "OVERLAY")
	Label:SetPoint("LEFT", self, 6, -0.5)
	Label:SetFont(SharedMedia:Fetch("font", self.Settings.WindowFont), self.Settings.FontSize)
	Label:SetText(L["Call to Arms"])
	Label:SetTextColor(unpack(self.Settings.FontColor or {1, 1, 1}))
	Label:SetShadowColor(0.01, 0.01, 0.01)
	Label:SetShadowOffset(0, -1)

	local Close = CreateFrame("Frame", nil, self)
	Close:SetPoint("RIGHT", self, 0, 0)
	Close:SetSize(self.Settings.HeaderHeight, self.Settings.HeaderHeight)
	Close:SetScript("OnEnter", self.CloseButtonOnEnter)
	Close:SetScript("OnLeave", self.CloseButtonOnLeave)
	Close:SetScript("OnMouseUp", self.CloseButtonMouseUp)

	local CloseTexture = Close:CreateTexture(nil, "OVERLAY")
	CloseTexture:SetPoint("CENTER", Close, 0, 0)
	CloseTexture:SetSize(16, 16)
	CloseTexture:SetTexture("Interface\\AddOns\\CallToArms\\Assets\\HydraUIClose.tga")

	if (not self.Settings.LockWidget) then
		self:SetScript("OnDragStart", self.StartMoving)
		self:SetScript("OnDragStop", self.StopMovingOrSizing)
	end

	self.Label = Label
	self.Close = Close
	Close.Texture = CloseTexture

	self.Widget = self
	self.WidgetVisible = true
	self.WidgetHiddenInGroup = false
	self:UpdateGroupVisibility()
end

function CTA:ToggleWidget()
	local Widget = self.Widget

	if (not Widget) then
		self:CreateWidget()

		return
	end

	-- Toggle the player's preference rather than the frame's current state. The frame may already be hidden temporarily by the group visibility setting.
	self.WidgetVisible = not self.WidgetVisible
	self.WidgetHiddenInGroup = false

	if self.WidgetVisible then
		Widget:Show()
	else
		Widget:Hide()
	end

	self:UpdateGroupVisibility()
end

function CTA:UpdateGroupVisibility()
	local Widget = self.Widget

	if (not Widget) then
		return
	end

	local HideForGroup = self.Settings.HideInGroup and (IsInGroup() or IsInRaid())

	if (HideForGroup and self.WidgetVisible) then
		if Widget:IsShown() then
			Widget:Hide()
		end

		self.WidgetHiddenInGroup = true
	elseif self.WidgetHiddenInGroup then
		-- Only undo a hide performed by this setting. A widget the player closed manually should remain closed when leaving a group or disabling it.
		self.WidgetHiddenInGroup = false

		if self.WidgetVisible then
			Widget:Show()
		end
	elseif (not self.WidgetVisible and Widget:IsShown()) then
		Widget:Hide()
	end
end