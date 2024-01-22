
### TOOLS

Selection
- (de)select wires and components
	= Filters to select components and wires individually
	= Force multi-selection mode where it cannot deselect even if you click on nothing

Transform (Move + Rotate)
- move and rotate components
	= Option to break connections on move

Wire
- Connect components together
	= Parallel connect (keeps all selection wires parallel to each other)
	= Reversed connection (makes the connection reversed so the selected item now receives an input instead of outputting)
	= Index-based parallel connect

Pulse
- pulse components and makes them output a value of true in all indexes

Delete
- Filter connections and components
- Delete selected items

Saves
- Save/Load
	= allow exporting (if save too large, split into chunks)

Stamper

Inspect

Statistics

Undo / Redo
- Undo and redo previous actions (although disabled for lots of items, >50)

### Components

- AND
- NAND
- OR
- XOR
- XNOR
- NOR
- Button
- Flipflop
- LED
- Conductor
- CharacterLabel
- TextLabel
- Block / Tile
- Random,
- Sound

### Commands
!build list
!build [name]

- Integrated Circuit (truth table mechanism otherwise parse logic of all components in pure-data form)
- 4bit Memory (clicking gives a textbox to paste memory)
- 8bit Memory (clicking gives a textbox to paste memory)
- 12bit Memory (clicking gives a textbox to paste memory)
- 16bit Memory (clicking gives a textbox to paste memory)
- 24bit Memory (clicking gives a textbox to paste memory)
- 32bit Memory (clicking gives a textbox to paste memory)
- Graph (several inputs, each resulting in different height values)
- Small User Input (numbers)
- Medium User Input (alphabet)
- Medium User Input (alphabet + numbers)
- Massive User Input (everything)
- Door

### Special

Workshop
- upload saves to workshop
