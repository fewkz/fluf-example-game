local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local froact = require(ReplicatedStorage.Froact)

local useBoolean = require(ReplicatedStorage.Common.useBoolean)

type StatusCircleProps = {
	status: string,
	size: number,
}
local function StatusCircle(props: StatusCircleProps)
	local color
	if props.status == "Disabled" then
		color = Color3.fromRGB(196, 33, 4)
	elseif props.status == "Starting" then
		color = Color3.fromRGB(231, 122, 24)
	else
		color = Color3.fromRGB(77, 179, 79)
	end
	return froact.Frame({
		Size = UDim2.fromOffset(props.size, props.size),
		BackgroundColor3 = color,
	}, {
		UICorner = froact.UICorner({ CornerRadius = UDim.new(1, 0) }),
	})
end

-- Occupies as much horizontal space as it can.
local HorizontalSpacer = froact.c({}, function(props: {}, hooks)
	local ref = hooks.useValue(froact.Roact.createRef()).value
	local size, setSize = hooks.useBinding(UDim2.new())
	hooks.useEffect(function()
		local conn = RunService.RenderStepped:Connect(function()
			local instance: Frame = ref:getValue()
			local parent = instance:FindFirstAncestorWhichIsA("GuiObject")
			assert(parent)
			local uiListLayout = parent:FindFirstChildOfClass("UIListLayout")
			assert(
				uiListLayout,
				"HorizontalSpacer must be siblings with a UIListLayout"
			)
			local width = parent.AbsoluteSize.X
				- (uiListLayout.AbsoluteContentSize.X - instance.AbsoluteSize.X)
			local uiPadding = parent:FindFirstChildOfClass("UIPadding")
			if uiPadding then
				width -= uiPadding.PaddingLeft.Offset
				width -= uiPadding.PaddingRight.Offset
			end
			setSize(UDim2.fromOffset(width, 0))
		end)
		return function()
			conn:Disconnect()
		end
	end, {})
	return froact.Frame({
		BackgroundTransparency = 1,
		Size = size,
		ref = ref,
	})
end)

type ServiceProps = {
	name: string,
	description: string,
	status: string,
	onActivated: () -> ()?,
}
local Service = froact.c({}, function(props: ServiceProps, hooks)
	local hovering, hoveringMods = useBoolean(hooks, false)
	if props.status == "NoDisable" then
		hovering = false
	end
	local columns = froact.list({ orderByName = true }, {
		froact.UIListLayout({
			SortOrder = Enum.SortOrder.Name,
			FillDirection = Enum.FillDirection.Horizontal,
			VerticalAlignment = Enum.VerticalAlignment.Center,
			Padding = UDim.new(0, 4),
		}),
		StatusCircle({ status = props.status, size = 10 }),
		froact.TextLabel({
			Text = props.name,
			AutomaticSize = Enum.AutomaticSize.XY,
			Font = Enum.Font.GothamMedium,
			TextXAlignment = Enum.TextXAlignment.Left,
			BackgroundTransparency = 1,
		}),
		HorizontalSpacer({}),
		froact.TextLabel({
			Text = if props.status == "NoDisable"
				then "Disabling disabled"
				else if props.status == "Disabled"
					then "Click to enable"
					else "Click to disable",
			AutomaticSize = Enum.AutomaticSize.XY,
			Font = Enum.Font.Gotham,
			TextColor3 = Color3.new(0.5, 0.5, 0.5),
			TextXAlignment = Enum.TextXAlignment.Left,
			BackgroundTransparency = 1,
		}),
	})
	return froact.ImageButton({
		AutomaticSize = Enum.AutomaticSize.Y,
		Active = props.status ~= "NoDisable",
		Size = UDim2.fromScale(1, 0),
		BackgroundColor3 = if hovering
			then Color3.new(0.8, 0.8, 0.8)
			else Color3.new(0.9, 0.9, 0.9),
		onMouseEnter = hoveringMods.set,
		onMouseLeave = hoveringMods.unset,
		onActivated = props.onActivated,
	}, {
		UICorner = froact.UICorner({}),
		UIListLayout = froact.UIListLayout({ Padding = UDim.new(0, 4) }),
		UIPadding = froact.UIPadding({
			PaddingLeft = UDim.new(0, 8),
			PaddingRight = UDim.new(0, 8),
			PaddingTop = UDim.new(0, 8),
			PaddingBottom = UDim.new(0, 8),
		}),
		Top = froact.Frame({
			BackgroundTransparency = 1,
			Size = UDim2.fromScale(1, 0),
			AutomaticSize = Enum.AutomaticSize.Y,
			LayoutOrder = 1,
		}, columns),
		Description = froact.TextLabel({
			BackgroundTransparency = 1,
			Size = UDim2.fromScale(1, 0),
			AutomaticSize = Enum.AutomaticSize.Y,
			Font = Enum.Font.Gotham,
			TextColor3 = Color3.new(0.2, 0.2, 0.2),
			Text = props.description,
			TextWrapped = true,
			LayoutOrder = 2,
		}),
	})
end)

