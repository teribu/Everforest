local Creator = require("../modules/creator")
local Tween = require("../modules/tween")

local New = Creator.New
local AddSignal = Creator.AddSignal

local Element = {}
Element.__index = Element
Element.__type = "Dropdown"

function Element:New(Flag, Config)
    local Library = self.Library

    local Dropdown = {
        Library = Library,
        Options = Config.Options or {},
        Value = Config.Default,
        Multi = Config.Multi,
        Buttons = {
            TotalButtons = 0
        },
        Opened = false,
        Type = "Dropdown",
        DropdownOpenHeight = Config.DropdownOpenHeight or 200,
        Callback = Config.Callback or function() end,
    }

    if Dropdown.Multi then
        local NewValue = {}
        for _, value in Dropdown.Options do
            NewValue[value] = Dropdown.Value[value] and true or table.find(Dropdown.Value, value) and true or false
        end

        Dropdown.Value = NewValue
    end

    local DropdownScroll = New("ScrollingFrame", {
        CanvasSize = UDim2.new(0, 0, 0, 0),
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
        AnchorPoint = Vector2.new(0.5, 0.5),
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        Size = UDim2.new(1, -16, 1, -16),
        Position = UDim2.new(0.5, 0, 0.5, 0),
        ScrollBarThickness = 0,
        ClipsDescendants = true,
        BackgroundTransparency = 1,
        Visible = false
    }, {
        New("UIListLayout", {
            Padding = UDim.new(0, 2),
            SortOrder = Enum.SortOrder.LayoutOrder,
        })
    })

    local DropdownContainer = New("Frame", {
        BackgroundColor3 = Color3.fromRGB(45, 43, 52),
        Size = UDim2.new(1, 0, 0, 0),
        Position = UDim2.new(0, 0, 0, 6),
        LayoutOrder = 1
    }, {
        DropdownScroll,
        New("UICorner", {
            CornerRadius = UDim.new(0, 5)
        }),
        New("UIStroke", {
            Thickness = 1.6,
            Transparency = 1,
            ThemeTag = {
                Color = "DropdownBorder"
            }
        })
    })

    local DropdownFrame = New("Frame", {
        BackgroundColor3 = Color3.fromRGB(45, 43, 52),
        AutomaticSize = Enum.AutomaticSize.Y,
        Size = UDim2.new(1, 0, 0, 60),
        BackgroundTransparency = 1,
        Parent = self.Container
    }, {
        DropdownContainer,
        New("UIListLayout", {
            SortOrder = Enum.SortOrder.LayoutOrder,
        })
    })

    local DropdownTop = require("../components/element")(Config.Title, DropdownFrame, true,
        function() return not Dropdown.Opened end)
    DropdownTop.LabelHolder.Size = UDim2.new(1, -20, 0, 0)

    local DropdownText = New("TextLabel", {
        Text = "None",
        RichText = true,
        TextSize = 18,
        TextWrapped = true,
        FontFace = Font.new("rbxassetid://11702779409", Enum.FontWeight.Medium, Enum.FontStyle.Normal),
        TextXAlignment = Enum.TextXAlignment.Left,
        AutomaticSize = Enum.AutomaticSize.Y,
        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
        BackgroundTransparency = 1,
        Size = UDim2.new(1, -50, 0, 0),
        ThemeTag = {
            TextColor3 = "DropdownText"
        }
    })

    local DropdownHeader = New("Frame", {
        AutomaticSize = Enum.AutomaticSize.Y,
        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
        BackgroundTransparency = 1,
        LayoutOrder = 1,
        Position = UDim2.new(0, 10, 0, 26),
        Size = UDim2.new(1, -5, 0, 18),
        Parent = DropdownTop.LabelHolder
    }, {
        DropdownText,
        New("ImageLabel", {
            AnchorPoint = Vector2.new(1, 0.5),
            BackgroundColor3 = Color3.fromRGB(255, 255, 255),
            BackgroundTransparency = 1,
            Position = UDim2.new(1, 0, 0.5, 0),
            Size = UDim2.new(0, 16, 0, 16),
            ThemeTag = {
                ImageColor3 = "DropdownImage",
                Image = "DropdownImageId"
            }
        })
    })

    Dropdown.SetTitle = DropdownTop.SetTitle

    function Dropdown:OnChanged(Func)
        Dropdown.Changed = Func
        Func(Dropdown.Value)
    end

    function Dropdown:UpdateValue()
        if #self.Options == self.Buttons.TotalButtons then
            for value, button in self.Buttons do
                if type(button) == "table" then
                    local isSelected = false
                    if self.Multi then
                        isSelected = self.Value[value] == true
                    else
                        isSelected = self.Value == value
                    end

                    button.Value = isSelected

                    if button.Tweens.Frame then button.Tweens.Frame:Cancel() end
                    if button.Tweens.Arrow then button.Tweens.Arrow:Cancel() end

                    button.Tweens.Frame = Tween.Play(button.Frame, {
                        BackgroundColor3 = Creator.GetThemeProperty("Item"),
                        BackgroundTransparency = isSelected and 0 or 1
                    })
                    button.Tweens.Arrow = Tween.Play(button.Arrow, {
                        ImageTransparency = isSelected and 0 or 1
                    })
                end
            end
        else
            for key, button in self.Buttons do
                if type(button) == "table" and button.Destroy then
                    button:Destroy()
                end
                self.Buttons[key] = nil
            end

            self.Buttons = {
                TotalButtons = 0
            }

            for _, value in self.Options do
                self.Buttons.TotalButtons = self.Buttons.TotalButtons + 1

                local isSelected = false
                if self.Multi then
                    isSelected = self.Value[value] == true
                else
                    isSelected = self.Value == value
                end

                self.Buttons[value] = {
                    Value = isSelected,
                    Connections = {},
                    Tweens = {}
                }

                local button = self.Buttons[value]

                button.Button = New("TextButton", {
                    Font = Enum.Font.SourceSans,
                    Text = "",
                    TextSize = 14,
                    BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 1, 0)
                })

                button.Arrow = New("ImageLabel", {
                    Image = "rbxassetid://120679435135651",
                    AnchorPoint = Vector2.new(0, 0.5),
                    BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                    BackgroundTransparency = 1,
                    Position = UDim2.new(0, 6, 0.5, 0),
                    Rotation = -90,
                    Size = UDim2.new(0, 10, 0, 10),
                    ImageTransparency = isSelected and 0 or 1,
                    ThemeTag = {
                        ImageColor3 = "ItemHoldArrow"
                    }
                })

                button.Title = New("TextLabel", {
                    FontFace = Font.new("rbxassetid://11702779409", Enum.FontWeight.Medium, Enum.FontStyle.Normal),
                    TextSize = 16,
                    TextWrapped = true,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    TextYAlignment = Enum.TextYAlignment.Top,
                    AutomaticSize = Enum.AutomaticSize.Y,
                    BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                    BackgroundTransparency = 1,
                    LayoutOrder = 1,
                    Position = UDim2.new(0, 20, 0, 0),
                    Size = UDim2.new(1, -30, 0, 0),
                    Text = tostring(value),
                    ThemeTag = {
                        TextColor3 = "ItemText"
                    }
                }, {
                    New("UIPadding", {
                        PaddingBottom = UDim.new(0, 4),
                        PaddingTop = UDim.new(0, 4)
                    })
                })

                button.Frame = New("Frame", {
                    LayoutOrder = self.Buttons.TotalButtons,
                    Size = UDim2.new(1, 0, 0, 24),
                    AutomaticSize = Enum.AutomaticSize.Y,
                    Parent = DropdownScroll,
                    BackgroundTransparency = isSelected and 0 or 1,
                    ThemeTag = {
                        BackgroundColor3 = "Item"
                    }
                }, {
                    button.Button,
                    button.Title,
                    button.Arrow,
                    New("UICorner", {
                        CornerRadius = UDim.new(0, 5)
                    })
                })

                table.insert(button.Connections, AddSignal(button.Frame.MouseEnter, function()
                    if button.Tweens.Frame then button.Tweens.Frame:Cancel() end
                    if button.Tweens.Arrow then button.Tweens.Arrow:Cancel() end

                    button.Tweens.Frame = Tween.Play(button.Frame, {
                        BackgroundColor3 = Creator.GetThemeProperty("ItemHold"),
                        BackgroundTransparency = 0
                    })
                    button.Tweens.Arrow = Tween.Play(button.Arrow, {
                        ImageTransparency = 0,
                    })
                end))

                table.insert(button.Connections, AddSignal(button.Frame.MouseLeave, function()
                    local currentlySelected = false
                    if self.Multi then
                        currentlySelected = self.Value[value] == true
                    else
                        currentlySelected = self.Value == value
                    end

                    if button.Tweens.Frame then button.Tweens.Frame:Cancel() end
                    if button.Tweens.Arrow then button.Tweens.Arrow:Cancel() end

                    button.Tweens.Frame = Tween.Play(button.Frame, {
                        BackgroundColor3 = Creator.GetThemeProperty("Item"),
                        BackgroundTransparency = currentlySelected and 0 or 1
                    })
                    button.Tweens.Arrow = Tween.Play(button.Arrow, {
                        ImageTransparency = currentlySelected and 0 or 1,
                    })
                end))

                table.insert(button.Connections, AddSignal(button.Button.Activated, function()
                    if DropdownTop.SoundClick then DropdownTop.SoundClick:Play() end
                    if self.Multi then
                        self.Value[value] = not self.Value[value] or nil
                        self:SetValue(self.Value)
                    else
                        Dropdown.Opened = false

                        Tween.Plays(DropdownContainer, {
                            { Props = { Size = UDim2.new(1, 0, 0, 0) } },
                            UIStroke = { Props = { Transparency = 1 } }
                        }, { Duration = 0.15 })

                        Tween.Play(DropdownFrame.UIListLayout, {
                            Padding = UDim.new(0, 0)
                        }, { Duration = 0.15 })

                        local closeTween = Tween.Play(DropdownTop.Border, {
                            Color = Creator.GetThemeProperty("ElementBorder")
                        }, { Duration = 0.15 })
                        AddSignal(closeTween.Completed, function()
                            DropdownScroll.Visible = false
                        end)

                        DropdownTop.Hoving = false
                        Tween.Plays(DropdownTop, {
                            Fade = { Props = { BackgroundTransparency = 1 } },
                            Border = { Props = { Transparency = 1 }, Condition = Element.Condition }
                        }, { EasingStyle = "Quad" })

                        self:SetValue(value)
                    end
                end))

                function button:Destroy()
                    if button.Connections then
                        for i = 1, #button.Connections do
                            Creator.RemoveSignal(button.Connections[i])
                        end
                    end
                    if button.Tweens then
                        for _, tween in button.Tweens do
                            if tween then tween:Cancel() end
                        end
                    end
                    if button.Frame then button.Frame:Destroy() end
                end
            end
        end

        if self.Multi then
            local selectedItems = {}
            for k, v in self.Value do
                if table.find(self.Options, k) and v == true then
                    table.insert(selectedItems, tostring(k))
                end
            end

            DropdownText.Text = #selectedItems > 0 and table.concat(selectedItems, ", ") or "None"
        else
            DropdownText.Text = tostring(self.Value or "None")
        end
    end

    function Dropdown:SetValue(Value)
        if self.Multi then
            local NewValue = {}
            for _, value in self.Options do
                NewValue[value] = self.Value[value] and true or table.find(self.Value, value) and true or false
            end

            self.Value = NewValue
        else
            self.Value = table.find(self.Options, Value) and Value or self.Value
        end

        self:UpdateValue()

        Library:SafeCallback(self.Callback, self.Value)
        Library:SafeCallback(self.Changed, self.Value)
    end

    function Dropdown:Destroy()
        if DropdownFrame then DropdownFrame:Destroy() end
        if self.Buttons then
            for key, button in self.Buttons do
                if type(button) == "table" and button.Destroy then
                    button:Destroy()
                end
                self.Buttons[key] = nil
            end
        end
        Library.Options[Flag] = nil
    end

    Dropdown:UpdateValue()

    AddSignal(DropdownTop.Button.Activated, function()
        if DropdownTop.SoundClick then DropdownTop.SoundClick:Play() end
        Dropdown.Opened = not Dropdown.Opened

        if Dropdown.Opened then
            DropdownScroll.Visible = true
            Tween.Play(DropdownFrame.UIListLayout, {
                Padding = UDim.new(0, 6)
            }, { Duration = 0.15 })

            Tween.Plays(DropdownContainer, {
                { Props = { Size = UDim2.new(1, 0, 0, Dropdown.DropdownOpenHeight) } },
                UIStroke = { Props = { Transparency = 0 } }
            }, { Duration = 0.15 })

            Tween.Play(DropdownTop.Border, {
                Color = Creator.GetThemeProperty("DropdownBorder")
            }, { Duration = 0.15 })
        else
            Tween.Plays(DropdownContainer, {
                { Props = { Size = UDim2.new(1, 0, 0, 0) } },
                UIStroke = { Props = { Transparency = 1 } }
            }, { Duration = 0.15 })

            Tween.Play(DropdownFrame.UIListLayout, {
                Padding = UDim.new(0, 0)
            }, { Duration = 0.15 })

            local closeTween = Tween.Play(DropdownTop.Border, {
                Color = Creator.GetThemeProperty("ElementBorder")
            }, { Duration = 0.15 })
            AddSignal(closeTween.Completed, function()
                DropdownScroll.Visible = false
            end)
        end
    end)

    Library.Options[Flag] = Dropdown
    return Dropdown
end

return Element
