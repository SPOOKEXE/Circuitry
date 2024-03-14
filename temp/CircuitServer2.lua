
local Players = game:GetService("Players")

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local ReplicatedModules = require(ReplicatedStorage:WaitForChild("Modules"))

local ComponentsConfigModule = ReplicatedModules.Data.CircuitComponents
local TableUtility = ReplicatedModules.Utility.Table

local SystemsContainer = {}

-- // Module // --
local Module = {}

Module.ActiveCircuitsCache = {} -- { [string] : { UUID : string, ID : string, Connections : dict, } }
Module.PlayerToComponents = {} -- { [Player] = {uuid} }
Module.ComponentsToPlayer = {} -- { [uuid] = Player }

function Module.GetComponentFromUUID( uuid : string ) : { }?
	return Module.ActiveCircuitsCache[ uuid ]
end

function Module.CreateComponentData( uuid : string, id : string )
	return { UUID = uuid, ID = id, Connections = { }, }
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
		local Data = Module.CreateComponentData( componentUUID, componentId )
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
	Data.Connections = { }
end

function Module.RemoveConnection( source : string, snode : string, target : string, tnode : string )
	local Data = Module.ActiveCircuitsCache[source]
	if not Data then
		return false, 'Component does not exist.'
	end

	local snodeConns = Data.Connections[ snode ]
	if not snodeConns then
		return true, 'Connection has been removed.'
	end

	if not snodeConns[ target ] then
		return true, 'Connection has been removed.'
	end

	local index = table.find( snodeConns[ target ], tnode )
	if index then
		table.remove( snodeConns[ target ], index )
	end
	snodeConns[ target ] = nil

	if TableUtility.CountDictionary( snodeConns ) == 0 then
		Data.Connections[ snode ] = nil
	end

	return true, 'Connection has been removed.'
end

function Module.DeleteComponent( uuid : string )
	-- wipe all connections
	Module.WipeConnections( uuid )
	-- remove it from the cache
	local ownerPlayer = Module.ComponentsToPlayer[uuid]
	if ownerPlayer then
		local index = table.find( Module.PlayerToComponents[uuid], uuid )
		while index do
			table.remove( Module.PlayerToComponents[uuid], index )
			index = table.find( Module.PlayerToComponents[uuid], uuid )
		end
		if #Module.PlayerToComponents[uuid] == 0 then
			Module.PlayerToComponents[player] = nil
		end
		Module.PlayerToComponents[ownerPlayer] = nil
	end
	Module.ActiveCircuitsCache[uuid] = nil
	Module.ComponentsToPlayer[uuid] = nil
	return true, 'Component has been deleted.'
end

type ComponentConnection = { sourcec : string, sourcen : string, targetc : string, targetn : string }

function Module.AddConnections( connections : { ComponentConnection }, reversed : boolean )
	for _, connection in ipairs( connections ) do
		if connection.sourcec == connection.targetc and connection.sourcen == connection.targetn then
			continue -- cannot connect self into self
		end

		local sourceComponent : {} = Module.ActiveCircuitsCache[connection.sourcec]
		if not sourceComponent then
			continue -- source does not exist
		end

		local sourceConfig : {} = ComponentsConfigModule.GetComponentFromId( sourceComponent.ID )
		if not sourceConfig then
			continue -- no source config
		end

		local targetComponent : {} = Module.ActiveCircuitsCache[connection.targetc]
		if not targetComponent then
			continue -- target does not exist
		end

		local targetConfig : {} = ComponentsConfigModule.GetComponentFromId( targetComponent.ID )
		if not targetConfig then
			continue -- no target config
		end

		if reversed then
			-- target component connects to the source component
			if not sourceComponent.Connections[ connection.targetn ] then
				sourceComponent.Connections[ connection.targetn ] = { }
			end
			if not sourceComponent.Connections[ connection.targetn ][ connection.sourcec ] then
				sourceComponent.Connections[ connection.targetn ][ connection.sourcec ] = { }
			end
			local targetConns = sourceComponent.Connections[ connection.targetn ][ connection.sourcec ]
			if not table.find( targetConns, connection.sourcen ) then
				table.insert( targetConns, connection.sourcen )
			end
		else
			-- source component connects to the target component
			if not sourceComponent.Connections[ connection.sourcen ] then
				sourceComponent.Connections[ connection.sourcen ] = { }
			end
			if not sourceComponent.Connections[ connection.sourcen ][ connection.targetc ] then
				sourceComponent.Connections[ connection.sourcen ][ connection.targetc ] = { }
			end
			local targetConns = sourceComponent.Connections[ connection.sourcen ][ connection.targetc ]
			if not table.find( targetConns, connection.targetn ) then
				table.insert( targetConns, connection.targetn )
			end
		end
	end
end

function Module.UpdateComponents( _ : number )

	for sourceUUID, sourceData in pairs( Module.ActiveCircuitsCache ) do
		for targetUUID, targetNodeArray in pairs( sourceData.Connections ) do
			for _, targetNode in ipairs( targetNodeArray ) do

			end
		end
	end

end

function Module.Start()
	Players.PlayerRemoving:Connect(Module.UnclaimAllPlayerComponents)
	RunService.Heartbeat:Connect(Module.UpdateComponents)
end

function Module.Init(otherSystems)
	SystemsContainer = otherSystems
end

return Module
