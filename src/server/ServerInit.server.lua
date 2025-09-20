--!strict
local total = 0
local required = 0

local Type = script.ClassName == "Script" and "Server" or "Client"

local path = script -- Path To Track

for _, module: ModuleScript in path:GetDescendants() do
	local parent = module.Parent :: any
	if module:IsA("ModuleScript") and parent.ClassName ~= "ModuleScript" then
		total += 1
		task.spawn(function()
			local mod = require(module) :: any
			required += 1

			if typeof(mod) == "function" then
				mod()
			elseif typeof(mod) == "table" and typeof(mod.Init) == "function" then
				mod.Init()
			end
		end)
	end
end

print(`Total Modules {Type}: {total}`)

repeat
	task.wait(0.1)
until required >= total / 1.2
print(`Required Modules {Type}: {required}`)
