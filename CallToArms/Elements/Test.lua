local Name, AddOn = ...
local CTA = AddOn.CTA

-- Fake header setup
function CTA:CreateTestHeaders()
	wipe(self.InstanceData) -- Clear any previous headers

	for i = 1, 5 do
		local name = format("Test Dungeon %d", i)
		local header = self:CreateHeaderFrame(name)

		header.ID = i
		header.Name = name
		header.Visible = false
		header:SetAlpha(0)
		header:Hide()

		for j = 1, 3 do
			header.RoleButtons[j]:Show()
		end

		self.InstanceData[i] = header
	end
end

-- Toggle visibility for a random header
function CTA:ToggleRandomHeader()
	local pool = {}

	for _, header in pairs(self.InstanceData) do
		table.insert(pool, header)
	end

	if #pool == 0 then
		print("No test headers to toggle.")

		return
	end

	local header = pool[math.random(1, #pool)]

	self:SetHeaderVisible(header, not header.Visible)
	self:SortQueueHeaders()
end

-- Show all headers (for static testing)
function CTA:ShowAllTestHeaders()
	for _, header in pairs(self.InstanceData) do
		self:SetHeaderVisible(header, true)
	end

	self:SortQueueHeaders()
end

-- Hide all headers
function CTA:HideAllTestHeaders()
	for _, header in pairs(self.InstanceData) do
		self:SetHeaderVisible(header, false)
	end

	self:SortQueueHeaders()
end

-- Clean up all headers
function CTA:ClearTestHeaders()
	for _, header in pairs(self.InstanceData) do
		header.Visible = false
		header:Hide()
	end

	for id, header in pairs(self.InstanceData) do
		if header.IsTest then
			header:Hide()
			self.InstanceData[id] = nil
		end
	end
end

function CTA:DumpSettings()
	print("CTA Settings Dump:")

	for key, value in pairs(self.Settings) do
		if type(value) == "table" then
			print(key .. " = { " .. table.concat(value, ", ") .. " }")
		else
			print(key .. " = " .. tostring(value))
		end
	end
end

function CTA:DumpSavedVariables()
	if not CallToArmsDB then
		print("CallToArmsDB not found.")

		return
	end

	print("Dumping SavedVariables (CallToArmsDB):")

	for key, value in pairs(CallToArmsDB) do
		if type(value) == "table" then
			local flat = {}

			for _, v in ipairs(value) do
				table.insert(flat, tostring(v))
			end

			print(key .. " = { " .. table.concat(flat, ", ") .. " }")
		else
			print(key .. " = " .. tostring(value))
		end
	end
end

function CTA:DumpDungeonFilters()
	if not CallToArmsFilters then
		print("CallToArmsFilters table not found.")

		return
	end

	if not self.InstanceData then
		print("Instance data not loaded.")

		return
	end

	print("CallToArmsFilters (All Tracked Dungeons):")

	local total = 0
	local enabled = 0
	local disabled = 0

	for id, header in pairs(self.InstanceData) do
		local name = header.Name or ("Unknown (" .. id .. ")")

		if CallToArmsFilters[id] then
			print(format("  %d: %s — |cffff5555DISABLED|r", id, name))

			disabled = disabled + 1
		else
			print(format("  %d: %s — |cff55ff55ENABLED|r", id, name))

			enabled = enabled + 1
		end

		total = total + 1
	end

	print(format("\nSummary: %d total — %d enabled, %d disabled", total, enabled, disabled))
end

-- Test command macros
CTA_CreateTestHeaders = function() -- /run CTA_CreateTestHeaders()
	CTA:CreateTestHeaders()
end

CTA_ToggleRandomHeader = function() -- /run CTA_ToggleRandomHeader()
	CTA:ToggleRandomHeader()
end

CTA_ShowAllHeaders = function() -- /run CTA_ShowAllHeaders()
	CTA:ShowAllTestHeaders()
end

CTA_HideAllHeaders = function() -- /run CTA_HideAllHeaders()
	CTA:HideAllTestHeaders()
end

CTA_ClearTestHeaders = function() -- /run CTA_ClearTestHeaders()
	CTA:ClearTestHeaders()
end

CTA_TestLevelUp = function() -- /run CTA_TestLevelUp()
	CTA:debug("Mimicking level up event...")
	CTA:PLAYER_LEVEL_UP()
end

CTA_DumpSettings = function() -- /run CTA_DumpSettings()
	CTA:DumpSettings()
end

CTA_DumpSavedVariables = function() -- /run CTA_DumpSavedVariables()
	CTA:DumpSavedVariables()
end

CTA_DumpDungeonFilters = function() -- /run CTA_DumpDungeonFilters()
	CTA:DumpDungeonFilters()
end