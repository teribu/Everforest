local Elements = {}

for _, module in script:GetChildren() do
    if module:IsA("ModuleScript") and module ~= script then
        local element = require(module)
        Elements[element.__type] = element
    end
end

return Elements
