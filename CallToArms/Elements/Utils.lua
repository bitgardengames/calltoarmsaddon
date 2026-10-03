local Name, AddOn = ...
local CTA = AddOn.CTA
local L = CTA.L

-- Constants
CTA.ClassRoleMap = { -- CanTank, CanHeal
	DEATHKNIGHT = {true, false},
	DEMONHUNTER = {true, false},
	DRUID =       {true, true},
	EVOKER =      {false, true},
	HUNTER =      {false, false},
	MAGE =        {false, false},
	MONK =        {true, true},
	PALADIN =     {true, true},
	PRIEST =      {false, true},
	ROGUE =       {false, false},
	SHAMAN =      {false, true},
	WARLOCK =     {false, false},
	WARRIOR =     {true, false},
}

CTA.Rename = { -- Deprecated
	[744] = PLAYER_DIFFICULTY_TIMEWALKER, -- Random Timewalking Dungeon (Burning Crusade) --> Timewalking
	[995] = PLAYER_DIFFICULTY_TIMEWALKER, -- Random Timewalking Dungeon (Wrath of the Lich King) --> Timewalking
	[1146] = PLAYER_DIFFICULTY_TIMEWALKER, -- Random Timewalking Dungeon (Cataclysm) --> Timewalking
	[1453] = PLAYER_DIFFICULTY_TIMEWALKER, -- Random Timewalking Dungeon (Mists of Pandaria) --> Timewalking
	[1971] = PLAYER_DIFFICULTY_TIMEWALKER, -- Random Timewalking Dungeon (Warlords of Draenor) --> Timewalking
	[2274] = PLAYER_DIFFICULTY_TIMEWALKER, -- Random Timewalking Dungeon (Legion) --> Timewalking
	[1670] = LFG_TYPE_RANDOM_DUNGEON, -- Random Dungeon (Battle for Azeroth) --> Random Dungeon
	[1671] = LFG_TYPE_HEROIC_DUNGEON, -- Random Heroic (Battle for Azeroth) --> Heroic Dungeon
}

-- Debugging and messaging
function CTA:print(...)
	print("|cffFF7C0ACTA|r:", ...)
end

function CTA:debug(...)
	if not self.Settings.Debug then
		return
	end

	print("|cffFF7C0ACTA [Debug]|r:", ...)
end

-- Utils
function CTA:IsQueued(id)
	for i, v in ipairs(LFGQueuedForList) do
		if v[id] then
			return true
		end
	end

	return false
end

function CTA:FormatDuration(seconds)
	local m = floor(seconds / 60)
	local s = seconds % 60

	return (m > 0) and format("%dm %ds", m, s) or format("%ds", s)
end

CTA.RoleIcons = {
	Tank = CreateAtlasMarkup("groupfinder-icon-role-large-tank", 16, 16),
	Heal = CreateAtlasMarkup("groupfinder-icon-role-large-heal", 16, 16),
	DPS = CreateAtlasMarkup("groupfinder-icon-role-large-dps", 16, 16),
}

function CTA:FormatHistoryEntry(entry)
	local time = format("|cff00ccff[%s]|r", date("%H:%M", entry.Time))
	local dungeon = entry.Dungeon or "Unknown"
	local role = entry.Role or "DPS"
	local icon = CTA.RoleIcons[role] or CTA.RoleIcons["DPS"]

	local tag = entry.State == "start" and "|cff00ff00+|r" or "|cffff6666–|r"

	local durationText = ""

	if entry.State == "end" then
		durationText = format(" (%s)", CTA:FormatDuration(entry.Duration or 0))
	end

	return format("%s %s %s %s%s", time, tag, icon, dungeon, durationText)
end

-- Likely move to a Tooltips.lua
function CTA:CreateTooltip()
	if self.Settings.CustomTooltip then
		local Tooltip = CreateFrame("GameTooltip", "CTATooltip", UIParent, "GameTooltipTemplate")
		Tooltip:SetFrameLevel(3)
		Tooltip.NineSlice:SetAlpha(0)

		local Outside = CreateFrame("Frame", nil, Tooltip, "BackdropTemplate")
		Outside:SetPoint("TOPLEFT", Tooltip, -1, 1)
		Outside:SetPoint("BOTTOMRIGHT", Tooltip, 1, -1)
		Outside:SetBackdrop(self.Backdrop)
		Outside:SetBackdropColor(0.125, 0.133, 0.145)
		Outside:SetBackdropBorderColor(0, 0, 0)
		Outside:SetFrameLevel(1)

		self.Tooltip = Tooltip
	else
		self.Tooltip = GameTooltip
	end
end

function CTA:ShowHeaderTooltip(header)
	local Tooltip = self.Tooltip
	Tooltip:SetOwner(header, "ANCHOR_NONE")
	Tooltip:SetPoint("BOTTOM", header, "TOP", 0, 4)
	Tooltip:ClearLines()
	Tooltip:AddLine(header.Name)

	if self:IsQueued(header.ID) then
		Tooltip:AddLine(" ")
		Tooltip:AddLine(L["|cff00ccffYou are currently queued for this dungeon|r"])
	end

	Tooltip:Show()
