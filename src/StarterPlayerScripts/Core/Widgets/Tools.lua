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

local RNetModule = ReplicatedModules.Libraries.RNet
local ToolsBridge = RNetModule.Create('PlacementTools')

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

Module.SelectedComponents = {}

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
		local Components = RaycasterModule.GetComponentsInScreenBox( OriginXY, NewXY, Module.SelectedComponents )
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
			local Model, _ = RaycasterModule.RaycastComponentAtMouse(nil)
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
			local Model, Position = RaycasterModule.RaycastComponentAtMouse( nil )
			if Model then
				task.spawn(callback, Model, Position)
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
end

function Module.EnableSelectTool()
	local Boxes = {}

	local function DestroyBoxes()
		for _, box in ipairs( Boxes ) do
			box:Destroy()
		end
		Boxes = {}
	end

	local function ResetSelections()
		Module.SelectedComponents = {}
		DestroyBoxes()
	end

	--[[
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
	]]

	local BaseSelectionBox = Instance.new('SelectionBox')
	BaseSelectionBox.Name = 'SelectedBox'
	BaseSelectionBox.SurfaceTransparency = 0.8
	BaseSelectionBox.SurfaceColor3 = Color3.fromRGB(7, 93, 121)
	BaseSelectionBox.LineThickness = 0.02
	BaseSelectionBox.Transparency = 0.8
	BaseSelectionBox.Color3 = Color3.fromRGB(17, 152, 197)

	local function AppendSelections( selections : { Model } )
		for _, object in ipairs( selections ) do
			local index = table.find( Module.SelectedComponents, object )
			if index then
				continue
			end
			local selectionBox = BaseSelectionBox:Clone()
			selectionBox.Adornee = object
			selectionBox.Parent = object
			table.insert( Module.SelectedComponents, object )
			table.insert( Boxes, selectionBox )
		end
	end

	local Maid = Module.SetupSelectorClickAndDraggingBox(function( clicked : boolean, models : {Model} )
		print( clicked and 'Clicked on' or 'Dragging Box', #models )
		if not UserInputService:IsKeyDown( Enum.KeyCode.LeftControl ) then -- TODO: force multi-select
			ResetSelections()
		end
		AppendSelections( models )
	end)

	Maid:Give(ResetSelections, DestroyBoxes)

	local function CopySelectionNames()
		local newSelections = {}
		for _, basePart in ipairs( Module.SelectedComponents ) do
			table.insert(newSelections, basePart.Name)
		end
		return newSelections
	end

	ContextActionService:BindAction('deleteBind', function(actionName, inputState, _)
		if actionName == 'deleteBind' and inputState == Enum.UserInputState.Begin then
			if #Module.SelectedComponents > 0 then
				local Selections = CopySelectionNames()
				ToolsBridge:FireServer( ToolConfigModule.RemoteEnums.Delete, Selections )
				ResetSelections()
			end
		end
	end, false, Enum.KeyCode.Delete)

	Maid:Give(function()
		ContextActionService:UnbindAction('deleteBind')
	end)

	Module.ToolMaid:Give( Maid )
end

function Module.EnableTransformTool()
	warn('Not Implemented - Transform Tool')
end

function Module.EnableWireTool()
	warn('Not Implemented - Wire Tool')

	local TargetModel = nil

	local ActiveWires = {}

	local function StartWireDragging()

		while TargetModel and UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) do

			local OriginPivot = TargetModel:GetPivot()
			local TargetComponent = RaycasterModule.RaycastComponentAtMouse( 100 )

			local MousePivot = nil
			if TargetComponent then
				-- connect to the component
				MousePivot = TargetComponent:GetPivot()
			else
				MousePivot = RaycasterModule.GetMouseHit( 100 )
			end

			-- move connection part
			-- TODO: parallel connect for all selected

			task.wait()
		end
		TargetModel = nil
	end

	local Maid = Module.SetupSelectorLeftClick(function( Model, _, _ )
		if not Model:IsDescendantOf( PlacementsFolder ) then
			return
		end
		if TargetModel == Model then
			StartWireDragging()
		else
			TargetModel = Model
		end
	end)

	Module.ToolMaid:Give( Maid )

end

function Module.EnablePulseTool()
	warn('Not Implemented - Pulse Tool')
end

function Module.EnableDeleteTool()

	local Maid = Module.SetupSelectorLeftClick(function( Model, _, _ )
		if Model:IsDescendantOf( PlacementsFolder ) then
			ToolsBridge:FireServer( ToolConfigModule.RemoteEnums.Delete, {Model.Name} )
		end
	end)

	Module.ToolMaid:Give( Maid )

end

function Module.EnableSavesTool()
	warn('Not Implemented - Saves Tool')
end

function Module.EnableRegisterTool()
	warn('Not Implemented - Register Tool')
end

function Module.EnableStamperTool()
	warn('Not Implemented - Stamper Tool')
end

function Module.EnableInspectTool()
	warn('Not Implemented - Inspect Tool')
end

function Module.EnableLayersTool()
	warn('Not Implemented - Layers Tool')
end

function Module.EnableStatisticsTool()
	warn('Not Implemented - Statistics Tool')
end

function Module.EnableBusTool()
	-- option to select bits in the bus
	warn('Not Implemented - Bus Tool')
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
	elseif toolId == 'Bus' then
		Module.EnableBusTool()
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
