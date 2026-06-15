local Creator = require("../modules/creator")

local Element = {}
Element.__index = Element
Element.__type = "Paragraph"

function Element:New(Config)
    assert(Config.Title, "Paragraph - Missing Title")
    local Paragraph = require("../components/element")(Config.Title, self.Container, false)

    Paragraph.Root.BackgroundTransparency = Creator.GetThemeProperty("ParagraphTransparency")
    Paragraph.Root.BackgroundColor3 = Creator.GetThemeProperty("Paragraph")
    Paragraph.Title.FontFace = Font.new("rbxassetid://11702779409", Enum.FontWeight.SemiBold, Enum.FontStyle.Normal)
    Paragraph.Title.TextColor3 = Creator.GetThemeProperty("ParagraphText")
    Paragraph.LabelHolder.Size = UDim2.new(1, -20, 0, 0)

    Creator.AddThemeObject(Paragraph.Root, {
        BackgroundColor3 = "Paragraph",
    })

    Creator.AddThemeObject(Paragraph.Title, {
        TextColor3 = "ParagraphText",
    })

    return Paragraph
end

return Element
