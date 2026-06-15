local TweenService = game:GetService("TweenService")
local Creator = require("./creator")
local AddSignal = Creator.AddSignal

local Tween = {
    Presets = require("./presets"),
    InfoCache = {},
    RunningTweens = {}
}

function Tween.ParseEnum(EnumType, Value)
    if typeof(Value) == "EnumItem" then return Value end
    if type(Value) == "string" then
        local Success, Result = pcall(function() return Enum[EnumType][Value] end)
        if Success then return Result end
    end
    return Tween.Presets.Default[EnumType]
end

function Tween.GetTweenInfo(Preset)
    local CurrentPreset = type(Preset) == "table" and Preset or type(Preset) == "string" and Tween.Presets[Preset] or Tween.Presets.Default
    local Duration = tonumber(CurrentPreset.Duration) or Tween.Presets.Default.Duration
    local EasingStyle = Tween.ParseEnum("EasingStyle", CurrentPreset.EasingStyle)
    local EasingDirection = Tween.ParseEnum("EasingDirection", CurrentPreset.EasingDirection)

    if not Tween.InfoCache[Duration] then Tween.InfoCache[Duration] = {} end
    if not Tween.InfoCache[Duration][EasingStyle] then Tween.InfoCache[Duration][EasingStyle] = {} end
    if not Tween.InfoCache[Duration][EasingStyle][EasingDirection] then
        Tween.InfoCache[Duration][EasingStyle][EasingDirection] = TweenInfo.new(Duration, EasingStyle, EasingDirection)
    end
    return Tween.InfoCache[Duration][EasingStyle][EasingDirection]
end

function Tween.GetTransparencyProperty(Object)
    if Object:IsA("TextLabel") or Object:IsA("TextButton") or Object:IsA("TextBox") then return "TextTransparency" end
    if Object:IsA("ImageLabel") or Object:IsA("ImageButton") then return "ImageTransparency" end
    if Object:IsA("UIStroke") then return "Transparency" end
    return "BackgroundTransparency"
end

function Tween.Play(Object, Props, Preset, Callback)
    local FormattedProps = {}
    for Prop, Value in Props do
        local success = pcall(function() return Object[Prop] end)
        if success then
            if Prop == "Transparency" then FormattedProps[Tween.GetTransparencyProperty(Object)] = Value
            else FormattedProps[Prop] = Value end
        else
            warn("Tween Error: " .. Object.Name .. " không có thuộc tính " .. Prop)
        end
    end

    if next(FormattedProps) == nil then return nil end

    if Tween.RunningTweens[Object] and Tween.RunningTweens[Object].Props == FormattedProps then Tween.RunningTweens[Object].Tween:Cancel() end
    local TweenObject = TweenService:Create(Object, Tween.GetTweenInfo(Preset), FormattedProps)
    Tween.RunningTweens[Object] = { Tween = TweenObject, Props = FormattedProps }

    local Connection
    Connection = AddSignal(TweenObject.Completed, function(PlaybackState)
        Connection:Disconnect()
        if Tween.RunningTweens[Object] and Tween.RunningTweens[Object].Tween == TweenObject then Tween.RunningTweens[Object] = nil end
        if Callback and type(Callback) == "function" and PlaybackState == Enum.PlaybackState.Completed then
            Callback(PlaybackState)
        end
    end)
    TweenObject:Play()
    return TweenObject
end

function Tween._applyRecursive(Target, Structure, Props, Preset, Callback, Tweens)
    for Key, Value in Structure do
        if Key == "Props" or Key == "Preset" or Key == "Callback" or Key == "Delay" or Key == "Condition" then
            continue
        end
        local Target = type(Value) == "string" and ((Target.FindFirstChild and Target:FindFirstChild(Key)) or Target[Value]) or type(Key) == "string" and (Target.FindFirstChild and Target:FindFirstChild(Key) or Target[Key]) or type(Key) == "number" and Target
        local Props = Value.Props or Props
        local Preset = Value.Preset or Preset
        local Callback = Value.Callback or Callback
        if Target then
            task.delay(Value.Delay or 0, function()
                if Value.Condition and type(Value.Condition) == "function" and not Value.Condition() then return end
                table.insert(Tweens, Tween.Play(Target, Props, Preset, Callback))
            end)
        end
        if type(Key) == "string" and type(Value) == "table" then
            Tween._applyRecursive(Target, Value, Props, Preset, Callback, Tweens)
        end
    end
end

function Tween.Plays(Target, Structure, Props, Preset, Callback)
    local Tweens = {}

    if typeof(Target) == "Instance" or type(Target) == "table" then
        Tween._applyRecursive(Target, Structure, Props, Preset, Callback, Tweens)
    end

    return {
        Tweens = Tweens,
        Pause = function(self) for _, v in self.Tweens do v:Pause() end end,
        Cancel = function(self) for _, v in self.Tweens do v:Cancel() end end,
    }
end

return Tween
