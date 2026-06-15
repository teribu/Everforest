local UserInputService = game:GetService("UserInputService")
local Creator = require("../modules/creator")
local Tween = require("../modules/tween")

local New = Creator.New
local AddSignal = Creator.AddSignal

local Element = {}
Element.__index = Element
Element.__type = "Slider"

function Element:New(Idx, Config)
	local Library = self.Library
	assert(Config.Title, "Slider - Missing Title.")
	assert(Config.Default, "Slider - Missing default value.")

	local Slider = {
		Value = Config.Default,
		Realtime = Config.Realtime or false,
		Min = Config.Min or 0,
		Max = Config.Max or 100,
		Increment = Config.Increment or 1,
		Suffix = Config.Suffix or "",
		SliderWidth = Config.SliderWidth or 200,
		ClearTextOnFocus = Config.ClearTextOnFocus or false,
		Callback = Config.Callback or function(Value) end,
		Type = "Slider"
	}

	local Dragging = false
	local Focused = false

	local SliderFrame = require("../components/element")(Config.Title, self.Container, true, function() return not Dragging and not Focused end)
	SliderFrame.Button.Visible = false
	SliderFrame.LabelHolder.Size = UDim2.new(1, -Slider.SliderWidth-20, 0, 0)
	Slider.SetTitle = SliderFrame.SetTitle

	local SliderDisplay = New("TextBox", {
		TextXAlignment = Enum.TextXAlignment.Left,
		TextWrapped = true,
		TextSize = 18,
		RichText = true,
		TextYAlignment = Enum.TextYAlignment.Top,
		BackgroundColor3 = Color3.fromRGB(255, 255, 255),
		FontFace = Font.new("rbxassetid://11702779409", Enum.FontWeight.Medium, Enum.FontStyle.Normal),
		AutomaticSize = Enum.AutomaticSize.Y,
		Size = UDim2.new(1, 0, 0, 18),
		Text = tostring(Slider.Value) .. Slider.Suffix,
		LayoutOrder = 1,
		BackgroundTransparency = 1,
		ClearTextOnFocus = Slider.ClearTextOnFocus,
		Parent = SliderFrame.LabelHolder,
		PlaceholderText = "0" .. Slider.Suffix,
		ThemeTag = {
			TextColor3 = "SliderText",
			PlaceholderColor3 = "SliderText"
		}
	})

	local SliderDot = New("Frame", {
		AnchorPoint = Vector2.new(1, 0),
		Size = UDim2.new(0, 10, 1, 0),
		Position = UDim2.new(1, 0, 0, 0),
		ThemeTag = {
			BackgroundColor3 = "SliderDot",
		}
	}, {
		New("UICorner", {
			CornerRadius = UDim.new(0, 100),
		}),
	})

	local SliderFill = New("Frame", {
		AnchorPoint = Vector2.new(0, 0.5),
		Size = UDim2.new(0.7, 0, 0, 40),
		Position = UDim2.new(0, 0, 0.5, 0),
		ThemeTag = {
			BackgroundColor3 = "SliderFill",
		}
	}, {
		SliderDot,
		New("UICorner", {
			CornerRadius = UDim.new(0, 6),
		})
	})

	local SliderTrack = New("Frame", {
		AnchorPoint = Vector2.new(0.5, 0.5),
		Size = UDim2.new(0, 180, 0, 40),
		Position = UDim2.new(0.5, 0, 0.5, 0),
		BorderColor3 = Color3.fromRGB(0, 0, 0),
		ThemeTag = {
			BackgroundColor3 = "SliderTrack",
		},
	}, {
		SliderFill,
		New("UICorner", {
			CornerRadius = UDim.new(0, 6),
		}),
	})

	local SliderHolder = New("Frame", {
		AnchorPoint = Vector2.new(1, 0.5),
		Size = UDim2.new(0, Slider.SliderWidth, 1, 0),
		Position = UDim2.new(1, 0, 0.5, 0),
		BackgroundTransparency = 1,
		Parent = SliderFrame.Root,
	}, {
		SliderTrack
	})

	function Slider:_round(Number, Factor)
		local Result = math.floor(Number/Factor + (math.sign(Number) * 0.5)) * Factor
		if Result < 0 then
			Result = Result + Factor
		end
		return Result
	end

	local isUpdating = false
    SliderDisplay:GetPropertyChangedSignal("Text"):Connect(function()
        if isUpdating then return end
        isUpdating = true

        local cleanedText = SliderDisplay.Text:gsub("[^%d%.]", "")

        local firstDot = cleanedText:find("%.")
        if firstDot and cleanedText:find("%.", firstDot + 1) then
            cleanedText = cleanedText:sub(1, firstDot) .. cleanedText:sub(firstDot + 1):gsub("%.", "")
        end

        local numValue = tonumber(cleanedText)
        if numValue and numValue > Slider.Max then
            SliderDisplay.Text = tostring(Slider.Max) .. Config.Suffix
        else
            SliderDisplay.Text = cleanedText .. Config.Suffix
        end

        isUpdating = false
    end)

	AddSignal(SliderDisplay.Focused, function()
		Tween.Play(SliderFrame.Border, { Color = Creator.GetThemeProperty("SliderHold") }, { Duration = 0.1 })
		Focused = true

		local cleanText = SliderDisplay.Text:gsub(Slider.Suffix, "")
		SliderDisplay.Text = cleanText
	end)

	AddSignal(SliderDisplay.FocusLost, function()
		local cleanText = SliderDisplay.Text:gsub("[^%d%.]", "")
		local finalValue = tonumber(cleanText) or Slider.Min

		Slider:SetValue(finalValue)

		Tween.Play(SliderFrame.Border, { Color = Creator.GetThemeProperty("ElementBorder") }, { Duration = 0.1 })
		if not SliderFrame.Hoving then
			Tween.Play(SliderFrame.Border, { Transparency = 1 }, { Duration = 0.1 })
		end
		Focused = false
	end)

	AddSignal(SliderTrack.MouseEnter, function()
		Tween.Play(SliderDot, { BackgroundColor3 = Creator.GetThemeProperty("SliderDotHold") })
	end)

	AddSignal(SliderTrack.MouseLeave, function()
		Tween.Play(SliderDot, { BackgroundColor3 = Creator.GetThemeProperty("SliderDot") })
	end)

	AddSignal(SliderHolder.InputBegan, function(Input)
		if
			Input.UserInputType == Enum.UserInputType.MouseButton1
			or Input.UserInputType == Enum.UserInputType.Touch
		then
			Dragging = true
			SliderFrame.SoundClick:Play()
			Tween.Play(SliderFrame.Border, { Color = Creator.GetThemeProperty("SliderHold") })
			Tween.Play(SliderDot, { BackgroundColor3 = Creator.GetThemeProperty("SliderDotHold") })
		end
	end)

	AddSignal(SliderHolder.InputEnded, function(Input)
		if
			Input.UserInputType == Enum.UserInputType.MouseButton1
			or Input.UserInputType == Enum.UserInputType.Touch
		then
			Dragging = false
			Tween.Play(SliderFrame.Border, { Color = Creator.GetThemeProperty("ElementBorder") }, { Duration = 0.1 })
			if not SliderFrame.Hoving then
				Tween.Play(SliderFrame.Border, { Transparency = 1 }, { Duration = 0.1 })
			end

			if not Slider.Realtime then
				local SizeScale = math.clamp((Input.Position.X - SliderTrack.AbsolutePosition.X) / SliderTrack.AbsoluteSize.X, 0, 1)
				Slider:SetValue(Slider.Min + ((Slider.Max - Slider.Min) * SizeScale))
			end
		end
	end)

	AddSignal(UserInputService.InputChanged, function(Input)
		if
			Dragging
			and (
				Input.UserInputType == Enum.UserInputType.MouseMovement
				or Input.UserInputType == Enum.UserInputType.Touch
			)
		then
			local SizeScale = math.clamp((Input.Position.X - SliderTrack.AbsolutePosition.X) / SliderTrack.AbsoluteSize.X, 0, 1)
			local Value = math.clamp(Slider:_round(Slider.Min + ((Slider.Max - Slider.Min) * SizeScale), Slider.Increment), Slider.Min, Slider.Max)

			if Slider.Realtime then
				Slider:SetValue(Value)
			else
                local incrementStr = tostring(Slider.Increment)
                local dotIndex = incrementStr:find("%.")
                local decimalPlaces = dotIndex and (#incrementStr - dotIndex) or 0
                local cleanDisplayValue = tonumber(string.format("%." .. decimalPlaces .. "f", Value))

                SliderDisplay.Text = tostring(cleanDisplayValue) .. Slider.Suffix
                Tween.Play(SliderFill, { Size = UDim2.fromScale((Value - Slider.Min) / (Slider.Max - Slider.Min), 1) }, { Duration = 0.2 })
            end
		end
	end)

	function Slider:OnChanged(Func)
		Slider.Changed = Func
		Func(Slider.Value)
	end

	function Slider:SetValue(Value)
		local ComputedValue = math.clamp(Slider:_round(Value, Slider.Increment), Slider.Min, Slider.Max)

		local incrementStr = tostring(Slider.Increment)
		local dotIndex = incrementStr:find("%.")
		local decimalPlaces = dotIndex and (#incrementStr - dotIndex) or 0

		local CleanValue = tonumber(string.format("%." .. decimalPlaces .. "f", ComputedValue))

		Slider.Value = CleanValue
		SliderDisplay.Text = tostring(CleanValue) .. Slider.Suffix
		Tween.Play(SliderFill, { Size = UDim2.fromScale((CleanValue - Slider.Min) / (Slider.Max - Slider.Min), 1) }, { Duration = 0.2 })

		Library:SafeCallback(Slider.Callback, self.Value)
		Library:SafeCallback(Slider.Changed, self.Value)
	end

	function Slider:Destroy()
		SliderFrame:Destroy()
		Library.Options[Idx] = nil
	end

	Slider:SetValue(Config.Default)

	Library.Options[Idx] = Slider
	return Slider
end

return Element
