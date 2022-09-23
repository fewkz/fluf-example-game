local function generateMods(setValue: any)
	return {
		set = function()
			setValue(true)
		end,
		unset = function()
			setValue(false)
		end,
		toggle = function()
			setValue(function(value)
				return not value
			end)
		end,
	}
end
type BooleanMods = typeof(generateMods())
local function useBoolean(hooks: any, initial: boolean)
	local value, setValue = hooks.useState(initial)
	local valueMod = hooks.useMemo(function()
		return generateMods(setValue)
	end, {})
	return value :: boolean, valueMod :: BooleanMods
end

return useBoolean
