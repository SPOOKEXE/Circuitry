
local GamepassIds = {
	Cheapest = 0,
	Moderate = 1,
	Expensive = 2,
}

local function CreateFreeComponentData( modelName : string ) : {}
	return {
		Model = modelName,
		Gamepass = false,
	}
end

local function CreatePaidComponentData( modelName : string, gamepassTier : number ) : {}
	local Data = CreateFreeComponentData( modelName )
	Data.Gamepass = gamepassTier
	return Data
end

-- // Module // --
local Module = {}

Module.Components = {

	-- // FREE COMPONENTS // --
	Block1x1x1 = CreateFreeComponentData( 'Block1x1x1' ),
	Block2x1x2 = CreateFreeComponentData( 'Block2x1x2' ),
	Block3x1x3 = CreateFreeComponentData( 'Block3x1x3' ),
	Block4x1x4 = CreateFreeComponentData( 'Block4x1x4' ),
	Block5x1x5 = CreateFreeComponentData( 'Block5x1x5' ),
	WordBlock = CreateFreeComponentData( 'WordBlock' ),
	CharacterBlock = CreateFreeComponentData( 'CharacterBlock' ),
	Conductor = CreateFreeComponentData( 'Conductor' ),
	LED = CreateFreeComponentData( 'LED' ),

	ANDGate = CreateFreeComponentData( 'ANDGate' ),
	NANDGate = CreateFreeComponentData( 'NANDGate' ),
	ORGate = CreateFreeComponentData( 'ORGate' ),
	XORGate = CreateFreeComponentData( 'XORGate' ),
	NORGate = CreateFreeComponentData( 'NORGate' ),
	XNORGate = CreateFreeComponentData( 'XNORGate' ),
	RandomGate = CreateFreeComponentData( 'RandomGate' ),
	SoundGate = CreateFreeComponentData( 'SoundGate' ),
	KeyNoteGate = CreateFreeComponentData( 'KeyNoteGate' ),
	FlipFlopGate = CreateFreeComponentData( 'FlipFlopGate' ),

	NumbersKeyInput = CreateFreeComponentData( 'NumbersKeyInput' ),
	LettersKeyInput = CreateFreeComponentData( 'LettersKeyInput' ),
	DIP4Switches = CreateFreeComponentData( 'DIP4Switches' ),
	Button = CreateFreeComponentData( 'Button' ),
	Lever = CreateFreeComponentData( 'Lever' ),
	PressurePlate = CreateFreeComponentData( 'PressurePlate' ),
	Door = CreateFreeComponentData( 'Door' ),
	DoubleDoor = CreateFreeComponentData( 'Door' ),

	Bit8Memory = CreateFreeComponentData( 'Bit8Memory' ),
	Bit8Graph = CreateFreeComponentData( 'Bit8Graph' ),
	Bit16Memory = CreateFreeComponentData( 'Bit16Memory' ),

	LazerPointer = CreateFreeComponentData( 'LazerPointer' ),
	LazerReceiver = CreateFreeComponentData( 'LazerReceiver' ),

	-- // Cheapest Paid Components // --

	-- // Moderate Paid Components // --

	-- // Expensive Paid Components // --

}

return Module
