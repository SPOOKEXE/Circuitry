local UserInputService = game:GetService("UserInputService")
local ContextActionService = game:GetService('ContextActionService')

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local LocalMouse = LocalPlayer:GetMouse()
local LocalAssets = LocalPlayer:WaitForChild('PlayerScripts'):WaitForChild('Assets')

local LocalModules = require(LocalPlayer:WaitForChild("PlayerScripts"):WaitForChild("Modules"))
local UserInterfaceUtility = LocalModules.Utility.UserInterface
local RaycasterModule = LocalModules.Modules.Raycaster

local Interface = LocalPlayer.PlayerGui:WaitForChild('Interface')

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ReplicatedModules = require(ReplicatedStorage:WaitForChild("Modules"))

local ToolConfigModule = ReplicatedModules.Data.Tools
local MaidClassModule = ReplicatedModules.Modules.Maid

local SystemsContainer = {}
local WidgetsModule = {}

local PlacementsFolder = workspace:WaitForChild('Placements')
local CurrentCamera = workspace.CurrentCamera

local TimeBeforeDraggingStarts = 0.2

local function SetProperties( parent : Instance, properties : {[string] : any} ) : Instance
	for propName, propValue in pairs( properties ) do
		parent[propName] = propValue
	end
	return parent
end

-- // Module // --
local Module = {}

Module.IsOpen = false
Module.WidgetMaid = MaidClassModule.New()

Module.CurrentTool = false
Module.ToolMaid = MaidClassModule.New()

Module.SelectionBlacklist = nil

function Module.SetupSelectorClickAndDraggingBox( callback : ( boolean, { {any} } ) -> nil ) : { Cleanup : () -> nil }

	local DraggerMaid = MaidClassModule.New()

	local DraggerScreenGui = Instance.new('ScreenGui')
	DraggerScreenGui.Name = 'DraggerScreenGui'
	DraggerScreenGui.IgnoreGuiInset = false
	DraggerScreenGui.ResetOnSpawn = false
	DraggerScreenGui.Parent = LocalPlayer.PlayerGui

	local Frame = Instance.new('Frame')
	Frame.Name = 'SelectionBoxFrame'
	Frame.BackgroundTransparency = 0.7
	Frame.BackgroundColor3 = Color3.fromRGB(50, 132, 200)
	Frame.Visible = false
	Frame.Parent = DraggerScreenGui

	local OriginXY = Vector2.new(0, 0)
	local IsHoldingLeft = false
	local IsDragging = false

	local function UpdateDraggerItems()
		local NewXY = Vector2.new(LocalMouse.X, LocalMouse.Y)
		Frame.Position = UDim2.fromOffset(OriginXY.X, OriginXY.Y)
		Frame.Size = UDim2.fromOffset( NewXY.X - OriginXY.X, NewXY.Y - OriginXY.Y )
		if (OriginXY - NewXY).Magnitude < 2 then
			return -- only if a larger change occurs
		end
		local Components = RaycasterModule.GetComponentsInScreenBox( OriginXY, NewXY, Module.SelectionBlacklist )
		task.spawn( callback, false, Components )
	end

	local function OnButton1Down()
		IsHoldingLeft = true
		OriginXY = Vector2.new(LocalMouse.X, LocalMouse.Y)
		task.delay(TimeBeforeDraggingStarts, function()
			if IsHoldingLeft then
				UpdateDraggerItems()
				Frame.Visible = true
				IsDragging = true
			end
		end)
	end

	local function OnButton1Up()
		if not IsDragging then
			local Model, _, _ = RaycasterModule.RaycastComponentAtMouse(nil)
			callback(true, { Model })
		end
		Frame.Visible = false
		OriginXY = nil
		IsHoldingLeft = false
		IsDragging = false
	end

	ContextActionService:BindAction('keybinds113', function(actionName, inputState, inputObject)
		if actionName == 'keybinds113' then
			if inputObject.UserInputType == Enum.UserInputType.MouseButton1 then
				if inputState == Enum.UserInputState.Begin then
					OnButton1Down()
				else
					OnButton1Up()
				end
			elseif inputObject.UserInputType == Enum.UserInputType.MouseMovement and OriginXY then
				if IsHoldingLeft and IsDragging then
					UpdateDraggerItems()
				end
			end
			return Enum.ContextActionResult.Sink
		end
		return Enum.ContextActionResult.Pass
	end, false, Enum.UserInputType.MouseButton1, Enum.UserInputType.MouseMovement)

	DraggerMaid:Give(DraggerScreenGui, Frame, function()
		ContextActionService:UnbindAction('keybinds113')
	end)

	return DraggerMaid

