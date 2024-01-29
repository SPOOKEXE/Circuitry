
local Module = {}

function Module.ClampToGrid( position : Vector3, grid : number, lockY : boolean )
	return Vector3.new(
		math.round(position.X / grid) * grid,
		lockY and position.Y or (math.floor(position.Y / grid) * grid),
		math.round(position.Z / grid) * grid
	)
end

function Module.GetModelBoundingBoxData( Model : Model | BasePart ) : (CFrame, Vector3)
	local HitboxPart : BasePart? = Model:FindFirstChild('Hitbox')
	if HitboxPart then
		return HitboxPart.CFrame, HitboxPart.Size
	end
	if Model:IsA('Model') then
		local CFram, Size = Model:GetBoundingBox()
		return CFram, Size
	end
	return Model.CFrame, Model.Size
end

return Module
