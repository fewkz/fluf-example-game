local ReplicatedStorage = game:GetService("ReplicatedStorage")

local fluf = require(ReplicatedStorage.Packages.fluf)

local TimerClientInterface = require(ReplicatedStorage.TimerClientInterface)

TimerClientInterface.setEnabled.connect(function(enabled)
	ReplicatedStorage.Remotes.SetTimerEnabled:InvokeServer(enabled)
end)

TimerClientInterface.loading.set(true)

fluf.onDisabled(script, function()
	TimerClientInterface.loading.set(false)
end)

task.wait(1) -- Simulate network lag
TimerClientInterface.count.set(
	ReplicatedStorage.Remotes.RequestTimerCount:InvokeServer()
)
TimerClientInterface.timerEnabled.set(
	ReplicatedStorage.Remotes.RequestTimerEnabled:InvokeServer()
)
ReplicatedStorage.Remotes.TimerCountChanged.OnClientEvent:Connect(
	TimerClientInterface.count.set
)
ReplicatedStorage.Remotes.TimerEnabledChanged.OnClientEvent:Connect(
	TimerClientInterface.timerEnabled.set
)

TimerClientInterface.loading.set(false)
