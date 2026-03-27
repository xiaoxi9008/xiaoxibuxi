local WindUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/Potato5466794/Wind/refs/heads/main/Wind.luau"))()

-- 全局变量
local infiniteStaminaActive = false
local staminaConnection = nil
local generatorDrawings = {}
local generatorConnection = nil
local generatorFolder = nil

-- ==================== 无限体力功能 ====================
local function getSprintingModule()
    local ReplicatedStorage = game:GetService("ReplicatedStorage")
    return ReplicatedStorage:WaitForChild("Systems"):WaitForChild("Character"):WaitForChild("Game"):WaitForChild("Sprinting")
end

local function startInfiniteStamina()
    if staminaConnection then staminaConnection:Disconnect() end
    
    -- 先尝试设置一次
    pcall(function()
        local module = getSprintingModule()
        module.StaminaLoss = 0
        module.StaminaGain = 9999
    end)
    
    -- 持续保持
    staminaConnection = game:GetService("RunService").Heartbeat:Connect(function()
        if not infiniteStaminaActive then return end
        pcall(function()
            local module = getSprintingModule()
            module.StaminaLoss = 0
            module.StaminaGain = 9999
        end)
    end)
end

local function stopInfiniteStamina()
    if staminaConnection then
        staminaConnection:Disconnect()
        staminaConnection = nil
    end
    -- 恢复默认值
    pcall(function()
        local module = getSprintingModule()
        module.StaminaLoss = 10
        module.StaminaGain = 25
    end)
end

-- 角色重生时重新应用无限体力
local function onCharacterAdded(character)
    if infiniteStaminaActive then
        startInfiniteStamina()
    end
end

game.Players.LocalPlayer.CharacterAdded:Connect(onCharacterAdded)

-- ==================== 电机绘制功能 ====================
local function createGeneratorESP(generator)
    if not generator or not generator:FindFirstChild("Main") or generatorDrawings[generator] then return end
    
    -- 进度条Billboard
    local billboard = Instance.new("BillboardGui")
    billboard.Name = "GeneratorESP"
    billboard.Size = UDim2.new(4, 0, 1, 0)
    billboard.StudsOffset = Vector3.new(0, 2.5, 0)
    billboard.Adornee = generator.Main
    billboard.Parent = generator.Main
    billboard.AlwaysOnTop = true
    
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, 0, 1, 0)
    frame.BackgroundTransparency = 0.5
    frame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    frame.Parent = billboard
    
    local progressBar = Instance.new("Frame")
    progressBar.Size = UDim2.new(0, 0, 1, 0)
    progressBar.BackgroundColor3 = Color3.fromRGB(0, 255, 255)
    progressBar.Parent = frame
    
    local textLabel = Instance.new("TextLabel")
    textLabel.Size = UDim2.new(1, 0, 1, 0)
    textLabel.BackgroundTransparency = 1
    textLabel.Text = "电机进度: 0%"
    textLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    textLabel.Font = Enum.Font.GothamBold
    textLabel.TextSize = 14
    textLabel.Parent = frame
    
    -- 距离显示
    local distanceBillboard = Instance.new("BillboardGui")
    distanceBillboard.Name = "GeneratorDistanceESP"
    distanceBillboard.Size = UDim2.new(3, 0, 0.5, 0)
    distanceBillboard.StudsOffset = Vector3.new(0, 3.8, 0)
    distanceBillboard.Adornee = generator.Main
    distanceBillboard.Parent = generator.Main
    distanceBillboard.AlwaysOnTop = true
    
    local distanceLabel = Instance.new("TextLabel")
    distanceLabel.Size = UDim2.new(1, 0, 1, 0)
    distanceLabel.BackgroundTransparency = 1
    distanceLabel.Text = "距离: 0m"
    distanceLabel.TextColor3 = Color3.fromRGB(255, 255, 0)
    distanceLabel.Font = Enum.Font.GothamBold
    distanceLabel.TextSize = 12
    distanceLabel.Parent = distanceBillboard
    
    generatorDrawings[generator] = {
        billboard = billboard,
        distanceBillboard = distanceBillboard,
        progressBar = progressBar,
        textLabel = textLabel,
        distanceLabel = distanceLabel
    }
    
    -- 进度变化监听
    if generator:FindFirstChild("Progress") then
        generator.Progress:GetPropertyChangedSignal("Value"):Connect(function()
            if generatorDrawings[generator] then
                local progress = generator.Progress.Value
                generatorDrawings[generator].progressBar.Size = UDim2.new(progress / 100, 0, 1, 0)
                generatorDrawings[generator].textLabel.Text = string.format("电机进度: %d%%", progress)
                if progress >= 100 then
                    generatorDrawings[generator].billboard:Destroy()
                    generatorDrawings[generator].distanceBillboard:Destroy()
                    generatorDrawings[generator] = nil
                end
            end
        end)
    end
    
    -- 距离更新
    local function updateDistance()
        if not generatorDrawings[generator] then return end
        local player = game.Players.LocalPlayer
        local char = player.Character
        if char and char:FindFirstChild("HumanoidRootPart") and generator:FindFirstChild("Main") then
            local distance = (char.HumanoidRootPart.Position - generator.Main.Position).Magnitude
            generatorDrawings[generator].distanceLabel.Text = string.format("距离: %dm", math.floor(distance))
            
            -- 根据距离调整透明度
            local alpha = math.clamp((distance - 30) / 70, 0.2, 1)
            generatorDrawings[generator].billboard.Enabled = distance <= 100
            generatorDrawings[generator].distanceBillboard.Enabled = distance <= 100
        end
    end
    
    -- 定期更新距离
    task.spawn(function()
        while generatorDrawings[generator] and generator.Parent do
            updateDistance()
            task.wait(0.5)
        end
    end)
