local ReplicatedStorage = game:GetService("ReplicatedStorage")

local froact = require(ReplicatedStorage.Froact)

local ServiceList = require(ReplicatedStorage.Common.ServiceList)

local element = ServiceList({
	clientServices = {
		{
			name = "ServiceUI",
			description = "Controls this UI",
			status = "Starting",
		},
		{
			name = "Controls",
			description = "Adds keybinds for toggling the UI",
			status = "Disabled",
		},
	},
	serverServices = {
		{
			name = "Timer",
			description = "Counts how long it's been active",
			status = "Active",
		},
	},
})

return function(parent)
	local handle = froact.Roact.mount(element, parent)
	return function()
		froact.Roact.unmount(handle)
	end
end
