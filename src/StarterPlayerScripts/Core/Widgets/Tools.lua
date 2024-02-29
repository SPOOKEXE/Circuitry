local CollectionService = game:GetService("CollectionService")
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
local VisualizersModule = ReplicatedModules.Utility.Visualizers

local RNetModule = ReplicatedModules.Libraries.RNet
local ToolsBridge = RNetModule.Create('PlacementTools')

local SystemsContainer = {}
local WidgetsModule = {}

local PlacementsFolder = workspace:WaitForChild('Placements')
local CurrentCamera = workspace.CurrentCamera

local TimeBeforeDraggingStarts = 0.2

local BaseSelectionBox = Instance.new('SelectionBox')
BaseSelectionBox.Name = 'SelectedBox'
BaseSelectionBox.SurfaceTransparency = 0.8
BaseSelectionBox.SurfaceColor3 = Color3.fromRGB(7, 93, 121)
BaseSelectionBox.LineThickness = 0.02
BaseSelectionBox.Transparency = 0.8
BaseSelectionBox.Color3 = Color3.fromRGB(17, 152, 197)

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
Module.SelectionBoxes = {}

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
	local LastXY = Vector2.zero

	local function UpdateDraggerItems()
		local NewXY = Vector2.new(LocalMouse.X, LocalMouse.Y)
		if NewXY == LastXY then
			return
		end
		LastXY = NewXY
		Frame.Position = UDim2.fromOffset(OriginXY.X, OriginXY.Y)
		Frame.Size = UDim2.fromOffset( NewXY.X - OriginXY.X, NewXY.Y - OriginXY.Y )
		if (OriginXY - NewXY).Magnitude < 2 then
			return -- only if a larger change occurs
		end
		local Components = RaycasterModule.GetComponentsInScreenBox( OriginXY, NewXY )
		task.spawn( callback, false, Components )
	end

	local function OnButton1Down()
		IsHoldingLeft = true
		OriginXY = Vector2.new(LocalMouse.X, LocalMouse.Y)
		task.delay(TimeBeforeDraggingStarts, function()
			if IsHoldingLeft then
				Frame.Visible = true
				IsDragging = true
				while IsDragging and Frame.Visible and IsHoldingLeft do
					UpdateDraggerItems()
					task.wait()
				end
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
		if actionName == 'keybinds113' and inputObject.UserInputType == Enum.UserInputType.MouseButton1 then
			if inputState == Enum.UserInputState.Begin then
				OnButton1Down()
			else
				OnButton1Up()
			end
			return Enum.ContextActionResult.Sink
		end
		return Enum.ContextActionResult.Pass
	end, false, Enum.UserInputType.MouseButton1)

	DraggerMaid:Give(DraggerScreenGui, Frame, function()
		ContextActionService:UnbindAction('keybinds113')
	end)

	return DraggerMaid

end

function Module.SetupSelectorLeftClick( callback : ( Instance?, Vector3? ) -> nil ) : { Cleanup : () -> nil }

	local ClickerMaid = MaidClassModule.New()

	ContextActionService:BindAction('keybinds112', function(actionName, inputState, _)
		if actionName == 'keybinds112' and inputState == Enum.UserInputState.Begin then
			local Model, Position = RaycasterModule.RaycastPlaceablePartAtMouse( nil )
			task.spawn(callback, Model, Position)
			return Enum.ContextActionResult.Sink
		end
		return Enum.ContextActionResult.Pass
	end, false, Enum.UserInputType.MouseButton1)

	ClickerMaid:Give( function()
		ContextActionService:UnbindAction('keybinds112')
	end )

	return ClickerMaid

end

function Module.ClearSelectedItems()
	Module.SelectedComponents = {}
	for _, box in pairs( Module.SelectionBoxes ) do
		box:Destroy()
	end
	Module.SelectionBoxes = {}
end

function Module.AppendSelections( selections : { Model } )
	for _, object in ipairs( selections ) do
		local index = table.find( Module.SelectedComponents, object )
		if index then
			continue
		end
		local selectionBox = BaseSelectionBox:Clone()
		selectionBox.Adornee = object
		selectionBox.Parent = object
		table.insert( Module.SelectedComponents, object )
		Module.SelectionBoxes[object] = selectionBox
	end
end

function Module.DisableAllTools()
	Module.CurrentTool = false
	Module.ToolMaid:Cleanup()
end

