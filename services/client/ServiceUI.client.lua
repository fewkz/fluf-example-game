local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local fluf = require(ReplicatedStorage.Packages.fluf)
local froact = require(ReplicatedStorage.Froact)
froact.Roact.setGlobalConfig({ elementTracing = true })

local ServiceUIInterface = require(ReplicatedStorage.ServiceUIInterface)
local TimerClientInterface = require(ReplicatedStorage.TimerClientInterface)

local useBoolean = require(ReplicatedStorage.Common.useBoolean)
local ServiceList = require(ReplicatedStorage.Common.ServiceList)

local function useServiceScriptEnabled(hooks, script: BaseScript)
	local enabled: boolean, setEnabled = hooks.useState(false)
	hooks.useEffect(function()
		local conn = script
			:GetPropertyChangedSignal("Enabled")
			:Connect(function()
				setEnabled(script.Enabled)
			end)
		setEnabled(script.Enabled)
		return function()
			conn:Disconnect()
		end
	end, { script })
	local toggleEnabled = hooks.useCallback(function()
		script.Enabled = not script.Enabled
	end, { script })
	return enabled, toggleEnabled
end

local ServiceUIScript =
	Players.LocalPlayer.PlayerScripts:WaitForChild("ServiceUI")
local ControlsScript =
	Players.LocalPlayer.PlayerScripts:WaitForChild("Controls")
local TimerUIScript = Players.LocalPlayer.PlayerScripts:WaitForChild("TimerUI")
local TimerClientScript =
	Players.LocalPlayer.PlayerScripts:WaitForChild("TimerClient")

type ServiceUIProps = {}
local ServiceUI = froact.c({}, function(props: ServiceUIProps, hooks)
	local enabled, enabledMods = useBoolean(hooks, false)
	fluf.useConnect(hooks, ServiceUIInterface.toggleVisible, enabledMods.toggle)

	local timerClientLoading, setTimerClientLoading =
		hooks.useState(false :: boolean?)
	fluf.useState(hooks, TimerClientInterface.loading, setTimerClientLoading)

	local serviceUIEnabled, setServiceUIEnabled =
		useServiceScriptEnabled(hooks, ServiceUIScript)
	local controlsEnabled, setControlsEnabled =
		useServiceScriptEnabled(hooks, ControlsScript)
	local timerUIEnabled, setTimerUIEnabled =
		useServiceScriptEnabled(hooks, TimerUIScript)
	local timerClientEnabled, setTimerClientEnabled =
		useServiceScriptEnabled(hooks, TimerClientScript)
	local timerEnabled, setTimerEnabled = hooks.useState(false :: boolean?)
	fluf.useState(hooks, TimerClientInterface.timerEnabled, setTimerEnabled)
	local toggleTimerEnabled = hooks.useCallback(function()
		TimerClientInterface.setEnabled.fire(
			not TimerClientInterface.timerEnabled.get()
		)
	end, {})

	local serviceUIStatus = if serviceUIEnabled then "Active" else "Disabled"
	local controlsStatus = if controlsEnabled then "Active" else "Disabled"
	local timerUIStatus = if timerUIEnabled then "Active" else "Disabled"
	local timerClientStatus = if timerClientEnabled
		then "Active"
		else "Disabled"
	if timerClientLoading then
		timerClientStatus = "Starting"
	end
	local timerStatus = if timerEnabled then "Active" else "Disabled"
	local element = ServiceList({
		clientServices = {
			{
				name = "ServiceUI",
				description = "Mounts this UI",
				status = serviceUIStatus,
				onActivated = setServiceUIEnabled,
			},
			{
				name = "Controls",
				description = "Adds keybinds for toggling the UI",
				status = controlsStatus,
				onActivated = setControlsEnabled,
			},
			{
				name = "TimerUI",
				description = "Mounts the UI for viewing the timer",
				status = timerUIStatus,
				onActivated = setTimerUIEnabled,
			},
			{
				name = "TimerClient",
				description = "Talks to the TimerServer to interact with the Timer service",
				status = timerClientStatus,
				onActivated = setTimerClientEnabled,
			},
		},
		serverServices = {
			{
				name = "Timer",
				description = "The service that counts",
				status = timerStatus,
				onActivated = toggleTimerEnabled,
			},
			{
				name = "TimerServer",
				description = "Controls clients interacting with the timer and receiving it's count",
				status = "NoDisable",
			},
		},
		onExit = enabledMods.unset,
	})
	return froact.ScreenGui({
		Enabled = enabled,
		DisplayOrder = 2,
	}, element)
end)

local handle =
	froact.Roact.mount(ServiceUI({}), Players.LocalPlayer.PlayerGui, "Services")

fluf.onDisabled(script, function()
	froact.Roact.unmount(handle)
end)
