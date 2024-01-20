
-- If ANY value is true, returns false, otherwise returns true
local function GateNOT( inputs : { boolean } ) : { boolean }
	for _, value in inputs do
		if value then
			return false
		end
	end
	return true
end

-- if all inputs are true, returns true, otherwise false
local function GateAND( inputs : { boolean } ) : { boolean }
	for _, input in inputs do
		if not input then
			return { false }
		end
	end
	return { true }
end

-- if all inputs are true, returns false, otherwise returns true
local function GateNAND( inputs : { boolean } ) : { boolean }
	for _, input in inputs do
		if not input then
			return { true }
		end
	end
	return { false }
end

-- if any input is true, returns true, otherwise false
local function GateOR( inputs : { boolean } ) : { boolean }
	for _, input in inputs do
		if input then
			return { true }
		end
	end
	return { false }
end

-- if any input is true, returns false, otherwise returns true
local function GateNOR( inputs : { boolean } ) : { boolean }
	for _, input in inputs do
		if input then
			return { false }
		end
	end
	return { true }
end

-- if only ONE input is true, returns true, otherwises false for all other cases
local function GateXOR( inputs : { boolean } ) : { boolean }
	local isOutputting = false
	for _, input in inputs do
		if isOutputting and input then
			return { false }
		elseif (not isOutputting) and input then
			isOutputting = true
		end
	end
	return { isOutputting }
end

-- all inputs must be the same (all true or all false) for true output, otherwise false.
local function GateXNOR( inputs : { boolean } ) : { boolean }
	local matchValue : boolean = inputs[1]
	for index, input in inputs do
		if index == 1 then
			continue
		end
		if input ~= matchValue then
			return { false }
		end
	end
	return { matchValue }
end

-- // Module // --
local Module = {}

Module.GateEnums = {
	NOT = 0,
	OR = 1,
	NOR = 2,
	AND = 3,
	NAND = 4,
	XOR = 5,
	XNOR = 6,
}

Module.Gates = {

	[Module.GateEnums.NOT] = {
		Operation = GateNOT,
	},

	[Module.GateEnums.AND] = {
		Operation = GateAND,
	},

	[Module.GateEnums.NAND] = {
		Operation = GateNAND,
	},

	[Module.GateEnums.OR] = {
		Operation = GateOR,
	},

	[Module.GateEnums.NOR] = {
		Operation = GateNOR,
	},

	[Module.GateEnums.XOR] = {
		Operation = GateXOR,
	},

	[Module.GateEnums.XNOR] = {
		Operation = GateXNOR,
	},

}

return Module
