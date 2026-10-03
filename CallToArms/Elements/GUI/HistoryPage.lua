local Name, AddOn = ...
local CTA = AddOn.CTA
local L = CTA.L

local SharedMedia = CTA.SharedMedia

function CTA:CreateHistoryPage(page)
	local Parent = CreateFrame("Frame", nil, page, "BackdropTemplate")
	Parent:SetSize(403, 236)
	Parent:SetPoint("LEFT", page, 0, 0)
	Parent:EnableMouse(true)
	Parent:SetBackdrop(self.BlankBackdrop)
	Parent:SetBackdropColor(0.184, 0.192, 0.211)

	local Backdrop = CreateFrame("Frame", nil, Parent, "BackdropTemplate")
	Backdrop:SetPoint("TOPLEFT", Parent, 3, -3)
	Backdrop:SetPoint("BOTTOMRIGHT", Parent, -3, 3)
	Backdrop:SetBackdrop(self.BlankBackdrop)
	Backdrop:SetBackdropColor(0.125, 0.133, 0.145, 0.5)

	local HistoryFrame = CreateFrame("ScrollingMessageFrame", nil, Backdrop)
	HistoryFrame:SetPoint("TOPLEFT", Backdrop, 3, -3)
	HistoryFrame:SetPoint("BOTTOMRIGHT", Backdrop, -3, 3)
	HistoryFrame:SetFont(SharedMedia:Fetch("font", self.Settings.WindowFont), 12, "")
	HistoryFrame:SetJustifyH("LEFT")
	HistoryFrame:SetShadowColor(0, 0, 0)
	HistoryFrame:SetShadowOffset(1, -1)
	HistoryFrame:SetFading(false)

	if (#self.History > 0) then
		for i = 1, #self.History do
			local Message = self:FormatHistoryEntry(self.History[i])

			HistoryFrame:AddMessage(Message)
		end
	end

	self.HistoryFrame = HistoryFrame
end