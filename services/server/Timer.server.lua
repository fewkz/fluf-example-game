local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")

local fluf = require(ReplicatedStorage.Packages.fluf)

local TimerInterface = require(ServerStorage.TimerInterface)

local firstEnabled = fluf.inlineState(DateTime.now())
local count, setCount = fluf.inlineState(0)
TimerInterface.count.set(count)

TimerInterface.reset.connect(function()
	count = setCount(0)
	TimerInterface.count.set(count)
end)

print(
	"Timer started! This was first enabled at",
	firstEnabled:FormatLocalTime("LTS", "en-us")
)

fluf.onDisabled(script, function()
	print("Timer was stopped.")
end)

while true do
	task.wait(1)
	count = setCount(count + 1)
	TimerInterface.count.set(count)
	print("Timer has been active for " .. count .. " seconds.")
end
