--[[

	FIX:
	- connections made to specific outputs in the component (basePart.Name)

]]


local Players = game:GetService("Players")

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ReplicatedModules = require(ReplicatedStorage:WaitForChild("Modules"))

local ComponentsConfigModule = ReplicatedModules.Data.CircuitComponents

local SystemsContainer = {}

local function RemoveOccurancesFrom( array : {any}, value : any ) : nil
	local index = table.find(array, value)
	while index do
		table.remove( array, index )
		index = table.find(array, value)
	end
end

-- // Module // --
local Module = {}

Module.ActiveCircuitsCache = {} -- { [uuid] = componentData }
Module.PlayerToComponents = {} -- { [Player] = uuid }
Module.ComponentsToPlayer = {} -- { [uuid] = Player }

function Module.GetComponentFromUUID( uuid : string ) : { }?
	return Module.ActiveCircuitsCache[ uuid ]
end

function Module.CreateRealtimeData( componentUUID, componentId )
	return { UUID = componentUUID, ID = componentId, Inputs = { }, Outputs = { }, }
end

function Module.ClaimComponentOwnership( componentUUID : string, LocalPlayer : Player? )
	Module.ComponentsToPlayer[componentUUID] = LocalPlayer
	if not Module.PlayerToComponents[LocalPlayer] then
		Module.PlayerToComponents[LocalPlayer] = {}
	end
	if not table.find(Module.PlayerToComponents[LocalPlayer], componentUUID) then
		table.insert(Module.PlayerToComponents[LocalPlayer], componentUUID)
	end
	return true, 'Claimed ownership of the target component.'
end

-- function Module.AttemptComponentOwneshipClaim( LocalPlayer : Player, componentUUID : string )
-- 	-- TODO: permissions check
-- 	return Module.ClaimComponentOwnership( componentUUID, LocalPlayer )
-- end

function Module.UnclaimAllPlayerComponents( LocalPlayer : Player )
	if not Module.PlayerToComponents[LocalPlayer] then
		return false, 'Component does not exist.'
	end
	for _, uuid in ipairs( Module.PlayerToComponents[LocalPlayer] ) do
		Module.ComponentsToPlayer[uuid] = nil
	end
	Module.PlayerToComponents[LocalPlayer] = nil
	return true, 'Unclaimed all components of the target player.'
end

function Module.AddComponent( componentUUID : string, componentId : string )
	local ComponentConfig = ComponentsConfigModule.GetComponentFromId( componentId )
	if not ComponentConfig then
		return false, 'No component config found for component of id: ' .. tostring(componentId)
	end
	if not Module.ActiveCircuitsCache[componentUUID] then
		local Data = Module.CreateRealtimeData( componentUUID, componentId )
		Module.ActiveCircuitsCache[componentUUID] = Data
	end
	return Module.ActiveCircuitsCache[componentUUID]
end

function Module.WipeConnections( componentUUID : string )
	-- check if component exists
	local Data = Module.ActiveCircuitsCache[componentUUID]
	if not Data then
		return false, 'Component does not exist.'
	end
	-- search all input nodes for my component id and remove it
	for _, inputUUID in ipairs( Data.Inputs ) do
		local InputData = Module.ActiveCircuitsCache[inputUUID]
		if InputData then
			RemoveOccurancesFrom( InputData.Inputs, componentUUID )
			RemoveOccurancesFrom( InputData.Outputs, componentUUID )
		end
	end
	-- search all output nodes for my component id and remove it
	for _, outputUUID in ipairs( Data.Outputs ) do
		local OutputData = Module.ActiveCircuitsCache[outputUUID]
		if OutputData then
			RemoveOccurancesFrom( OutputData.Inputs, componentUUID )
			RemoveOccurancesFrom( OutputData.Outputs, componentUUID )
		end
	end
end

function Module.RemoveConnection( componentUUID : string, targetUUID : string )
	local Data = Module.ActiveCircuitsCache[componentUUID]
	if not Data then
		return false, 'Component does not exist.'
	end
	RemoveOccurancesFrom( Data.Inputs, targetUUID )
	RemoveOccurancesFrom( Data.Outputs, targetUUID )
end

function Module.DeleteComponent( componentUUID : string )
	-- wipe all connections
	Module.WipeConnections( componentUUID )
	-- remove it from the cache
	Module.ActiveCircuitsCache[componentUUID] = nil
end

function Module.AddConnections( componentUUID : string, uuids : {string}, reversed : boolean )
	-- check if the component exists
	local componentData = Module.ActiveCircuitsCache[componentUUID]
	if not componentData then
		return false, 'Component does not exist.'
	end

	for _, targetUUID in ipairs( uuids ) do
		if targetUUID == componentUUID then
			continue -- can't connect to self
		end

		if table.find( componentData.Inputs, targetUUID ) or table.find(componentData.Outputs, targetUUID ) then
			continue -- cannot connect A to B and B to A
		end

		local targetData = Module.ActiveCircuitsCache[targetUUID]
		if not targetData then
			continue -- doesn't exist
		end

		if table.find( targetData.Inputs, componentUUID ) or table.find(targetData.Outputs, componentUUID ) then
			continue -- cannot connect A to B and B to A
		end

		local array1 = reversed and targetData.Outputs or targetData.Inputs
		if not table.find( array1, componentUUID ) then
			table.insert( array1, componentUUID )
		end

		local array2 = reversed and targetData.Inputs or targetData.Outputs
		if not table.find( array2, targetUUID ) then
			table.insert( array2, targetUUID )
		end
	end

end

function Module.AddIndexedConnections( array0 : {string}, array1 : {string}, reversed : boolean )
	for index, sourceUUID in ipairs( array0 ) do
		local componentData = Module.ActiveCircuitsCache[sourceUUID]
		if not componentData then
			continue -- doesnt exist
		end

		local targetUUID = array1[index]
		if not targetUUID then
			continue -- no matching index output to
		end

		local targetData = Module.ActiveCircuitsCache[targetUUID]
		if not targetData then
			continue -- doesn't exist
		end

		local Array1 = reversed and targetData.Outputs or targetData.Inputs
		if not table.find( Array1, sourceUUID ) then
			table.insert( Array1, sourceUUID )
		end

		local Array2 = reversed and targetData.Inputs or targetData.Outputs
		if not table.find( Array2, targetUUID ) then
			table.insert( Array2, targetUUID )
		end
	end
end

function Module.Start()
	Players.PlayerRemoving:Connect(Module.UnclaimAllPlayerComponents)
end

function Module.Init(otherSystems)
	SystemsContainer = otherSystems
end

return Module