function Module.EnableSelectTool()

	local Maid = Module.SetupSelectorClickAndDraggingBox(function( clicked : boolean, baseParts : { BasePart } )
		print( clicked and 'Clicked on' or 'Dragging Box', #baseParts )

		local models : {Model} = {}
		for _, basePart in ipairs( baseParts ) do
			local component = RaycasterModule.GetComponentModelFromPart(basePart)
			if component and not table.find(models, component) then
				table.insert(models, component)
			end
		end

		-- TODO: force multi-select GUI option
		if UserInputService:IsKeyDown( Enum.KeyCode.LeftControl ) then
			Module.AppendSelections( models )
			return
		end

		-- select target item
		if clicked then
			Module.ClearSelectedItems()
			Module.AppendSelections( models )
			return
		end

		-- delta selections to prevent selected objects spamming outlines
		local uuidCache = {}
		for _, object in ipairs( models ) do
			table.insert( uuidCache, object.Name )
		end
		Module.AppendSelections( models )

		-- remove un-selected items
		for object, selectionBox in pairs( Module.SelectionBoxes ) do
			if table.find(uuidCache, object.Name) then
				continue
			end
			selectionBox:Destroy()
			Module.SelectionBoxes[object] = nil
			local index = table.find(Module.SelectedComponents, object)
			if index then
				table.remove(Module.SelectedComponents, index)
			end
		end
	end)

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
				Module.ClearSelectedItems()
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
	Module.ClearSelectedItems()

end

function Module.EnableWireTool()

	local ActiveWires = {}
	local ParallelMode = true
	local Reversed = false

	local function StartWireDragging( GlobalOrigin : Vector3 )
		print('START DRAGGING')
		local GlobalTarget = GlobalOrigin

		local BeamOffset = Vector3.new(0, 0.5, 0)
		local BeamProperties1 = {
			Texture = Reversed and 'rbxassetid://2557513744' or 'rbxassetid://2557513411',
			TextureSpeed = Reversed and -1 or 1,
			Width0 = 1, Width1 = 1, TextureLength = 1, TextureMode = Enum.TextureMode.Static, Color = ColorSequence.new( Color3.new() ),
		}

		local BeamProperties2 = {
			Color = ColorSequence.new( Color3.new() ),
			Width0 = 0.2, Width1 = 0.2, TextureLength = 0.2, Texture = '', TextureMode = Enum.TextureMode.Static,
		}

		for _, Model in ipairs( Module.SelectedComponents ) do
			local Position = Model:GetPivot().Position
			local Beam1 = VisualizersModule.Beam(Position + BeamOffset, Position + BeamOffset, nil, BeamProperties1)
			local Beam2 = VisualizersModule.Beam(Position + BeamOffset, Position + BeamOffset, nil, BeamProperties2)
			-- flip arrows if in "reverse" mode
			local WireData = { UUID = Model.Name, Origin = Position, Beam1 = Beam1, Beam2 = Beam2, }
			table.insert(ActiveWires, WireData)
		end

		local GlobalOffset = Vector3.zero
		while Module.CurrentTool == 'Wire' and UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) do
			local TargetComponent = RaycasterModule.RaycastComponentAtMouse( 100 )
			if TargetComponent then
				-- print(TargetComponent:GetFullName())
				GlobalTarget = TargetComponent:GetPivot().Position -- snap to the component
			else
				-- print(GlobalTarget)
				GlobalTarget = RaycasterModule.GetMouseHit( 100 ).Position
			end

			GlobalOffset = (GlobalTarget - GlobalOrigin)
			-- print(GlobalOffset, GlobalTarget, GlobalOrigin)
			for _, WireData in ipairs( ActiveWires ) do
				local ResultCFrame
				if ParallelMode then
					ResultCFrame = CFrame.new( WireData.Origin + GlobalOffset + BeamOffset )
				else
					ResultCFrame = CFrame.new( GlobalTarget )
				end
				WireData.Beam1.Attachment1.WorldCFrame = ResultCFrame
				WireData.Beam2.Attachment1.WorldCFrame = ResultCFrame
			end
			task.wait()
		end

		if Module.CurrentTool ~= 'Wire' then
			return -- wire tool was exited
		end

		-- single wire mode
		if not ParallelMode then
			local TargetComponent = RaycasterModule.GetComponentsAtPoint3D( GlobalTarget )[1]
			if not TargetComponent then
				return
			end
			local SourceUUIDs = {}
			for _, WireData in ipairs( ActiveWires ) do
				table.insert(SourceUUIDs, WireData.UUID)
			end
			if table.find(SourceUUIDs, TargetComponent.Name) then
				return -- can't connect to self
			end
			ToolsBridge:FireServer(ToolConfigModule.RemoteEnums.WireSingle, TargetComponent.Name, SourceUUIDs, not Reversed)
			return
		end

		local ParallelSources = {}
		local ParallelTargets = {}
		for _, WireData in ipairs( ActiveWires ) do
			local Component = RaycasterModule.GetComponentsAtPoint3D( WireData.Origin + GlobalOffset )[1]
			if not Component then
				continue
			end
			if Component.Name == WireData.UUID then
				continue
			end
			table.insert(ParallelSources, WireData.UUID)
			table.insert(ParallelTargets, Component.Name)
		end
		if #ParallelSources > 0 then
			ToolsBridge:FireServer(ToolConfigModule.RemoteEnums.WireParallel, ParallelSources, ParallelTargets, Reversed)
		end
		print('STOP DRAGGING')
	end

	local function OnLeftClicked( basePart, _ )
		local Model = basePart and RaycasterModule.GetComponentModelFromPart( basePart )
		if #Module.SelectedComponents == 0 then
			if not Model then
				return
			end
			Module.AppendSelections({Model})
			StartWireDragging( basePart.Position )
			Module.ClearSelectedItems() -- only temporary selection
		else
			if Model then
				StartWireDragging( basePart.Position )
			else
				StartWireDragging( RaycasterModule.GetMouseHit(50).Position )
			end
		end
		for _, WireData in ipairs( ActiveWires ) do
			WireData.Beam1.Attachment0:Destroy()
			WireData.Beam1.Attachment1:Destroy()
			WireData.Beam1:Destroy()
			WireData.Beam2.Attachment0:Destroy()
			WireData.Beam2.Attachment1:Destroy()
			WireData.Beam2:Destroy()
		end
		ActiveWires = {}
	end

	local Maid = Module.SetupSelectorLeftClick(OnLeftClicked)
	Module.ToolMaid:Give( Maid )
