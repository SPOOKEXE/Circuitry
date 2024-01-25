
local SystemsContainer = {}

-- // Module // --
local Module = {}

function Module.CanPlaceObjectAtPosition( ObjectFrame : CFrame, BoundBoxSize : Vector3 )

end

function Module.CanPlaceComponentAtPosition( ComponentId : string, ObjectCFrame : CFrame )

end

function Module.Start()

end

function Module.Init(otherSystems)
	SystemsContainer = otherSystems
end

return Module