end

local function scanGenerators()
    local map = workspace:FindFirstChild("Map")
    if not map then return end
    local ingame = map:FindFirstChild("Ingame")
    if not ingame then return end
    generatorFolder = ingame:FindFirstChild("Map") or ingame
    
    for _, obj in ipairs(generatorFolder:GetDescendants()) do
        if obj:IsA("Model") and obj.Name == "Generator" and obj:FindFirstChild("Main") then
            createGeneratorESP(obj)
        end
    end
end

local function startGeneratorESP()
    if generatorConnection then generatorConnection:Disconnect() end
    
    scanGenerators()
    
    -- 监听新生成的电机
    local function onDescendantAdded(obj)
        if obj:IsA("Model") and obj.Name == "Generator" and obj:FindFirstChild("Main") then
            createGeneratorESP(obj)
        end
    end
    
    if generatorFolder then
        generatorConnection = generatorFolder.DescendantAdded:Connect(onDescendantAdded)
    end
end

local function stopGeneratorESP()
    if generatorConnection then
        generatorConnection:Disconnect()
        generatorConnection = nil
    end
    for _, data in pairs(generatorDrawings) do
        if data.billboard then data.billboard:Destroy() end
        if data.distanceBillboard then data.distanceBillboard:Destroy() end
    end
    generatorDrawings = {}
end

