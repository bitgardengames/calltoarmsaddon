local Name, AddOn = ...
local CTA = AddOn.CTA
local L = CTA.L

local format = format
local next = next
local GetTime = GetTime
local InCombatLockdown = InCombatLockdown
local RequestLFDPlayerLockInfo = RequestLFDPlayerLockInfo
local GetLFGRoleShortageRewards = GetLFGRoleShortageRewards
local LFG_ROLE_NUM_SHORTAGE_TYPES = LFG_ROLE_NUM_SHORTAGE_TYPES
local GetModifiedInfo

if C_ModifiedInstance then
	GetModifiedInfo = C_ModifiedInstance.GetModifiedInstanceInfoFromMapID
end

local Class = select(2, UnitClass("player"))
local RoleNames = {TANK, HEALER, DAMAGER}
local RoleIcons = {"Interface\\Icons\\Ability_warrior_defensivestance", "Interface\\Icons\\spell_chargepositive", "Interface\\Icons\\ability_throw"}
local UpdateInt = 45
local CombatTime = 0

CTA.InstanceData = {}
CTA.RecycledHeaders = {}
CTA.History = {}

function CTA:HandleBonusStateChange(header, role, state)
	local Now = time()
	local Role = role .. "StartTime"
	local Active = role .. "Active"
	local History = self.History

	local Entry = {
		Time = Now,
		Dungeon = header.Name,
		Role = role,
		State = state,
	}

	if (state == "start") then
		header[Role] = Now
		header[Active] = true
	elseif (state == "end") then
		if header[Role] then
			Entry.Duration = Now - header[Role]
		end

		header[Role] = nil
		header[Active] = false
	end

	table.insert(History, Entry)

	if (#History > 50) then
		table.remove(History, 1)
	end

	if self.HistoryFrame then
		local Message = self:FormatHistoryEntry(Entry)

		self.HistoryFrame:AddMessage(Message)
	end
end

function CTA:AddInstanceData(id, name, lfgtype, minlevel, maxlevel, modified)
	if self.InstanceData[id] then
		return
	end

	local Header
	local Recycle = self.RecycledHeaders

	if (#Recycle > 0) then
		Header = table.remove(Recycle)

		if Header then
			self:debug('"AddInstanceData" recycled a header')
			return Header
		end
	else
		Header = self:CreateHeaderFrame(name)
	end

	Header.ID = id
	Header.Name = name
	Header.Type = lfgtype
	Header.Modified = modified
	Header.MinLevel = minlevel
	Header.MaxLevel = maxlevel
	Header.TankActive = false
	Header.HealActive = false
	Header.DPSActive = false

	self.InstanceData[id] = Header

	self:debug(format("Added instance data for %s [%s]", name, id))
end

function CTA:ScanForInstances()
	local Level = UnitLevel("player")
	local InstanceData = self.InstanceData

	if (Level < 15) then
		self:debug("LFD isn't unlocked yet")
		return
	end

	for id, header in pairs(self.InstanceData) do
		if not header.IsTest then
			self.InstanceData[id] = nil
		end
	end

	self:debug("Scanning for dungeons at level", Level)

	-- Find dungeons
	for i = 1, GetNumRandomDungeons() do
		local ID, Name, SubType, _, _, _, _, Min, Max, _, _, _, _, _, _, _, _, _, Timewalking = GetLFGRandomDungeonInfo(i)
		local ForAll, ForPlayer = IsLFGDungeonJoinable(ID)

		if ForPlayer and (not InstanceData[ID]) then
			self:AddInstanceData(ID, (self.Rename[ID] or Name), LFG_SUBTYPEID_DUNGEON, Min, Max)
		end
	end

	-- Find raids
	if (self.Build > 90000) then
		for i = 1, GetNumRFDungeons() do

			local ID, Name, SubType, Type, _, _, Min, Max, _, _, _, _, _, _, _, _, _, _, _, _, _, _, MapID = GetRFDungeonInfo(i)

			if (Level >= Min) and (Level <= Max) and (not InstanceData[ID]) then
				if GetModifiedInfo then
					local Info = GetModifiedInfo(MapID)

					self:AddInstanceData(ID, Name, SubType, Min, Max, Info)
				else
					self:AddInstanceData(ID, Name, SubType, Min, Max)
				end
			end
		end
	end

	self:SortQueueHeaders()
end

function CTA:PLAYER_LEVEL_UP()
	local Recycle = self.RecycledHeaders

	for id, Header in pairs(self.InstanceData) do
		if not Header.IsTest then
			Header.Visible = false
			Header:Hide()
			table.insert(Recycle, Header)
			self.InstanceData[id] = nil
		end
	end

	C_Timer.After(2, function()
		self:ScanForInstances()
		self:LFG_UPDATE_RANDOM_INFO()
	end)
end

function CTA:OnUpdate(ela)
	self.Ela = self.Ela + ela

	if (self.Ela > UpdateInt) then
		RequestLFDPlayerLockInfo()
		self.Ela = 0
	end
end

function CTA:PLAYER_REGEN_ENABLED()
	self.Ela = self.Ela + (GetTime() - CombatTime)

	self:SetScript("OnUpdate", self.OnUpdate)
end

function CTA:PLAYER_REGEN_DISABLED()
	self:SetScript("OnUpdate", nil)

	CombatTime = GetTime()
end

function CTA:LFG_UPDATE_RANDOM_INFO()
	local Settings = self.Settings
	local AnnounceStart = Settings.AnnounceStart
	local AnnounceEnd = Settings.AnnounceEnd
	local PlaySound = Settings.PlaySound

	for ID, Header in next, self.InstanceData do
		local TankBonus, HealerBonus, DPSBonus = false, false, false

		for j = 1, LFG_ROLE_NUM_SHORTAGE_TYPES do
			local _, ForTank, ForHealer, ForDPS, ItemCount = GetLFGRoleShortageRewards(ID, j)

			if ItemCount and ItemCount > 0 then
				if ForTank then TankBonus = true end
				if ForHealer then HealerBonus = true end
				if ForDPS then DPSBonus = true end
			end
		end

		if TankBonus then
			if Settings.ShowTank then
				Header.RoleButtons[1]:Show()
				if not Header.TankActive then
					if AnnounceStart then self:print(format(L["[%s] — Tank Bonus Available"], Header.Name)) end
					if PlaySound then self:PlaySound() end
					self:HandleBonusStateChange(Header, "Tank", "start")
					Header.TankActive = true
				end
			else
				Header.RoleButtons[1]:Hide()
			end
		elseif Header.TankActive then
			Header.RoleButtons[1]:Hide()
			if AnnounceEnd and Settings.ShowTank then
				self:print(format(L["[%s] — Tank Bonus Ended"], Header.Name))
			end
			self:HandleBonusStateChange(Header, "Tank", "end")
			Header.TankActive = false
		end

		if HealerBonus then
			if Settings.ShowHealer then
				Header.RoleButtons[2]:Show()
				if not Header.HealActive then
					if AnnounceStart then self:print(format(L["[%s] — Heal Bonus Available"], Header.Name)) end
					if PlaySound then self:PlaySound() end
					self:HandleBonusStateChange(Header, "Heal", "start")
					Header.HealActive = true
				end
			else
				Header.RoleButtons[2]:Hide()
			end
		elseif Header.HealActive then
			Header.RoleButtons[2]:Hide()
			if AnnounceEnd and Settings.ShowHealer then
				self:print(format(L["[%s] — Heal Bonus Ended"], Header.Name))
			end
			self:HandleBonusStateChange(Header, "Heal", "end")
			Header.HealActive = false
		end

		if DPSBonus then
			if Settings.ShowDamage then
				Header.RoleButtons[3]:Show()
				if not Header.DPSActive then
					if AnnounceStart then self:print(format(L["[%s] — DPS Bonus Available"], Header.Name)) end
					if PlaySound then self:PlaySound() end
					self:HandleBonusStateChange(Header, "DPS", "start")
					Header.DPSActive = true
				end
			else
				Header.RoleButtons[3]:Hide()
			end
		elseif Header.DPSActive then
			Header.RoleButtons[3]:Hide()
			if AnnounceEnd and Settings.ShowDamage then
				self:print(format(L["[%s] — DPS Bonus Ended"], Header.Name))
			end
			self:HandleBonusStateChange(Header, "DPS", "end")
			Header.DPSActive = false
		end

		local ShowHeader = (TankBonus and Settings.ShowTank) or (HealerBonus and Settings.ShowHealer) or (DPSBonus and Settings.ShowDamage)

		self:SetHeaderVisible(Header, ShowHeader and not CallToArmsFilters[Header.ID])
	end

	self:SortQueueHeaders()
	self:UpdateBrokerText()

	if not self:GetScript("OnUpdate") and not InCombatLockdown() then
		self:SetScript("OnUpdate", self.OnUpdate)
	end
end

function CTA:LFG_UPDATE()
	self:UpdateQueueIndicators()
end

function CTA:PLAYER_ENTERING_WORLD()
	if (not self.Init) then
		if (not CallToArmsDB) then
			CallToArmsDB = {minimap = {minimapPos = 171}}
		end

		if not CallToArmsDB.minimap then
			CallToArmsDB.minimap = {minimapPos = 171}
		end

		if (not CallToArmsFilters) then
			CallToArmsFilters = {}
		end

		self.Settings = setmetatable(CallToArmsDB, {__index = self.DefaultSettings})

		-- Fix backwards filtering
		if CallToArmsDB.IgnoreTank ~= nil and CallToArmsDB.ShowTank == nil then
			CallToArmsDB.ShowTank = not CallToArmsDB.IgnoreTank
			CTA.Settings.ShowTank = CallToArmsDB.ShowTank
			CallToArmsDB.IgnoreTank = nil
		end

		if CallToArmsDB.IgnoreHeal ~= nil and CallToArmsDB.ShowHealer == nil then
			CallToArmsDB.ShowHealer = not CallToArmsDB.IgnoreHeal
			CTA.Settings.ShowHealer = CallToArmsDB.ShowHealer
			CallToArmsDB.IgnoreHeal = nil
		end

		if CallToArmsDB.IgnoreDamage ~= nil and CallToArmsDB.ShowDamage == nil then
			CallToArmsDB.ShowDamage = not CallToArmsDB.IgnoreDamage
			CTA.Settings.ShowDamage = CallToArmsDB.ShowDamage
			CallToArmsDB.IgnoreDamage = nil
		end

		self:CreateWidget()
		self:CreateTooltip()
		self:RegisterBrokerObject()

		if not self.Settings.MinimapButton then
			CTA:HideMinimapButton()
		end

		C_Timer.After(5, function()
			if (self.Build < 90000) then
				self:VersionYell()
			end

			self:ScanForInstances()
			self:LFG_UPDATE_RANDOM_INFO()
			self:RefreshDungeonLines()
		end)

		self.Init = true
		self.Ela = 0
		self:UnregisterEvent("PLAYER_ENTERING_WORLD")
	end
end

CTA:RegisterEvent("PLAYER_ENTERING_WORLD")
CTA:RegisterEvent("LFG_UPDATE_RANDOM_INFO")
CTA:RegisterEvent("PLAYER_REGEN_ENABLED")
CTA:RegisterEvent("PLAYER_REGEN_DISABLED")
CTA:RegisterEvent("LFG_UPDATE")
CTA:RegisterEvent("PLAYER_LEVEL_UP")