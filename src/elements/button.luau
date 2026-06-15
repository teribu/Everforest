local Creator = require("../modules/creator")
local Tween = require("../modules/tween")

local New = Creator.New
local AddSignal = Creator.AddSignal

local Element = {}
Element.__index = Element
Element.__type = "Button"

function Element:New(Config)
	assert(Config.Title, "Button - Missing Title")
	local Button = {
		Callback = Config.Callback or function() end,
	}

	local ButtonFlash = New("Frame", {
		BackgroundColor3 = Color3.fromRGB(255, 255, 255),
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 1, 0),
	}, {
		New("UICorner", {
			CornerRadius = UDim.new(0, 6),
		}),
	})

	local SoundHover = New("Sound", {
		ThemeTag = {
			SoundId = "ButtonSoundHoverId",
			Volume = "ButtonSoundHoverVolume",
		}
    })

	local SoundClick = New("Sound", {
		ThemeTag = {
			SoundId = "ButtonSoundClickId",
			Volume = "ButtonSoundClickVolume",
		},
	})

	local ButtonButton = New("TextButton", {
		TextWrapped = true,
		RichText = true,
		TextSize = 18,
		FontFace = Font.new("rbxassetid://11702779409", Enum.FontWeight.Bold, Enum.FontStyle.Normal),
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 1, 0),
		Text = Config.Title,
		ThemeTag = {
			TextColor3 = "ButtonText",
		},
	}, {
	    New("UIPadding", {
			PaddingLeft = UDim.new(0, 12),
			PaddingRight = UDim.new(0, 12),
			PaddingTop = UDim.new(0, 12),
			PaddingBottom = UDim.new(0, 12),
		})
	})

	local Scaller = New("UIScale", {
		Scale = 1,
	})

	local ButtonFrame = New("Frame", {
    	AnchorPoint = Vector2.new(0.5, 0.5),
    	Size = UDim2.new(1, 0, 0, 42),
    	Position = UDim2.new(0.5, 0, 0.5, 0),
    	ThemeTag = {
        	BackgroundColor3 = "Button"
        },
	}, {
		ButtonFlash,
		ButtonButton,
		SoundHover,
		SoundClick,
		Scaller,
		New("UICorner", {
			CornerRadius = UDim.new(0, 6),
		})
	})

	local ButtonRoot = New("Frame", {
    	Size = UDim2.new(1, 0, 0, 42),
    	BackgroundTransparency = 1,
    	Parent = self.Container,
	}, {
		ButtonFrame
	})

	AddSignal(ButtonFrame.MouseEnter, function()
		SoundHover:Play()
		ButtonFlash.BackgroundTransparency = 0.8
		Tween.Play(ButtonFlash, { BackgroundTransparency = 1 }, { Duration = 1 })
	end)

	AddSignal(ButtonButton.InputBegan, function(input)
        if input.UserInputType ~= Enum.UserInputType.MouseButton1 and input.UserInputType ~= Enum.UserInputType.Touch then return end
        local StartTime = os.clock()

        Tween.Play(Scaller, { Scale = 0.92 }, { Duration = 2, EasingStyle = "Quad" })

        input.Changed:Wait()
        if input.UserInputState ~= Enum.UserInputState.End then return end

        local MousePos = input.Position
        local ButtonPos = ButtonButton.AbsolutePosition
        local ButtonSize = ButtonButton.AbsoluteSize

        local IsInside = (MousePos.X >= ButtonPos.X and MousePos.X <= ButtonPos.X + ButtonSize.X) and
            (MousePos.Y >= ButtonPos.Y and MousePos.Y <= ButtonPos.Y + ButtonSize.Y)

        local ClickTime = os.clock() - StartTime
        local TargetScale = (ClickTime >= 0.2) and 1.04 or 1.02
        Tween.Play(Scaller, { Scale = TargetScale }, { Duration = 0.2, EasingStyle = "Quad" })

        if IsInside then
            SoundClick:Play()

            self.Library:SafeCallback(Button.Callback)
            ButtonFlash.BackgroundTransparency = 0.8
            Tween.Play(ButtonFlash, { BackgroundTransparency = 1 }, { Duration = 2 })

            task.wait(0.1)
        end

        Tween.Play(Scaller, { Scale = 1 }, { Duration = 0.1, EasingStyle = "Quad" })
    end)

	function Button:SetTitle(Title)
		ButtonButton.Text = tostring(Title)
	end

	return Button
end

return Element
