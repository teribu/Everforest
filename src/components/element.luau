local Creator = require("../modules/creator")
local Tween = require("../modules/tween")

local New = Creator.New
local AddSignal = Creator.AddSignal

return function(Title, Parent, Hover, Condition)
    local Element = {
        Hoving = false,
        Condition = Condition or function() return true end
    }

    Element.Title = New("TextLabel", {
        FontFace = Font.new("rbxassetid://11702779409", Enum.FontWeight.Medium, Enum.FontStyle.Normal),
        Text = Title,
        TextWrapped = true,
        TextSize = 16,
        RichText = true,
        TextXAlignment = Enum.TextXAlignment.Left,
        AutomaticSize = Enum.AutomaticSize.Y,
        Size = UDim2.new(1, 0, 0, 16),
        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
        BackgroundTransparency = 1,
        ThemeTag = {
            TextColor3 = "ElementText"
        }
    })

    Element.LabelHolder = New("Frame", {
        AutomaticSize = Enum.AutomaticSize.Y,
        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 10, 0, 0),
        Size = UDim2.new(1, -100, 0, 0)
    }, {
        New("UIPadding", {
            PaddingBottom = UDim.new(0, 10),
            PaddingTop = UDim.new(0, 10)
        }),
        New("UIListLayout", {
            Padding = UDim.new(0, 6),
            SortOrder = Enum.SortOrder.LayoutOrder
        }),
        Element.Title
    })

    Element.Border = New("UIStroke", {
        Thickness = 1.8,
        Transparency = 1,
        ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
        Color = Color3.fromRGB(99, 75, 172),
        ThemeTag = {
            Color = "ElementBorder"
        }
    })

    Element.Root = New("Frame", {
        Size = UDim2.new(1, 0, 0, 36),
        Parent = Parent,
        AutomaticSize = Enum.AutomaticSize.Y,
        ThemeTag = {
            BackgroundColor3 = "Element",
            BackgroundTransparency = "ElementTransparency"
        }
    }, {
        Element.Border,
        Element.LabelHolder,
        New("UICorner", {
            CornerRadius = UDim.new(0, 5)
        })
    })

    function Element:SetTitle(Text)
        Element.Title.Text = Text
    end

    function Element:Destroy()
        Element.Root:Destroy()
    end

    Element:SetTitle(Title)

    if Hover then
        Element.Button = New("TextButton", {
            Text = "",
            AnchorPoint = Vector2.new(0, 0),
            Size = UDim2.new(1, 0, 1, 0),
            Position = UDim2.new(0, 0, 0, 0),
            BackgroundTransparency = 1,
            Parent = Element.Root
        })

        Element.SoundHover = New("Sound", {
            ThemeTag = {
                SoundId = "ElementSoundHoverId",
                Volume = "ElementSoundHoverVolume"
            }
        })

        Element.SoundClick = New("Sound", {
            ThemeTag = {
                SoundId = "ElementSoundClickId",
                Volume = "ElementSoundClickVolume"
            }
        })

        Element.Fade = New("Frame", {
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 1, 0),
            Parent = Element.Root,
            ThemeTag = {
                BackgroundColor3 = "ElementFade"
            }
        }, {
            Element.SoundHover,
            Element.SoundClick,
            New("UICorner", {
                CornerRadius = UDim.new(0, 5)
            }),
            New("UIGradient", {
                Rotation = -90,
                Transparency = NumberSequence.new({
                    NumberSequenceKeypoint.new(0, 0.5),
                    NumberSequenceKeypoint.new(1, 1)
                }),
                Color = ColorSequence.new(Color3.fromRGB(255, 255, 255), Color3.fromRGB(255, 255, 255))
            })
        })

        AddSignal(Element.Root.MouseEnter, function()
            Element.Hoving = true
            Tween.Plays(Element, {
                Fade = { Props = { BackgroundTransparency = 0.9 } },
                Border = { Props = { Transparency = 0 } }
            }, { EasingStyle = "Quad" })
            Element.SoundHover:Play()
        end)

        AddSignal(Element.Root.MouseLeave, function()
            Element.Hoving = false
            Tween.Plays(Element, {
                Fade = { Props = { BackgroundTransparency = 1 } },
                Border = { Props = { Transparency = 1 }, Condition = Element.Condition }
            }, { EasingStyle = "Quad" })
        end)
    end
    return Element
end
