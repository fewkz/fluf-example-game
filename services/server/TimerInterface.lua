local ReplicatedStorage = game:GetService("ReplicatedStorage")

local fluf = require(ReplicatedStorage.Packages.fluf)

local TimerInterface = {
	reset = fluf.event() :: fluf.Event<()>,
	count = fluf.state() :: fluf.State<number>,
}
return TimerInterface