-- ==================== 创建UI ====================
local function gradient(text, startColor, endColor)
    local result, chars = "", {}
    for uchar in text:gmatch("[%z\1-\127\194-\244][\128-\191]*") do
        chars[#chars + 1] = uchar
    end
    for i = 1, #chars do
        local t = (i - 1) / math.max(#chars - 1, 1)
        result = result .. string.format('<font color="rgb(%d,%d,%d)">%s</font>', 
            math.floor((startColor.R + (endColor.R - startColor.R) * t) * 255), 
            math.floor((startColor.G + (endColor.G - startColor.G) * t) * 255), 
            math.floor((startColor.B + (endColor.B - startColor.B) * t) * 255), 
            chars[i])
    end
    return result
end

-- 欢迎弹窗
WindUI:Popup({
    Title = gradient("被遗弃脚本", Color3.fromHex("FFB6C1"), Color3.fromHex("FF69B4")),
    Icon = "sparkles",
    Content = "无限体力 + 电机绘制\n按F键打开菜单",
    Buttons = {
        { Title = "开始体验", Icon = "arrow-right", Variant = "Primary", Callback = function() end }
    }
})

local Window = WindUI:CreateWindow({
    Title = "xiaoxi",
    Icon = "rbxassetid://4483362748",
    Author = "Yuxingchen",
    Folder = "Abandoned_Script_Data",
    Size = UDim2.fromOffset(500, 400),
    Transparent = true,
    Theme = "Dark",
    UserEnabled = true,
    SideBarWidth = 150,
    HasOutline = true
})

-- 主题颜色
WindUI.Themes.Dark.Toggle = Color3.fromHex("FF69B4")
WindUI.Themes.Dark.Checkbox = Color3.fromHex("FFB6C1")
WindUI.Themes.Dark.Button = Color3.fromHex("FF1493")
WindUI.Themes.Dark.Slider = Color3.fromHex("FF69B4")

-- 创建选项卡
local Tabs = {
    Main = Window:Tab({ Title = "主页", Icon = "home" }),
    Functions = Window:Tab({ Title = "功能", Icon = "zap" })
}

-- ==================== 主页 ====================
local mainSection = Tabs.Main:Section({ Title = "欢迎", Icon = "heart", Opened = true })

mainSection:Paragraph({
    Title = "被遗弃脚本",
    Desc = "功能：\n- 无限体力\n- 电机进度显示\n- 电机距离显示\n\n按F键打开/关闭菜单",
    ImageSize = 20,
    Color = "White"
})

mainSection:Divider()

mainSection:Button({
    Title = "显示群号",
    Icon = "message-circle",
    Callback = function()
        WindUI:Notify({
            Title = "群号",
            Content = "主群：134786908423441\n二群：3574769415",
            Duration = 5
        })
    end
})

-- ==================== 功能选项卡 ====================
local functionSection = Tabs.Functions:Section({ Title = "功能开关", Icon = "toggle-left", Opened = true })

-- 无限体力开关
functionSection:Toggle({
    Title = "无限体力",
    Desc = "开启后体力不会消耗",
    Value = false,
    Callback = function(state)
        infiniteStaminaActive = state
        if state then
            startInfiniteStamina()
            WindUI:Notify({ Title = "无限体力", Content = "已开启", Duration = 2 })
        else
            stopInfiniteStamina()
            WindUI:Notify({ Title = "无限体力", Content = "已关闭", Duration = 2 })
        end
    end
})

functionSection:Divider()

-- 电机绘制开关
functionSection:Toggle({
    Title = "电机绘制",
    Desc = "显示电机进度和距离",
    Value = false,
    Callback = function(state)
        if state then
            startGeneratorESP()
            WindUI:Notify({ Title = "电机绘制", Content = "已开启", Duration = 2 })
        else
            stopGeneratorESP()
            WindUI:Notify({ Title = "电机绘制", Content = "已关闭", Duration = 2 })
        end
    end
})

-- 刷新电机按钮（如果电机没显示可以手动刷新）
functionSection:Button({
    Title = "刷新电机",
    Icon = "refresh-cw",
    Callback = function()
        stopGeneratorESP()
        startGeneratorESP()
        WindUI:Notify({ Title = "电机绘制", Content = "已刷新", Duration = 2 })
    end
})

-- ==================== 设置选项卡 ====================
local settingsSection = Tabs.Functions:Section({ Title = "设置", Icon = "settings", Opened = true })

settingsSection:Button({
    Title = "删除UI",
    Icon = "trash-2",
    Callback = function()
        stopInfiniteStamina()
        stopGeneratorESP()
        Window:Destroy()
    end
})

-- ==================== 窗口关闭清理 ====================
Window:OnClose(function()
    print("窗口关闭")
    stopInfiniteStamina()
    stopGeneratorESP()
end)

-- 角色重生时重新应用无限体力
game.Players.LocalPlayer.CharacterAdded:Connect(function()
    if infiniteStaminaActive then
        startInfiniteStamina()
    end
end)

print("被遗弃脚本已加载，按F键打开/关闭菜单")