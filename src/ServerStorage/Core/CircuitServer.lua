
local RunService = game:GetService('RunService')
local Players = game:GetService('Players')

local SystemsContainer = {}

local DEFAULT_TICK_SPEED = 20
local CUSTOM_TICK_SPEED = { }

local AUTO_TICK_PLAYERS = { }
local LAST_TICK_PLAYERS = { }

-- // Module // --
local Module = {}

function Module.EnableAutoUpdateForPlayer( LocalPlayer : Player )
	if not table.find( AUTO_TICK_PLAYERS, LocalPlayer ) then
		table.insert(AUTO_TICK_PLAYERS, LocalPlayer)
	end
end

function Module.DisableAutoUpdateForPlayer( LocalPlayer : Player )
	local index = table.find( AUTO_TICK_PLAYERS, LocalPlayer )
	while index do
		table.remove(AUTO_TICK_PLAYERS, index)
		index = table.find( AUTO_TICK_PLAYERS, LocalPlayer ) -- remove duplicates as well
	end
end

function Module.GetPlayerTickSpeed( LocalPlayer : Player )
	return CUSTOM_TICK_SPEED[ LocalPlayer ] or DEFAULT_TICK_SPEED
end

function Module.SetPlayerTickSpeed( LocalPlayer : Player, stepsPerSecond : number )
	CUSTOM_TICK_SPEED[LocalPlayer] = stepsPerSecond
end

function Module.StepPlayerCircuitTick( LocalPlayer : Player )
	local index = table.find( AUTO_TICK_PLAYERS, LocalPlayer )
	if index then
		return false, 'You cannot use this command whilst your ticks are NOT frozen.'
	end

	error( string.format('Update Player\'s circuit: %s', LocalPlayer.Name) )
end

function Module.OnPlayerAdded( LocalPlayer : Player )
	Module.EnableAutoUpdateForPlayer(LocalPlayer)
end

function Module.Start()
	for _, LocalPlayer in ipairs( Players:GetPlayers() ) do
		task.spawn(Module.OnPlayerAdded, LocalPlayer)
	end
	Players.PlayerAdded:Connect(Module.OnPlayerAdded)
	Players.PlayerRemoving:Connect(Module.DisableAutoUpdateForPlayer)

	RunService.Heartbeat:Connect(function(_ : number)
		for _, LocalPlayer in ipairs( AUTO_TICK_PLAYERS ) do
			if LAST_TICK_PLAYERS[LocalPlayer] and time() < LAST_TICK_PLAYERS[LocalPlayer] then
				continue
			end
			LAST_TICK_PLAYERS[LocalPlayer] = time() + 1 / Module.GetPlayerTickSpeed( LocalPlayer )

			local success, err = pcall(Module.StepPlayerCircuitTick, LocalPlayer )
			if not success then
				warn(err)
				LAST_TICK_PLAYERS[LocalPlayer] = time() + 5
				-- it errored so let the player know
			end
		end
	end)
end

function Module.Init(otherSystems)
	SystemsContainer = otherSystems
end

return Module
