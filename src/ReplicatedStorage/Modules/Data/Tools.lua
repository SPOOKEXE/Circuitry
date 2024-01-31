
local ReplicatedStorage = game:GetService('ReplicatedStorage')
local ReplicatedAssets = ReplicatedStorage:WaitForChild('Assets')

local GamepassIds ={ Cheapest = 0, Moderate = 1, Expensive = 2, }

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

local function CreateFreeToolData( properties :{} ) : { }
	return SetProperties({
		LayoutOrder = 99,
		Icon = false,
		Gamepass = false,
	}, properties)
end

-- // Module // --
local Module = { }

Module.RemoteEnums = {

}

Module.Tools = {
	Select = CreateFreeToolData({
		Icon = 'rbxassetid://-1',
		LayoutOrder = 1,
		Gamepass = false,
	}),

	Transform = CreateFreeToolData({
		Icon = 'rbxassetid://-1',
		LayoutOrder = 2,
		Gamepass = false,
	}),

	Wire = CreateFreeToolData({
		Icon = 'rbxassetid://-1',
		LayoutOrder = 3,
		Gamepass = false,
	}),

	Pulse = CreateFreeToolData({
		Icon = 'rbxassetid://-1',
		LayoutOrder = 4,
		Gamepass = false,
	}),

	Delete = CreateFreeToolData({
		Icon = 'rbxassetid://-1',
		LayoutOrder = 5,
		Gamepass = false,
	}),

	Saves = CreateFreeToolData({
		Icon = 'rbxassetid://-1',
		LayoutOrder = 6,
		Gamepass = false,
	}),

	Register = CreateFreeToolData({
		Icon = 'rbxassetid://-1',
		LayoutOrder = 7,
		Gamepass = false,
	}),

	Stamper = CreateFreeToolData({
		Icon = 'rbxassetid://-1',
		LayoutOrder = 8,
		Gamepass = false,
	}),

	Inspect = CreateFreeToolData({
		Icon = 'rbxassetid://-1',
		LayoutOrder = 9,
		Gamepass = false,
	}),

	Statistics = CreateFreeToolData({
		Icon = 'rbxassetid://-1',
		LayoutOrder = 10,
		Gamepass = false,
	}),

	--[[Undo = CreateFreeToolData({
		Icon = 'rbxassetid://-1',
		LayoutOrder = 11,
		Gamepass = false,
	}),

	Redo = CreateFreeToolData({
		Icon = 'rbxassetid://-1',
		LayoutOrder = 12,
		Gamepass = false,
	}),]]
}

function Module.GetToolFromId( toolId : string )
	return Module.Tools[ toolId ]
end

return Module
