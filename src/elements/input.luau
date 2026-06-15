local Creator = require("../modules/creator")
local Tween = require("../modules/tween")

local New = Creator.New
local AddSignal = Creator.AddSignal

local Element = {}
Element.__index = Element
Element.__type = "Input"

function Element:New(Flag, Config)
    local Library = self.Library
    assert(Config.Title, "Input - Missing Title")

    local Input = {
        Value = Config.Default or "",
        Placeholder = Config.Placeholder or "",
        ClearTextOnFocus = Config.ClearTextOnFocus or false,
        Callback = Config.Callback or function(Value) end,
    }

    local Focused = false
    local InputFrame = require("../components/element")(Config.Title, self.Container, true, function() return not Focused end)
    InputFrame.Button.Visible = false
    InputFrame.LabelHolder.Size = UDim2.new(1, -20, 0, 0)
    Input.SetTitle = InputFrame.SetTitle

    local InputBox = New("TextBox", {
        TextXAlignment = Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Top,
        TextSize = 18,
        FontFace = Font.new("rbxassetid://11702779409", Enum.FontWeight.Medium, Enum.FontStyle.Normal),
        PlaceholderText = Input.Placeholder,
        Size = UDim2.new(1, 0, 0, 18),
        Text = Input.Value,
        LayoutOrder = 1,
        BackgroundTransparency = 1,
        Parent = InputFrame.LabelHolder,
        TextWrapped = true,
        AutomaticSize = Enum.AutomaticSize.Y,
        RichText = true,
        ClearTextOnFocus = Input.ClearTextOnFocus,
        ThemeTag = {
            PlaceholderColor3 = "InputPlaceholder",
            TextColor3 = "InputText",
        }
    })

    AddSignal(InputBox.Focused, function()
        Focused = true
        Tween.Play(InputFrame.Border, { Color = Creator.GetThemeProperty("InputBorder") })
    end)

    AddSignal(InputBox.FocusLost, function()
        Focused = false
        Tween.Play(InputFrame.Border, { Color = Creator.GetThemeProperty("ElementBorder") })
        if not InputFrame.Hoving then
            Tween.Play(InputFrame.Border, { Transparency = 1 })
        end

        Input:SetValue(InputBox.Text)
    end)

    function Input:OnChanged(Func)
        Input.Changed = Func
        Func(Input.Value)
    end

    function Input:SetValue(Value)
        Input.Value = Value
        InputBox.Text = Input.Value

        Library:SafeCallback(Input.Callback, Input.Value)
        Library:SafeCallback(Input.Changed, Input.Value)
    end

    function Input:Destroy()
        InputFrame:Destroy()
        Library.Options[Flag] = nil
    end

    Library.Options[Flag] = Input
    return Input
end

return Element
