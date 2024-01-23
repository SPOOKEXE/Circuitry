
### TOOLS

**Selection**
- (de)select wires and components
	= Filters to select components and wires individually
	= Force multi-selection mode where it cannot deselect even if you click on nothing

**Transform (Move + Rotate)**
- move and rotate components
	= Option to break connections on move

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
- Delete selected items

**Saves**
- Save/Load
	= allow exporting (if save too large, split into chunks)

**Stamper**

**Inspect**

**Statistics**

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
!claim
!unclaim

[PREMIUM+]
!tickspeed [number]
!tickfreeze
!tickstep

[ADMIN+]
!bypassclaims
!servertickspeed [number]

[DEVELOPER+]
!clear-unclaimed

### Special

Workshop
- upload saves to workshop
- export to bot (gives a unique id which can be given to a discord bot to get the text file of the save)
