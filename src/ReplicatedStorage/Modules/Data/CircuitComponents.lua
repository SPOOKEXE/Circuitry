
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

local function CreateComponentData( properties :{} ) : { }
	return SetProperties({
		LayoutOrder = 99,
		Icon = false,
		Model = false, -- required
		Gamepass = false,
	}, properties)
end

local QUESTION_MARK_IMAGE = nil --CreateImageData( 'rbxassetid://15668939723' )

-- // Module // --
local Module = { }

Module.Components = {

	-- // FREE COMPONENTS // --
	Block1x1x1 =		CreateComponentData({ Model = 'Block1x1x1', LayoutOrder = 1, Icon = CreateImageData( 'rbxassetid://12140923635' ) }),
	Block2x1x2 =		CreateComponentData({ Model = 'Block2x1x2', LayoutOrder = 1, Icon = CreateImageData( 'rbxassetid://12140923635' ) }),
	Block3x1x3 =		CreateComponentData({ Model = 'Block3x1x3', LayoutOrder = 1, Icon = CreateImageData( 'rbxassetid://12140923635' ) }),
	Block4x1x4 =		CreateComponentData({ Model = 'Block4x1x4', LayoutOrder = 1, Icon = CreateImageData( 'rbxassetid://12140923635' ) }),
	Block5x1x5 =		CreateComponentData({ Model = 'Block5x1x5', LayoutOrder = 1, Icon = CreateImageData( 'rbxassetid://12140923635' ) }),
	WireNode =			CreateComponentData({ Model = 'WireNode', LayoutOrder = 2, Icon = CreateImageData( 'rbxassetid://12140923635' ) }),
	WordBlock =			CreateComponentData({ Model = 'WordBlock', LayoutOrder = 3, Icon = CreateImageData( 'rbxassetid://16168027553' ) }),
	CharacterBlock =	CreateComponentData({ Model = 'CharacterBlock', LayoutOrder = 3, Icon = CreateImageData( 'rbxassetid://16168027553' ) }),
	Door = 				CreateComponentData({ Model = 'Door', LayoutOrder = 4, Icon = QUESTION_MARK_IMAGE }),
	DoubleDoor = 		CreateComponentData({ Model = 'DoubleDoor', LayoutOrder = 4, Icon = QUESTION_MARK_IMAGE }),

	ANDGate = 			CreateComponentData({ Model = 'ANDGate', LayoutOrder = 5, Icon = CreateImageData( 'rbxassetid://16167879896' ) }),
	NANDGate = 			CreateComponentData({ Model = 'NANDGate', LayoutOrder = 5, Icon = CreateImageData( 'rbxassetid://16167879691' ) }),
	ORGate = 			CreateComponentData({ Model = 'ORGate', LayoutOrder = 5, Icon = CreateImageData( 'rbxassetid://16167879339' ) }),
	XORGate = 			CreateComponentData({ Model = 'XORGate', LayoutOrder = 5, Icon = CreateImageData( 'rbxassetid://16167878803' ) }),
	NORGate = 			CreateComponentData({ Model = 'NORGate', LayoutOrder = 5, Icon = CreateImageData( 'rbxassetid://16167887505' ) }),
	XNORGate = 			CreateComponentData({ Model = 'XNORGate', LayoutOrder = 5, Icon =CreateImageData( 'rbxassetid://16167879048' ) }),
	RandomGate = 		CreateComponentData({ Model = 'RandomGate', LayoutOrder = 6, Icon = QUESTION_MARK_IMAGE }),
	SoundGate = 		CreateComponentData({ Model = 'SoundGate', LayoutOrder = 6, Icon = QUESTION_MARK_IMAGE }),
	KeyNoteGate = 		CreateComponentData({ Model = 'KeyNoteGate', LayoutOrder = 6, Icon = QUESTION_MARK_IMAGE }),
	FlipFlopGate = 		CreateComponentData({ Model = 'FlipFlopGate', LayoutOrder = 6, Icon = QUESTION_MARK_IMAGE }),
	Conductor = 		CreateComponentData({ Model = 'Conductor', LayoutOrder = 6, Icon = QUESTION_MARK_IMAGE }),
	LED = 				CreateComponentData({ Model = 'LED', LayoutOrder = 6, Icon = QUESTION_MARK_IMAGE }),

	NumbersKeyInput = 	CreateComponentData({ Model = 'NumbersKeyInput', LayoutOrder = 10, Icon = QUESTION_MARK_IMAGE }),
	LettersKeyInput = 	CreateComponentData({ Model = 'LettersKeyInput', LayoutOrder = 10, Icon = QUESTION_MARK_IMAGE }),
	Button = 			CreateComponentData({ Model = 'Button', LayoutOrder = 10, Icon = QUESTION_MARK_IMAGE }),
	Lever = 			CreateComponentData({ Model = 'Lever', LayoutOrder = 10, Icon = QUESTION_MARK_IMAGE }),
	PressurePlate = 	CreateComponentData({ Model = 'PressurePlate', LayoutOrder = 10, Icon = QUESTION_MARK_IMAGE }),
	LazerPointer = 		CreateComponentData({ Model = 'LazerPointer', LayoutOrder = 10, Icon = QUESTION_MARK_IMAGE }),
	LazerReceiver = 	CreateComponentData({ Model = 'LazerReceiver', LayoutOrder = 10, Icon = QUESTION_MARK_IMAGE }),
	DIP4Switches = 		CreateComponentData({ Model = 'DIP4Switches', LayoutOrder = 10, Icon = QUESTION_MARK_IMAGE }),

	Bit8Memory = 		CreateComponentData({ Model = 'Bit8Memory', LayoutOrder = 15, Icon = QUESTION_MARK_IMAGE }),
	Bit8Graph = 		CreateComponentData({ Model = 'Bit8Graph', LayoutOrder = 15, Icon = QUESTION_MARK_IMAGE }),
	Bit16Memory = 		CreateComponentData({ Model = 'Bit16Memory', LayoutOrder = 15, Icon = QUESTION_MARK_IMAGE }),

	IntegratedCircuit = CreateComponentData({ Model = 'IntegratedCircuit', LayoutOrder = 20, Icon = QUESTION_MARK_IMAGE }),

	-- // Cheapest Paid Components // --
	Bit16Graph = 		CreateComponentData({ Model = 'Bit16Graph', LayoutOrder = 25, Icon = QUESTION_MARK_IMAGE, Gamepass = MarketModule.GamepassIds.Cheapest }),
	ClockTimer = 		CreateComponentData({ Model = 'ClockTimer', LayoutOrder = 25, Icon = QUESTION_MARK_IMAGE, Gamepass = MarketModule.GamepassIds.Cheapest }),
	WirelessNode =		CreateComponentData({ Model = 'WirelessNode', LayoutOrder = 25, Icon = QUESTION_MARK_IMAGE, Gamepass = MarketModule.GamepassIds.Cheapest }),
	DIP8Switches =		CreateComponentData({ Model = 'DIP8Switches', LayoutOrder = 25, Icon = QUESTION_MARK_IMAGE, Gamepass = MarketModule.GamepassIds.Cheapest }),
	DIP16Switches =		CreateComponentData({ Model = 'DIP16Switches', LayoutOrder = 25, Icon = QUESTION_MARK_IMAGE, Gamepass = MarketModule.GamepassIds.Cheapest }),

	BusNode =			CreateComponentData({ Model = 'BusNode', LayoutOrder = 30, Icon = QUESTION_MARK_IMAGE, Gamepass = MarketModule.GamepassIds.Cheapest }),
	Bus2Adapter =		CreateComponentData({ Model = '2BusAdapter', LayoutOrder = 30, Icon = QUESTION_MARK_IMAGE, Gamepass = MarketModule.GamepassIds.Cheapest }),
	Bus4Adapter =		CreateComponentData({ Model = '4BusAdapter', LayoutOrder = 30, Icon = QUESTION_MARK_IMAGE, Gamepass = MarketModule.GamepassIds.Cheapest }),
	Bus8Adapter =		CreateComponentData({ Model = '8BusAdapter', LayoutOrder = 30, Icon = QUESTION_MARK_IMAGE, Gamepass = MarketModule.GamepassIds.Cheapest }),

	Bit2Counter = 		CreateComponentData({ Model = '2BitCounter', LayoutOrder = 35, Icon = QUESTION_MARK_IMAGE }),
	Bit4Counter = 		CreateComponentData({ Model = '4BitCounter', LayoutOrder = 35, Icon = QUESTION_MARK_IMAGE }),
	Bit2Adder = 		CreateComponentData({ Model = '2BitAdder', LayoutOrder = 35, Icon = QUESTION_MARK_IMAGE }),
	Bit4Adder = 		CreateComponentData({ Model = '4BitAdder', LayoutOrder = 35, Icon = QUESTION_MARK_IMAGE }),
	Bit2Mux = 			CreateComponentData({ Model = '2BitMux', LayoutOrder = 35, Icon = QUESTION_MARK_IMAGE }),
	Bit4Mux = 			CreateComponentData({ Model = '4BitMux', LayoutOrder = 35, Icon = QUESTION_MARK_IMAGE }),
	Bit2Demux = 		CreateComponentData({ Model = '2BitDemux', LayoutOrder = 35, Icon = QUESTION_MARK_IMAGE }),
	Bit4Demux = 		CreateComponentData({ Model = '4BitDemux', LayoutOrder = 35, Icon = QUESTION_MARK_IMAGE }),
	Bit2Comparator =	CreateComponentData({ Model = '2BitComparator', LayoutOrder = 35, Icon = QUESTION_MARK_IMAGE }),
	Bit4Comparator =	CreateComponentData({ Model = '4BitComparator', LayoutOrder = 35, Icon = QUESTION_MARK_IMAGE }),

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
		if Folder:IsA('Folder') then
			Model = Folder:FindFirstChild( modelName )
			if Model then
				return Model
			end
		end
	end
	return nil
end

return Module
