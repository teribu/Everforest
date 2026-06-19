while not game:IsLoaded() do
    task.wait()
end

task.wait(3)

local Everforest = require(game:GetService("ReplicatedStorage"):WaitForChild("Everforest"))

local Window = Everforest:CreateWindow({
    Top = {
        Title = "Everforest",
        Description = "Powerful scripting utility",
        User = {
            Icon = "rbxassetid://138895252616906",
            Name = game.Players.LocalPlayer.Name
        }
    },
    PageHeader = {
        Title = "settings",
        Description = "configure your preferences while using Everforest",
        SearchBar = {
            Enabled = true,
            Placeholder = "type to search...",
            Icon = "rbxassetid://89922969033534"
        },
    },
    Footer = {
        Title = "everforest",
        Description = "v" .. Everforest.Version .. " " .. os.date("%Y.%m.%d"),
    },
    Theme = "Dark",
    TabWidth = 200,
    Keybind = Enum.KeyCode.LeftControl,
    ContainerWidth = 400
})

local Tabs = {
    General = Window:AddTab({
        Title = "General",
        Icon = "rbxassetid://112616282616371"
    }),
    Skin = Window:AddTab({
        Title = "Skin",
        Icon = "rbxassetid://102121848363393"
    }),
    Input = Window:AddTab({
        Title = "Input",
        Icon = "rbxassetid://100161629948232"
    })
}

do
    Everforest:Notify({
        Title = "Everforest initializing, Please wait...",
        Duration = 5,
    })
end

do
    Tabs.General:AddSection({
        Title = "Core Settings"
    })

    local Elements = {
        AutoUpdate = Tabs.General:AddToggle("AutoUpdate", {
            Title = "Auto Update",
            Default = true
        }),

        DebugMode = Tabs.General:AddToggle("DebugMode", {
            Title = "Debug Mode",
            Default = false
        }),

        Notifications = Tabs.General:AddToggle("Notifications", {
            Title = "Notifications",
            Default = true
        }),

        Volume = Tabs.General:AddSlider("Volume", {
            Title = "Volume",
            Min = 0,
            Max = 100,
            Default = 50,
            Suffix = "%"
        }),

        FPSCap = Tabs.General:AddSlider("FPSCap", {
            Title = "FPS Cap",
            Min = 30,
            Max = 240,
            Default = 144
        }),

        Language = Tabs.General:AddDropdown("Language", {
            Title = "Language",
            Options = {
                "English",
                "Tiếng Việt",
                "日本語",
                "한국어"
            },
            Default = "English"
        }),

        Permissions = Tabs.General:AddDropdown("Permissions", {
            Title = "Permissions",
            Options = {
                "Read",
                "Write",
                "Execute",
                "Delete",
                "Admin"
            },
            Default = {
                "Read",
                "Write"
            },
            Multi = true
        }),

        Username = Tabs.General:AddInput("Username", {
            Title = "Display Name",
            Placeholder = "Enter display name...",
            Default = tostring(game.Players.LocalPlayer.Name)
        })
    }

    Elements.AutoUpdate:OnChanged(function(v)
        print("[ General ] AutoUpdate:", v)
    end)

    Elements.DebugMode:OnChanged(function(v)
        print("[ General ] DebugMode:", v)
    end)

    Elements.Notifications:OnChanged(function(v)
        print("[ General ] Notifications:", v)
    end)

    Elements.Volume:OnChanged(function(v)
        print("[ General ] Volume:", v)
    end)

    Elements.FPSCap:OnChanged(function(v)
        print("[ General ] FPSCap:", v)
    end)

    Elements.Language:OnChanged(function(v)
        print("[ General ] Language:", v)
    end)

    Elements.Permissions:OnChanged(function(v)
        print("[ General ] Permissions:")

        for Permission, Bool in v do
            print(" -", Permission .. ":", Bool)
        end
    end)

    Elements.Username:OnChanged(function(v)
        print("[ General ] Username:", v)
    end)

    Tabs.General:AddButton({
        Title = "Check For Updates",
        Callback = function()
            print("[ General ] Checking updates...")
        end
    })

    Tabs.General:AddButton({
        Title = "Restore Defaults",
        Callback = function()
            print("[ General ] Restored defaults")
        end
    })
end


