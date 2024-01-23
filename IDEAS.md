
### TOOLS

**Selection**
- (de)select wires and components
	= Filters to select components and wires individually
	= Force multi-selection mode where it cannot deselect even if you click on nothing

**Transform (Move + Rotate)**
- move and rotate components
	= Option to break connections on move
	= shows a bounding box of where everything is moving (client setting to make it show the objects)

**Wire**
- Connect components together
	= Parallel connect (keeps all selection wires parallel to each other)
	= Reversed connection (makes the connection reversed so the selected item now receives an input instead of outputting)
	= Index-based parallel connect

**Pulse**
- pulse components and makes them output a value of true in all indexes
- pulse connections (will activate the connected input)

**Delete**
- Filter connections and components
- Delete selected items (button to press)

**Saves**
- Save/Load
	= allow exporting (if save too large, split into chunks)

**Register**
- Stores copied values where it can be exported (chunks of 200k text and multi-paged if needed)
	= button to copy selected objects to the register
	= CTRL+C keybind if items are selected to save to register

**Stamper**
- Allows copied values in register to be pasted down (bounding box visual or high-detail visual)
	= shows a bounding box of where everything is moving (client setting to make it show the objects)

**Inspect**
- Allows editing of component properties (shows inputs, outputs and attributes)

**Statistics**
- Shows server statistics
- Shows client statistics

**Undo / Redo**
- Undo and redo previous actions (although disabled for lots of items, >50)

### Components

- AND
- NAND
- OR
- NOR
- XOR
- XNOR
- Button (click detector)
- Lever (click detector)
- Pressure Plate (walk on)
- Flip-Flop
- LED
- Conductor
- CharacterLabel (1 character text square)
- TextLabel (12 character text rectangle)
- Block / Tile
- Random
- Sound

- 8bit Memory (hex encoded)
- 16bit Memory (base64 encoded)
- Graph (several inputs, each resulting in different height values)
- Small User Input (numbers)
- Medium User Input (alphabet)
- Medium User Input (alphabet + numbers)
- Single Door
- Double Door

### SPECIAL 1 - PAYWALL CHEAP - 100 robux

- 7 segment display
- 7 segment decoder
- Laser Motion Detector (casts ray to a receiver infront, when player walks through it triggers)
- Floppy Disk Drive + Floppys (computercraft)
- nDIPSwitches
- Fast Clock
- Massive User Input (everything)
- Wireless Transmitter (channels; PRIVATE-ONLY)
- nBitCounter (INCREMENT, RESET)
- nBitAdder
- nBitSubtractor
- nBitDeMultiplexer
- nBitMultiplexer
- Integrated-Circuit (parse logic of all components in pure-data form, truth-table version available in paywall)
- Inverter

### SPECIAL 2 - PAYWALL EXPENSIVE - 200 robux

- 32bitMemory (BASE64 + bigNum library)
- 64bitMemory (BASE64 + bigNum library)
- TruthTable-Integrated-Circuit (will assume 'default' integrated circuit otherwise if cannot resolve truth-table)
- NxN LED SCREEN (MAX 32x32)
- nBitPower
- nBitComparator ('A > B' or 'A = B' or 'A < B' selectable options and matching outputs)
- nBitDivider
- nBitMultiplier
- nBitModulo

### SPECIAL 3 - PAYWALL EXPENSIVE - 300 robux

- nBitALU
- nBitMemory (BASE64 + bigNum library + )
- NxN LED SCREEN (MAX 128x128)

### Commands

[USER]
!claim									<< Claim the land near the user (if not intersecting spawn / other claims)
!unclaim								<< Unclaim the player's land if they have claimed any
!clearobjects							<< Clear the player's placed down objects
!hideothers								<< Hide the other players
!showothers								<< Show the other players
!hideotherbuilds						<< Hide the other players' builds (replaces it with a 'bounding box')
!showotherbuilds						<< Show the other players' builds

[PREMIUM+]
!tickspeed [number]						<< Set the user's ticking speed (if not forcively frozen)
!tickfreeze								<< Freeze the user's ticking (if not forcively frozen)
!tickunfreeze							<< Unfreeze the user's ticking (if not forcively frozen)
!tickstep								<< Step the user's ticking (if not forcively frozen)

[ADMIN+]
!bypassclaims							<< Bypass all player claims and allows editing in them
!removeclaim [player]					<< Remove the target player's claim
!removebuilds [player]					<< Remove the target player's builds (in claimed and unclaimed)
!to [player]							<< Teleport self to the player
!bring [player]							<< Bring player to the self
!freeze [player]						<< Freeze the player and prevent them from moving
!unfreeze [player]						<< Unfreeze the player and allow them to move
!disable [player]						<< Disable the player's ability to place, run commands and disable their circuit tick iterator
!enable [player]						<< Enable the player's ability to place, run commands and enable their circuit tick iterator
!clear-all								<< Clear all claimed and unclaimed placeables
!clear-claimed							<< Clear all claimed placeables
!clear-unclaimed						<< Clear all unclaimed placeables
!tickspeed-server [number]				<< Set the server tickspeed (makes all other tickspeeds go faster)
!tickfreeze-server						<< Freeze the ticking (makes all player ticks freeze)
!tickunfreeze-server					<< Unfreeze the ticking (makes all player ticks unfrozen)
!tickstep-server						<< Step the ticking (makes all player ticks step)
!tickspeed-player [player] [number]		<< Set the target player's tick speed
!tickfreeze-player [player]				<< Freeze the target player's ticking
!tickstep-player [player]				<< Step the target player's tick
!tick-multistep-player [player]			<< Set the players' number of tick multi-steps (how many times to tick per tick) (DEFAULT IS 1)
!force-tickspeed-player [player]		<< Force set the target player's ticking speed
!force-tickstep-player [player]			<< Force the target player's 'forced' ticking to step (acts like tickstep otherwise)
!force-tickfreeze-player [player]		<< Force freeze the target player's ticking (can only be stepped with tickstep)
!force-tickunfreeze-player [player]		<< unfreeze the forced target player's ticking

### Special

Workshop
- upload saves to workshop
- export to bot (gives a unique id which can be given to a discord bot to get the text file of the save)
