local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local fluf = require(ReplicatedStorage.Packages.fluf)
local froact = require(ReplicatedStorage.Froact)

local TimerClientInterface = require(ReplicatedStorage.TimerClientInterface)
local ServiceUIInterface = require(ReplicatedStorage.ServiceUIInterface)

local useBoolean = require(ReplicatedStorage.Common.useBoolean)

local function openServiceUI()
	if
		not Players.LocalPlayer.PlayerScripts:WaitForChild("ServiceUI").Enabled
	then
		Players.LocalPlayer.PlayerScripts.ServiceUI.Enabled = true
	end
	ServiceUIInterface.toggleVisible.fire()
end

type ButtonProps = { text: string, onActivated: () -> () }
local Button = froact.c({}, function(props: ButtonProps, hooks)
	local hovering, hoveringMods = useBoolean(hooks, false)
	return froact.TextButton({
		AutomaticSize = Enum.AutomaticSize.XY,
		Text = props.text,
		BackgroundColor3 = if hovering
			then Color3.new(0.8, 0.8, 0.8)
			else Color3.new(0.9, 0.9, 0.9),
		onMouseEnter = hoveringMods.set,
		onMouseLeave = hoveringMods.unset,
		onActivated = props.onActivated,
	}, {
		UIPadding = froact.UIPadding({
			PaddingLeft = UDim.new(0, 16),
			PaddingTop = UDim.new(0, 8),
			PaddingRight = UDim.new(0, 16),
			PaddingBottom = UDim.new(0, 8),
		}),
		UICorner = froact.UICorner({}),
	})
end)

local TimerUI = froact.c({}, function(props, hooks)
	local timerCount: number?, setTimerCount = hooks.useState(0 :: number?)
	fluf.useState(hooks, TimerClientInterface.count, setTimerCount)
	local timerEnabled, setTimerEnabled = hooks.useState(false :: boolean?)
	fluf.useState(hooks, TimerClientInterface.timerEnabled, setTimerEnabled)
	local children = froact.list({ orderByName = true }, {
		froact.UIListLayout({
			SortOrder = Enum.SortOrder.Name,
			HorizontalAlignment = Enum.HorizontalAlignment.Center,
			Padding = UDim.new(0, 8),
		}),
		froact.UIPadding({
			PaddingLeft = UDim.new(0, 24),
			PaddingRight = UDim.new(0, 24),
			PaddingTop = UDim.new(0, 16),
			PaddingBottom = UDim.new(0, 16),
		}),
		froact.UICorner({}),
		froact.TextLabel({
			AutomaticSize = Enum.AutomaticSize.XY,
			Text = "Timer",
			TextSize = 24,
			Font = Enum.Font.GothamBold,
		}),
		froact.TextLabel({
			AutomaticSize = Enum.AutomaticSize.XY,
			TextSize = 16,
			Text = if not timerEnabled
				then "Timer service is disabled"
				else if timerCount
					then "Has been active for " .. timerCount .. " seconds"
					else "Couldn't get timer count",
		}),
		froact.TextLabel({
			AutomaticSize = Enum.AutomaticSize.XY,
			Text = "Press Z to view a list of services",
		}),
		Button({
			text = "View Services",
			onActivated = openServiceUI,
		}),
	})
	local element = froact.Frame({
		Position = UDim2.fromScale(0.5, 0.5),
		AnchorPoint = Vector2.new(0.5, 0.5),
		AutomaticSize = Enum.AutomaticSize.XY,
	}, children)
	return froact.ScreenGui({}, element)
end)

local handle =
	froact.Roact.mount(TimerUI({}), Players.LocalPlayer.PlayerGui, "Timer")

fluf.onDisabled(script, function()
	froact.Roact.unmount(handle)
end)
