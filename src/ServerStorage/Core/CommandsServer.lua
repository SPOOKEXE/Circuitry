
local SystemsContainer = {}

local COMMAND_SUCCESS_COLOR = Color3.new(0, 0.6, 0)
local COMMAND_UNSUCCESSFUL_COLOR = Color3.new( 0.6, 0, 0 )

local COMMAND_DICTIONARY = {

	default = function( LocalPlayer, ... : string )
		return 'This is not a valid command, run !help [page] to see commands.', COMMAND_UNSUCCESSFUL_COLOR
	end,

	help = function(LocalPlayer, pageNumber, ...)
		-- pageNumber = tonumber(pageNumber)
		-- if not pageNumber then
		-- 	return ''
		-- end
		return [[Available Commands:
!claim		<< Claim the area where you are standing.
!unclaim	<< Unclaim any area you have.
		]], COMMAND_SUCCESS_COLOR
	end,

	claim = function( LocalPlayer, ... : string )
		if not SystemsContainer.GameControllerService.CanPlayerRunCommands( LocalPlayer ) then
			return 'You cannot run commands at this time.', COMMAND_UNSUCCESSFUL_COLOR
		end
		local success, err = SystemsContainer.ClaimsService.CreatePlayerClaim( LocalPlayer )
		if success then
			return 'Command ran successfully.', COMMAND_SUCCESS_COLOR
		end
		return err, COMMAND_UNSUCCESSFUL_COLOR
	end,

	unclaim = function( LocalPlayer, ... : string )
		if not SystemsContainer.GameControllerService.CanPlayerRunCommands( LocalPlayer ) then
			return 'You cannot run commands at this time.', COMMAND_UNSUCCESSFUL_COLOR
		end
		local hadClaimedArea = SystemsContainer.ClaimsService.ClearPlayerClaim( LocalPlayer )
		if hadClaimedArea then
			return 'Your claim is now removed', COMMAND_SUCCESS_COLOR
		end
		return 'You do not have a claimed area.', COMMAND_UNSUCCESSFUL_COLOR
	end,

} :: { [string] : ( Player, ...string ) -> ( string, Color3 ) }

-- // Module // --
local Module = {}

function Module.SendMessageToClient( TargetPlayer : Player, message : string, textColor3 : Color3 )
	print( TargetPlayer.Name, message, textColor3 )
end

function Module.ParseChatCommand( LocalPlayer : Player, message : string )
	local splits = string.split(message, ' ')
	local command = table.remove(splits, 1)
	local callback = COMMAND_DICTIONARY[command] or COMMAND_DICTIONARY.default
	local responseText, responseColor = callback( LocalPlayer, unpack(splits) )
	Module.SendMessageToClient( LocalPlayer, responseText, responseColor)
end

function Module.SetupPlayerCommandsHook( LocalPlayer : Player )

	LocalPlayer.Chatted:Connect(function(message, recipient)
		if recipient then
			return
		end
		if string.sub(message, 1, 1) == '!' then
			Module.ParseChatCommand( LocalPlayer, string.sub(message, 2) )
		end
	end)

end

function Module.Start()

end

function Module.Init(otherSystems)
	SystemsContainer = otherSystems
end

return Module
