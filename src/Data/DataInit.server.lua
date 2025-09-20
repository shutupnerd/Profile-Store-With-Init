-- Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ServerScriptService = game:GetService("ServerScriptService")

-- Folders
--local Events = ReplicatedStorage.Events

-- ProfileStore
local ProfileStore = require(ServerScriptService.Services.ProfileStore)

-- Error Message
local defaultErrorMessage = `Data error occured. Please Rejoin, your data will be safe.`

-- Modules
local Template = require(ServerScriptService.Data.Template) -- Our Data Template
local DataManager = require(ServerScriptService.Data.DataManager)

-- Studio/Live Check
local function GetDataName()
	return RunService:IsStudio() and "Studio" or "Live"
end

local Profiles = ProfileStore.New(GetDataName(), Template) -- Access Profile From Template

-- Adds Functions According To Players Profile
local function Initilize(player: Player, profile: typeof(Profiles:StartSessionAsync()))
	-- Leaderstats
	local leaderstats = Instance.new("Folder")
	leaderstats.Parent = player
	leaderstats.Name = "leaderstats"

	local Wins = Instance.new("NumberValue")
	Wins.Parent = leaderstats
	Wins.Name = "Wins"
	Wins.Value = profile.Data.Wins or 0

	local Cash = Instance.new("NumberValue")
	Cash.Parent = leaderstats
	Cash.Name = "Cash"
	Cash.Value = profile.Data.Cash or 0
end

-- Creates/Stores Profile
local function PlayerAdded(player: Player)
	local profile = Profiles:StartSessionAsync("player_" .. player.UserId, { -- e.g player_12983393
		Cancel = function()
			return player.Parent ~= Players
		end,
	})

	if profile ~= nil then
		profile:AddUserId(player.UserId) --GDPR Stuff
		profile:Reconcile() -- Fill in missing variables

		profile.OnSessionEnd:Connect(function() -- Cancel function
			DataManager.Profiles[player] = nil -- Dont Save Data
			player:Kick(defaultErrorMessage)
		end)

		if player.Parent == Players then -- Profile Exists
			DataManager.Profiles[player] = profile
			Initilize(player, profile)
		else
			profile:EndSession()
		end
	else
		player:Kick(defaultErrorMessage)
	end
end

-- In case Players have joined the server earlier than this script ran
for _, player in Players:GetPlayers() do
	task.spawn(PlayerAdded, player)
end
Players.PlayerAdded:Connect(PlayerAdded)

Players.PlayerRemoving:Connect(function(player)
	local profile = DataManager.Profiles[player]
	if not profile then
		return
	end

	profile:EndSession()
	DataManager.Profiles[player] = nil -- Dont Save Data
end)
