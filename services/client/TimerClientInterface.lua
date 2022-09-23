local ReplicatedStorage = game:GetService("ReplicatedStorage")

local fluf = require(ReplicatedStorage.Packages.fluf)

local TimerClientInterface = {
	count = fluf.state() :: fluf.State<number>,
	loading = fluf.state() :: fluf.State<boolean>,
	timerEnabled = fluf.state() :: fluf.State<boolean>,
	setEnabled = fluf.event() :: fluf.Event<boolean>,
}
return TimerClientInterface
