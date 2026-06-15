local Creator = require("../modules/creator")

local New = Creator.New

local Element = {}
Element.__index = Element
Element.__type = "Section"

function Element:New(Config)
    assert(Config.Title, "Section - Missing Title")
    local Section = {}

    Section.Title = New("TextLabel", {
        FontFace = Font.new("rbxassetid://12187365364", Enum.FontWeight.Regular, Enum.FontStyle.Normal),
        Text = Config.Title,
        TextColor3 = Color3.fromRGB(255, 255, 255),
        TextSize = 22,
        TextWrapped = true,
        RichText = true,
        TextXAlignment = Enum.TextXAlignment.Left,
        AutomaticSize = Enum.AutomaticSize.Y,
        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
        BackgroundTransparency = 1,
        BorderColor3 = Color3.fromRGB(0, 0, 0),
        BorderSizePixel = 0,
        Position = UDim2.new(0, -2, 0, 13),
        Size = UDim2.new(1, 0, 0, 22)
    })

    Section.Root = New("Frame", {
        AutomaticSize = Enum.AutomaticSize.Y,
        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 45),
        Parent = self.Container
    }, {
        Section.Title,
        New("UIPadding", {
            PaddingBottom = UDim.new(0, 10)
        })
    })

    function Section:SetTitle(Title)
        Section.Title.Text = tostring(Title)
    end

    function Element:Destroy()
        Section.Root:Destroy()
    end

    return Section
end

return Element