do
    Tabs.Skin:AddSection({
        Title = "Visual Configuration"
    })

    local Elements = {
        Theme = Tabs.Skin:AddDropdown("Theme", {
            Title = "Theme",
            Options = {
                "Dark",
                "Light",
                "Everforest",
                "Nord",
                "Tokyo Night",
                "Catppuccin"
            },
            Default = "Dark"
        }),

        Accent = Tabs.Skin:AddDropdown("Accent", {
            Title = "Accent Color",
            Options = {
                "Green",
                "Blue",
                "Red",
                "Purple",
                "Orange",
                "Pink"
            },
            Default = "Green"
        }),

        Opacity = Tabs.Skin:AddSlider("Opacity", {
            Title = "Window Opacity",
            Min = 0,
            Max = 1,
            Default = 0.9,
            Increment = 0.1
        }),

        UIScale = Tabs.Skin:AddSlider("UIScale", {
            Title = "UI Scale",
            Min = 50,
            Max = 150,
            Default = 100,
            Suffix = "%"
        }),

        Blur = Tabs.Skin:AddToggle("Blur", {
            Title = "Background Blur",
            Default = true
        }),

        Animations = Tabs.Skin:AddToggle("Animations", {
            Title = "Enable Animations",
            Default = true
        }),

        RoundedCorners = Tabs.Skin:AddToggle("RoundedCorners", {
            Title = "Rounded Corners",
            Default = true
        })
    }

    Elements.Theme:OnChanged(function(v)
        print("[ Skin ] Theme:", v)
    end)

    Elements.Accent:OnChanged(function(v)
        print("[ Skin ] Accent:", v)
    end)

    Elements.Opacity:OnChanged(function(v)
        print("[ Skin ] Opacity:", v)
    end)

    Elements.UIScale:OnChanged(function(v)
        print("[ Skin ] UIScale:", v)
    end)

    Elements.Blur:OnChanged(function(v)
        print("[ Skin ] Blur:", v)
    end)

    Elements.Animations:OnChanged(function(v)
        print("[ Skin ] Animations:", v)
    end)

    Elements.RoundedCorners:OnChanged(function(v)
        print("[ Skin ] RoundedCorners:", v)
    end)

    Tabs.Skin:AddButton({
        Title = "Preview Theme",
        Callback = function()
            print("[ Skin ] Preview Theme")
        end
    })

    Tabs.Skin:AddButton({
        Title = "Reset Skin",
        Callback = function()
            print("[ Skin ] Reset Skin")
        end
    })
end


do
    Tabs.Input:AddSection({
        Title = "Keybinds & Controls"
    })

    local Elements = {
        BindKey = Tabs.Input:AddInput("BindKey", {
            Title = "Toggle UI Key",
            Placeholder = "Insert",
            Default = "Insert"
        }),

        PanicKey = Tabs.Input:AddInput("PanicKey", {
            Title = "Panic Key",
            Placeholder = "End",
            Default = "End"
        }),

        OpenMenuKey = Tabs.Input:AddInput("OpenMenuKey", {
            Title = "Open Menu Key",
            Placeholder = "Home",
            Default = "Home"
        }),

        ShiftLock = Tabs.Input:AddToggle("ShiftLock", {
            Title = "Force ShiftLock",
            Default = false
        }),

        InvertMouse = Tabs.Input:AddToggle("InvertMouse", {
            Title = "Invert Mouse",
            Default = false
        }),

        MouseSensitivity = Tabs.Input:AddSlider("MouseSensitivity", {
            Title = "Mouse Sensitivity",
            Min = 1,
            Max = 20,
            Default = 10
        }),

        InputMode = Tabs.Input:AddDropdown("InputMode", {
            Title = "Input Mode",
            Options = {
                "Keyboard",
                "Controller",
                "Touch"
            },
            Default = "Keyboard"
        }),

        Devices = Tabs.Input:AddDropdown("Devices", {
            Title = "Allowed Devices",
            Options = {
                "Keyboard",
                "Mouse",
                "Controller",
                "Touch",
                "VR"
            },
            Default = {
                "Keyboard",
                "Mouse"
            },
            Multi = true
        })
    }

    Elements.BindKey:OnChanged(function(v)
        print("[ Input ] BindKey:", v)
    end)

    Elements.PanicKey:OnChanged(function(v)
        print("[ Input ] PanicKey:", v)
    end)

    Elements.OpenMenuKey:OnChanged(function(v)
        print("[ Input ] OpenMenuKey:", v)
    end)

    Elements.ShiftLock:OnChanged(function(v)
        print("[ Input ] ShiftLock:", v)
    end)

    Elements.InvertMouse:OnChanged(function(v)
        print("[ Input ] InvertMouse:", v)
    end)

    Elements.MouseSensitivity:OnChanged(function(v)
        print("[ Input ] MouseSensitivity:", v)
    end)

    Elements.InputMode:OnChanged(function(v)
        print("[ Input ] InputMode:", v)
    end)

    Elements.Devices:OnChanged(function(v)
        print("[ Input ] Devices:")

        for Devices, Bool in v do
            print(" -", Devices .. ":", Bool)
        end
    end)

    Tabs.Input:AddButton({
        Title = "Save Configuration",
        Callback = function()
            print("[ Input ] Saved")
        end
    })

    Tabs.Input:AddButton({
        Title = "Load Configuration",
        Callback = function()
            print("[ Input ] Loaded")
        end
    })

    Tabs.Input:AddButton({
        Title = "Reset Keybinds",
        Callback = function()
            print("[ Input ] Reset Keybinds")
        end
    })
end

task.delay(1, function()
    Everforest:Notify({
        Title = "Everforest initialized, thanks for using the script!",
        Duration = 5,
    })
end)
