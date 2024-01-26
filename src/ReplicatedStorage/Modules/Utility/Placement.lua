
local Module = {}

function Module.ClampToGrid( position : Vector3, grid : number, lockY : boolean )
	return Vector3.new(
		math.round(position.X / grid) * grid,
		lockY and (math.round(position.Y / grid) * grid) or position.Y,
		math.round(position.Z / grid) * grid
	)
end

--[[function Module.GetModelBoundingBoxSize( Model : Model | BasePart )
	local HitboxPart : BasePart? = Model:FindFirstChild('Hitbox')
	if HitboxPart then
		return HitboxPart.Size
	end
	if Model:IsA('Model') then
		local _, Size = Model:GetBoundingBox()
		return Size
	end
	return Model.Size
end]]

return Module
