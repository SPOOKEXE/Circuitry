
local SystemsContainer = {}

local WidgetCache = {}
for _, ModuleScript in ipairs( script:GetChildren() ) do
	WidgetCache[ModuleScript.Name] = require(ModuleScript)
end

-- // Module // --
local Module = {}

Module.Widgets = WidgetCache

function Module.HideAllWidgets()
	for _, widget in pairs( WidgetCache ) do
		widget.HideWidget()
	end
end

function Module.GetOpenWidgets() : { string }
	local widgetNames = {}
	for widgetName, widget in pairs( WidgetCache ) do
		if widget.IsOpen then
			table.insert( widgetNames, widgetName )
		end
	end
	return widgetNames
end

function Module.HideWidgets( widgets : { string } )
	for widgetName, widget in pairs( WidgetCache ) do
		if table.find(widgets, widgetName) then
			widget.HideWidget()
		end
	end
end

function Module.ShowWidgets( widgets : { string } )
	for widgetName, widget in pairs( WidgetCache ) do
		if table.find(widgets, widgetName) then
			widget.ShowWidget()
		end
	end
end

function Module.Start()
	print('Widgets Handler Started')
	for name, widget in pairs( WidgetCache ) do
		print('Starting widget: ', name)
		widget.Start()
	end

	Module.ShowWidgets({'Components', 'Tools'}) -- , 'Onscreen'
end

function Module.Init(otherSystems)
	print('Widgets Handler Initialized')
	SystemsContainer = otherSystems

	for name, widget in pairs( WidgetCache ) do
		print('Initializing widget: ', name)
		widget.Init(otherSystems, Module)
	end
end

return Module
