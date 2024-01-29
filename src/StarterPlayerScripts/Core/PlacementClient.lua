
local ContextActionService = game:GetService('ContextActionService')
local RunService = game:GetService('RunService')
local StarterGui = game:GetService('StarterGui')

local Players = game:GetService('Players')
local LocalPlayer = Players.LocalPlayer
local LocalMouse = LocalPlayer:GetMouse()

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ReplicatedModules = require(ReplicatedStorage:WaitForChild("Modules"))

local RNetModule = ReplicatedModules.Libraries.RNet
local PlacementBridge = RNetModule.Create('PlacementSystem')

local CircuitComponentsModule = ReplicatedModules.Data.CircuitComponents
local PlacementUtility = ReplicatedModules.Utility.Placement
local MaidClassModule = ReplicatedModules.Modules.Maid

local CurrentCamera = workspace.CurrentCamera

local SystemsContainer = {}

local CurrentRotation = 0
local CurrentPosition = Vector3.zero
local IsPlacementEnabled = false
local IsCollisionDetected = false
local CurrentModel = nil
local CurrentId = nil

local rayParams = RaycastParams.new()
rayParams.FilterType = Enum.RaycastFilterType.Include
local overlapParams = OverlapParams.new()
overlapParams.FilterType = Enum.RaycastFilterType.Include

local PlacementModelHighlight = Instance.new('Highlight')
PlacementModelHighlight.Name = 'Highlight'
PlacementModelHighlight.OutlineTransparency = 0.5
PlacementModelHighlight.OutlineColor = Color3.new(1, 1, 1)
PlacementModelHighlight.FillTransparency = 1

local PlacementsFolder = workspace:WaitForChild('Placements')

local function GetMouseHit( distance : number? )
	distance = distance or 50
	local ray = CurrentCamera:ScreenPointToRay( LocalMouse.X, LocalMouse.Y )
	local RayResult = workspace:Raycast( ray.Origin, ray.Direction * distance, rayParams )
	if RayResult then
		return CFrame.lookAt(RayResult.Position, RayResult.Position + ray.Direction.Unit)
	end
	return CFrame.lookAt( ray.Origin, ray.Origin + ray.Direction ) + (ray.Direction.Unit * distance)
end

local function SetupModelForPlacement( Model )
	Model = Model:Clone()

	PlacementModelHighlight.Adornee = Model

	local Descendants = Model:GetDescendants()
	table.insert(Descendants, Model)
	for _, BasePart in ipairs( Descendants ) do
		if BasePart:IsA('BasePart') then
			BasePart.Anchored = true
			BasePart.CanCollide = false
			BasePart.CanQuery = false
			if BasePart.Name == 'Hitbox' then
				BasePart.Transparency = 1
			end
		end
	end

	return Model
end

-- // Module // --
local Module = {}

function Module.IsCurrentlyPlacing()
	return IsPlacementEnabled
end

function Module.StopPlacement()
	print('Stop Placement')
	IsPlacementEnabled = false
	CurrentId = nil
	if CurrentModel then
		CurrentModel:Destroy()
	end
	CurrentModel = nil
	PlacementModelHighlight.Adornee = nil
end

function Module.StartPlacingComponent( componentId : string )
	if IsPlacementEnabled then
		Module.StopPlacement()
	end

	local ComponentData : {}? = CircuitComponentsModule.GetComponentFromId( componentId )
	local ComponentModel : Instance? = ComponentData and CircuitComponentsModule.FindModelFromName( ComponentData.Model )
	if not ComponentModel then
		warn(string.format('Could not find component model for id %s', tostring(componentId)))
		return
	end

	print('Start Placing: ', componentId)
	CurrentId = componentId
	CurrentRotation = 1
	IsPlacementEnabled = true

	CurrentModel = SetupModelForPlacement( ComponentModel )
	CurrentModel.Parent = workspace
end

function Module.RotateCurrent()
	CurrentRotation += 1
	if CurrentRotation == 5 then
		CurrentRotation = 1
	end
	print( CurrentRotation )
end

function Module.PlaceObject()
	local TargetComponentId = CurrentId
	local TargetPosition = CurrentPosition
	local TargetRotation = CurrentRotation
	print('Place:', TargetComponentId, TargetPosition, TargetRotation)

	PlacementBridge:FireServer( TargetComponentId, TargetPosition, TargetRotation )
	--[[
		local ComponentData : {}? = CircuitComponentsModule.GetComponentFromId( TargetComponentId )
		local ComponentModel : Instance? = ComponentData and CircuitComponentsModule.FindModelFromName( ComponentData.Model )

		print( TargetPosition, TargetRotation )
		local Pivot = CFrame.new( TargetPosition ) * CFrame.Angles(0, math.rad(TargetRotation * 90), 0)

		local Model = ComponentModel:Clone()
		Model:PivotTo( Pivot )
		Model.Parent = PlacementsFolder
	]]
end

function Module.Start()

	local Keybinds = {
		[Enum.KeyCode.Q] = function()
			Module.StopPlacement()
		end,

		[Enum.KeyCode.R] = function()
			Module.RotateCurrent()
		end,

		[Enum.UserInputType.MouseButton1] = function()
			print('PLACE', #LocalPlayer.PlayerGui:GetGuiObjectsAtPosition(LocalMouse.X, LocalMouse.Y))
			if not IsCollisionDetected and #LocalPlayer.PlayerGui:GetGuiObjectsAtPosition(LocalMouse.X, LocalMouse.Y) == 0 then
				Module.PlaceObject()
			end
		end,
	}

	local UnpackingKeybinds = {}
	for keyCode, _ in pairs( Keybinds ) do
		table.insert(UnpackingKeybinds, keyCode)
	end

	ContextActionService:BindAction('keybinds111', function(actionName, inputState, inputObject)
		if actionName == 'keybinds111' and inputState == Enum.UserInputState.Begin and IsPlacementEnabled then
			local Callback = Keybinds[ inputObject.KeyCode ] or Keybinds[ inputObject.UserInputType ]
			if Callback then
				Callback()
			end
			return Enum.ContextActionResult.Sink
		end
		return Enum.ContextActionResult.Pass
	end, false, unpack(UnpackingKeybinds))

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

	rayParams.FilterDescendantsInstances = { workspace:WaitForChild('BetterBasePlates'), PlacementsFolder }
	overlapParams.FilterDescendantsInstances = { PlacementsFolder }
	PlacementModelHighlight.Parent = workspace:WaitForChild('Terrain')

end

function Module.Init(otherSystems)
	SystemsContainer = otherSystems
end

return Module
