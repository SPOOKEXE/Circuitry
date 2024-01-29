
local ReplicatedStorage = game:GetService('ReplicatedStorage')
local ReplicatedAssets = ReplicatedStorage:WaitForChild('Assets')

local GamepassIds ={
	Cheapest = 0,
	Moderate = 1,
	Expensive = 2,
}

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

local function CreateFreeComponentData( properties :{} ) : { }
	return SetProperties({
		LayoutOrder = 99,
		Icon = false,
		Model = false, -- required
		Gamepass = false,
	}, properties)
end

-- // Module // --
local Module = { }

Module.RemoteEnums = {
	Place = 1,
	Delete = 2,
	Rotate = 3,
}

Module.Components = {

	-- // FREE COMPONENTS // --
	Block1x1x1 =		CreateFreeComponentData({ Model = 'Block1x1x1', LayoutOrder = 1, Icon = CreateImageData( 'rbxassetid://12140923635' ) }),
	Block2x1x2 =		CreateFreeComponentData({ Model = 'Block2x1x2', LayoutOrder = 2, Icon = CreateImageData( 'rbxassetid://12140923635' ) }),
	Block3x1x3 =		CreateFreeComponentData({ Model = 'Block3x1x3', LayoutOrder = 3, Icon = CreateImageData( 'rbxassetid://12140923635' ) }),
	Block4x1x4 =		CreateFreeComponentData({ Model = 'Block4x1x4', LayoutOrder = 4, Icon = CreateImageData( 'rbxassetid://12140923635' ) }),
	Block5x1x5 =		CreateFreeComponentData({ Model = 'Block5x1x5', LayoutOrder = 5, Icon = CreateImageData( 'rbxassetid://12140923635' ) }),
	WordBlock =			CreateFreeComponentData({ Model = 'WordBlock', LayoutOrder = 6, Icon = CreateImageData( 'rbxassetid://16168027553' ) }),
	CharacterBlock =	CreateFreeComponentData({ Model = 'CharacterBlock', LayoutOrder = 7, Icon = CreateImageData( 'rbxassetid://16168027553' ) }),

	ANDGate = 			CreateFreeComponentData({ Model = 'ANDGate', LayoutOrder = 15, Icon = CreateImageData( 'rbxassetid://16167879896' ) }),
	NANDGate = 			CreateFreeComponentData({ Model = 'NANDGate', LayoutOrder = 16, Icon = CreateImageData( 'rbxassetid://16167879691' ) }),
	ORGate = 			CreateFreeComponentData({ Model = 'ORGate', LayoutOrder = 17, Icon = CreateImageData( 'rbxassetid://16167879339' ) }),
	XORGate = 			CreateFreeComponentData({ Model = 'XORGate', LayoutOrder = 18, Icon = CreateImageData( 'rbxassetid://16167878803' ) }),
	NORGate = 			CreateFreeComponentData({ Model = 'NORGate', LayoutOrder = 19, Icon = CreateImageData( 'rbxassetid://16167887505' ) }),
	XNORGate = 			CreateFreeComponentData({ Model = 'XNORGate', LayoutOrder = 20, Icon =CreateImageData( 'rbxassetid://16167879048' ) }),
	RandomGate = 		CreateFreeComponentData({ Model = 'RandomGate' }),
	SoundGate = 		CreateFreeComponentData({ Model = 'SoundGate' }),
	KeyNoteGate = 		CreateFreeComponentData({ Model = 'KeyNoteGate' }),
	FlipFlopGate = 		CreateFreeComponentData({ Model = 'FlipFlopGate' }),
	Conductor = 		CreateFreeComponentData({ Model = 'Conductor' }),
	LED = 				CreateFreeComponentData({ Model = 'LED' }),

	NumbersKeyInput = 	CreateFreeComponentData({ Model = 'NumbersKeyInput' }),
	LettersKeyInput = 	CreateFreeComponentData({ Model = 'LettersKeyInput' }),
	DIP4Switches = 		CreateFreeComponentData({ Model = 'DIP4Switches' }),
	Button = 			CreateFreeComponentData({ Model = 'Button' }),
	Lever = 			CreateFreeComponentData({ Model = 'Lever' }),
	PressurePlate = 	CreateFreeComponentData({ Model = 'PressurePlate' }),
	Door = 				CreateFreeComponentData({ Model = 'Door' }),
	DoubleDoor = 		CreateFreeComponentData({ Model = 'DoubleDoor' }),

	Bit8Memory = 		CreateFreeComponentData({ Model = 'Bit8Memory' }),
	Bit8Graph = 		CreateFreeComponentData({ Model = 'Bit8Graph' }),
	Bit16Memory = 		CreateFreeComponentData({ Model = 'Bit16Memory' }),

	LazerPointer = 		CreateFreeComponentData({ Model = 'LazerPointer' }),
	LazerReceiver = 	CreateFreeComponentData({ Model = 'LazerReceiver' }),

	-- // Cheapest Paid Components // --

	-- // Moderate Paid Components // --

	-- // Expensive Paid Components // --

}

function Module.GetComponentFromId( componentId : string )
	return Module.Components[ componentId ]
end

function Module.FindModelFromName( modelName : string )
	local Model = ReplicatedAssets.Components:FindFirstChild( modelName )
	if Model then
		return Model
	end
	for _, Folder in ipairs( ReplicatedAssets.Components:GetChildren() ) do
		Model = Folder:FindFirstChild( modelName )
		if Model then
			return Model
		end
	end
	return nil
end

return Module
