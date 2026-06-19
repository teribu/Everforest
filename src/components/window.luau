local Tween = require("../modules/tween")
local Creator = require("../modules/creator")

local New = Creator.New

return function(Config)
    local Window = {
        State = false,
        TabWidth = 0,
        SidebarWidth = 0,
        Keybind = Config.Keybind
    }

    Window.TabHolder = New("ScrollingFrame", {
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        CanvasSize = UDim2.new(0, 0, 0, 0),
        ElasticBehavior = Enum.ElasticBehavior.Always,
        ScrollBarThickness = 0,
        ClipsDescendants = false,
        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
        BackgroundTransparency = 1,
        AnchorPoint = Vector2.new(0.5, 0.5),
        Size = UDim2.new(1, -15, 1, -15),
        Position = UDim2.new(0.5, 0, 0.5, 0),
    }, {
        New("UIListLayout", {
            Padding = UDim.new(0, 8),
            SortOrder = Enum.SortOrder.LayoutOrder
        })
    })

    Window.Sidebar = New("Frame", {
        BackgroundColor3 = Color3.fromRGB(37, 36, 44),
        ClipsDescendants = true,
        Size = UDim2.new(0, Config.TabWidth or 200, 1, 0),
        Position = UDim2.new(0, -Window.SidebarWidth, 0, 0),
    }, {
        Window.TabHolder
    })

    Window.Fade = New("Frame", {
        BackgroundColor3 = Color3.fromRGB(1, 1, 1),
        BackgroundTransparency = 0.1,
        Size = UDim2.new(1, 0, 0, 60),
        ThemeTag = {
            BackgroundColor3  = "ContainerFade"
        }
    }, {
        New("UIGradient", {
            Rotation = 90,
            Transparency = NumberSequence.new({
                NumberSequenceKeypoint.new(0, 0),
                NumberSequenceKeypoint.new(1, 1)
            }),
            Color = ColorSequence.new(Color3.fromRGB(255, 255, 255), Color3.fromRGB(255, 255, 255))
        })
    })

    Window.Footer = New("Frame", {
        BackgroundColor3 = Color3.fromRGB(50, 48, 58),
        AutomaticSize = Enum.AutomaticSize.Y,
        Size = UDim2.new(1, 0, 0, 82),
        LayoutOrder = 1
    }, {
        New("UIPadding", {
            PaddingLeft = UDim.new(0, 15),
            PaddingRight = UDim.new(0, 15),
            PaddingTop = UDim.new(0, 24),
            PaddingBottom = UDim.new(0, 24),
        }),
        New("UIListLayout", {
            SortOrder = Enum.SortOrder.LayoutOrder,
        }),
        New("TextLabel", {
            TextWrapped = true,
            TextSize = 18,
            TextYAlignment = Enum.TextYAlignment.Top,
            BackgroundColor3 = Color3.fromRGB(255, 255, 255),
            FontFace = Font.new([[rbxassetid://11702779409]], Enum.FontWeight.Bold, Enum.FontStyle.Normal),
            TextColor3 = Color3.fromRGB(255, 255, 255),
            BackgroundTransparency = 1,
            RichText = true,
            Size = UDim2.new(1, 0, 0, 0),
            Text = Config.Footer.Title or Config.Top.Title,
            LayoutOrder = 0,
            AutomaticSize = Enum.AutomaticSize.Y,
        }),
        New("TextLabel", {
            TextWrapped = true,
            TextSize = 16,
            TextYAlignment = Enum.TextYAlignment.Top,
            BackgroundColor3 = Color3.fromRGB(255, 255, 255),
            FontFace = Font.new([[rbxassetid://11702779409]], Enum.FontWeight.Regular, Enum.FontStyle.Normal),
            TextColor3 = Color3.fromRGB(255, 255, 255),
            BackgroundTransparency = 1,
            RichText = true,
            Size = UDim2.new(1, 0, 0, 0),
            BorderColor3 = Color3.fromRGB(0, 0, 0),
            Text = Config.Footer.Description or ,
            LayoutOrder = 1,
            AutomaticSize = Enum.AutomaticSize.Y,
        })
    })

    Window.Header = New("Frame", {
        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
        AutomaticSize = Enum.AutomaticSize.Y,
        Size = UDim2.new(1, 0, 0, 80),
        BackgroundTransparency = 1,
        LayoutOrder = 0,
    }, {
        New("UIListLayout", {
            Padding = UDim.new(0, 0),
            SortOrder = Enum.SortOrder.LayoutOrder
        }),
        New("TextLabel", {
            TextSize = 40,
            BackgroundColor3 = Color3.fromRGB(255, 255, 255),
            FontFace = Font.new([[rbxassetid://11702779409]], Enum.FontWeight.Medium, Enum.FontStyle.Normal),
            BackgroundTransparency = 1,
            Text = Config.Header.Title or "settings",
            AutomaticSize = Enum.AutomaticSize.Y,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextYAlignment = Enum.TextYAlignment.Top,
            TextWrapped = true,
            Size = UDim2.new(1, 0, 0, 0),
            ThemeTag = {
                TextColor3 = "HeaderTitle"
            },
            LayoutOrder = 0
        }),
        New("TextLabel", {
            TextSize = 20,
            BackgroundColor3 = Color3.fromRGB(255, 255, 255),
            FontFace = Font.new([[rbxassetid://11702779409]], Enum.FontWeight.Regular, Enum.FontStyle.Normal),
            BackgroundTransparency = 1,
            Text = Config.Header.Description or "change the way Everforest behaves",
            TextWrapped = true,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextYAlignment = Enum.TextYAlignment.Top,
            AutomaticSize = Enum.AutomaticSize.Y,
            Size = UDim2.new(1, 0, 0, 0),
            ThemeTag = {
                TextColor3 = "HeaderDescription"
            },
            LayoutOrder = 1
        }),
        New("UIPadding", {
            PaddingBottom = UDim.new(0, 15),
            PaddingLeft = UDim.new(0, 15),
            PaddingRight = UDim.new(0, 15),
            PaddingTop = UDim.new(0, 30),
        })
    })

    if Config.Header.SearchBar and Config.Header.SearchBar.Enabled then
        Window.SearchBox = New("TextBox", {
            TextXAlignment = Enum.TextXAlignment.Left,
            TextSize = 18,
            BackgroundColor3 = Color3.fromRGB(255, 255, 255),
            FontFace = Font.new([[rbxassetid://11702779409]], Enum.FontWeight.Medium, Enum.FontStyle.Normal),
            AutomaticSize = Enum.AutomaticSize.Y,
            AnchorPoint = Vector2.new(0, 0.5),
            PlaceholderText = Config.Header.SearchBar.PlaceholderText or "type to search",
            Size = UDim2.new(1, -50, 0, 0),
            Position = UDim2.new(0, 12, 0.5, 0),
            Text = "",
            ClipsDescendants = true,
            BackgroundTransparency = 1,
            ThemeTag = {
                PlaceholderColor3 = "SearchBoxPlaceholder",
                TextColor3 = "SearchBoxText"
            }
        })

        Window.SearchBar = New("Frame", {
            BackgroundColor3 = Color3.fromRGB(37, 35, 43),
            AnchorPoint = Vector2.new(0.5, 1),
            Size = UDim2.new(1, 0, 0, 40),
            Position = UDim2.new(0.5, 0, 1, -4),
            BorderColor3 = Color3.fromRGB(0, 0, 0),
        }, {
            Window.SearchBox,
            New("ImageLabel", {
                BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                AnchorPoint = Vector2.new(1, 0.5),
                Image = Config.Header.SearchBar.Icon or "rbxassetid://89922969033534",
                Size = UDim2.new(0, 28, 0, 28),
                BorderColor3 = Color3.fromRGB(0, 0, 0),
                BackgroundTransparency = 1,
                Position = UDim2.new(1, -6, 0.5, 0)
            }),
            New("UICorner", {
                CornerRadius = UDim.new(0, 6)
            })
        })

        Window.Wrapper = New("Frame", {
            BackgroundColor3 = Color3.fromRGB(255, 255, 255),
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            LayoutOrder = 2,
            Parent = Window.Header,
            Size = UDim2.new(1, 0, 0, 70),
        }, {
            Window.SearchBar
        })
    end

    Window.ContainerHolder = New("ScrollingFrame", {
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        CanvasSize = UDim2.new(0, 0, 0, 0),
        ElasticBehavior = Enum.ElasticBehavior.Always,
        ScrollBarThickness = 0,
        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
        BackgroundTransparency = 1,
        ClipsDescendants = false,
        Size = UDim2.new(1, 0, 1, 0),
        ZIndex = 0,
    }, {
        New("UIListLayout", {
            Padding = UDim.new(0, 0),
            SortOrder = Enum.SortOrder.LayoutOrder
        }),
        Window.Header,
        Window.Footer
    })

    Window.TabContainer = New("Frame", {
        BackgroundColor3 = Color3.fromRGB(49, 47, 57),
        ClipsDescendants = true,
        Size = UDim2.new(0, Config.ContainerWidth or 400, 1, 0),
        Position = UDim2.new(0, -Window.SidebarWidth - Window.TabWidth, 0, 0),
    }, {
        Window.Fade,
        Window.ContainerHolder
    })

    Window.Root = New("Frame", {
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 1, 0),
        Position = UDim2.new(0, 0, 0, 0),
        Parent = Config.Parent,
    })

    Window.Top = require("./top")({
        Title = Config.Top.Title,
        Description = Config.Top.Description,
        Icon = Config.Top.Logo,
        User = Config.Top.User,
        Parent = Window.Root,
        Window = Window
    })

    Window.Main = New("Frame", {
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 1, -Window.Top.Root.Size.Y.Offset),
        Position = UDim2.new(0, 0, 0, Window.Top.Root.Size.Y.Offset),
        Parent = Window.Root,
        BackgroundColor3 = Color3.new(0, 0, 0)
    }, {
        Window.Sidebar,
        Window.TabContainer,
    })

    function Window:Destroy()
        Window.Root:Destroy()
    end

    local TabModule = require("./tab"):Init(Window)
    function Window:AddTab(TabConfig)
        return TabModule:New(TabConfig.Title, TabConfig.Icon, Window.TabHolder)
    end

    function Window:SelectTab(Tab)
        TabModule:SelectTab(Tab)
    end

    Window.SidebarWidth = Window.Sidebar.Size.X.Offset
    Window.TabWidth = Window.TabContainer.Size.X.Offset

    function Window:ToggleVisibility()
        self.State = not self.State
        if self.State then
            Tween.Plays(Window, {
                Main = { Props = { BackgroundTransparency = 0.5 } },
                Sidebar = { Props = { Position = UDim2.new(0, 0, 0, 0) } },
                TabContainer = { Props = { Position = UDim2.new(0, Window.SidebarWidth, 0, 0) } }
            }, {}, { Duration = 0.5 })
        else
            Tween.Plays(Window, {
                Main = { Props = { BackgroundTransparency = 1 } },
                Sidebar = { Props = { Position = UDim2.new(0, -Window.SidebarWidth, 0, 0) } },
                TabContainer = { Props = { Position = UDim2.new(0, -Window.SidebarWidth - Window.TabWidth, 0, 0) } }
            }, {}, { Duration = 0.2 })
        end
        return self.State
    end

    game:GetService("UserInputService").InputBegan:Connect(function(input, gameProcessedEvent)
        if gameProcessedEvent then return end

        if input.KeyCode == Window.Keybind then
            Window:ToggleVisibility()
        end
    end)

    Window:ToggleVisibility()
    return Window
end
