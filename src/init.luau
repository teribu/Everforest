local RunService = game:GetService("RunService")
local LocalPlayer = game:GetService("Players").LocalPlayer

local Creator = require(script.modules.creator)
local ElementsTable = require(script.elements)
local NotificationModule = require(script.components.notification)

local New = Creator.New

local ProtectGui = protectgui or (syn and syn.protect_gui) or function() end
local GUI = New("ScreenGui", {
    Parent = RunService:IsStudio() and LocalPlayer.PlayerGui or game:GetService("CoreGui"),
    IgnoreGuiInset = true,
})

ProtectGui(GUI)
NotificationModule:Init(GUI)

local Library = {
    Version = "1.0.0",
    Window = nil,
    Options = {},
    Themes = require(script.themes).Names,
    Theme = "Dark",
    GUI = GUI,
}

function Library:SafeCallback(Function, ...)
    if not Function then
        return
    end

    local Success, Event = pcall(Function, ...)
    if not Success then
        local _, i = Event:find(":%d+: ")

        if not i then
            return Library:Notify({
                Title = "Callback error: " .. Event,
                Duration = 5,
            })
        end

        return Library:Notify({
            Title = "Callback error: " .. Event:sub(i + 1),
            Duration = 5,
        })
    end
    return Success
end

function Library:MergeDictionaries(Default, User)
    if not User then return Default end
    local Result = {}
    for Key, Value in Default do
        if type(Value) == "table" and type(User[Key]) == "table" then
            Result[Key] = self:MergeDictionaries(Value, User[Key])
        else
            Result[Key] = User[Key] ~= nil and User[Key] or Value
        end
    end

    for Key, Value in User do
        if Result[Key] == nil then
            Result[Key] = Value
        end
    end
    return Result
end

local Icons = require(script.modules.icons).assets
function Library:GetIcon(Name)
    return Name ~= nil and Icons["lucide-" .. Name] or nil
end

local Elements = {}
Elements.__index = Elements
Elements.__namecall = function(Table, Key, ...)
    return Elements[Key](...)
end

for _, ElementComponent in ElementsTable do
    Elements["Add" .. ElementComponent.__type] = function(self, Flag, Config)
        ElementComponent.Container = self.Container
        ElementComponent.Type = self.Type
        ElementComponent.Library = Library

        return ElementComponent:New(Flag, Config)
    end
end

Library.Elements = Elements

function Library:CreateWindow(Config)
    if Library.Window then
        warn("You cannot create more than one window.")
        return Library.Window
    end

    Library.Theme = Config.Theme or "Dark"

    local DefaultTop = {
        Title = "Everforest",
    }

    local DefaultHeader = {
        Title = "settings",
    }

    local Window = require(script.components.window)({
        Parent = GUI,
        Top = self:MergeDictionaries(DefaultTop, Config.Top),
        Header = self:MergeDictionaries(DefaultHeader, Config.PageHeader),
        TabWidth = Config.TabWidth,
        Keybind = Config.Keybind,
        ContainerWidth = Config.ContainerWidth
    })

    Library.Window = Window
    Library:SetTheme(Config.Theme)

    return Window
end

function Library:SetTheme(Value)
    if Library.Window and table.find(Library.Themes, Value) then
        Library.Theme = Value
        Creator.UpdateTheme()
    end
end

function Library:Destroy()
    if Library.Window then
        Creator.Disconnect()
        Library.GUI:Destroy()
    end
end

function Library:Notify(Config)
    return NotificationModule:New(Config)
end

if getgenv then
    getgenv().Everforest = Library
end

return Library
