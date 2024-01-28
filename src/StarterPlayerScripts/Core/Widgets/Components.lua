
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local Interface = LocalPlayer.PlayerGui:WaitForChild('Interface')

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ReplicatedModules = require(ReplicatedStorage:WaitForChild("Modules"))

local MaidClassModule = ReplicatedModules.Modules.Maid

local SystemsContainer = {}

-- // Module // --
local Module = {}
Module.IsOpen = false
Module.WidgetMaid = MaidClassModule.New()

function Module.ShowWidget()
	if Module.IsOpen then
		return
	end
	Module.IsOpen = true

	Interface.Components.Visible = true

end

function Module.HideWidget()
	if not Module.IsOpen then
		return
	end
	Module.IsOpen = false
	Module.WidgetMaid:Cleanup()
	Interface.Components.Visible = false
end

function Module.Start()
	Interface.Components.Visible = false
end

function Module.Init(otherSystems)
	SystemsContainer = otherSystems
end

return Module
