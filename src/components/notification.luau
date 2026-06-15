local Creator = require("../modules/creator")
local Tween = require("../modules/tween")

local New = Creator.New
local AddSignal = Creator.AddSignal

local Notification = {}

function Notification:Init(GUI)
    Notification.Holder = New("Frame", {
        Position = UDim2.new(1, -30, 0, 86),
        Size = UDim2.new(0, 190, 1, -86),
        AnchorPoint = Vector2.new(1, 0),
        BackgroundTransparency = 1,
        ZIndex = 2,
        Parent = GUI,
    }, {
        New("UIListLayout", {
            Padding = UDim.new(0, 5),
            HorizontalAlignment = Enum.HorizontalAlignment.Right,
            SortOrder = Enum.SortOrder.LayoutOrder
        })
    })
end

function Notification:New(Config)
    Config.Indicator = Config.Indicator or {}
    Config.Duration = Config.Duration or 5

    local NewNotification = {
        Closed = false,
        Connection = nil
    }

    NewNotification.Title = New("TextLabel", {
        TextSize = 16,
        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
        FontFace = Font.new([[rbxassetid://11702779409]], Enum.FontWeight.Medium, Enum.FontStyle.Normal),
        BackgroundTransparency = 1,
        Text = Config.Title or "Notification",
        LayoutOrder = 1,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Top,
        AutomaticSize = Enum.AutomaticSize.Y,
        Position = UDim2.new(0, 0, 0, 0),
        Size = UDim2.new(0, 134, 0, 31),
        TextTransparency = 1,
        MaxVisibleGraphemes = 0,
        RichText = true,
        TextWrapped = true,
        ThemeTag = { TextColor3 = "NotificationTitle" }
    }, {
        New("UIPadding", {
            PaddingLeft = UDim.new(0, 0),
            PaddingRight = UDim.new(0, 10),
            PaddingTop = UDim.new(0, 0),
            PaddingBottom = UDim.new(0, 15)
        })
    })

    NewNotification.LabelHolder = New("Frame", {
        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
        AnchorPoint = Vector2.new(0, 0),
        AutomaticSize = Enum.AutomaticSize.XY,
        Size = UDim2.new(0, 0, 0, 0),
        Position = UDim2.new(0, 0, 0, 0),
        BackgroundTransparency = 1,
        LayoutOrder = 2
    }, {
        NewNotification.Title,
        New("UIListLayout", {
            Padding = UDim.new(0, 0),
            SortOrder = Enum.SortOrder.LayoutOrder
        }),
        New("UIPadding", {
            PaddingLeft = UDim.new(0, 12),
            PaddingRight = UDim.new(0, 0),
            PaddingTop = UDim.new(0, 16),
            PaddingBottom = UDim.new(0, 0)
        })
    })

    NewNotification.Indicator = New("Frame", {
        BackgroundColor3 = Config.Indicator.Color or Color3.fromRGB(42, 38, 9),
        BackgroundTransparency = 1,
        Size = UDim2.new(0, 44, 0, 47),
        LayoutOrder = 1
    }, {
        New("UICorner", {
            TopLeftRadius = UDim.new(0, 6),
            BottomLeftRadius = UDim.new(0, 6),
            TopRightRadius = UDim.new(0, 0),
            BottomRightRadius = UDim.new(0, 0)
        }),
        New("ImageLabel", {
            Image = Config.Indicator.Icon or "rbxassetid://10723374276",
            BackgroundColor3 = Color3.fromRGB(255, 255, 255),
            ImageColor3 = Config.Indicator.IconColor or Color3.fromRGB(255, 228, 55),
            ImageTransparency = 1,
            AnchorPoint = Vector2.new(0.5, 0.5),
            Size = UDim2.new(0, 18, 0, 18),
            BackgroundTransparency = 1,
            Position = UDim2.new(0.5, 0, 0.5, 0)
        })
    })

    NewNotification.Indicator.Visible = Config.Indicator.Enabled or false

    NewNotification.Flash = New("Frame", {
        Size = UDim2.new(1, 0, 1, 0),
        Position = UDim2.new(0, 0, 0, 0),
        BackgroundColor3 = Color3.new(1, 1, 1),
        BackgroundTransparency = 0.8,
        ZIndex = 2
    }, {
        New("UICorner", { CornerRadius = UDim.new(0, 6) })
    })

    NewNotification.Root = New("Frame", {
        AnchorPoint = Vector2.new(0, 0),
        AutomaticSize = Enum.AutomaticSize.XY,
        Size = UDim2.new(0, 0, 0, 48),
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 0, 0, 0),
        ThemeTag = { BackgroundColor3 = "Notification" }
    }, {
        NewNotification.LabelHolder,
        NewNotification.Indicator,
        New("UICorner", { CornerRadius = UDim.new(0, 6) }),
        New("UIListLayout", {
            Padding = UDim.new(0, 0),
            FillDirection = Enum.FillDirection.Horizontal,
            SortOrder = Enum.SortOrder.LayoutOrder
        }),
        New("UIStroke", {
            Thickness = 0.7,
            Transparency = 1,
            ThemeTag = { Color = "NotificationBorder" }
        })
    })

    NewNotification.Holder = New("Frame", {
        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
        Size = UDim2.new(0, 0, 0, 48),
        AutomaticSize = Enum.AutomaticSize.XY,
        BackgroundTransparency = 1,
        Parent = Notification.Holder,
    }, {
        NewNotification.Flash,
        NewNotification.Root
    })

    local LastHeight = 0
    NewNotification.Connection = AddSignal(NewNotification.LabelHolder:GetPropertyChangedSignal("AbsoluteSize"),
        function()
            local CurrentSize = NewNotification.LabelHolder.AbsoluteSize
            if CurrentSize.Y > 0 and CurrentSize.Y ~= LastHeight then
                LastHeight = CurrentSize.Y
                NewNotification.Indicator.Size = UDim2.new(0, 44, 0, CurrentSize.Y)
            end
        end)

    function NewNotification:Open()
        task.spawn(function()
            local TextLength = #NewNotification.Title.Text
            game:GetService("TweenService"):Create(NewNotification.Title,
                TweenInfo.new(
                    tonumber(string.format("%.2f", TextLength * 0.03)),
                    Enum.EasingStyle.Linear,
                    Enum.EasingDirection.Out
                ),
                { MaxVisibleGraphemes = TextLength }
            ):Play()

            Tween.Plays(NewNotification, {
                Indicator = { "ImageLabel" },
                Flash = {
                    Props = { BackgroundTransparency = 1 },
                    Preset = { Duration = 3 }
                },
                Root = {
                    UIStroke = { Props = { Transparency = 0.85 } }
                },
                "Title"
            }, { Transparency = 0 }, { Duration = 0.5 })
        end)
    end

    function NewNotification:Close()
        if NewNotification.Closed then return end
        NewNotification.Closed = true

        task.spawn(function()
            if NewNotification.Connection then
                NewNotification.Connection:Disconnect()
                NewNotification.Connection = nil
            end

            local CloseTween = Tween.Plays(NewNotification, {
                Indicator = { "ImageLabel" },
                Root = { "UIStroke" },
                "Title"
            }, { Transparency = 1 }, { Duration = 0.3, EasingStyle = "Quad" })

            task.wait(0.3)
            NewNotification.Holder:Destroy()
        end)
    end

    task.spawn(function()
        NewNotification:Open()
        task.wait(Config.Duration)
        NewNotification:Close()
    end)

    return NewNotification
end

return Notification