end

function Module.EnablePulseTool()
	warn('Not Implemented - Pulse Tool')
	Module.ClearSelectedItems()

end

function Module.EnableDeleteTool()

	local Maid = Module.SetupSelectorLeftClick(function( basePart, _ )
		local Model = RaycasterModule.GetComponentModelFromPart( basePart )
		if Model and Model:IsDescendantOf( PlacementsFolder ) then
			ToolsBridge:FireServer( ToolConfigModule.RemoteEnums.Delete, { Model.Name } )
		end
	end)

	Module.ToolMaid:Give( Maid )

end

function Module.EnableSavesTool()
	warn('Not Implemented - Saves Tool')
	Module.ClearSelectedItems()

end

function Module.EnableRegisterTool()
	warn('Not Implemented - Register Tool')
	Module.ClearSelectedItems()
end

function Module.EnableStamperTool()
	warn('Not Implemented - Stamper Tool')
	Module.ClearSelectedItems()
end

function Module.EnableInspectTool()
	warn('Not Implemented - Inspect Tool')
	Module.ClearSelectedItems()
end

function Module.EnableLayersTool()
	warn('Not Implemented - Layers Tool')
	Module.ClearSelectedItems()
end

function Module.EnableStatisticsTool()
	warn('Not Implemented - Statistics Tool')
	Module.ClearSelectedItems()
end

function Module.EnableBusTool()
	-- option to select bits in the bus
	warn('Not Implemented - Bus Tool')
	Module.ClearSelectedItems()
end

--[[
	-- include placing/deleting components
	function Module.UndoLast()
		SystemsContainer.DisableAllTools()
		SystemsContainer.PlacementClient.StopPlacement()
		Module.ClearSelectedItems()
	end

	function Module.RedoLast()
		SystemsContainer.DisableAllTools()
		SystemsContainer.PlacementClient.StopPlacement()
		Module.ClearSelectedItems()
	end
]]

function Module.EnableToolById( toolId : string )

	local IsCurrentTool = (Module.CurrentTool == toolId)

	Module.DisableAllTools()
	SystemsContainer.PlacementClient.StopPlacement()

	if IsCurrentTool then
		print('Disabling tool: ', toolId)
		return
	end

	print('Enabling tool: ', toolId)
	Module.CurrentTool = toolId

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
		Module.CurrentTool = false
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
