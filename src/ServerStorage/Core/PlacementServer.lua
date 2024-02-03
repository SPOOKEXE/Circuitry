
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

function Module.PlaceComponentAtPosition( LocalPlayer, componentId : string, position : Vector3, rotation : number )
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
	Clone:SetAttribute('OwnerId', LocalPlayer.UserId)
	Clone:PivotTo( Pivot )
	Clone.Parent = PlacementsFolder

	-- SystemsContainer.CircuitServer.RegisterCircuit( LocalPlayer, componentUUID, componentId )

	return true, 'Component has been placed.'
end

function Module.DeleteComponent( LocalPlayer : Player, targetUUID : string )
	if typeof(targetUUID) ~= 'string' then
		return false, 'Target component is not a string.'
	end

	local Object = PlacementsFolder:FindFirstChild( targetUUID )
	print( targetUUID, Object and Object:GetFullName() or 'Does not exist.' )
	if Object then
		Object:Destroy()
	end
	-- SystemsContainer.CircuitServer.DeleteComponent( LocalPlayer, targetUUID )

	return true, 'Component has been deleted.'
end

function Module.ParseToolCommand( LocalPlayer : Player, ... : any )

	print( LocalPlayer.Name, ... )

	local Args = {...}
	local Job = table.remove(Args, 1)

	if Job == ToolsConfigModule.RemoteEnums.Delete then
		local Arg0 = table.remove(Args, 1)
		if typeof(Arg0) ~= 'table' or #Arg0 == 0 then
			return
		end
		for _, componentId in ipairs( Arg0 ) do
			task.defer( Module.DeleteComponent, LocalPlayer, componentId )
		end
	end

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
