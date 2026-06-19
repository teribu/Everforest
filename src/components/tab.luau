local Creator = require("../modules/creator")
local Tween = require("../modules/tween")

local New = Creator.New
local AddSignal = Creator.AddSignal

local TabModule = {
    Window = nil,
    SelectedTab = 1,
    Tabs = {},
    Containers = {},
    Limits = {},
    IsAutoScrolling = false,
    TotalTabs = 0
}

local function IsPageRendered(PageRoot)
    return PageRoot and PageRoot.AbsoluteSize.Y > 0
end

function TabModule:New(Title, Icon, Parent)
    local Library = require("../")

    local Window = TabModule.Window
    local Elements = Library.Elements

    TabModule.TotalTabs = TabModule.TotalTabs + 1

    local Tab = {
        Selected = TabModule.TotalTabs == 1,
        Name = Title,
        Index = TabModule.TotalTabs,
        Type = "Tab",
        Navigation = {},
        Page = {}
    }

    local CheckedIcon = Library:GetIcon(Icon) or Icon
    if CheckedIcon == "" or CheckedIcon == nil then
        CheckedIcon = nil
    end

    local Navigation = Tab.Navigation
    local TabIndex = Tab.Index

    Navigation.Button = New("TextButton", {
        Text = "",
        BackgroundTransparency = 1,
        AnchorPoint = Vector2.new(0, 0),
        Position = UDim2.new(0, 0, 0, 0),
        Size = UDim2.new(1, 0, 1, 0)
    })

    Navigation.Indicator = New("Frame", {
        BackgroundTransparency = 1,
        AnchorPoint = Vector2.new(0, 0.5),
        Position = UDim2.new(0, 10, 0.5, 0),
        Size = UDim2.new(0, 1, 0, 14),
        ThemeTag = { BackgroundColor3 = "Indicator" }
    }, {
        New("UICorner", { CornerRadius = UDim.new(0, 10) }),
        New("UIStroke", { Thickness = 0.8, Transparency = 1, ThemeTag = { Color = "Indicator" } })
    })

    Navigation.Scaller = New("UIScale", { Scale = 1 })

    Navigation.Icon = New("ImageLabel", {
        Image = CheckedIcon or "",
        ImageTransparency = 0,
        AnchorPoint = Vector2.new(0, 0.5),
        Position = UDim2.new(0, 25, 0.5, 0),
        Size = UDim2.new(0, 20, 0, 20),
        Visible = CheckedIcon and true or false,
        ThemeTag = { ImageColor3 = "TabNotSelected" }
    })

    local TextPosition = CheckedIcon and 60 or 25

    Navigation.Title = New("TextLabel", {
        Text = Title,
        FontFace = Font.new("rbxassetid://12187365364", Enum.FontWeight.Regular, Enum.FontStyle.Normal),
        TextSize = 16,
        AutomaticSize = Enum.AutomaticSize.XY,
        AnchorPoint = Vector2.new(0, 0.5),
        Position = UDim2.new(0, TextPosition, 0.5, 0),
        Size = UDim2.new(0, 0, 1, 0),
        ThemeTag = { TextColor3 = "TabNotSelected" }
    })

    Navigation.Flash = New("Frame", {
        BackgroundTransparency = 1,
        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.new(0.5, 0, 0.5, 0),
        Size = UDim2.new(1, 0, 1, 0)
    }, {
        New("UICorner", { CornerRadius = UDim.new(0, 4) })
    })

    Navigation.Insider = New("Frame", {
        BackgroundTransparency = 1,
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.new(0.5, 0, 0.5, 0),
        Size = UDim2.new(1, 0, 1, 0),
        ThemeTag = { BackgroundColor3 = "TabHover" }
    }, {
        Navigation.Title,
        Navigation.Button,
        Navigation.Indicator,
        Navigation.Icon,
        Navigation.Flash,
        Navigation.Scaller,
        New("UICorner", { CornerRadius = UDim.new(0, 4) })
    })

    Navigation.SoundHover = New("Sound", { ThemeTag = { SoundId = "TabSoundHoverId", Volume = "TabSoundHoverVolume" } })
    Navigation.SoundClick = New("Sound", { ThemeTag = { SoundId = "TabSoundClickId", Volume = "TabSoundClickVolume" } })

    Navigation.Root = New("Frame", {
        BackgroundTransparency = 1,
        Parent = Parent,
        Size = UDim2.new(1, 0, 0, 36)
    }, {
        Navigation.Insider,
        Navigation.SoundHover,
        Navigation.SoundClick,
    })

    AddSignal(Navigation.Insider.MouseEnter, function()
        Tween.Play(Navigation.Insider, { Transparency = 0 })
        Navigation.SoundHover:Play()
    end)

    AddSignal(Navigation.Insider.MouseLeave, function()
        Tween.Play(Navigation.Insider, { Transparency = 1 })
    end)

    local NavButton = Navigation.Button
    local NavScaller = Navigation.Scaller
    local NavFlash = Navigation.Flash
    local SoundClick = Navigation.SoundClick

    AddSignal(NavButton.InputBegan, function(input)
        if input.UserInputType ~= Enum.UserInputType.MouseButton1 and input.UserInputType ~= Enum.UserInputType.Touch then return end
        local StartTime = os.clock()

        Tween.Play(NavScaller, { Scale = 0.92 }, { Duration = 2, EasingStyle = "Quad" })

        input.Changed:Wait()
        if input.UserInputState ~= Enum.UserInputState.End then return end

        local MousePos = input.Position
        local ButtonPos = NavButton.AbsolutePosition
        local ButtonSize = NavButton.AbsoluteSize

        local IsInside = (MousePos.X >= ButtonPos.X and MousePos.X <= ButtonPos.X + ButtonSize.X) and
            (MousePos.Y >= ButtonPos.Y and MousePos.Y <= ButtonPos.Y + ButtonSize.Y)

        local ClickTime = os.clock() - StartTime
        local TargetScale = (ClickTime >= 0.2) and 1.1 or 1.04
        Tween.Play(NavScaller, { Scale = TargetScale }, { Duration = 0.2, EasingStyle = "Quad" })

        if IsInside then
            SoundClick:Play()

            TabModule.IsAutoScrolling = true
            TabModule:SelectTab(TabIndex)

            NavFlash.BackgroundTransparency = 0.8
            Tween.Play(NavFlash, { Transparency = 1 }, { Duration = 0.3, EasingStyle = "Quad" })

            task.wait(0.1)
        end

        Tween.Play(NavScaller, { Scale = 1 }, { Duration = 0.1, EasingStyle = "Quad" })
    end)

    local Page = Tab.Page

    Page.Title = New("TextLabel", {
        TextSize = 30,
        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
        FontFace = Font.new([[rbxassetid://11702779409]], Enum.FontWeight.Regular, Enum.FontStyle.Normal),
        TextColor3 = Color3.fromRGB(255, 255, 255),
        BackgroundTransparency = 1,
        AnchorPoint = Vector2.new(0, 1),
        Text = Title,
        AutomaticSize = Enum.AutomaticSize.XY,
        Position = UDim2.new(0, 0, 1, -10)
    })

    Page.Header = New("Frame", {
        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
        Size = UDim2.new(1, 0, 0, 70),
        Position = UDim2.new(0, 0, 0, 2),
        BorderColor3 = Color3.fromRGB(0, 0, 0),
        LayoutOrder = 1,
        BackgroundTransparency = 1
    }, {
        Page.Title,
        New("UIPadding", {
            PaddingLeft = UDim.new(0, 15),
            PaddingRight = UDim.new(0, 15),
            PaddingTop = UDim.new(0, 0),
            PaddingBottom = UDim.new(0, 0),
        })
    })

    Page.Container = New("Frame", {
        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
        AutomaticSize = Enum.AutomaticSize.Y,
        Size = UDim2.new(1, 0, 0, 0),
        Position = UDim2.new(0, 0, 0, 70),
        LayoutOrder = 2,
        BackgroundTransparency = 1
    }, {
        New("UIListLayout", { Padding = UDim.new(0, 4), SortOrder = Enum.SortOrder.LayoutOrder }),
        New("UIPadding", {
            PaddingLeft = UDim.new(0, 17),
            PaddingRight = UDim.new(0, 15),
            PaddingTop = UDim.new(0, 0),
            PaddingBottom = UDim.new(0, 32),
        })
    })

    Page.Fade = New("Frame", {
        BackgroundColor3 = Color3.fromRGB(0, 0, 0),
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 0.8
    })

    Page.Button = New("TextButton", {
        TextSize = 14,
        TextColor3 = Color3.fromRGB(0, 0, 0),
        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
        FontFace = Font.new([[rbxasset://fonts/families/SourceSansPro.json]], Enum.FontWeight.Regular,
            Enum.FontStyle.Normal),
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 1, 0),
        Text = ""
    })

    Page.Root = New("Frame", {
        Size = UDim2.new(1, 0, 0, 90),
        BackgroundColor3 = Color3.fromRGB(49, 47, 57),
        AutomaticSize = Enum.AutomaticSize.Y,
        Parent = Window.ContainerHolder
    }, {
        Page.Header, Page.Container, Page.Fade, Page.Button,
        New("Frame", { BackgroundColor3 = Color3.fromRGB(24, 23, 28), Size = UDim2.new(1, 0, 0, 2) })
    })

    local PageFade = Page.Fade
    local PageButton = Page.Button

    AddSignal(PageFade.MouseEnter, function()
        if Tab.Selected then return end
        Tween.Play(PageFade, { Transparency = 0.9 }, { Duration = 0.2, EasingStyle = "Quad" })
    end)

    AddSignal(PageFade.MouseLeave, function()
        if Tab.Selected then return end
        Tween.Play(PageFade, { Transparency = 0.8 }, { Duration = 0.2, EasingStyle = "Quad" })
    end)

    AddSignal(PageButton.Activated, function()
        TabModule.IsAutoScrolling = true
        TabModule:SelectTab(TabIndex)
    end)

    if Tab.Selected then
        Tween.Plays(Tab.Navigation, {
            Indicator = {
                Props = { Size = UDim2.new(0, 1, 0, 14), BackgroundTransparency = 0 },
                UIStroke = { Props = { Thickness = 0.8, Transparency = 0 } }
            },
            Title = { Props = { TextColor3 = Creator.GetThemeProperty("TabSelected") }, Preset = { Duration = 0.1 } },
            Icon = { Props = { ImageColor3 = Creator.GetThemeProperty("TabSelected") }, Preset = { Duration = 0.1 } }
        }, { Duration = 0.2, EasingStyle = "Quad" })
        Tab.Page.Fade.Transparency = 1
        Tab.Page.Button.Visible = false
    end
    TabModule.Containers[TabIndex] = Page.Container
    TabModule.Tabs[TabIndex] = Tab
    TabModule.Limits[TabIndex] = Page.Root

    Tab.Container = Page.Container
    setmetatable(Tab, Elements)
    return Tab
end

function TabModule:SelectTab(Index)
    local Window = TabModule.Window
    local OldActiveIndex = TabModule.SelectedTab

    local Tab = TabModule.Tabs[Index]
    task.spawn(function()
        if not TabModule.IsAutoScrolling then return end
        local CurrentCanvasY = Window.ContainerHolder.CanvasPosition.Y
        local RelativeY = Tab.Page.Root.AbsolutePosition.Y - Window.ContainerHolder.AbsolutePosition.Y
        local TargetY = CurrentCanvasY + RelativeY - 70

        local ContainerTween = Tween.Play(Window.ContainerHolder, {
            CanvasPosition = Vector2.new(0, math.max(0, TargetY))
        }, { Duration = 0.5 })

        ContainerTween.Completed:Wait()
        TabModule.IsAutoScrolling = false
    end)


    if OldActiveIndex == Index then return end

    if OldActiveIndex and OldActiveIndex ~= Index then
        local SelectedTab = TabModule.Tabs[OldActiveIndex]
        if SelectedTab then
            Tween.Plays(SelectedTab.Navigation, {
                Indicator = {
                    Props = { Size = UDim2.new(0, 1, 0, 0), Transparency = 1 },
                    UIStroke = { Props = { Thickness = 0, Transparency = 1 } }
                },
                Title = { Props = { TextColor3 = Creator.GetThemeProperty("TabNotSelected") }, Preset = { Duration = 0.1 } },
                Icon = { Props = { ImageColor3 = Creator.GetThemeProperty("TabNotSelected") }, Preset = { Duration = 0.1 } }
            }, { Duration = 0.2, EasingStyle = "Quad" })
            SelectedTab.Page.Button.Visible = true
            Tween.Play(SelectedTab.Page.Fade, { Transparency = 0.8 }, { Duration = 0.2, EasingStyle = "Quad" })
            SelectedTab.Selected = false
        end
    end

    Tween.Plays(Tab.Navigation, {
        Indicator = {
            Props = { Size = UDim2.new(0, 1, 0, 14), BackgroundTransparency = 0 },
            UIStroke = { Props = { Thickness = 0.8, Transparency = 0 } }
        },
        Title = { Props = { TextColor3 = Creator.GetThemeProperty("TabSelected") }, Preset = { Duration = 0.1 } },
        Icon = { Props = { ImageColor3 = Creator.GetThemeProperty("TabSelected") }, Preset = { Duration = 0.1 } }
    }, { Duration = 0.2, EasingStyle = "Quad" })

    TabModule.SelectedTab = Index
    Tween.Play(Tab.Page.Fade, { Transparency = 1 }, { Duration = 0.2, EasingStyle = "Quad" })
    Tab.Page.Button.Visible = false

    Tab.Selected = true
    return Tab
end

function TabModule:Init(Window)
    TabModule.Window = Window

    local UpdateTabOnScroll = function()
        if TabModule.IsAutoScrolling then return end

        local Container = Window.ContainerHolder
        local CurrentY = Container.CanvasPosition.Y
        local HolderY = Container.AbsolutePosition.Y
        local ScrollThreshold = CurrentY + 75

        for Index = 1, TabModule.TotalTabs do
            local PageRoot = TabModule.Limits[Index]

            if IsPageRendered(PageRoot) then
                local PageTop = CurrentY + (PageRoot.AbsolutePosition.Y - HolderY) - 70
                local PageBottom = PageTop + PageRoot.AbsoluteSize.Y

                if ScrollThreshold >= PageTop and ScrollThreshold < PageBottom then
                    if TabModule.SelectedTab ~= Index then
                        TabModule:SelectTab(Index)
                    end
                    break
                end
            end
        end
    end

    AddSignal(Window.ContainerHolder:GetPropertyChangedSignal("CanvasPosition"), UpdateTabOnScroll)
    return TabModule
end

return TabModule
