
local TextChatService = game:GetService('TextChatService')

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ReplicatedModules = require(ReplicatedStorage:WaitForChild("Modules"))

local RNetModule = ReplicatedModules.Libraries.RNet
local CommandResponseBridge = RNetModule.Create('CommandsResponse')

local SystemsContainer = {}

-- // Module // --
local Module = {}

function Module.OutputResponse( message : string, colorHex : string )
	local Channel : TextChannel = TextChatService.TextChannels.RBXGeneral
	for _, line in string.split(message, '\n') do
		-- line = string.format('<font color="%s">%s</font>', colorHex, line)
		Channel:DisplaySystemMessage(line)
	end
end

function Module.Start()
	CommandResponseBridge:OnClientEvent(Module.OutputResponse)
end

function Module.Init(otherSystems)
	SystemsContainer = otherSystems
end

return Module
