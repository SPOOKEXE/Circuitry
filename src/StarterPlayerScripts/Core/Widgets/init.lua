
local SystemsContainer = {}

local WidgetCache = {}
for _, ModuleScript in ipairs( script:GetChildren() ) do
	WidgetCache[ModuleScript.Name] = require(ModuleScript)
end

-- // Module // --
local Module = {}

function Module.HideAllWidgets()
	for _, widget in pairs( WidgetCache ) do
		widget.HideWidget()
	end
end

function Module.ShowWidgets( widgets : { string } )
	for widgetName, widget in pairs( WidgetCache ) do
		if table.find(widgets, widgetName) then
			widget.ShowWidget()
		end
	end
end

function Module.HideWidgets( widgets : { string } )
	for widgetName, widget in pairs( WidgetCache ) do
		if table.find(widgets, widgetName) then
			widget.HideWidget()
		end
	end
end

function Module.Start()
	for _, widget in pairs( WidgetCache ) do
		widget.Start()
	end
	Module.ShowWidgets({'Components', 'Tools', 'Onscreen'})
end

function Module.Init(otherSystems)
	SystemsContainer = otherSystems
	for _, widget in pairs( WidgetCache ) do
		widget.Init(otherSystems)
	end
end

return Module
