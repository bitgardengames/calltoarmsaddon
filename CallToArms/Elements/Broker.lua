local Name, AddOn = ...
local CTA = AddOn.CTA
local L = CTA.L

local Text = L["Call to Arms"]
local LibDBIcon = LibStub("LibDBIcon-1.0")
local LibDB = LibStub:GetLibrary("LibDataBroker-1.1")

local Broker = LibDB:NewDataObject(Text, {label = Text, type = "data source", icon = 348524, text = Text})

function CTA:RegisterBrokerObject()
	if (LibDBIcon and not LibDBIcon:IsRegistered(Text)) then
		LibDBIcon:Register(Text, Broker, CallToArmsDB.minimap)
	end
end

Broker.OnClick = function(self, button)
	if (button == "LeftButton") then
		CTA:ToggleWidget()
	else
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
end

Broker.OnEnter = function(self)
	local Tooltip = CTA.Tooltip

	Tooltip:ClearLines()
	Tooltip:SetOwner(self, "ANCHOR_NONE")
	Tooltip:SetPoint("TOPRIGHT", self, "BOTTOMRIGHT")
	Tooltip:AddLine(Text)

	local List = CTA:GetShortageSummaryList()

	if #List > 0 then
		Tooltip:AddLine(" ")
		Tooltip:AddLine(L["Current Bonus Dungeons:"])

		for _, line in ipairs(List) do
			Tooltip:AddLine(line, 1, 1, 1)
		end
	else
		Tooltip:AddLine(" ")
		Tooltip:AddLine(L["No active bonuses"], 1, 1, 1)
	end

	Tooltip:AddLine(" ")
	Tooltip:AddLine(L["|cff00ccffLeft-Click:|r Toggle Widget"], 1, 1, 1)
	Tooltip:AddLine(L["|cff00ccffRight-Click:|r Open Settings"], 1, 1, 1)
	Tooltip:Show()
end

Broker.OnLeave = function()
	CTA.Tooltip:Hide()
end

function CTA:HideMinimapButton()
	LibDBIcon:Hide(Text)
end

CTA.DataBroker = Broker