
local Players = game:GetService('Players')

local SystemsContainer = {}

-- // Module // --
local Module = {}

function Module.ParseChatCommand( LocalPlayer : Player, message : string )
	local splits = string.split(message, ' ')
	local command = table.remove(splits, 1)
	if command == 'help' then
		print(LocalPlayer.Name, ' has used the chat command \'help\'.')
		--[[
			commands:
			- !claim
			- !unclaim
			- !tickfreeze
			- !tickunfreeze
			- !tickstep
		]]
	elseif command == 'claim' then
		SystemsContainer.ClaimsService.CreatePlayerClaim( LocalPlayer )
	elseif command == 'unclaim' then
		SystemsContainer.ClaimsService.ClearPlayerClaim( LocalPlayer )
	elseif command == 'tickfreeze' then
		SystemsContainer.CircuitServer.DisableAutoUpdateForPlayer( LocalPlayer )
	elseif command == 'tickunfreeze' then
		SystemsContainer.CircuitServer.EnableAutoUpdateForPlayer( LocalPlayer )
	elseif command == 'tickstep' then
		SystemsContainer.CircuitServer.StepPlayerCircuitTick( LocalPlayer )
	else
		warn('Unsupported chat command; ' .. tostring(command))
	end
end

function Module.OnPlayerAdded( LocalPlayer : Player )

	LocalPlayer.Chatted:Connect(function(message, recipient)
		if recipient then
			return
		end
		if string.sub(message, 1, 1) == '!' then
			Module.ParseChatCommand( LocalPlayer, string.sub(message, 2) )
		end
	end)

end

function Module.Start()

	for _, LocalPlayer in ipairs( Players:GetPlayers() ) do
		task.spawn(Module.OnPlayerAdded, LocalPlayer)
	end
	Players.PlayerAdded:Connect(Module.OnPlayerAdded)

end

function Module.Init(otherSystems)
	SystemsContainer = otherSystems
end

return Module
