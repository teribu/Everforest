local Creator = require("../modules/creator")
local Tween = require("../modules/tween")

local New = Creator.New
local AddSignal = Creator.AddSignal

return function(Config)
    local Top = {}

    Top.Button = New("TextButton", {
        Text = "",
        Size = UDim2.new(1, 0, 1, 0),
        Position = UDim2.new(0, 0, 0, 0),
        BackgroundTransparency = 1,
    })

    Top.User = New("Frame", {
        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
        AnchorPoint = Vector2.new(1, 0),
        AutomaticSize = Enum.AutomaticSize.X,
        Size = UDim2.new(0, 0, 1, 0),
        Position = UDim2.new(1, -18, 0, 0),
        BackgroundTransparency = 1
    }, {
        New("TextLabel", {
            TextSize = 14,
            TextXAlignment = Enum.TextXAlignment.Left,
            BackgroundColor3 = Color3.fromRGB(255, 255, 255),
            FontFace = Font.new("rbxassetid://11702779409", Enum.FontWeight.Medium, Enum.FontStyle.Normal),
            TextColor3 = Color3.fromRGB(255, 255, 255),
            BackgroundTransparency = 1,
            AnchorPoint = Vector2.new(0, 0.5),
            Text = Config.User.Name,
            AutomaticSize = Enum.AutomaticSize.XY,
            Position = UDim2.new(0, 30, 0.5, -1)
        }),
        New("ImageLabel", {
            BackgroundColor3 = Color3.fromRGB(255, 255, 255),
            AnchorPoint = Vector2.new(0, 0.5),
            Image = Config.User.Icon or "rbxassetid://138895252616906",
            Size = UDim2.new(0, 25, 0, 25),
            BorderColor3 = Color3.fromRGB(0, 0, 0),
            BackgroundTransparency = 1,
            Position = UDim2.new(0, 0, 0.5, 0)
        })
    })

    local TextWidth = (Config.Logo ~= nil and Config.Logo ~= "" and 54) or 12

    Top.Root = New("Frame", {
        Size = UDim2.new(1, 0, 0, 58),
        Parent = Config.Parent,
        ThemeTag = {
            BackgroundColor3 = "Top",
            BackgroundTransparency = "TopTransparency",
        }
    }, {
        Top.Button,
        Top.User,
        New("Frame", {
            Size = UDim2.new(0, 200, 1, 0),
            Position = UDim2.new(0, 0, 0, 0),
            BackgroundTransparency = 1,
            AutomaticSize = Enum.AutomaticSize.X,
        }, {
            New("ImageLabel", {
                Size = UDim2.new(0, 30, 0, 30),
                AnchorPoint = Vector2.new(0, 0.5),
                Position = UDim2.new(0, 12, 0.5, 0),
                Image = TextWidth == 54 and Config.Icon or "",
            }),
            New("TextLabel", {
                Text = Config.Title,
                FontFace = Font.new("rbxassetid://12187376910", Enum.FontWeight.Regular, Enum.FontStyle.Normal),
                BackgroundTransparency = 1,
                TextSize = 20,
                AnchorPoint = Vector2.new(0, 0),
                Position = UDim2.new(0, TextWidth, 0, 11),
                AutomaticSize = Enum.AutomaticSize.XY,
                ThemeTag = {
                    TextColor3 = "TopTitle"
                }
            }),
            New("TextLabel", {
                Text = Config.Description,
                BackgroundTransparency = 1,
                FontFace = Font.new("rbxassetid://11702779409", Enum.FontWeight.Medium, Enum.FontStyle.Normal),
                TextSize = 14,
                AnchorPoint = Vector2.new(0, 0),
                Position = UDim2.new(0, TextWidth, 0, 29),
                AutomaticSize = Enum.AutomaticSize.XY,
                ThemeTag = {
                    TextColor3 = "TopDescription"
                }
            })
        })
    })


    AddSignal(Top.Button.Activated, function()
        Config.Window:ToggleVisibility()
    end)
    return Top
end