end

function Module.SetupSelectorLeftClick( callback : ( Model?, Vector3?, Vector3? ) -> nil ) : { Cleanup : () -> nil }

	local ClickerMaid = MaidClassModule.New()

	ContextActionService:BindAction('keybinds112', function(actionName, inputState, _)
		if actionName == 'keybinds112' and inputState == Enum.UserInputState.Begin then
			local Model, Position, Normal = RaycasterModule.RaycastComponentAtMouse( nil )
			if Model then
				task.spawn(callback, Model, Position, Normal)
			end
			return Enum.ContextActionResult.Sink
		end
		return Enum.ContextActionResult.Pass
	end, false, Enum.UserInputType.MouseButton1)

	ClickerMaid:Give( function()
		ContextActionService:UnbindAction('keybinds112')
	end )

	return ClickerMaid

end

function Module.DisableAllTools()
	Module.CurrentTool = false
	Module.ToolMaid:Cleanup()


	ContextActionService:UnbindAction('escapeExit')
end

function Module.EnableSelectTool()
	local Boxes = {}
	local Selected = {}

	Module.SelectionBlacklist = Selected

	local function ResetSelections()
		Selected = {}
		for _, box in ipairs( Boxes ) do
			box:Destroy()
		end
		Boxes = {}
		Module.SelectionBlacklist = {}
	end

	local function RemoveSelections( selections : { Model } )
		for _, object in ipairs( selections ) do
			local index = table.find( Selected, object )
			if index then
				table.remove(Selected, index)
				local box = table.remove(Boxes, index)
				if box then
					box:Destroy()
				end
			end
		end
	end

	local BaseSelectionBox = Instance.new('SelectionBox')
	BaseSelectionBox.Name = 'SelectedBox'
	BaseSelectionBox.SurfaceTransparency = 0.8
	BaseSelectionBox.SurfaceColor3 = Color3.fromRGB(7, 93, 121)
	BaseSelectionBox.LineThickness = 0.02
	BaseSelectionBox.Transparency = 0.8
	BaseSelectionBox.Color3 = Color3.fromRGB(17, 152, 197)

	local function AppendSelections( selections : { Model } )
		for _, object in ipairs( selections ) do
			local index = table.find( Selected, object )
			if index then
				continue
			end
			local selectionBox = BaseSelectionBox:Clone()
			selectionBox.Adornee = object
			selectionBox.Parent = object
			table.insert( Selected, object )
			table.insert( Boxes, selectionBox )
		end
	end

	local Maid = Module.SetupSelectorClickAndDraggingBox(function( clicked : boolean, models : {Model} )
		print( clicked and 'Clicked on' or 'Dragging Box', #models )
		ResetSelections( )
		AppendSelections( models )
	end)

	Maid:Give(ResetSelections, function()
		Module.SelectionBlacklist = nil
	end)

	Module.ToolMaid:Give( Maid )
end

function Module.EnableTransformTool()

end

function Module.EnableWireTool()

end

function Module.EnablePulseTool()

end

function Module.EnableDeleteTool()

end

function Module.EnableSavesTool()

end

function Module.EnableRegisterTool()

end

function Module.EnableStamperTool()

end

function Module.EnableInspectTool()

end

function Module.EnableLayersTool()

end

function Module.EnableStatisticsTool()

end

--[[
	-- include placing/deleting components
	function Module.UndoLast()
		SystemsContainer.DisableAllTools()
		SystemsContainer.PlacementClient.StopPlacement()

	end

	function Module.RedoLast()
		SystemsContainer.DisableAllTools()
		SystemsContainer.PlacementClient.StopPlacement()

	end
]]

function Module.EnableToolById( toolId : string )

	local IsCurrentTool = Module.CurrentTool == toolId

	Module.DisableAllTools()
	SystemsContainer.PlacementClient.StopPlacement()

	if IsCurrentTool then
		print('Disabling tool: ', toolId)
		return
	end

	print('Enabling tool: ', toolId)
	-- generate config options at bottom of screen
	if toolId == 'Select' then
		Module.EnableSelectTool()
	elseif toolId == 'Transform' then
		Module.EnableTransformTool()
	elseif toolId == 'Wire' then
		Module.EnableWireTool()
	elseif toolId == 'Pulse' then
		Module.EnablePulseTool()
	elseif toolId == 'Delete' then
		Module.EnableDeleteTool()
	elseif toolId == 'Saves' then
		Module.EnableSavesTool()
	elseif toolId == 'Register' then
		Module.EnableRegisterTool()
	elseif toolId == 'Stamper' then
		Module.EnableStamperTool()
	elseif toolId == 'Inspect' then
		Module.EnableInspectTool()
	elseif toolId == 'Layers' then
		Module.EnableLayersTool()
	elseif toolId == 'Statistics' then
		Module.EnableStatisticsTool()
	else
		warn('Unsupported Tool Id: ' .. tostring(toolId))
	end
end

function Module.GetToolFrame( toolId : string ) : Frame
	local TargetFrame = Interface.Tools.Scroll:FindFirstChild( toolId )
	if TargetFrame then
		return TargetFrame
	end

	local ToolData = ToolConfigModule.GetToolFromId( toolId )
	if not ToolData then
		warn(string.format('Could not find tool data for tool of id: %s', toolId))
		return nil
	end

	TargetFrame = LocalAssets.UI.TemplateSquare:Clone()
	TargetFrame.Name = toolId

	local ComponentButton : ImageButton = UserInterfaceUtility.CreateActionButton({Parent = TargetFrame})

	Module.WidgetMaid:Give(ComponentButton.MouseEnter:Connect(function()
		Interface.Components.ComponentLabel.Text = string.upper(toolId)
	end))

	Module.WidgetMaid:Give(ComponentButton.Activated:Connect(function()
		print('Tool has been activated:', toolId)
		Module.EnableToolById( toolId )
	end))

	TargetFrame.Viewport:Destroy() -- not needed
	TargetFrame.Icon.Visible = true

	TargetFrame.LayoutOrder = ToolData.LayoutOrder or 1
	TargetFrame.Parent = Interface.Tools.Scroll

	if ToolData.Icon then
		TargetFrame.Icon.ImageTransparency = 0
		if typeof(ToolData.Icon) == 'table' then
			SetProperties( TargetFrame.Icon, ToolData.Icon )
		else
			TargetFrame.Icon.Image = ToolData.Icon
		end
	end

	return TargetFrame
end

function Module.ShowWidget()
	if Module.IsOpen then
		return
	end
	Module.IsOpen = true

	-- generate all tool frames
	for toolId, _ in pairs( ToolConfigModule.Tools ) do
		local Frame = Module.GetToolFrame( toolId )
		if not Frame then
			continue
		end

	end

	Module.WidgetMaid:Give(Module.ToolMaid)

	Interface.Tools.Visible = true
end

function Module.HideWidget()
	if not Module.IsOpen then
		return
	end
	Module.IsOpen = false
	Module.WidgetMaid:Cleanup()

	Interface.Tools.Visible = false
end

function Module.Start()
	Interface.Tools.Visible = false
end

function Module.Init(otherSystems, widgetModule)
	SystemsContainer = otherSystems
	WidgetsModule = widgetModule
end

return Module
