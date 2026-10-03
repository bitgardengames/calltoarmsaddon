local Name, AddOn = ...

local Version, Build, Date, TOC = GetBuildInfo()

local CTA = CreateFrame("Frame", "CallToArmsDriver", UIParent, "BackdropTemplate")
CTA:SetPoint("CENTER")
CTA:EnableMouse(true)
CTA:SetMovable(true)
CTA:SetUserPlaced(true)

-- Assets and Constants
local SharedMedia = LibStub:GetLibrary("LibSharedMedia-3.0")
SharedMedia:Register("font", "PT Sans", "Interface\\Addons\\CallToArms\\Assets\\PTSans.ttf")
SharedMedia:Register("sound", "CTA Beep 1", "Interface\\Addons\\CallToArms\\Assets\\beep1.ogg")
SharedMedia:Register("sound", "CTA Beep 2", "Interface\\Addons\\CallToArms\\Assets\\beep2.ogg")

CTA.BlankTexture = "Interface\\AddOns\\CallToArms\\Assets\\HydraUIBlank.tga"
CTA.BarTexture = "Interface\\AddOns\\CallToArms\\Assets\\HydraUI4.tga"
CTA.Font = "Interface\\Addons\\CallToArms\\Assets\\PTSans.ttf"
CTA.Textures = SharedMedia:HashTable("statusbar")
CTA.Fonts = SharedMedia:HashTable("font")
CTA.Sounds = SharedMedia:HashTable("sound")
CTA.SharedMedia = SharedMedia
CTA.Build = tonumber(TOC)

CTA.BlankBackdrop = {bgFile = CTA.BlankTexture}

CTA.Backdrop = {
	bgFile = CTA.BlankTexture,
	edgeFile = CTA.BlankTexture,
	edgeSize = 1,
	insets = {left = 0, right = 0, top = 0, bottom = 0},
}

-- Events
function CTA:OnEvent(event, ...)
	if self[event] then
		self[event](self, ...)
	end
end

CTA:SetScript("OnEvent", CTA.OnEvent)

AddOn.CTA = CTA