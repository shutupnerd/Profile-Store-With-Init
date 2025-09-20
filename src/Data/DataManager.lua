local DataManager = {}

-- Stores profiles from ProfileStore
DataManager.Profiles = {}

function DataManager.GetData(player: Player)
	if not DataManager.Profiles[player] then
		return
	end
	return DataManager.Profiles[player].Data
end

function DataManager.AddCash(player: Player, amount: number)
	local profile = DataManager.Profiles[player]
	if not profile then
		return
	end

	profile.Data.Cash += amount
	player:SetAttribute("Cash", profile.Data.Cash)
end

function DataManager.AddWins(player: Player, amount: number)
	local profile = DataManager.Profiles[player]
	if not profile then
		return
	end

	profile.Data.Wins += amount
	player:SetAttribute("Wins", profile.Data.Wins)
end

function DataManager.AddItem(player: Player, item: string, amount: number?)
	local profile = DataManager.Profiles[player]
	if not profile then
		return
	end

	if amount <= 1 then
		table.insert(profile.Data.Inventory, item)
		return
	else
		for _ = 1, amount or 1 do
			table.insert(profile.Data.Inventory, item)
		end
	end
end

return DataManager
