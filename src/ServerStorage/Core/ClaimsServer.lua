
local Players = game:GetService('Players')
local CollectionService = game:GetService('CollectionService')

local SystemsContainer = {}

local PlayerClaimsCache = {}
local BASEPLATE_Y_LEVEL = 3

-- // Module // --
local Module = {}

function Module.GetPlayerClaimPermissions( LocalPlayer : Player )
	error('Claim permissions is not implemented.')
end

function Module.CanPlayerEditInClaim( LocalPlayer : Player, ClaimOwner : Player )
	-- local PermissionsDictionary = Module.GetPlayerClaimPermissions( ClaimOwner )
	return false
end

function Module.GetPlayerClaims( LocalPlayer : Player )
	return PlayerClaimsCache[ LocalPlayer ]
end

function Module.IsCFrameValidForClaim( CharacterPivot : CFrame, claimSize : Vector3 )
	local SpawnPosition = Vector3.zero
	if (CharacterPivot.Position - SpawnPosition).Magnitude < 16 then -- spawn area
		return false, 'You cannot claim near the spawn.'
	end

	local overlap = OverlapParams.new()
	overlap.FilterType = Enum.RaycastFilterType.Include
	overlap.FilterDescendantsInstances = CollectionService:GetAllTags('ClaimParts')

	local claimIntersects = workspace:GetPartBoundsInBox( CharacterPivot, claimSize, overlap )
	return #claimIntersects == 0, 'The claim intersects another claim, choose somewhere else.'
end

function Module.ClearPlayerClaim( LocalPlayer : Player )
	local hasClaimedArea = false
	if PlayerClaimsCache[ LocalPlayer.UserId ] then
		PlayerClaimsCache[ LocalPlayer.UserId ].Part:Destroy()
		hasClaimedArea = true
	end
	PlayerClaimsCache[ LocalPlayer.UserId ] = nil
	return hasClaimedArea
end

function Module.CreatePlayerClaim( LocalPlayer : Player )
	if Module.GetPlayerClaims( LocalPlayer ) then
		return false, 'You already have a claim!'
	end

	local CharacterPivot = LocalPlayer.Character and LocalPlayer.Character:GetPivot()
	local CharacterPosition = Vector3.new(CharacterPivot.X, BASEPLATE_Y_LEVEL, CharacterPivot.Z)
	CharacterPivot = CFrame.new( CharacterPosition, CharacterPosition + CharacterPivot.LookVector )

	local success, err = Module.IsCFrameValidForClaim( CharacterPivot, Vector3.one * 12 )
	if not success then
		return false, err
	end

	-- create claim block and *return true*

	return false, 'Claims are not currently enabled or implemented.'
end

function Module.Start()

end

function Module.Init(otherSystems)
	SystemsContainer = otherSystems
end

return Module
