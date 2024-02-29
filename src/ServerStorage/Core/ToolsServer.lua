
local HttpService = game:GetService('HttpService')

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ReplicatedModules = require(ReplicatedStorage:WaitForChild("Modules"))

local RNetModule = ReplicatedModules.Libraries.RNet
local PlacementBridge = RNetModule.Create('PlacementSystem')
local ToolsBridge = RNetModule.Create('PlacementTools')

local CircuitComponentsModule = ReplicatedModules.Data.CircuitComponents
local ToolsConfigModule = ReplicatedModules.Data.Tools
local PlacementUtility = ReplicatedModules.Utility.Placement

local PlacementsFolder = workspace:WaitForChild('Placements')

local SystemsContainer = {}

local overlapParams = OverlapParams.new()
overlapParams.FilterType = Enum.RaycastFilterType.Include

-- // Module // --
local Module = {}

function Module.PlaceComponentAtPosition( LocalPlayer : Player, componentId : string, position : Vector3, rotation : number )
	if typeof(componentId) ~= 'string' then
		return false, 'ComponentId is an invalid datatype.'
	end
	if typeof(position) ~= 'Vector3' then
		return false, 'Position is an invalid datatype.'
	end
	if typeof(rotation) ~= 'number' then
		return false, 'Rotation is an invalid datatype.'
	end
	rotation = math.floor( math.clamp(rotation, 1, 4) )

	print( LocalPlayer.Name, '-', componentId, position, rotation )

	local ComponentData = CircuitComponentsModule.GetComponentFromId( componentId )
	if not ComponentData then
		return false, string.format('Component with id %s does not exist.', tostring(componentId))
	end

	local ComponentModel = ComponentData.Model and CircuitComponentsModule.FindModelFromName( ComponentData.Model )
	if not ComponentModel then
		return false, string.format('Could not find component model for component %s', componentId)
	end

	local GridSnapped = PlacementUtility.ClampToGrid( position, 1, false )
	local Pivot = CFrame.new( GridSnapped ) * CFrame.Angles(0, math.rad((rotation % 4) * 90), 0)

	local BoxCFrame, BoxSize = PlacementUtility.GetModelBoundingBoxData( ComponentModel )
	if #workspace:GetPartBoundsInBox( BoxCFrame, BoxSize * 0.95, overlapParams ) ~= 0 then
		return false, 'You cannot place the component here as it collides with other components.'
	end

	local componentUUID = HttpService:GenerateGUID(false)

	local Clone = ComponentModel:Clone()
	Clone.Name = componentUUID
	Clone:SetAttribute('ComponentId', componentId)
	Clone:SetAttribute('LastOwnerId', LocalPlayer.UserId)
	Clone:PivotTo( Pivot )
	Clone.Parent = PlacementsFolder

	SystemsContainer.CircuitServer.AddComponent( componentUUID, componentId )
	SystemsContainer.CircuitServer.ClaimComponentOwnership( componentUUID, LocalPlayer )

	return true, 'Component has been placed.'
end

function Module.DeleteComponent( targetUUID : string )
	if typeof(targetUUID) ~= 'string' then
		return false, 'Target component is not a string.'
	end

	local Object = PlacementsFolder:FindFirstChild( targetUUID )
	if Object then
		Object:Destroy()
	end
	SystemsContainer.CircuitServer.DeleteComponent( targetUUID )

	return true, 'Component has been deleted.'
end

function Module.MoveComponent( componentUUID : string, position : Vector3, rotation : number )
	local ComponentModel = PlacementsFolder:FindFirstChild(componentUUID)
	if not ComponentModel then
		return false, 'Component does not exist.'
	end

	local GridSnapped = PlacementUtility.ClampToGrid( position, 1, false )
	local Pivot = CFrame.new( GridSnapped ) * CFrame.Angles(0, math.rad((rotation % 4) * 90), 0)

	local BoxCFrame, BoxSize = PlacementUtility.GetModelBoundingBoxData( ComponentModel )
	if #workspace:GetPartBoundsInBox( BoxCFrame, BoxSize * 0.95, overlapParams ) ~= 0 then
		return false, 'You cannot place the component here as it collides with other components.'
	end

	ComponentModel:PivotTo( Pivot )

	return true, 'Component has bee nmoved.'
end

function Module.AttemptComponentDelete( LocalPlayer : Player, targetUUID : string )
	-- TODO: permissions check
	return Module.DeleteComponent(targetUUID)
end

function Module.AttemptSingleConnect( LocalPlayer : Player, source : string, targets : {string}, reversed : string )
	-- TODO: permissions check
	return SystemsContainer.CircuitServer.AddConnections( source, targets, reversed )
end

function Module.AttemptParallelConnect( LocalPlayer : Player, sources : {string}, targets : {string}, reversed : string )
	-- TODO: permissions check
	return SystemsContainer.CircuitServer.AddIndexedConnections( sources, targets, reversed )
end

function Module.ParseToolCommand( LocalPlayer : Player, ... : any )

	print( LocalPlayer.Name, ... )

	local Args = {...}
	local Job = table.remove(Args, 1)

	if Job == ToolsConfigModule.RemoteEnums.Delete then
		local Arg0 = table.remove(Args, 1)
		if typeof(Arg0) ~= 'table' then
			return false, 'Invalid arguments.'
		end
		for _, componentId in ipairs( Arg0 ) do
			task.defer( Module.AttemptComponentDelete, componentId )
		end
		return true, 'Components have been deleted.'
	elseif Job == ToolsConfigModule.RemoteEnums.WireSingle then
		local source, targets, reversed = unpack(Args)
		if typeof(source) ~= 'string' then
			return false, 'Invalid argument.'
		end
		if typeof(targets) ~= 'table' then
			return false, 'Invalid argument.'
		end
		if typeof(reversed) ~= 'boolean' then
			return false, 'Invalid argument.'
		end
		Module.AttemptSingleConnect( LocalPlayer, source, targets, reversed )
		return true, 'Valid connections were made.'
	elseif Job == ToolsConfigModule.RemoteEnums.WireParallel then
		local sources, targets, reversed = unpack(Args)
		if typeof(sources) ~= 'table' then
			return false, 'Invalid argument.'
		end
		if typeof(targets) ~= 'table' then
			return false, 'Invalid argument.'
		end
		if typeof(reversed) ~= 'boolean' then
			return false, 'Invalid argument.'
		end
		Module.AttemptParallelConnect( LocalPlayer, sources, targets, reversed )
		return true, 'Valid connections were made.'
	elseif Job == ToolsConfigModule.RemoteEnums.Rotate then
		warn('rotate not implemented.')
	elseif Job == ToolsConfigModule.RemoteEnums.Move then
		warn('move not implemented.')
	end

	return false, 'Could not find given job.'
end

function Module.Start()
	overlapParams.FilterDescendantsInstances = { PlacementsFolder }

	PlacementBridge:OnServerInvoke(Module.PlaceComponentAtPosition)
	ToolsBridge:OnServerEvent(Module.ParseToolCommand)
end

function Module.Init(otherSystems)
	SystemsContainer = otherSystems
end

return Module
