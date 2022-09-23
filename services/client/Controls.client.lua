local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")

local ServiceUIInterface = require(ReplicatedStorage.ServiceUIInterface)

UserInputService.InputBegan:Connect(function(input)
	if input.KeyCode == Enum.KeyCode.Z then
		if
			not Players.LocalPlayer.PlayerScripts:WaitForChild("ServiceUI").Enabled
		then
			Players.LocalPlayer.PlayerScripts.ServiceUI.Enabled = true
		end
		ServiceUIInterface.toggleVisible.fire()
	end
end)
