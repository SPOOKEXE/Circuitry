
local Players = game:GetService('Players')

local SystemsContainer = {}

local PLAYERS_WITH_DISABLED_COMMANDS = { }
local PLAYERS_WITH_DISABLED_GAMEPLAY = { }

-- // Module // --
local Module = {}

function Module.CanPlayerRunGameplay( LocalPlayer : Player )
	return not PLAYERS_WITH_DISABLED_GAMEPLAY[LocalPlayer]
end

function Module.CanPlayerRunCommands( LocalPlayer : Player )
	return not PLAYERS_WITH_DISABLED_COMMANDS[LocalPlayer]
end

function Module.AllowPlayerGameplay( LocalPlayer : Player )
	PLAYERS_WITH_DISABLED_GAMEPLAY[LocalPlayer] = nil
end

function Module.DisallowPlayerGameplay( LocalPlayer : Player )
	PLAYERS_WITH_DISABLED_GAMEPLAY[LocalPlayer] = true
end

function Module.AllowPlayerCommands( LocalPlayer : Player )
	PLAYERS_WITH_DISABLED_COMMANDS[LocalPlayer] = nil
end

function Module.DisallowPlayerCommands( LocalPlayer : Player )
	PLAYERS_WITH_DISABLED_COMMANDS[LocalPlayer] = true
end

function Module.OnPlayerAdded( LocalPlayer : Player )
	-- SystemsContainer.CircuitServer.OnPlayerAdded( LocalPlayer )
	SystemsContainer.CommandsServer.SetupPlayerCommandsHook( LocalPlayer )
end

function Module.OnPlayerRemoving( LocalPlayer : Player )
	-- SystemsContainer.CircuitServer.OnPlayerRemoving( LocalPlayer )
end

function Module.Start()

	for _, LocalPlayer in ipairs( Players:GetPlayers() ) do
		Module.OnPlayerAdded( LocalPlayer )
	end
	Players.PlayerAdded:Connect(Module.OnPlayerAdded)
	Players.PlayerRemoving:Connect(Module.OnPlayerRemoving)

end

function Module.Init(otherSystems)
	SystemsContainer = otherSystems
end

return Module
