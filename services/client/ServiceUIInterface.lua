local ReplicatedStorage = game:GetService("ReplicatedStorage")

local fluf = require(ReplicatedStorage.Packages.fluf)

local ServiceUIInterface = {
	toggleVisible = fluf.event() :: fluf.Event<()>,
}
return ServiceUIInterface
