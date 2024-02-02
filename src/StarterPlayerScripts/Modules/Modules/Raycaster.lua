
local LocalPlayer = game:GetService('Players').LocalPlayer
local LocalMouse = LocalPlayer:GetMouse()

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ReplicatedModules = require(ReplicatedStorage:WaitForChild("Modules"))

local PlacementUtility = ReplicatedModules.Utility.Placement

local CurrentCamera = workspace.CurrentCamera
local PlacementsFolder = workspace:WaitForChild('Placements')

local componentsRayParams = RaycastParams.new()
componentsRayParams.FilterType = Enum.RaycastFilterType.Include
componentsRayParams.FilterDescendantsInstances = { PlacementsFolder }

local anyRayParams = RaycastParams.new()
anyRayParams.FilterType = Enum.RaycastFilterType.Include
anyRayParams.FilterDescendantsInstances = { PlacementsFolder, workspace:WaitForChild('BetterBasePlates') }

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
	local RayResult = workspace:Raycast( ray.Origin, ray.Direction * distance, anyRayParams )
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

function Module.RaycastComponentAtMouse( distance : number? ) : ( Model?, Vector3?, Vector3? )
	local ray = CurrentCamera:ScreenPointToRay( LocalMouse.X, LocalMouse.Y )
	local rayResult = workspace:Raycast( ray.Origin, ray.Direction * (distance or 100) )
	if rayResult and rayResult.Instance:IsDescendantOf( PlacementsFolder ) then
		local Model = Module.GetComponentModelFromPart( rayResult.Instance )
		return Model, rayResult.Position, rayResult.Normal
	end
	return nil, nil, nil
end

function Module.IsObjectInCameraFOV( objectPivot : CFrame, cameraCFrame : CFrame ) : boolean
	local lookForward = cameraCFrame.LookVector
	local lookToPoint = (objectPivot.Position - cameraCFrame.Position).Unit
	local angle = AngleBetween(lookForward, lookToPoint)
	return math.abs(angle) <= (CurrentCamera.FieldOfView / 2)
end

function Module.GetComponentsInScreenBox( point0 : Vector2, point1 : Vector2, ignoreList : { Model }? ) : { Model }
	local topLeft = Vector2.new( math.min( point0.X, point1.X ), math.min( point0.Y, point1.Y ) )
	local bottomRight = Vector2.new( math.max( point0.X, point1.X ), math.max( point0.Y, point1.Y ) )

	local CameraCFrame = CurrentCamera.CFrame
	local Components = {}
	for _, Model in ipairs( PlacementsFolder:GetChildren() ) do
		if ignoreList and table.find(ignoreList, Model) then
			continue
		end

		-- local PlacementPivot = Model:GetPivot()
		local BoundsCFrame, _ = PlacementUtility.GetModelBoundingBoxData( Model )

		local InFOV = Module.IsObjectInCameraFOV( BoundsCFrame, CameraCFrame )
		if not InFOV then
			continue
		end

		local ScreenXY = CurrentCamera:WorldToScreenPoint( BoundsCFrame.Position )
		if not IsPointInRect( ScreenXY, topLeft, bottomRight ) then
			continue
		end
		table.insert(Components, Model)
	end
	return Components
end

return Module
