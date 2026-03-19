game:GetService("StarterGui"):SetCore("SendNotification", {
  Title = "因为你检测到可执行看片UI",
  Text = "正在启动UI",
  Icon = "rbxassetid://123691280552142",
  Duration = 1,
  Callback = bindable,
  Button1 = "谢谢使用",
  Button2 = "😘",
})
wait(1.5)
game:GetService("StarterGui"):SetCore("SendNotification", {
  Title = "祝你玩得开心",
  Text = "卡密：小西",
  Icon = "rbxassetid://123691280552142",
  Duration = 1,
  Callback = bindable,
  Button1 = "qq群：705378396",
  Button2 = "作者qq：3574769415",
})
local WindUI = loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"))()
local Window = WindUI:CreateWindow({
    Title = "私人UI",
    Icon = "rbxassetid://123691280552142",
    Author = "by小西制作",
    AuthorImage = 90840643379863,
    Folder = "CloudHub",
    Size = UDim2.fromOffset(560, 360),
    KeySystem = {
        Key = { "我爱大司马", "小西", "宇星辰", "阵雨眉目" }, 
        Note = "请输入卡密",
        SaveKey = false,
    },
    Transparent = true,
    Background = "video:https://raw.githubusercontent.com/xiaoxi9008/chesksks/refs/heads/main/video_260309_225716.mp4",
    User = {
            Enabled = true,
            Callback = function()
                WindUI:Notify({
                    Title = "点击了自己",
                    Content = "没什么", 
                    Duration = 1,
                    Icon = "4483362748"
                })
            end,
            Anonymous = false
        },
})

Window:EditOpenButton(
    {
        Title = "爸爸",
        Icon = "rbxassetid://123691280552142",
        CornerRadius = UDim.new(0, 13),
        StrokeThickness = 4,
        Color = ColorSequence.new({ColorSequenceKeypoint.new(0, Color3.fromRGB(186, 19, 19)),ColorSequenceKeypoint.new(1, Color3.fromRGB(8, 60, 129))}),
        Draggable = true
    }
)

function Tab(a)
    return Window:Tab({Title = a, Icon = "eye"})
end

function Button(a, b, c)
    return a:Button({Title = b, Callback = c})
end

function Toggle(a, b, c, d)
    return a:Toggle({Title = b, Value = c, Callback = d})
end

function Slider(a, b, c, d, e, f)
    return a:Slider({Title = b, Step = 1, Value = {Min = c, Max = d, Default = e}, Callback = f})
end

function Dropdown(a, b, c, d, e)
    return a:Dropdown({Title = b, Values = c, Value = d, Callback = e})
end

function Input(a, b, c, d, e, f)
    return a:Input({
        Title = b,
        Desc = c or "",
        Value = d or "",
        Placeholder = e or "",
        Callback = f
    })
end
