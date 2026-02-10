if _G.XION_Script_Loaded then
    _G.XION_Execution_Count = (_G.XION_Execution_Count or 0) + 1
    return
end

_G.XION_Script_Loaded = true
_G.XION_Execution_Count = 1

local WindUI = loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"))()
local Window = WindUI:CreateWindow({
    Title = "XIAOXI脚本",
    Icon = "crown",
    Author = "by小西制作",
    AuthorImage = 90840643379863,
    Folder = "CloudHub",
    Size = UDim2.fromOffset(560, 360),
    Transparent = true,
    User = {
        Enabled = true,
        Callback = function() 
            print("clicked") 
        end,
        Anonymous = true
    },
})

Window:EditOpenButton(
    {
        Title = "XIAOXI",
        Icon = "crown",
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

local Taba = Tab("首页")
local Tabjb = Tab("支持服务器")
local Tabb = Tab("设置")

local player = game.Players.LocalPlayer

Taba:Paragraph({
    Title = "系统信息",
    Desc = string.format("用户名: %s\n显示名: %s\n用户ID: %d\n账号年龄: %d天", 
        player.Name, player.DisplayName, player.UserId, player.AccountAge),
    Image = "info",
    ImageSize = 20,
    Color = Color3.fromHex("#0099FF")
})

local fpsCounter = 0
local fpsLastTime = tick()
local fpsText = "计算中..."

spawn(function()
    while wait() do
        fpsCounter += 1
        
        if tick() - fpsLastTime >= 1 then
            fpsText = string.format("%.1f FPS", fpsCounter) -- 显示一位小数
            fpsCounter = 0
            fpsLastTime = tick()
        end
    end
end)

Taba:Paragraph({
    Title = "性能信息",
    Desc = "帧率: " .. fpsText,
    Image = "bar-chart",
    ImageSize = 20,
    Color = Color3.fromHex("#00A2FF")
})

Taba:Paragraph({
    Title = "本人在此声明：封号与本脚本无关",
    Desc = [[ ]],
    Image = "eye",
    ImageSize = 24,
    Color = Color3.fromHex("#FFFFFF"),
    BackgroundTransparency = 1,
    OutlineColor = Color3.fromHex("#FFFFFF"),
    OutlineThickness = 1,
    Padding = UDim.new(0, 1)
})

Taba:Paragraph({
    Title = "此脚本为免费⭕钱和作者无关",
    Desc = [[ ]],
    Image = "eye",
    ImageSize = 24,
    Color = Color3.fromHex("#000000"),
    BackgroundColor3 = Color3.fromHex("#000000"),
    BackgroundTransparency = 0.2,
    OutlineColor = Color3.fromHex("#000000"),
    OutlineThickness = 1,
    Padding = UDim.new(0, 1)
})
Taba:Paragraph({
    Title = "计划50个服务器😋😋",
    Desc = [[ ]],
    Image = "eye",
    ImageSize = 24,
    Color = Color3.fromHex("#000000"),
    BackgroundTransparency = 1,
    OutlineColor = Color3.fromHex("#FFFFFF"),
    OutlineThickness = 1,
    Padding = UDim.new(0, 1)
})

--=======姥爷司空别翻过头了===========
--=======姥爷司空别翻过头了===========
--=======姥爷司空别翻过头了===========
--=======姥爷司空别翻过头了===========
Button(Tabjb, "点击此处复制小西私人qq以提供你的脚本", function()
    setclipboard("3574769415")
end)

Button(Tabjb, "殺脚本", function() 
        FengYu_HUB = "殺脚本"
loadstring(game:HttpGet("https://raw.githubusercontent.com/FengYu-3/FengYu/refs/heads/Feng/QQ1926190957"))()
end)

Button(Tabjb, "德与中山[免费版]", function() 
        loadstring(game:HttpGet("https://raw.githubusercontent.com/dream77239/Deyu-Zhongshan/refs/heads/main/%E5%BE%B7%E4%B8%8E%E4%B8%AD%E5%B1%B1.txt"))()
end)

Button(Tabjb, "点我复制免费版q群获取卡密", function()
    setclipboard("1040970564")
end)

Button(Tabjb, "皮脚本", function() 
        getgenv().XiaoPi="皮脚本QQ群1002100032" loadstring(game:HttpGet("https://raw.githubusercontent.com/xiaopi77/xiaopi77/main/QQ1002100032-Roblox-Pi-script.lua"))()
end)

Button(Tabjb, "xa", function() 
        loadstring(game:HttpGet("https://raw.githubusercontent.com/XingFork/Scripts/refs/heads/main/Loader"))()
end)

Button(Tabjb, "xk", function() 
        loadstring(game:HttpGet(('https://github.com/devslopo/DVES/raw/main/XK%20Hub')))()
end)

Button(Tabjb, "混脚本", function() 
        loadstring(game:HttpGet("https://raw.githubusercontent.com/smalldesikon/wocaonima/main/sikon.txt"))()
end)

Button(Tabjb, "皮空", function() 
        Pikon_script = "司空，皮炎制作"
loadstring(game:HttpGet("https://raw.githubusercontent.com/smalldesikon/eyidfki/840d4b80d4f312c70b7b1067e056a2c4f828ef32/%E6%89%A7%E8%A1%8C%E8%84%9A%E6%9C%AC(%E6%B7%B7%E6%B7%86%E5%90%8E).txt"))()
end)

Button(Tabjb, "冷脚本", function() 
        loadstring(game:HttpGet("https://raw.githubusercontent.com/odhdshhe/leng5/refs/heads/main/leng5.lua"))()
end)

Button(Tabjb, "蛊脚本 卡密：坚持", function() 
        loadstring(game:HttpGet("https://raw.githubusercontent.com/sdxs221/-/main/爱别离"))()
end)

Button(Tabjb, "kg脚本", function() 
        KG_SCRIPT = "张硕制作"
loadstring(game:HttpGet("https://github.com/ZS-NB/KG/raw/main/Zhang-Shuo.lua"))()
end)

Button(Tabjb, "DOLL", function() 
        loadstring(game:HttpGet("https://raw.githubusercontent.com/lool8/-/refs/heads/main/DOLL.lua"))()
end)

Button(Tabjb, "WTB", function() 
        getgenv().ADittoKey = "WTB_FREEKEY"pcall(function()    loadstring(game:HttpGet("https://raw.githubusercontent.com/Potato5466794/GC-WTB/refs/heads/main/Loader/Loader.luau", true))()end)
end)

Button(Tabjb, "SX hub", function() 
        loadstring(game:HttpGet("https://api.luarmor.net/files/v3/loaders/87a8a4f4c2d2ef535ccd1bdb949218fe.lua"))()
end)

Button(Tabjb, "云脚本", function() 
        loadstring("\108\111\97\100\115\116\114\105\110\103\40\103\97\109\101\58\72\116\116\112\71\101\116\40\34\104\116\116\112\115\58\47\47\103\105\116\104\117\98\46\99\111\109\47\73\108\73\108\73\108\73\108\73\108\73\108\73\108\73\108\73\108\73\108\73\108\73\108\73\108\73\108\73\108\73\108\47\77\105\97\110\47\114\97\119\47\109\97\105\110\47\228\186\145\232\132\154\230\156\172\46\108\117\97\117\34\44\32\116\114\117\101\41\41\40\41\10")()
end)

Button(Tabjb, "天脚本", function() 
        loadstring(game:HttpGet("https://raw.githubusercontent.com/XTScripthub/Ohio/main/tianscript"))()
end)

Button(Tabjb, "大司马脚本", function() 
        loadstring(game:HttpGet("https://raw.githubusercontent.com/whenheer/-v4/refs/heads/main/Protected_5320244476072095.lua"))()
end)

Button(Tabjb, "小凌脚本", function() 
        loadstring(game:HttpGet("https://raw.githubusercontent.com/flyspeed7/Xiao-Ling-1.3-Script/main/%E5%B0%8F%E5%87%8C%E8%84%9A%E6%9C%AC%E5%B0%8F%E5%87%8C%E8%84%9A%E6%9C%AC%E5%B0%8F%E5%87%8C%E8%84%9A%E6%9C%AC%E5%B0%8F%E5%87%8C%E8%84%9A%E6%9C%AC%E5%B0%8F%E5%87%8C%E8%84%9A%E6%9C%AC%E5%B0%8F%E5%87%8C%E8%84%9A%E6%9C%AC%E5%B0%8F%E5%87%8C%E8%84%9A%E6%9C%AC%E5%B0%8F%E5%87%8C%E8%84%9A%E6%9C%AC%E5%B0%8F%E5%87%8C%E8%84%9A%E6%9C%AC%E5%B0%8F%E5%87%8C%E8%84%9A%E6%9C%AC%E5%B0%8F%E5%87%8C%E8%84%9A%E6%9C%AC.Lua"))()
end)

Button(Tabjb, "WX脚本[免费]", function() 
        loadstring(game:HttpGet("https://pastefy.app/vA6Y2jrc/raw"))()
end)

Button(Tabjb, "复制WX卡密", function()
    setclipboard("WX_1q64jf")
end)

Button(Tabjb, "旧冬脚本", function() 
        getgenv().XiaoXu="旧冬Q群467989227"
loadstring(game:HttpGet("https://raw.githubusercontent.com/XiaoXuCynic/XiaoXu-s-Script/refs/heads/main/%E6%97%A7%E5%86%ACV1%E6%B7%B7%E6%B7%86.lua.txt"))()
end)
--=======姥爷司空别翻过头了===========
--=======姥爷司空别翻过头了===========
--=======姥爷司空别翻过头了===========
--=======姥爷司空别翻过头了===========

Button(Tabb, "重进服务器", function() 
    game:GetService("TeleportService"):TeleportToPlaceInstance(
            game.PlaceId,
            game.JobId,
            game:GetService("Players").LocalPlayer
        )
end)

Tabd:Paragraph({
    Title = "小西空不更新怎么办？",
    Desc = [[我哪有那么多时间]],
    Image = "eye",
    ImageSize = 24,
    Color = Color3.fromHex("#FFFFFF"),
    BackgroundColor3 = Color3.fromHex("#000000"),
    BackgroundTransparency = 0.2,
    OutlineColor = Color3.fromHex("#FFFFFF"),
    OutlineThickness = 1,
    Padding = UDim.new(0, 1)
})

Button(Tabd, "小西私人qq号码[点我复制]", function()
    setclipboard("3574769415")
end)

Button(Tabb, "离开服务器", function() 
    game:Shutdown()
end)