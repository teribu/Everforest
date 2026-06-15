local Themes = {
    Names = { "Dark" }
}

for _, Theme in script:GetChildren() do
    local Required = require(Theme)
    Themes[Required.Name] = Required
end

return Themes
