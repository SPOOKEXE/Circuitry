
local LocalPlayer = game:GetService('Players').LocalPlayer
local LocalMouse = LocalPlayer:GetMouse()

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ReplicatedModules = require(ReplicatedStorage:WaitForChild("Modules"))

local PlacementUtility = ReplicatedModules.Utility.Placement

local CurrentCamera = workspace.CurrentCamera
local PlacementsFolder = workspace:WaitForChild('Placements')

local rayParams = RaycastParams.new()
rayParams.FilterType = Enum.RaycastFilterType.Include
rayParams.FilterDescendantsInstances = { PlacementsFolder }

local function AngleBetween(vectorA : Vector3, vectorB : Vector3 )
	return math.acos(math.clamp(vectorA:Dot(vectorB), -1, 1))
end

local function IsPointInRect( point : Vector2, topLeft : Vector2, bottomRight : Vector2 ) : boolean
	return (point.X > topLeft.X and point.X < bottomRight.X and point.Y > topLeft.Y and point.Y < bottomRight.Y)
end

-- // Module // --
local Module = {}

function Module.GetMouseHit( distance : number? )
	distance = distance or 50
	local ray = CurrentCamera:ScreenPointToRay( LocalMouse.X, LocalMouse.Y )
	rayParams.FilterDescendantsInstances = { PlacementsFolder, workspace.BetterBasePlates }
	local RayResult = workspace:Raycast( ray.Origin, ray.Direction * distance, rayParams )
	if RayResult then
		return CFrame.lookAt(RayResult.Position, RayResult.Position + ray.Direction.Unit)
	end
	return CFrame.lookAt( ray.Origin, ray.Origin + ray.Direction ) + (ray.Direction.Unit * distance)
end

function Module.GetComponentModelFromPart( basePart : BasePart | Model ) : Model?
	local Model = basePart
	while Model.Parent ~= PlacementsFolder and Model:IsDescendantOf( PlacementsFolder ) do
		Model = Model.Parent
	end
	return Model
end

function Module.RaycastPlaceablePartAtMouse( distance : number? ) : ( Instance?, Vector3? )
	local ray = CurrentCamera:ScreenPointToRay( LocalMouse.X, LocalMouse.Y )
	rayParams.FilterDescendantsInstances = { PlacementsFolder }
	local rayResult = workspace:Raycast( ray.Origin, ray.Direction * (distance or 100), rayParams )
	if rayResult and rayResult.Instance:IsDescendantOf( PlacementsFolder ) then
		return rayResult.Instance, rayResult.Position
	end
	return nil, ray.Origin + (ray.Direction * (distance or 100))
end

function Module.RaycastComponentAtMouse( distance : number? ) : ( Model?, Vector3? )
	local BasePart, Position = Module.RaycastPlaceablePartAtMouse( distance )
	if BasePart then
		return Module.GetComponentModelFromPart( BasePart ), Position
	end
	return nil, nil
end

function Module.RaycastBasePartAtMouse( objects : { BasePart }, distance : number? ) : ( BasePart?, Model?, Vector3? )
	local ray = CurrentCamera:ScreenPointToRay( LocalMouse.X, LocalMouse.Y )
	rayParams.FilterDescendantsInstances = objects
	local rayResult = workspace:Raycast( ray.Origin, ray.Direction * (distance or 100), rayParams )
	if rayResult and rayResult.Instance:IsDescendantOf( PlacementsFolder ) then
		local Model = Module.GetComponentModelFromPart( rayResult.Instance )
		return rayResult.Instance, Model, rayResult.Position
	end
	return nil, nil, nil
end

function Module.IsObjectInCameraFOV( objectPivot : CFrame, cameraCFrame : CFrame ) : boolean
	local lookForward = cameraCFrame.LookVector
	local lookToPoint = (objectPivot.Position - cameraCFrame.Position).Unit
	local angle = AngleBetween(lookForward, lookToPoint)
	return math.abs(angle) <= (CurrentCamera.FieldOfView / 2)
end

function Module.GetBasePartsInScreenBox( objects : { BasePart }, point0 : Vector2, point1 : Vector2, ignoreList : { Instance }? ) : { Instance }
	local topLeft = Vector2.new( math.min( point0.X, point1.X ), math.min( point0.Y, point1.Y ) )
	local bottomRight = Vector2.new( math.max( point0.X, point1.X ), math.max( point0.Y, point1.Y ) )

	LocalPlayer.PlayerGui.Debug:ClearAllChildren()

	local CameraCFrame = CurrentCamera.CFrame
	local BaseParts = {}
	for _, Parts in ipairs( objects ) do
		if ignoreList and table.find(ignoreList, Parts) then
			continue
		end

		local BoundsCFrame, _ = PlacementUtility.GetModelBoundingBoxData( Parts )
		local InFOV = Module.IsObjectInCameraFOV( BoundsCFrame, CameraCFrame )
		if not InFOV then
			continue
		end

		local ScreenXY, _ = CurrentCamera:WorldToScreenPoint( BoundsCFrame.Position )

		-- local Frame = Instance.new('Frame')
		-- Frame.Name = tostring( ScreenXY )
		-- Frame.Size = UDim2.fromOffset(20, 20)
		-- Frame.BorderSizePixel = 0
		-- Frame.BackgroundColor3 = Color3.fromRGB(0, 180, 0)
		-- Frame.Position = UDim2.fromOffset( ScreenXY.X, ScreenXY.Y )
		-- Frame.Parent = LocalPlayer.PlayerGui.Debug

		if not IsPointInRect( ScreenXY, topLeft, bottomRight ) then
			continue
		end
		table.insert(BaseParts, Parts)
	end
	return BaseParts
end

function Module.GetComponentsInScreenBox( point0 : Vector2, point1 : Vector2, ignoreList : { Model }? ) : { Model }
	return Module.GetBasePartsInScreenBox( PlacementsFolder:GetChildren(), point0, point1, ignoreList )
end

local overlapParams = OverlapParams.new()
overlapParams.FilterType = Enum.RaycastFilterType.Include
function Module.GetComponentsAtPoint3D( point : Vector3 )
	overlapParams.FilterDescendantsInstances = { PlacementsFolder }
	local Parts = workspace:GetPartBoundsInBox( CFrame.new(point), Vector3.one * 2, overlapParams )
	local Components = {}
	for _, basePart in ipairs( Parts ) do
		local Component = Module.GetComponentModelFromPart( basePart )
		if not table.find( Components, Component ) then
			table.insert(Components, Component)
		end
	end
	return Components
end

return Module
