
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local LocalAssets = LocalPlayer:WaitForChild('PlayerScripts'):WaitForChild('Assets')

local LocalModules = require(LocalPlayer:WaitForChild("PlayerScripts"):WaitForChild("Modules"))
local UserInterfaceUtility = LocalModules.Utility.UserInterface

local Interface = LocalPlayer.PlayerGui:WaitForChild('Interface')

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ReplicatedModules = require(ReplicatedStorage:WaitForChild("Modules"))

local ToolConfigModule = ReplicatedModules.Data.Tools
local MaidClassModule = ReplicatedModules.Modules.Maid

local SystemsContainer = {}
local WidgetsModule = {}

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

function Module.DisableAllTools()
	Module.CurrentTool = false
	Module.ToolMaid:Cleanup()
end

function Module.EnableSelectTool()

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
	SystemsContainer.DisableAllTools()
	SystemsContainer.PlacementClient.StopPlacement()

	print('Enabling tool: ', toolId)
	-- generate config options at bottom of screen
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
	TargetFrame.Parent = Interface.Components.Scroll

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
