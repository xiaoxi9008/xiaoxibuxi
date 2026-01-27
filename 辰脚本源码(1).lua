local FpsGui = Instance.new("ScreenGui") local FpsXS = Instance.new("TextLabel") FpsGui.Name = "FPSGui" FpsGui.ResetOnSpawn = false FpsGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling FpsXS.Name = "FpsXS" FpsXS.Size = UDim2.new(0, 100, 0, 50) FpsXS.Position = UDim2.new(0, 10, 0, 10) FpsXS.BackgroundTransparency = 1 FpsXS.Font = Enum.Font.SourceSansBold FpsXS.Text = "帧率: 0" FpsXS.TextSize = 20 FpsXS.TextColor3 = Color3.new(1, 1, 1) FpsXS.Parent = FpsGui function updateFpsXS() local fps = math.floor(1 / game:GetService("RunService").RenderStepped:Wait()) FpsXS.Text = "帧率: " .. fps end game:GetService("RunService").RenderStepped:Connect(updateFpsXS) FpsGui.Parent = game.Players.LocalPlayer:WaitForChild("PlayerGui")

local ui = loadstring(game:HttpGet("https://raw.githubusercontent.com/qwrt5589/eododo/64b30a2b84891f44f8feb324e3cc56c6e663d7f4/%E9%BB%8E%E6%98%8E%E7%9A%84%E7%8B%97%E5%B1%8E.lua"))()
local win = ui:new("辰脚本")
--
local UITab84 = win:Tab("信息",'16060333448')

local about = UITab84:section("『介绍』",true)
about:Label("辰脚本")
about:Label("永久免费")
about:Label("作者小光")
about:Label("本脚本为免费缝合脚本")
about:Button("点我复制作者QQ群",function()
    setclipboard("1028199013")
end)

about:Toggle("脚本框架变小一点", "", false, function(state)
        if state then
        game:GetService("CoreGui")["frosty"].Main.Style = "DropShadow"
        else
            game:GetService("CoreGui")["frosty"].Main.Style = "Custom"
        end
    end)
    about:Button("关闭脚本",function()
        game:GetService("CoreGui")["frosty"]:Destroy()
    end)
    
task.spawn(function()
    while true do
        about:Label("当前时间: " .. os.date("%Y-%m-%d %H:%M:%S"))
        
        local springFestivalTime = os.time({
            year = 2025,
            month = 1,
            day = 29,
            hour = 0,
            min = 0,
            sec = 0,
        }) - os.time()
        
        if springFestivalTime > 0 then
            about:Label(string.format("春节倒计时: %d天%d小时%d分钟%d秒", 
                math.floor(springFestivalTime / 86400), 
                math.floor(springFestivalTime % 86400 / 3600), 
                math.floor(springFestivalTime % 3600 / 60), 
                springFestivalTime % 60))
        else
            about:Label("过年啦！！！")
        end
        
        local newYearTime = os.time({
            year = 2026,
            month = 1,
            day = 1,
            hour = 0,
            min = 0,
            sec = 0,
        }) - os.time()
        
        if newYearTime > 0 then
            about:Label(string.format("跨年倒计时: %d天%d小时%d分钟%d秒", 
                math.floor(newYearTime / 86400), 
                math.floor(newYearTime % 86400 / 3600), 
                math.floor(newYearTime % 3600 / 60), 
                newYearTime % 60))
        else
            about:Label("跨年啦！！！")
        end
        
        local newYearsEveTime = os.time({
            year = 2025,
            month = 1,
            day = 28,
            hour = 0,
            min = 0,
            sec = 0,
        }) - os.time()
        
        if newYearsEveTime > 0 then
            about:Label(string.format("除夕倒计时: %d天%d小时%d分钟%d秒", 
                math.floor(newYearsEveTime / 86400), 
                math.floor(newYearsEveTime % 86400 / 3600), 
                math.floor(newYearsEveTime % 3600 / 60), 
                newYearsEveTime % 60))
        else
            about:Label("除夕啦！！！")
        end
        
        local lanternFestivalTime = os.time({
            year = 2025,
            month = 2,
            day = 12,
            hour = 0,
            min = 0,
            sec = 0,
        }) - os.time()
        
        if lanternFestivalTime > 0 then
            about:Label(string.format("元宵节倒计时: %d天%d小时%d分钟%d秒", 
                math.floor(lanternFestivalTime / 86400), 
                math.floor(lanternFestivalTime % 86400 / 3600), 
                math.floor(lanternFestivalTime % 3600 / 60), 
                lanternFestivalTime % 60))
        else
            about:Label("元宵节啦！！！")
        end
        
        task.wait(1)
    end
end)

local UITab43 = win:Tab("『刀刃球』",'7734068321')

local about = UITab43:section("『刀刃球』",true)

about:Button("禁漫中心",function()
loadstring(game:HttpGet("https://raw.githubusercontent.com/dingding123hhh/ghbdrc/main/%E4%B8%81%E4%B8%81%E5%88%80%E5%88%83%E7%90%83.txt"))()
end)

about:Button("刀刃球自动格挡",function()
loadstring(game:HttpGet("https://raw.githubusercontent.com/Hosvile/Refinement/main/MC%3ABlade%20Ball%20Parry%20V4.0.0",true))()
end)

about:Button("刀刃球1",function()
loadstring(game:HttpGet(('https://raw.githubusercontent.com/Unknownkellymc1/Unknownscripts/main/slap-battles')))()
end)

about:Button("刀刃球2",function()
loadstring(game:HttpGet("https://raw.githubusercontent.com/REDzHUB/BladeBall/main/redz9999"))()
end)

about:Button("刀刃球3",function()
loadstring(game:HttpGet("https://raw.githubusercontent.com/Neoncat765/Neon.C-Hub-X/main/UnknownVersion"))()
end)



