local Themes = require("../themes")

local Creator = {
    Registry = {},
    Signals = {},
    DefaultProperties = {
        ScreenGui = {
            ResetOnSpawn = false,
            ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
        },
        Frame = {
            BackgroundColor3 = Color3.new(1, 1, 1),
            BorderColor3 = Color3.new(0, 0, 0),
            BorderSizePixel = 0,
        },
        ScrollingFrame = {
            BackgroundColor3 = Color3.new(1, 1, 1),
            BorderColor3 = Color3.new(0, 0, 0),
            ScrollBarImageColor3 = Color3.new(0, 0, 0),
            ScrollingDirection = Enum.ScrollingDirection.Y
        },
        TextLabel = {
            BackgroundColor3 = Color3.new(1, 1, 1),
            BorderColor3 = Color3.new(0, 0, 0),
            Font = Enum.Font.SourceSans,
            Text = "",
            TextColor3 = Color3.new(0, 0, 0),
            BackgroundTransparency = 1,
            TextSize = 14,
        },
        TextButton = {
            BackgroundColor3 = Color3.new(1, 1, 1),
            BorderColor3 = Color3.new(0, 0, 0),
            AutoButtonColor = false,
            Font = Enum.Font.SourceSans,
            Text = "",
            TextColor3 = Color3.new(0, 0, 0),
            TextSize = 14,
        },
        TextBox = {
            BackgroundColor3 = Color3.new(1, 1, 1),
            BorderColor3 = Color3.new(0, 0, 0),
            ClearTextOnFocus = false,
            Font = Enum.Font.SourceSans,
            Text = "",
            TextColor3 = Color3.new(0, 0, 0),
            TextSize = 14,
        },
        ImageLabel = {
            BackgroundTransparency = 1,
            BackgroundColor3 = Color3.new(1, 1, 1),
            BorderColor3 = Color3.new(0, 0, 0),
            BorderSizePixel = 0,
        },
        ImageButton = {
            BackgroundColor3 = Color3.new(1, 1, 1),
            BorderColor3 = Color3.new(0, 0, 0),
            AutoButtonColor = false,
        },
        CanvasGroup = {
            BackgroundColor3 = Color3.new(1, 1, 1),
            BorderColor3 = Color3.new(0, 0, 0),
            BorderSizePixel = 0,
        },
    },
}

Creator.Registry = setmetatable({}, { __mode = "k" })
Creator.Signals = setmetatable({}, { __mode = "k" })

function Creator.AddSignal(Signal, Function)
    local Connection = Signal:Connect(Function)
    Creator.Signals[Connection] = true
    return Connection
end

function Creator.RemoveSignal(Connection)
    if Connection then
        if Connection.Connected then
            Connection:Disconnect()
        end
        Creator.Signals[Connection] = nil
    end
end

function Creator.Disconnect()
    for Connection in Creator.Signals do
        if Connection.Connected then
            Connection:Disconnect()
        end
    end
    Creator.Signals = setmetatable({}, { __mode = "k" })
end

function Creator.GetThemeProperty(Property)
    local ThemeName = require("../").Theme
    return Themes[ThemeName] and Themes[ThemeName][Property] or Themes["Dark"][Property]
end

function Creator.ApplyThemeProperty(Object, Prop, Value)
    Object[Prop] = Creator.GetThemeProperty(Value)
end

function Creator.UpdateTheme()
    for Object, ThemeTag in Creator.Registry do
        if Object and Object.Parent then
            for Prop, Value in ThemeTag do
                pcall(function()
                    Creator.ApplyThemeProperty(Object, Prop, Value)
                end)
            end
        end
    end
end

function Creator.AddThemeObject(Object, Properties)
    if not Creator.Registry[Object] then
        Creator.Registry[Object] = {}
    end

    for Property, Value in Properties do
        Creator.Registry[Object][Property] = Value
        pcall(function()
            Creator.ApplyThemeProperty(Object, Property, Value)
        end)
    end

    return Object
end

function Creator.New(Name, Properties, Children)
    local Object = Instance.new(Name)

    for Prop, Value in Creator.DefaultProperties[Name] or {} do
        Object[Prop] = Value
    end

    if Properties then
        local ThemeTag = Properties.ThemeTag

        for Prop, Value in Properties do
            if Prop ~= "ThemeTag" then
                Object[Prop] = Value
            end
        end

        if ThemeTag then
            local ClonedTags = {}
            for Prop, Value in ThemeTag do
                ClonedTags[Prop] = Value
                Creator.ApplyThemeProperty(Object, Prop, Value)
            end
            Creator.Registry[Object] = ClonedTags
        end
    end

    if Children then
        for _, Child in Children do
            if Child then
                Child.Parent = Object
            end
        end
    end

    return Object
end

return Creator
