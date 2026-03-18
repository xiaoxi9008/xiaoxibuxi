if _G.XION_Script_Loaded then
    _G.XION_Execution_Count = (_G.XION_Execution_Count or 0) + 1
    return
end

_G.XION_Script_Loaded = true
_G.XION_Execution_Count = 1
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

local Tabjb = Tab("其他")
local Tab5 = Tab("omg")

local player = game.Players.LocalPlayer

--=======姥爷司空别翻过头了===========
--=======姥爷司空别翻过头了===========
--=======姥爷司空别翻过头了===========
--=======姥爷司空别翻过头了===========
Button(Tabjb, "1", function() 
        FengYu_HUB = "第一个"
loadstring(game:HttpGet("https://raw.githubusercontent.com/xiaoxi9008/xiaoxibuxi/refs/heads/main/1.lua"))() 
end)

Button(Tabjb, "终极战场", function() 
        loadstring(game:HttpGet("https://raw.githubusercontent.com/xiaoxi9008/Xiaoxi/refs/heads/main/Kanl%E6%9C%80%E6%96%B0%E7%BB%88%E6%9E%81%E6%88%98%E5%9C%BA%E6%BA%90%E7%A0%81.lua"))() 
end)

Button(Tabjb, "偷走一粒红", function() 
        loadstring(game:HttpGet("https://raw.githubusercontent.com/xiaoxi9008/Xiaoxi/refs/heads/main/%E5%81%B7%E8%B5%B0%E8%84%91%E7%BA%A2.lua"))() 
end)

Button(Tabjb, "自然灾害", function() 
        loadstring(game:HttpGet("https://raw.githubusercontent.com/xiaoxi9008/Xiaoxi/refs/heads/main/%E8%87%AA%E7%84%B6%E7%81%BE%E5%AE%B3.lua"))() 
end)

Button(Tabjb, "99个森林夜", function() 
        loadstring(game:HttpGet("https://raw.githubusercontent.com/xiaoxi9008/Xiaoxi/refs/heads/main/99%E5%A4%9C.lua"))() 
end)

Button(Tabjb, "忍者传奇", function() 
        loadstring(game:HttpGet("https://raw.githubusercontent.com/xiaoxi9008/Xiaoxi/refs/heads/main/%E5%BF%8D%E8%80%85%E4%BC%A0%E5%A5%87.lua"))()
end)

Button(Tabjb, "种植花园", function() 
        Pikon_script = "by小西"
loadstring(game:HttpGet("https://raw.githubusercontent.com/xiaoxi9008/Xiaoxi/refs/heads/main/%E7%A7%8D%E6%A4%8D%E8%8A%B1%E5%9B%AD.lua"))()
end)

Button(Tabjb, "被遗弃", function() 
        loadstring(game:HttpGet("https://raw.githubusercontent.com/xiaoxi9008/Xiaoxi/refs/heads/main/%E8%A2%AB%E9%81%97%E5%BC%83.lua"))()
end)

Button(Tabjb, "doors", function() 
        loadstring(game:HttpGet("https://raw.githubusercontent.com/xiaoxi9008/Xiaoxi/refs/heads/main/doors.lua"))()
end)

Button(Tabjb, "墨水", function() 
        KG_SCRIPT = "卡密：小西nb"
loadstring(game:HttpGet("https://raw.githubusercontent.com/xiaoxi9008/Xiaoxi/refs/heads/main/moshui.lua"))()
end)

Button(Tabjb, "OhioV3未完善", function() 
        loadstring(game:HttpGet("https://raw.githubusercontent.com/xiaoxi9008/Xiaoxi/refs/heads/main/1.lua"))()
end)

Button(Tabjb, "OhioV2可以配的V3一起玩", function() 
        loadstring(game:HttpGet("https://raw.githubusercontent.com/xiaoxi9008/Xiaoxi/refs/heads/main/SX%E4%BF%84%E4%BA%A5%E4%BF%84%E5%B7%9EV5%E6%BA%90%E7%A0%81(1).lua"))() 
end)

Button(Tabjb, "NOL老版本", function() 
        loadstring(game:HttpGet("https://raw.githubusercontent.com/xiaoxi9008/Xiaoxi/refs/heads/main/NOL%E5%8A%A0%E8%BD%BD%E5%99%A8.lua"))()
end)

Button(Tabjb, "NOL提供的被遗弃Bug太多了", function() 
        loadstring(game:HttpGet("https://raw.githubusercontent.com/xiaoxi9008/Xiaoxi/refs/heads/main/NOL-%E4%BB%98%E8%B4%B9%E7%89%88%E6%9C%80%E6%96%B0%E6%BA%90%E7%A0%81.lua"))() 
end)
