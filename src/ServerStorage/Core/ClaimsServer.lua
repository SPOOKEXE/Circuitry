
local Players = game:GetService('Players')
local CollectionService = game:GetService('CollectionService')

local SystemsContainer = {}

local PlayerClaimsCache = {}
local BASEPLATE_Y_LEVEL = 3

-- // Module // --
local Module = {}

function Module.CanPulseInClaim( LocalPlayer : Player, ClaimID : string ) : boolean
	return false
end

function Module.CanEditInClaim( LocalPlayer : Player, ClaimID : string ) : boolean
	return false
end

function Module.CanCreateClaimAtPosition( CharacterPivot : CFrame, claimSize : Vector3 )
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
	if PlayerClaimsCache[ LocalPlayer ] then
		PlayerClaimsCache[ LocalPlayer ].Part:Destroy()
	end
	PlayerClaimsCache[ LocalPlayer ] = nil
end

function Module.CreatePlayerClaim( LocalPlayer : Player )

	if PlayerClaimsCache[ LocalPlayer ] then
		return false, 'You already have a claim!'
	end

	local CharacterPivot = LocalPlayer.Character and LocalPlayer.Character:GetPivot()
	local CharacterPosition = Vector3.new(CharacterPivot.X, BASEPLATE_Y_LEVEL, CharacterPivot.Z)
	CharacterPivot = CFrame.new( CharacterPosition, CharacterPosition + CharacterPivot.LookVector )

	local success, err = Module.CanCreateClaimAtPosition( CharacterPivot, Vector3.one * 12 )
	if not success then
		return false, err
	end

	-- create claim block and *return true*

	return false, 'Claims are not currently enabled.'
end

function Module.Start()
	Players.PlayerRemoving:Connect(Module.ClearPlayerClaim)
end

function Module.Init(otherSystems)
	SystemsContainer = otherSystems
end

return Module
