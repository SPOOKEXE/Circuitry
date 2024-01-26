
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

---

### Components

```md
- Comparator - ('A > B' or 'A = B' or 'A < B' selectable options with matching outputs)

- Truth Table Integrated Circuit (TT-IC) - Attempts to create a truth table of of a circuit WITH CIRCUIT DELAYS (otherwise does circuit logic with delay)
- Instantaneous TT-IC (I-TT-IC) - Attempts to create a truth table of of a circuit WITHOUT CIRCUIT DELAYS (otherwise does circuit logic without delay)
```

##### FREE

```md
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
- 4Set DIP Switches

- 8bit Memory (hex encoded)
- 16bit Memory (base64 encoded)
- 8bitGraph (several inputs, each resulting in different height values)
- Numbers User Input (numbers)
- Alphabet User Input (alphabet)
- Single Door
- Double Door
```

##### SPECIAL 1 - PAYWALL CHEAP - 50 robux

```md
- 8Set DIP Switches
- 16Set DIP Switches
- 16bitGraph (several inputs, each resulting in different height values)
- Laser Motion Detector (casts ray to a receiver infront, when player walks through it triggers)
- Wireless Transmitter (channels, SEND/RECEIVE MODE, per-player; no sharing allowed)
- Floppy Disk Drive + Floppys (computercraft)
- Fast Clock / Timer
- 2/4 Bit Adder
- 2/4 Bit Counter/Demultiplexer/Multiplexer/Comparator

- [TODO] 7-segment display
- [TODO] 7-segment decoder
- [TODO] 2/4 Bit Subtractor
- [TODO] Truth-Table-Integrated-Circuit (will assume 'default' integrated circuit otherwise if cannot resolve truth-table)
```

##### SPECIAL 2 - PAYWALL EXPENSIVE - 200 robux

```md
- [TODO] 8/16 Bit Adder/Subtractor
- [TODO] 8/16 Bit Counter/Multiplier/Divider/Modulo/Power/Demux/Mux/Comparator
- [TODO] 32bitMemory (Base64 + bigNum library)
- [TODO] 64bitMemory (Base64 + bigNum library)
- [TODO] Instantaneous-Truth-Table-Integrated-Circuit (will assume 'default' integrated circuit otherwise if cannot resolve truth-table)
- [TODO] NxN LED SCREEN (MAX 32x32)
```

##### SPECIAL 3 - PAYWALL EXPENSIVE - 300 robux

```md
- [TODO] 32/64 Bit Counter/Adder/Subtractor/Multiplier/Divider/Modulo/Power/Demux/Mux/Comparator
- [TODO] 4/8/16/32/64 Bit ALU
- [TODO] 32/64/128/256 Bit Memory (Base64 + bigNum library)
- [TODO] 64x64/128x128 LED SCREEN
```

##### ADMIN COMPONENTS

```md
- [TODO] ...
```

---

### Commands

```toml
[USER]
!claim									<< Claim the area around the user (if not intersecting spawn / other claims)
!unclaim								<< Unclaim the player's land if they have claimed any
!clearobjects							<< Clear the player's placed down objects
!hideothers								<< Hide the other players
!showothers								<< Show the other players
!hideotherbuilds						<< Hide the other players' builds (replaces it with a 'bounding box')
!showotherbuilds						<< Show the other players' builds
```

```toml
[PREMIUM+]
!claim-large							<< Claim a large area around the user (if not intersecting spawn / other claims)
!tickspeed [number]						<< Set the user's ticking speed (if not forcively frozen)
!tickfreeze								<< Freeze the user's ticking (if not forcively frozen)
!tickunfreeze							<< Unfreeze the user's ticking (if not forcively frozen)
!tickstep								<< Step the user's ticking (if not forcively frozen)
```

```toml
[DEVELOPER+]
!claim-massive							<< Claim a massive area around the user (if not intersecting spawn / other claims)

!to [player]							<< Teleport self to the player
!bring [player]							<< Bring player to the self
!freeze [player]						<< Freeze the player and prevent them from moving
!unfreeze [player]						<< Unfreeze the player and allow them to move
!disable [player]						<< Disable the player's ability to place, run commands and disable their circuit tick iterator
!enable [player]						<< Enable the player's ability to place, run commands and enable their circuit tick iterator

!removeclaim [player]					<< Remove the target player's claim
!removebuilds [player]					<< Remove the target player's builds (in claimed and unclaimed)
!clear-all								<< Clear all claimed and unclaimed placeables
!clear-claimed							<< Clear all claimed placeables
!clear-unclaimed						<< Clear all unclaimed placeables
!editbypass								<< Bypass edit permissions for all player claims and allows editing in them

!tickspeed-server [number]				<< Set the server tickspeed (makes all other tickspeeds go faster)
!tickfreeze-server						<< Freeze the ticking (makes all player ticks freeze)
!tickunfreeze-server					<< Unfreeze the ticking (makes all player ticks unfrozen)
!tickstep-server						<< Step the ticking (makes all player ticks step)

!tickspeed-player [player] [number]		<< Set the target player's tick speed
!tickfreeze-player [player]				<< Freeze the target player's ticking
!tickstep-player [player]				<< Step the target player's tick
!tickmultistep-player [player]			<< Set the players' number of tick multi-steps (how many times to tick per tick) (DEFAULT IS 1)
!force-tickspeed-player [player]		<< Force set the target player's ticking speed
!force-tickstep-player [player]			<< Force the target player's 'forced' ticking to step (acts like tickstep otherwise)
!force-tickfreeze-player [player]		<< Force freeze the target player's ticking (can only be stepped with tickstep)
!force-tickunfreeze-player [player]		<< unfreeze the forced target player's ticking
```

---

### Special

```md
Workshop
- upload saves to workshop
- export to bot (gives a unique id which can be given to a discord bot to get the text file of the save)
```