type ExitButtonProps = { onActivated: () -> () }
local ExitButton = froact.c({}, function(props: ExitButtonProps, hooks)
	local hovering, hoveringMods = useBoolean(hooks, false)
	return froact.ImageButton({
		Position = UDim2.fromScale(1, 0),
		Size = UDim2.fromOffset(20, 20),
		AnchorPoint = Vector2.new(1, 0),
		BackgroundColor3 = if hovering
			then Color3.fromRGB(160, 0, 0)
			else Color3.fromRGB(200, 0, 0),
		onMouseEnter = hoveringMods.set,
		onMouseLeave = hoveringMods.unset,
		onActivated = props.onActivated,
	}, {
		UICorner = froact.UICorner({ CornerRadius = UDim.new(1, 0) }),
	})
end)

type ServiceListProps = {
	clientServices: { ServiceProps },
	serverServices: { ServiceProps },
	onExit: () -> ()?,
}
local ServiceList = froact.c({}, function(props: ServiceListProps)
	local elements = {
		froact.UIListLayout({
			SortOrder = Enum.SortOrder.Name,
			Padding = UDim.new(0, 4),
		}),
		froact.UIPadding({
			PaddingLeft = UDim.new(0, 8),
			PaddingRight = UDim.new(0, 8),
			PaddingTop = UDim.new(0, 8),
		}),
		froact.UIAspectRatioConstraint({ AspectRatio = 1 }),
		froact.UICorner({}),
		froact.Frame(
			{
				AutomaticSize = Enum.AutomaticSize.Y,
				Size = UDim2.fromScale(1, 0),
			},
			froact.list({}, {
				Text = froact.TextLabel({
					Text = "Client Services",
					AutomaticSize = Enum.AutomaticSize.Y,
					Size = UDim2.fromScale(1, 0),
					TextSize = 20,
					Font = Enum.Font.GothamBold,
					TextXAlignment = Enum.TextXAlignment.Left,
					BackgroundTransparency = 1,
				}),
				Exit = if props.onExit
					then ExitButton({ onActivated = props.onExit })
					else nil,
			})
		),
	}
	for i, serviceProps in props.clientServices do
		table.insert(elements, Service(serviceProps))
	end
	table.insert(
		elements,
		froact.TextLabel({
			Text = "Server Services",
			AutomaticSize = Enum.AutomaticSize.Y,
			Size = UDim2.fromScale(1, 0),
			TextSize = 20,
			Font = Enum.Font.GothamBold,
			TextXAlignment = Enum.TextXAlignment.Left,
		})
	)
	for i, serviceProps in props.serverServices do
		table.insert(elements, Service(serviceProps))
	end
	local children = froact.list({ orderByName = true, key = "name" }, elements)
	return froact.Frame({
		Size = UDim2.fromScale(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.5),
		AnchorPoint = Vector2.new(0.5, 0.5),
		ClipsDescendants = true,
	}, children)
end)

return ServiceList