end

function CTA:ShowShortageRewardTooltip(self)
	local Parent = self:GetParent()
	local Tooltip = CTA.Tooltip

	Tooltip:SetOwner(self, "ANCHOR_NONE")
	Tooltip:ClearAllPoints()
	Tooltip:SetPoint("BOTTOM", self, "TOP", 0, 5)

	for i = 1, LFG_ROLE_NUM_SHORTAGE_TYPES do
		local Eligable, ForTank, ForHealer, ForDamage, ItemCount = GetLFGRoleShortageRewards(Parent.ID, i)

		if (ItemCount and ItemCount > 0) then
			Tooltip:AddLine(BONUS_REWARDS)
			Tooltip:AddLine(" ")

			for j = 1, ItemCount do
				local Name, Icon, NumRewards, _, RewardType, ID, Quality = GetLFGDungeonShortageRewardInfo(Parent.ID, i, j)

				if (RewardType == "misc") then
					Tooltip:AddLine(REWARD_ITEMS_ONLY)

					local DoneToday, Money, MoneyMod, XP, XPMod, NumRewards, SpellID = GetLFGDungeonRewards(Parent.ID)

					if (XP > 0) then
						Tooltip:AddLine(format(GAIN_EXPERIENCE, XP))
					end

					if (Money > 0) then
						SetTooltipMoney(Tooltip, Money, nil)
					end

					Tooltip:Show()
				elseif (RewardType == "reward") then
					Tooltip:SetLFGDungeonReward(Parent.ID, j)
					Tooltip:Show()
				elseif (RewardType == "shortage") then
					Tooltip:SetLFGDungeonShortageReward(Parent.ID, j, i)
					Tooltip:Show()
				elseif (RewardType == "item") then
					local Link = GetLFGDungeonShortageRewardLink(Parent.ID, i, j)

					if Link then
						if (NumRewards > 1) then
							Tooltip:AddLine(format("%s %s", NumRewards, Link))
						else
							Tooltip:AddLine(Link)
						end

						Tooltip:Show()
					end
				elseif (RewardType == "currency") then
					local CurrencyNum = select(3, CurrencyContainerUtil.GetCurrencyContainerInfo(ID, NumRewards, Name, Icon, Quality))
					local Link = C_CurrencyInfo.GetCurrencyLink(ID, CurrencyNum)
					local CurrencyInfo = C_CurrencyInfo.GetCurrencyInfo(ID)
					local Hex = ITEM_QUALITY_COLORS[CurrencyInfo.quality].hex or "ffffff"

					if CurrencyInfo then
						Tooltip:AddLine(format("%s %s%s|r", NumRewards, Hex, CurrencyInfo.name), 1, 1, 1)
						Tooltip:Show()
					end
				end
			end
		end
	end
end

-- Data broker helpers
function CTA:GetShortageSummaryList()
	local List = {}

	for ID, Header in pairs(self.InstanceData) do
		if self:IsDungeonEnabled(ID) then
			local Roles = {}

			if Header.TankActive and self.Settings.ShowTank then
				table.insert(Roles, self.RoleIcons.Tank)
			end

			if Header.HealActive and self.Settings.ShowHealer then
				table.insert(Roles, self.RoleIcons.Heal)
			end

			if Header.DPSActive and self.Settings.ShowDamage then
				table.insert(Roles, self.RoleIcons.DPS)
			end

			if (#Roles > 0) then
				local Name = Header.Name or ("Dungeon ID " .. ID)
				table.insert(List, format("%s — %s", Name, table.concat(Roles, " ")))
			end
		end
	end

	table.sort(List)

	return List
end

function CTA:UpdateBrokerText()
	local Tank, Healer, DPS = 0, 0, 0

	for ID, Header in pairs(self.InstanceData) do
		if self:IsDungeonEnabled(ID) then
			if Header.TankActive and self.Settings.ShowTank then
				Tank = Tank + 1
			end

			if Header.HealActive and self.Settings.ShowHealer then
				Healer = Healer + 1
			end

			if Header.DPSActive and self.Settings.ShowDamage then
				DPS = DPS + 1
			end
		end
	end

	local Summary = {}

	if (Tank > 0) then
		table.insert(Summary, self.RoleIcons.Tank .. Tank)
	end
	if (Healer > 0) then
		table.insert(Summary, self.RoleIcons.Heal .. Healer)
	end
	if (DPS > 0) then
		table.insert(Summary, self.RoleIcons.DPS .. DPS)
	end

	if (#Summary == 0) then
		self.DataBroker.text = L["No Bonuses"]
	else
		self.DataBroker.text = table.concat(Summary, " ")
	end
end