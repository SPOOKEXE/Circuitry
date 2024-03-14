
local Players = game:GetService("Players")

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local ReplicatedModules = require(ReplicatedStorage:WaitForChild("Modules"))

local ComponentsConfigModule = ReplicatedModules.Data.CircuitComponents
local TableUtility = ReplicatedModules.Utility.Table

local SystemsContainer = {}

type NewConnectionWires = { sourcec : string, sourcen : string, targetc : string, targetn : string }

-- // Module // --
local Module = {}

function Module.ClearComponentConnections( component : string )
	local sourceComponent : {} = Module.ActiveCircuitsCache[component]
	if sourceComponent then
		sourceComponent.Connections = {}
	end
end

function Module.AddConnections( connections : { NewConnectionWires }, reversed : boolean )

	for _, connect in ipairs( connections ) do
		if connect.sourcec == connect.targetc and connect.sourcen == connect.targetn then
			continue -- cannot connect self into self
		end

		local sourceComponent : {} = Module.ActiveCircuitsCache[connect.sourcec]
		if not sourceComponent then
			continue -- source does not exist
		end

		local sourceConfig : {} = ComponentsConfigModule.GetComponentFromId( sourceComponent.ID )
		if not sourceConfig then
			continue -- no source config
		end

		local targetComponent : {} = Module.ActiveCircuitsCache[connect.targetc]
		if not targetComponent then
			continue -- target does not exist
		end

		local targetConfig : {} = ComponentsConfigModule.GetComponentFromId( targetComponent.ID )
		if not targetConfig then
			continue -- no target config
		end

		if reversed then
			-- target component connects to the source component
			if not sourceComponent.Connections[ connect.targetn ] then
				sourceComponent.Connections[ connect.targetn ] = { }
			end
			if not sourceComponent.Connections[ connect.targetn ][ connect.sourcec ] then
				sourceComponent.Connections[ connect.targetn ][ connect.sourcec ] = { }
			end
			local targetConns = sourceComponent.Connections[ connect.targetn ][ connect.sourcec ]
			if not table.find( targetConns, connect.sourcen ) then
				table.insert( targetConns, connect.sourcen )
			end
		else
			-- source component connects to the target component
			if not sourceComponent.Connections[ connect.sourcen ] then
				sourceComponent.Connections[ connect.sourcen ] = { }
			end
			if not sourceComponent.Connections[ connect.sourcen ][ connect.targetc ] then
				sourceComponent.Connections[ connect.sourcen ][ connect.targetc ] = { }
			end
			local targetConns = sourceComponent.Connections[ connect.sourcen ][ connect.targetc ]
			if not table.find( targetConns, connect.targetn ) then
				table.insert( targetConns, connect.targetn )
			end
		end
	end

end

function Module.Start()

end

function Module.Init(otherSystems)
	SystemsContainer = otherSystems
end

return Module
