
local RunService = game:GetService('RunService')

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local LocalAssets = LocalPlayer:WaitForChild('PlayerScripts'):WaitForChild('Assets')

local LocalModules = require(LocalPlayer:WaitForChild("PlayerScripts"):WaitForChild("Modules"))
local ViewportUtility = LocalModules.Utility.Viewport
local UserInterfaceUtility = LocalModules.Utility.UserInterface

local Interface = LocalPlayer.PlayerGui:WaitForChild('Interface')

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ReplicatedModules = require(ReplicatedStorage:WaitForChild("Modules"))

local CircuitComponentsModule = ReplicatedModules.Data.CircuitComponents
local MaidClassModule = ReplicatedModules.Modules.Maid

local GLOBAL_ROTATION_SPEED : number = 5

local function SetProperties( parent : Instance, properties : {[string] : any} ) : Instance
	for propName, propValue in pairs( properties ) do
		parent[propName] = propValue
	end
	return parent
end

local SystemsContainer = {}
local WidgetsModule = {}

-- // Module // --
local Module = {}
Module.IsOpen = false
Module.WidgetMaid = MaidClassModule.New()
Module.ViewportComponents = {}

function Module.GetComponentFrame( componentId : string ) : Frame
	local TargetFrame = Interface.Components.Scroll:FindFirstChild( componentId )
	if TargetFrame then
		return TargetFrame
	end

	local ComponentData = CircuitComponentsModule.GetComponentFromId( componentId )
	if not ComponentData then
		warn(string.format('Could not find component data for component of id: %s', componentId))
		return nil
	end

	TargetFrame = LocalAssets.UI.TemplateSquare:Clone()
	TargetFrame.Name = componentId

	local ComponentButton : ImageButton = UserInterfaceUtility.CreateActionButton({Parent = TargetFrame})

	Module.WidgetMaid:Give(ComponentButton.MouseEnter:Connect(function()
		Interface.Components.ComponentLabel.Text = string.upper(componentId)
	end))

	Module.WidgetMaid:Give(ComponentButton.Activated:Connect(function()
		SystemsContainer.PlacementClient.StartPlacingComponent( componentId )
	end))

	TargetFrame.LayoutOrder = ComponentData.LayoutOrder or 1
	TargetFrame.Parent = Interface.Components.Scroll

	if ComponentData.Icon then
		TargetFrame.Viewport.Visible = false
		TargetFrame.Icon.Visible = true
		TargetFrame.Icon.ImageTransparency = 0
		if typeof(ComponentData.Icon) == 'table' then
			SetProperties( TargetFrame.Icon, ComponentData.Icon )
		else
			TargetFrame.Icon.Image = ComponentData.Icon
		end
		return TargetFrame
	end

	local ComponentModel : Model = ComponentData.Model and CircuitComponentsModule.FindModelFromName( ComponentData.Model )
	if not ComponentModel then
		warn(string.format('Could not find the component model for component of id: %s', componentId))
		return TargetFrame
	end

	TargetFrame.Viewport.Visible = true
	TargetFrame.Icon.Visible = false

	local _, ModelSize = ComponentModel:GetBoundingBox()
	local Range = math.max(ModelSize.X, ModelSize.Z)

	local DEFAULT_VIEWPORT_CAMERA = CFrame.lookAt( Vector3.new(0, 1.5 + (Range * 0.75), 0), Vector3.zero )
	ViewportUtility.ViewportCamera(TargetFrame.Viewport).CFrame = DEFAULT_VIEWPORT_CAMERA

	local Model = ViewportUtility.SetupModelForViewport( ComponentModel:Clone() )
	Model:PivotTo( CFrame.new() )
	Model.Parent = TargetFrame.Viewport

	Module.WidgetMaid:Give(Model)
	table.insert(Module.ViewportComponents, Model)
end

function Module.UpdateWidget( dt : number )
	local RotateCFrame = CFrame.Angles(0, math.rad(GLOBAL_ROTATION_SPEED) * dt, 0)
	for _, Model in ipairs( Module.ViewportComponents ) do
		Model:PivotTo( Model:GetPivot() * RotateCFrame )
	end
end

function Module.UpdateFrames()
	if not Module.IsOpen then
		return
	end
	-- generate all circuit component frames
	for componentId, _ in pairs( CircuitComponentsModule.Components ) do
		local Frame = Module.GetComponentFrame( componentId )
		if not Frame then
			continue
		end
		local IsActive = (componentId == SystemsContainer.PlacementClient.CurrentId)
		Frame.UIStroke.Color = IsActive and Color3.fromRGB(215, 203, 71) or Color3.fromRGB(113, 113, 113)
	end
end

function Module.ShowWidget()
	if Module.IsOpen then
		return
	end
	Module.IsOpen = true

	Interface.Components.Visible = true

	Module.UpdateFrames()

	Module.WidgetMaid:Give(RunService.Heartbeat:Connect(function(dt : number)
		Module.UpdateWidget(dt)
	end))
end

function Module.HideWidget()
	if not Module.IsOpen then
		return
	end
	Module.IsOpen = false
	Module.ViewportComponents = {}
	Module.WidgetMaid:Cleanup()
	Interface.Components.Visible = false
end

function Module.Start()
	Interface.Components.Visible = false
end

function Module.Init(otherSystems, widgetsModule)
	SystemsContainer = otherSystems
	WidgetsModule = widgetsModule
end

return Module
