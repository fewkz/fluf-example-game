local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local ServerStorage = game:GetService("ServerStorage")

local TimerInterface = require(ServerStorage.TimerInterface)

TimerInterface.count.changed(function(count)
	ReplicatedStorage.Remotes.TimerCountChanged:FireAllClients(count)
end)

function ReplicatedStorage.Remotes.RequestTimerCount.OnServerInvoke()
	return TimerInterface.count.get()
end

function ReplicatedStorage.Remotes.SetTimerEnabled.OnServerInvoke(plr, enabled)
	ServerScriptService.Timer.Enabled = enabled == true
	ReplicatedStorage.Remotes.TimerEnabledChanged:FireAllClients(
		enabled == true
	)
end

function ReplicatedStorage.Remotes.RequestTimerEnabled.OnServerInvoke()
	return ServerScriptService.Timer.Enabled
end
