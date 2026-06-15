local Creator = require("../modules/creator")
local Tween = require("../modules/tween")

local New = Creator.New
local AddSignal = Creator.AddSignal

local Element = {}
Element.__index = Element
Element.__type = "Toggle"

function Element:New(Flag, Config)
    local Library = self.Library
    assert(Config.Title, "Toggle - Missing Title")

    local Toggle = {
        Value = Config.Default or false,
        Callback = Config.Callback or function(Value) end,
        Type = "Toggle",
    }

    local ToggleFrame = require("../components/element")(Config.Title, self.Container, true)
    Toggle.SetTitle = ToggleFrame.SetTitle

    local SwitchBorder = New("UIStroke", {
        Thickness = 2.7,
        ThemeTag = {
            Color = "ToggleSlider",
        },
    })

    local SwitchInsider = New("Frame", {
        BackgroundColor3 = Color3.fromRGB(128, 94, 233),
        AnchorPoint = Vector2.new(0.5, 0.5),
        Size = UDim2.new(0, 40, 0, 12),
        Position = UDim2.new(0.5, 0, 0.5, 0),
        BackgroundTransparency = 1,
        ThemeTag = {
            BackgroundColor3 = "ToggleSlider",
        },
    }, {
        SwitchBorder,
        New("UICorner", {
            CornerRadius = UDim.new(0, 100),
        })
    })

    local ToggleSwitch = New("Frame", {
        BackgroundColor3 = Color3.fromRGB(45, 43, 52),
        AnchorPoint = Vector2.new(1, 0.5),
        Size = UDim2.new(0, 80, 1, 0),
        Position = UDim2.new(1, 0, 0.5, 0),
        BackgroundTransparency = 1,
        Parent = ToggleFrame.Root,
    }, {
        SwitchInsider
    })

    local Hoving = false

    AddSignal(SwitchInsider.MouseEnter, function()
        Tween.Play(SwitchBorder, { Color = Creator.GetThemeProperty("ToggleHoverColor") })
        Tween.Play(SwitchInsider, { BackgroundColor3 = Creator.GetThemeProperty("ToggleHoverColor") })
        Hoving = true
    end)

    AddSignal(SwitchInsider.MouseLeave, function()
        local targetColor = Toggle.Value and Creator.GetThemeProperty("ToggleOnColor") or
            Creator.GetThemeProperty("ToggleOffColor")

        Tween.Play(SwitchBorder, { Color = targetColor })
        Tween.Play(SwitchInsider, { BackgroundColor3 = targetColor })
        Hoving = false
    end)

    function Toggle:OnChanged(Func)
        Toggle.Changed = Func
        Func(Toggle.Value)
    end

    function Toggle:SetValue(Value)
        Value = not not Value
        Toggle.Value = Value

        local currentThemeOn = Creator.GetThemeProperty("ToggleOnColor")
        local currentThemeOff = Creator.GetThemeProperty("ToggleOffColor")
        local currentThemeHover = Creator.GetThemeProperty("ToggleHoverColor")

        local targetColor = Hoving and currentThemeHover or currentThemeOn

        if Value then
            Tween.Plays(SwitchInsider, {
                {
                    Props = {
                        Size = UDim2.new(0, 54, 0, 12),
                        Transparency = 0,
                        BackgroundColor3 = targetColor
                    },
                    Preset = { Duration = 0.05 }
                },
                UIStroke = {
                    Props = { Color = targetColor }
                }
            }, { Duration = 0.1 })
        else
            local strokeColor = Hoving and currentThemeHover or currentThemeOff

            Tween.Plays(SwitchInsider, {
                {
                    Props = {
                        Size = UDim2.new(0, 40, 0, 12),
                        BackgroundTransparency = 1,
                        BackgroundColor3 = targetColor
                    },
                    Preset = { Duration = 0.05 }
                },
                UIStroke = {
                    Props = { Color = strokeColor }
                }
            }, { Duration = 0.1 })
        end

        Library:SafeCallback(Toggle.Callback, Toggle.Value)
        Library:SafeCallback(Toggle.Changed, Toggle.Value)
    end

    function Toggle:Destroy()
        ToggleFrame:Destroy()
        Library.Options[Flag] = nil
    end

    AddSignal(ToggleFrame.Button.Activated, function()
        ToggleFrame.SoundClick:Play()
        if ToggleFrame.Fade then
            ToggleFrame.Fade.BackgroundTransparency = 0.8
            Tween.Play(ToggleFrame.Fade, { BackgroundTransparency = 0.9 }, { Duration = 0.2 })
        end
        Toggle:SetValue(not Toggle.Value)
    end)

    Toggle:SetValue(Toggle.Value)

    Library.Options[Flag] = Toggle
    return Toggle
end

return Element
