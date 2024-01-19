
https://devforum.roblox.com/t/graph-module-easily-draw-graphs-of-your-data/828982
https://devforum.roblox.com/t/graphit-display-and-compare-your-functions/1846040
https://devforum.roblox.com/t/calculationservice-an-easier-way-to-calculate/2744585
https://devforum.roblox.com/t/infinitemath-go-above-103081e308/2182434
https://devforum.roblox.com/t/simplebit-v2-roblox-bitwise-made-easy/2687078/3
https://devforum.roblox.com/t/color-picker-free-and-open-source/2772473
https://devforum.roblox.com/t/cut3r-a-fun-shatter-and-slice-module-using-robloxs-realtime-csg-engine/2738546
https://devforum.roblox.com/t/cbuffer-bit-level-buffer-control/2738699
https://devforum.roblox.com/t/packet-profiler-accurately-measure-remote-packet-bandwidth/1890924/55
https://devforum.roblox.com/t/path-a-performant-module-for-creating-paths/2725341
https://devforum.roblox.com/t/inftable-infinite-size-tables/2649802
https://devforum.roblox.com/t/better-color3-enhanced-colour-manipulation-module/2693888
https://devforum.roblox.com/t/secureluavirtualmachine-controlled-execution-environment/2774729

https://create.roblox.com/docs/reference/engine/classes/CollectionService
https://create.roblox.com/docs/reference/engine/classes/HttpService
https://create.roblox.com/docs/reference/engine/classes/RunService

```
UI:
- Toolbar Widget + Editor
- Component Selection Widget + Editor
- Claim Permissions Menu
- Saves Widget + Export (with chunks)
- Truth Table Chart(s) for each component
- Truth Table Chart for ICs (calculated and only if possible)
- Circuit Creator Block Editor (scratch but for circuits)

Tools:
- Select
	= flood select
	= ignore connections
	= force multi-select
	= deselect whilst holding control
- Connect
	= reverse conneciton direction
	= parallel connect
	= connect to a value input / value output (set rgb of LED, etc)
- Move + Rotate Adornment (Move & Rotate Sphere)
	= keep / break connections
- Swap
	= swap a block with another
	= keep / break connections
	= swap first/all of selected
- Pulse
- Delete
- Save/Load
- Stamper (copied values are pasted)
- Inspect / Configure
	= Shows Inputs/Outputs
	= Shows configuration
	= Shows owner
- Server Stats

Gate Components:
- Redirect/Buffer (redirect wires)
- AND
- NAND
- OR
- NOR
- XOR
- XNOR
- Button
- Pressure Plate
- Flip-Flop
- LED
- Conductor
- Delay
- Single Character Text
- Large Label Text
- Sound / Notes
- Random
- Oscillator (pulse, sawtooth, sine, square, triangle, Hertz; 1Hz = one cycle per second)
- Wall (custom sizing with click and drag and 1x1x1/4x1x4/8x1x8/16x1x16)

Special Components:
- LED Screen (8x8, 16x16, 32x32, 64x64, 128x128, etc)
- SimpleInput
- KeyboardInput
- Timer (custom interval)
- 8bitMemory (8-bit output)
- 16bitMemory (16-bit output)
- 32bitMemory (32-bit output)
- 64bitMemory (64-bit output)
- Graph (several input nodes, each differing the height of the line at the time)
- Door
- Integrated Circuit Builder
- Input/Output Identifier Nodes (for IC)

Settings:
- Wire Size & Transparency
- Mute Sound Blocks (yours, others, global)

Role Commands: [ADMIN] < [DEVELOPER]

= ADMIN+ =
- !admins
- !tickfreeze
- !tickresume
- !tickstep [amount or 1]
- !tickspeed [amount] (set the tickspeed)
- !tp [to]
- !kick [player] (kick the player)

= DEVELOPER+ =
- !tempban [player] (tempban the player)
- !tempbanid [userid] (tempban the userid)
- !shutdown [reason] [time_until] (shutdown this server with a message after seconds)
- !shutdownall [reason] [time_until] (shutdown all servers with a message after seconds)
- !shutdowncancel (cancel the shutdown in this server)
- !shutdowncancelall (cancel the shutdown in this server)
- !ban [player] (ban the player)
- !banid [userid] (ban the userid)
- !tempadmin [player] (temporary gives the player admin in this server)
- !tempadminid [userid] (temporary gives the userid admin in this server)
- !bans
- !clearclaim [player]
- !bypassclaim [player]
- !bring [player]
- !clearmap (force clear the map, nothing in claims is cleared)

Special:
- Workshop?
- !claim (claim the nearby area, rectangle)
- !unclaim (unclaim your claimed area)
- !help (shows commands)
- !votekick [name] [reason]
- !voteclear (vote to clear the map for things NOT in claims)
```

-- hex
```lua
local function fromHex(str)
	return (str:gsub('..', function (cc)
		return string.char(tonumber(cc, 16))
	end))
end

local function toHex(str)
	return (str:gsub('.', function (c)
		return string.format('%02X', string.byte(c))
	end))
end
```

-- base64
```lua
local function to_base64(data)
	local b = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/'
	return ((data:gsub('.', function(x)
		local r,b='',x:byte()
		for i=8,1,-1 do r=r..(b%2^i-b%2^(i-1)>0 and '1' or '0') end
		return r;
	end)..'0000'):gsub('%d%d%d?%d?%d?%d?', function(x)
		if (#x < 6) then return '' end
		local c=0
		for i=1,6 do c=c+(x:sub(i,i)=='1' and 2^(6-i) or 0) end
		return b:sub(c+1,c+1)
	end)..({ '', '==', '=' })[#data%3+1])
end

local function from_base64(data)
	local b = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/'
	data = string.gsub(data, '[^'..b..'=]', '')
	return (data:gsub('.', function(x)
		if (x == '=') then return '' end
		local r,f='',(b:find(x)-1)
		for i=6,1,-1 do r=r..(f%2^i-f%2^(i-1)>0 and '1' or '0') end
		return r;
	end):gsub('%d%d%d?%d?%d?%d?%d?%d?', function(x)
		if (#x ~= 8) then return '' end
		local c=0
		for i=1,8 do c=c+(x:sub(i,i)=='1' and 2^(8-i) or 0) end
		return string.char(c)
	end))
end
```
