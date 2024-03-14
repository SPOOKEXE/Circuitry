
local ReplicatedStorage = game:GetService('ReplicatedStorage')
local ReplicatedAssets = ReplicatedStorage:WaitForChild('Assets')

local MarketModule = require(script.Parent.Market)

local function SetProperties( Parent, properties )
	if typeof(properties) == 'table' then
		for propName, propValue in pairs( properties ) do
			Parent[propName] = propValue
		end
	end
	return Parent
end

local function CreateImageData( image : string, color : Color3?, size : UDim2? )
	return { Image = image, ImageColor3 = color, Size = size }
end

local function CreateToolData( properties :{} ) : { }
	return SetProperties({
		LayoutOrder = 99,
		Icon = false,
		Gamepass = false,
	}, properties)
end

local QUESTION_MARK_IMAGE = CreateImageData('rbxassetid://15668939723')

-- // Module // --
local Module = { }

Module.RemoteEnums = { Place = 1, Delete = 2, Rotate = 3, Move = 4, Wire = 5 }
Module.AllowedBusBits = { 2, 4, 8, 12, 16, 24, 32, 48, 64 }

Module.Tools = {
	Select = CreateToolData({
		Icon = QUESTION_MARK_IMAGE,
		LayoutOrder = 1,
		Gamepass = false,
	}),

	Transform = CreateToolData({
		Icon = QUESTION_MARK_IMAGE,
		LayoutOrder = 2,
		Gamepass = false,
	}),

	Wire = CreateToolData({
		Icon = QUESTION_MARK_IMAGE,
		LayoutOrder = 3,
		Gamepass = false,
	}),

	Pulse = CreateToolData({
		Icon = QUESTION_MARK_IMAGE,
		LayoutOrder = 4,
		Gamepass = false,
	}),

	Delete = CreateToolData({
		Icon = QUESTION_MARK_IMAGE,
		LayoutOrder = 5,
		Gamepass = false,
	}),

	Saves = CreateToolData({
		Icon = QUESTION_MARK_IMAGE,
		LayoutOrder = 6,
		Gamepass = false,
	}),

	Register = CreateToolData({
		Icon = QUESTION_MARK_IMAGE,
		LayoutOrder = 7,
		Gamepass = false,
	}),

	Stamper = CreateToolData({
		Icon = QUESTION_MARK_IMAGE,
		LayoutOrder = 8,
		Gamepass = false,
	}),

	Inspect = CreateToolData({
		Icon = QUESTION_MARK_IMAGE,
		LayoutOrder = 9,
		Gamepass = false,
	}),

	Layers = CreateToolData({
		Icon = QUESTION_MARK_IMAGE,
		LayoutOrder = 10,
		Gamepass = false,
	}),

	Statistics = CreateToolData({
		Icon = QUESTION_MARK_IMAGE,
		LayoutOrder = 11,
		Gamepass = false,
	}),

	Undo = CreateToolData({
		Icon = QUESTION_MARK_IMAGE,
		LayoutOrder = 12,
		Gamepass = MarketModule.Cheapest,
	}),

	Redo = CreateToolData({
		Icon = QUESTION_MARK_IMAGE,
		LayoutOrder = 13,
		Gamepass = MarketModule.Cheapest,
	}),

	Bus = CreateToolData({
		Icon = QUESTION_MARK_IMAGE,
		LayoutOrder = 14,
		Gamepass = MarketModule.Cheapest,
	}),
}

function Module.GetToolFromId( toolId : string )
	return Module.Tools[ toolId ]
end

return Module
