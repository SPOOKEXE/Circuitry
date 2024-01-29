
local HttpService = game:GetService('HttpService')

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ReplicatedModules = require(ReplicatedStorage:WaitForChild("Modules"))

local RNetModule = ReplicatedModules.Libraries.RNet
local PlacementBridge = RNetModule.Create('PlacementSystem')

local CircuitComponentsModule = ReplicatedModules.Data.CircuitComponents
local PlacementUtility = ReplicatedModules.Utility.Placement

local PlacementsFolder = workspace:WaitForChild('Placements')

local SystemsContainer = {}

-- // Module // --
local Module = {}

--[[
	local TargetComponentId = CurrentId
	local TargetPosition = CurrentPosition
	local TargetRotation = CurrentRotation
	print('Place', TargetComponentId, TargetPosition, TargetRotation)

	local ComponentData : {}? = CircuitComponentsModule.GetComponentFromId( TargetComponentId )
	local ComponentModel : Instance? = ComponentData and CircuitComponentsModule.FindModelFromName( ComponentData.Model )

	print( TargetPosition, TargetRotation )
	local Pivot = CFrame.new( TargetPosition ) * CFrame.Angles(0, math.rad(TargetRotation * 90), 0)

	local Model = ComponentModel:Clone()
	Model:PivotTo( Pivot )
	Model.Parent = PlacementsFolder
]]

--[[
	local rayParams = RaycastParams.new()
	rayParams.FilterType = Enum.RaycastFilterType.Include
	rayParams.FilterDescendantsInstances = { workspace:WaitForChild('BetterBasePlates'), PlacementsFolder }
	local overlapParams = OverlapParams.new()
	overlapParams.FilterType = Enum.RaycastFilterType.Include
	overlapParams.FilterDescendantsInstances = { PlacementsFolder }
]]

--[[
	RunService.Heartbeat:Connect(function()
		if CurrentModel and IsPlacementEnabled then
			local BoxCFrame, BoxSize = PlacementUtility.GetModelBoundingBoxData( CurrentModel )
			-- find position
			local MouseHit : CFrame = GetMouseHit( 50 )
			local GridSnapped = PlacementUtility.ClampToGrid( MouseHit.Position, 1, false )
			CurrentPosition = GridSnapped
			local Pivot = CFrame.new( GridSnapped ) * CFrame.Angles(0, math.rad(CurrentRotation * 90), 0)
			-- pivot to
			CurrentModel:PivotTo( Pivot )
			-- collision detection
			IsCollisionDetected = #workspace:GetPartBoundsInBox( BoxCFrame, BoxSize * 0.95, overlapParams ) ~= 0
			local OutlineColor : Color3 = IsCollisionDetected and Color3.new(0.7,0,0) or Color3.new(0, 0.7, 0)
			PlacementModelHighlight.OutlineColor = OutlineColor
		end
	end)
]]

function Module.PlaceComponentAtPosition( LocalPlayer, componentId : string, position : Vector3, rotation : number )

	local componentUUID = HttpService:GenerateGUID(false)
	print( LocalPlayer.Name, '-', componentId, position, rotation, '-', componentUUID )

end

function Module.DeleteComponent( LocalPlayer, targetUUID : string )
	if typeof(targetUUID) ~= 'string' then
		return false, 'Target component is not a string.'
	end

	--local Object = PlacementsFolder:FindFirstChild( targetUUID )
	--if Object then
	--	Object:Destroy()
	--end
	--SystemsContainer.CircuitServer.DeleteComponent( LocalPlayer, targetUUID )

	return true, 'Component has been deleted.'
end

function Module.Start()

	PlacementBridge:OnServerEvent(function( LocalPlayer, ... )

	end)

end

function Module.Init(otherSystems)
	SystemsContainer = otherSystems
end

return Module
