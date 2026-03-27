local WindUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/Potato5466794/Wind/refs/heads/main/Wind.luau"))()

getgenv().TransparencyEnabled = getgenv().TransparencyEnabled or false

-- 全局变量存储
local _env = getgenv() or {}
_env.NoStun = false
_env.SpeedBoostValue = 1
_env.SpeedBoost = false
_env.Brightness = 0
_env.GlobalShadows = false
_env.NoFog = false
_env.Fullbright = false
_env.FovValue = 70
_env.FOV = false

-- 自动拾取相关变量
local autoTeleportMedkitEnabled = false
local autoTeleportColaEnabled = false
local autoMedkitEnabled = false
local autoColaEnabled = false
local teleportMedkitThread = nil
local teleportColaThread = nil
local medkitThread = nil
local colaThread = nil

-- 自瞄相关变量
local aimbot1x1 = false
local cool = false
local TWOTIME = false
local johnaim = false
local jasonaim = false
local CA = false
local shedaim = false
local aimbot1x1loop = nil
local coolloop = nil
local TWOloop = nil
local johnloop = nil
local jasonaimbotloop = nil
local CAbotConnection = nil
local shedloop = nil

-- 自动修机变量
_G.AutoGeneratorDelay = 1.5

-- 体力相关变量
local StaminaSettings = {
    MaxStamina = 100,
    StaminaGain = 25,
    StaminaLoss = 10,
    SprintSpeed = 28,
    InfiniteGain = 9999
}
local SettingToggles = {
    MaxStamina = true,
    StaminaGain = true,
    StaminaLoss = true,
    SprintSpeed = true
}
local SprintingModule = nil
local baiSpr = false
local staminaConnection = nil

-- 披萨功能变量
local pizzaAttractionActive = false
local pizzaConnection = nil
local pizzaTPConnection = nil
_G.HealthEatPizza = 50
_G.AutoEatPizza = false
_G.AutoTeleportPizza = false

-- 自动格挡变量
local config = {
    BlockDistance = 15,
    ScanInterval = 0.05,
    BlockCooldown = 0.5,
    DebugMode = false,
    AutoAdjustDistance = true,
    PredictEnabled = true,
    PredictDistance = 17,
    BasePredictAmount = 2,
    TargetSoundIds = {
        "rbxassetid://102228729296384",
        "rbxassetid://140242176732868",
        "rbxassetid://12222216",
        "rbxassetid://86174610237192",
        "rbxassetid://101199185291628",
        "rbxassetid://95079963655241",
        "rbxassetid://112809109188560"
    }
}
local lastBlockTime = 0
local combatConnection = nil

-- 三角炸弹变量
local tripmineData = {
    active = false,
    killerParts = {},
    tripmineParts = {},
    connections = {},
    speed = 20,
    survivorNames = {}
}
local tripmineActive = false
local tripmineConnection = nil

-- ==================== 辅助函数 ====================

-- 获取体力模块
local function getSprintingModule()
    local ReplicatedStorage = game:GetService("ReplicatedStorage")
    return ReplicatedStorage:WaitForChild("Systems"):WaitForChild("Character"):WaitForChild("Game"):WaitForChild("Sprinting")
end

-- 更新体力设置
local function updateStaminaSettings()
    if not SprintingModule then
        pcall(function()
            SprintingModule = getSprintingModule()
        end)
    end
    if SprintingModule then
        if SettingToggles.MaxStamina then SprintingModule.MaxStamina = StaminaSettings.MaxStamina end
        if SettingToggles.StaminaGain then SprintingModule.StaminaGain = StaminaSettings.StaminaGain end
        if SettingToggles.StaminaLoss then SprintingModule.StaminaLoss = StaminaSettings.StaminaLoss end
        if SettingToggles.SprintSpeed then SprintingModule.SprintSpeed = StaminaSettings.SprintSpeed end
    end
end

-- 无限体力函数
local function startInfiniteStamina()
    if staminaConnection then staminaConnection:Disconnect() end
    staminaConnection = game:GetService("RunService").Heartbeat:Connect(function()
        if baiSpr then
            pcall(function()
                if not SprintingModule then
                    SprintingModule = getSprintingModule()
                end
                if SprintingModule then
                    SprintingModule.StaminaLoss = 0
                    SprintingModule.StaminaGain = StaminaSettings.InfiniteGain or 9999
                end
            end)
        end
    end)
end

local function stopInfiniteStamina()
    if staminaConnection then
        staminaConnection:Disconnect()
        staminaConnection = nil
    end
    pcall(function()
        if not SprintingModule then
            SprintingModule = getSprintingModule()
        end
        if SprintingModule then
            SprintingModule.StaminaLoss = StaminaSettings.StaminaLoss or 10
            SprintingModule.StaminaGain = StaminaSettings.StaminaGain or 25
        end
    end)
end

-- 去前摇后摇功能
local function setupNoStun()
    local function onWalkSpeedChanged()
        local char = game.Players.LocalPlayer.Character
        if char and char:FindFirstChild("Humanoid") then
            if _env.NoStun and char.Humanoid.WalkSpeed < 16 then
                char.Humanoid.WalkSpeed = 16
            end
        end
    end
    
    game.Players.LocalPlayer.CharacterAdded:Connect(function(char)
        char:WaitForChild("Humanoid"):GetPropertyChangedSignal("WalkSpeed"):Connect(onWalkSpeedChanged)
    end)
    
    local char = game.Players.LocalPlayer.Character
    if char and char:FindFirstChild("Humanoid") then
        char.Humanoid:GetPropertyChangedSignal("WalkSpeed"):Connect(onWalkSpeedChanged)
    end
end

-- 速度调节功能
local function startSpeedBoost()
    while _env.SpeedBoost do
        local char = game.Players.LocalPlayer.Character
        if char and char:FindFirstChild("HumanoidRootPart") and char:FindFirstChild("Humanoid") then
            char.HumanoidRootPart.CFrame += char.Humanoid.MoveDirection * _env.SpeedBoostValue
            char.HumanoidRootPart.CanCollide = true
        end
        task.wait()
    end
end

-- 亮度调节功能
local function setupFullbright()
    game:GetService("RunService").RenderStepped:Connect(function()
        if not game.Lighting:GetAttribute("FogStart") then 
            game.Lighting:SetAttribute("FogStart", game.Lighting.FogStart) 
        end
        if not game.Lighting:GetAttribute("FogEnd") then 
            game.Lighting:SetAttribute("FogEnd", game.Lighting.FogEnd) 
        end
        game.Lighting.FogStart = _env.NoFog and 0 or game.Lighting:GetAttribute("FogStart")
        game.Lighting.FogEnd = _env.NoFog and math.huge or game.Lighting:GetAttribute("FogEnd")
        
        local fog = game.Lighting:FindFirstChildOfClass("Atmosphere")
        if fog then
            if not fog:GetAttribute("Density") then 
                fog:SetAttribute("Density", fog.Density) 
            end
            fog.Density = _env.NoFog and 0 or fog:GetAttribute("Density")
        end
        
        if _env.Fullbright then
            game.Lighting.OutdoorAmbient = Color3.new(1,1,1)
            game.Lighting.Brightness = _env.Brightness or 0
            game.Lighting.GlobalShadows = not _env.GlobalShadows
        else
            game.Lighting.OutdoorAmbient = Color3.fromRGB(55,55,55)
            game.Lighting.Brightness = 0
            game.Lighting.GlobalShadows = true
        end
    end)
end

-- 视野调节
local function setupFOV()
    game:GetService("RunService").RenderStepped:Connect(function()
        if _env.FOV then
            workspace.Camera.FieldOfView = _env.FovValue
        end
    end)
end

-- 自动拾取医疗包（传送）
local function startTeleportMedkit()
    teleportMedkitThread = task.spawn(function()
        while autoTeleportMedkitEnabled and task.wait(0.5) do
            local character = game.Players.LocalPlayer.Character
            if character and character:FindFirstChild("HumanoidRootPart") then
                local humanoidRootPart = character.HumanoidRootPart
                
                local medkit = workspace:FindFirstChild("Map", true)
                if medkit then
                    medkit = medkit:FindFirstChild("Ingame", true)
                    if medkit then
                        medkit = medkit:FindFirstChild("Medkit", true)
                        if medkit then
                            local itemRoot = medkit:FindFirstChild("ItemRoot", true)
                            if itemRoot then
                                itemRoot.CFrame = humanoidRootPart.CFrame + humanoidRootPart.CFrame.LookVector * 3
                                local prompt = itemRoot:FindFirstChild("ProximityPrompt", true)
                                if prompt then fireproximityprompt(prompt) end
                            end
                        end
                    end
                end
            end
        end
    end)
end

local function stopTeleportMedkit()
    if teleportMedkitThread then task.cancel(teleportMedkitThread); teleportMedkitThread = nil end
end

-- 自动拾取可乐（传送）
local function startTeleportCola()
    teleportColaThread = task.spawn(function()
        while autoTeleportColaEnabled and task.wait(0.5) do
            local character = game.Players.LocalPlayer.Character
            if character and character:FindFirstChild("HumanoidRootPart") then
                local humanoidRootPart = character.HumanoidRootPart
                
                local cola = workspace:FindFirstChild("Map", true)
                if cola then
                    cola = cola:FindFirstChild("Ingame", true)
                    if cola then
                        cola = cola:FindFirstChild("BloxyCola", true)
                        if cola then
                            local itemRoot = cola:FindFirstChild("ItemRoot", true)
                            if itemRoot then
                                itemRoot.CFrame = humanoidRootPart.CFrame + humanoidRootPart.CFrame.LookVector * 3
                                local prompt = itemRoot:FindFirstChild("ProximityPrompt", true)
                                if prompt then fireproximityprompt(prompt) end
                            end
                        end
                    end
                end
            end
        end
    end)
end

local function stopTeleportCola()
    if teleportColaThread then task.cancel(teleportColaThread); teleportColaThread = nil end
end

-- 自动互动医疗包（不传送）
local function startAutoMedkit()
    medkitThread = task.spawn(function()
        while autoMedkitEnabled and task.wait(0.5) do
            local medkit = workspace:FindFirstChild("Map", true)
            if medkit then
                medkit = medkit:FindFirstChild("Ingame", true)
                if medkit then
                    medkit = medkit:FindFirstChild("Medkit", true)
                    if medkit then
                        local itemRoot = medkit:FindFirstChild("ItemRoot", true)
                        if itemRoot then
                            local prompt = itemRoot:FindFirstChild("ProximityPrompt", true)
                            if prompt then fireproximityprompt(prompt) end
                        end
                    end
                end
            end
        end
    end)
end

local function stopAutoMedkit()
    if medkitThread then task.cancel(medkitThread); medkitThread = nil end
end

-- 自动互动可乐（不传送）
local function startAutoCola()
    colaThread = task.spawn(function()
        while autoColaEnabled and task.wait(0.5) do
            local cola = workspace:FindFirstChild("Map", true)
            if cola then
                cola = cola:FindFirstChild("Ingame", true)
                if cola then
                    cola = cola:FindFirstChild("BloxyCola", true)
                    if cola then
                        local itemRoot = cola:FindFirstChild("ItemRoot", true)
                        if itemRoot then
                            local prompt = itemRoot:FindFirstChild("ProximityPrompt", true)
                            if prompt then fireproximityprompt(prompt) end
                        end
                    end
                end
            end
        end
    end)
end

local function stopAutoCola()
    if colaThread then task.cancel(colaThread); colaThread = nil end
end

-- 自动修机
local function startAutoFix()
    local debounce = {}
    local generatorFolder = game.Workspace.Map.Ingame.Map
    
    task.spawn(function()
        while _G.AutoFixEnabled do
            task.wait()
            for _, generator in pairs(generatorFolder:GetChildren()) do
                if generator.Name == "Generator" and not debounce[generator] then
                    local remotes = generator:FindFirstChild("Remotes")
                    local re = remotes and remotes:FindFirstChild("RE")
                    if re then
                        debounce[generator] = true
                        re:FireServer()
                        task.delay(_G.AutoGeneratorDelay or 1.5, function()
                            debounce[generator] = nil
                        end)
                    end
                end
            end
        end
    end)
end

_G.AutoFixEnabled = false

-- 自动格挡
local LocalPlayer = game:GetService("Players").LocalPlayer
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RemoteEvent = ReplicatedStorage:WaitForChild("Modules"):WaitForChild("Network"):WaitForChild("RemoteEvent")

local function hasTargetSound(character)
    if not character then return false end
    for _, sound in ipairs(character:GetDescendants()) do
        if sound:IsA("Sound") then
            for _, targetId in ipairs(config.TargetSoundIds) do
                if sound.SoundId == targetId then return true end
            end
        end
    end
    return false
end

local function getKillersInRange()
    local killers = {}
    local killersFolder = workspace:FindFirstChild("Killers") or (workspace:FindFirstChild("Players") and workspace.Players:FindFirstChild("Killers"))
    if not killersFolder then return killers end
    
    local myCharacter = LocalPlayer.Character
    if not myCharacter or not myCharacter:FindFirstChild("HumanoidRootPart") then return killers end
    
    local myPos = myCharacter.HumanoidRootPart.Position
    local checkDistance = config.BlockDistance
    if config.PredictEnabled then checkDistance = checkDistance + config.BasePredictAmount end
    
    for _, killer in ipairs(killersFolder:GetChildren()) do
        if killer:FindFirstChild("HumanoidRootPart") then
            local distance = (killer.HumanoidRootPart.Position - myPos).Magnitude
            if distance <= checkDistance then
                table.insert(killers, killer)
            end
        end
    end
    return killers
end

local function performBlock()
    if os.clock() - lastBlockTime >= config.BlockCooldown then
        RemoteEvent:FireServer("UseActorAbility", "Block")
        lastBlockTime = os.clock()
    end
end

local function combatLoop()
    local killers = getKillersInRange()
    for _, killer in ipairs(killers) do
        if hasTargetSound(killer) then
            performBlock()
            break
        end
    end
end

local function startAutoBlock()
    if combatConnection then combatConnection:Disconnect() end
    combatConnection = game:GetService("RunService").Stepped:Connect(combatLoop)
end

local function stopAutoBlock()
    if combatConnection then
        combatConnection:Disconnect()
        combatConnection = nil
    end
end

-- 披萨功能
local function startAutoEatPizza()
    if pizzaConnection then pizzaConnection:Disconnect() end
    local lastCheck = 0
    pizzaConnection = game:GetService("RunService").Stepped:Connect(function(_, deltaTime)
        lastCheck = lastCheck + deltaTime
        if lastCheck < 0.3 then return end
        lastCheck = 0
        
        local player = game:GetService("Players").LocalPlayer
        local character = player.Character
        if not character or not character:FindFirstChild("Humanoid") or not character:FindFirstChild("HumanoidRootPart") then return end
        
        local humanoid = character.Humanoid
        local rootPart = character.HumanoidRootPart
        
        if _G.HealthEatPizza and humanoid.Health >= _G.HealthEatPizza then return end
        
        local pizzaFolder = workspace:FindFirstChild("Pizzas") or workspace.Map
        if not pizzaFolder then return end
        
        local closestPizza, closestDistance = nil, math.huge
        for _, pizza in ipairs(pizzaFolder:GetDescendants()) do
            if pizza:IsA("BasePart") and pizza.Name == "Pizza" then
                local distance = (rootPart.Position - pizza.Position).Magnitude
                if distance < closestDistance then
                    closestPizza = pizza
                    closestDistance = distance
                end
            end
        end
        
        if closestPizza then
            closestPizza.CFrame = closestPizza.CFrame:Lerp(rootPart.CFrame * CFrame.new(0, 0, -2), 0.5)
        end
    end)
end

local function startAutoTeleportPizza()
    if pizzaTPConnection then pizzaTPConnection:Disconnect() end
    local lastCheck = 0
    pizzaTPConnection = game:GetService("RunService").Stepped:Connect(function(_, deltaTime)
        lastCheck = lastCheck + deltaTime
        if lastCheck < 0.3 then return end
        lastCheck = 0
        
        local player = game:GetService("Players").LocalPlayer
        local character = player.Character
        if not character or not character:FindFirstChild("Humanoid") or not character:FindFirstChild("HumanoidRootPart") then return end
        
        local humanoid = character.Humanoid
        local rootPart = character.HumanoidRootPart
        
        if _G.HealthEatPizza and humanoid.Health >= _G.HealthEatPizza then return end
        
        local pizzaFolder = workspace:FindFirstChild("Pizzas") or workspace.Map
        if not pizzaFolder then return end
        
        local closestPizza, closestDistance = nil, math.huge
        for _, pizza in ipairs(pizzaFolder:GetDescendants()) do
            if pizza:IsA("BasePart") and pizza.Name == "Pizza" then
                local distance = (rootPart.Position - pizza.Position).Magnitude
                if distance < closestDistance then
                    closestPizza = pizza
                    closestDistance = distance
                end
            end
        end
        
        if closestPizza then
            closestPizza.CFrame = rootPart.CFrame * CFrame.new(0, 0, -2)
        end
    end)
end

local function stopPizzaFunctions()
    if pizzaConnection then pizzaConnection:Disconnect(); pizzaConnection = nil end
    if pizzaTPConnection then pizzaTPConnection:Disconnect(); pizzaTPConnection = nil end
end

-- 三角炸弹功能
local function updateSurvivors()
    tripmineData.survivorNames = {}
    local survivorsFolder = workspace:FindFirstChild("Map") and workspace.Map:FindFirstChild("Players") and workspace.Map.Players:FindFirstChild("Survivors")
    if survivorsFolder then
        for _, survivor in ipairs(survivorsFolder:GetChildren()) do
            if survivor:IsA("Model") then
                table.insert(tripmineData.survivorNames, survivor.Name)
            end
        end
    end
end

local function updateKillers()
    tripmineData.killerParts = {}
    local killersFolder = workspace:FindFirstChild("Players") and workspace.Players:FindFirstChild("Killers")
    if killersFolder then
        for _, killer in ipairs(killersFolder:GetChildren()) do
            if killer:IsA("Model") and not table.find(tripmineData.survivorNames, killer.Name) then
                local rootPart = killer:FindFirstChild("HumanoidRootPart") or killer:FindFirstChildWhichIsA("BasePart")
                if rootPart then
                    table.insert(tripmineData.killerParts, rootPart)
                end
            end
        end
    end
end

local function updateTripmines()
    tripmineData.tripmineParts = {}
    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("Model") and obj.Name == "SubspaceTripmine" then
            local part = obj.PrimaryPart or obj:FindFirstChildWhichIsA("BasePart")
            if part then
                table.insert(tripmineData.tripmineParts, part)
            end
        end
    end
end

local function moveTripmines(deltaTime)
    if #tripmineData.killerParts == 0 then return end
    for _, tripmine in ipairs(tripmineData.tripmineParts) do
        if tripmine and tripmine.Parent then
            local nearestKiller, minDist = nil, math.huge
            for _, killerPart in ipairs(tripmineData.killerParts) do
                if killerPart and killerPart.Parent then
                    local dist = (tripmine.Position - killerPart.Position).Magnitude
                    if dist < minDist then
                        minDist = dist
                        nearestKiller = killerPart
                    end
                end
            end
            if nearestKiller then
                local direction = (nearestKiller.Position - tripmine.Position).Unit
                local moveDistance = math.min(tripmineData.speed * deltaTime, minDist)
                tripmine.CFrame = CFrame.new(tripmine.Position + direction * moveDistance)
            end
        end
    end
end

local function startTripmineTracker()
    if tripmineConnection then tripmineConnection:Disconnect() end
    updateSurvivors()
    updateKillers()
    updateTripmines()
    local lastTime = os.clock()
    tripmineConnection = game:GetService("RunService").Heartbeat:Connect(function()
        local deltaTime = os.clock() - lastTime
        lastTime = os.clock()
        moveTripmines(deltaTime)
    end)
    
    local killersFolder = workspace:WaitForChild("Players"):WaitForChild("Killers")
    killersFolder.ChildAdded:Connect(function()
        task.wait(0.5); updateKillers()
    end)
end

local function stopTripmineTracker()
    if tripmineConnection then
        tripmineConnection:Disconnect()
        tripmineConnection = nil
    end
end

-- 自瞄辅助函数（角色专属自瞄）
local function setupCharacterAimbot(characterName, soundIds, maxIterations, shouldMoveHRP)
    local function startAimbot()
        local loop = game.Players.LocalPlayer.Character.HumanoidRootPart.ChildAdded:Connect(function(child)
            for _, v in pairs(soundIds) do
                if child.Name == v then
                    local survivors = {}
                    for _, player in pairs(game:GetService("Players"):GetPlayers()) do
                        if player ~= game.Players.LocalPlayer then
                            local character = player.Character
                            if character and character:FindFirstChild("HumanoidRootPart") then
                                table.insert(survivors, character)
                            end
                        end
                    end
                    local nearestSurvivor = nil
                    local shortestDistance = math.huge
                    for _, survivor in pairs(survivors) do
                        local survivorHRP = survivor.HumanoidRootPart
                        local playerHRP = game.Players.LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                        if playerHRP then
                            local distance = (survivorHRP.Position - playerHRP.Position).Magnitude
                            if distance < shortestDistance then
                                shortestDistance = distance
                                nearestSurvivor = survivor
                            end
                        end
                    end
                    if nearestSurvivor then
                        local nearestHRP = nearestSurvivor.HumanoidRootPart
                        local playerHRP = game.Players.LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                        if playerHRP then
                            local num = 1
                            local iterations = maxIterations or 100
                            while num <= iterations do
                                task.wait(0.01)
                                num = num + 1
                                workspace.CurrentCamera.CFrame = CFrame.new(workspace.CurrentCamera.CFrame.Position, nearestHRP.Position)
                                if shouldMoveHRP then
                                    playerHRP.CFrame = CFrame.lookAt(playerHRP.Position, Vector3.new(nearestHRP.Position.X, nearestHRP.Position.Y, nearestHRP.Position.Z))
                                end
                            end
                        end
                    end
                end
            end
        end)
        return loop
    end
    return startAimbot
end

-- ==================== 创建WindUI窗口 ====================

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

-- 弹出欢迎信息
WindUI:Popup({
    Title = gradient("被遗弃脚本", Color3.fromHex("FFB6C1"), Color3.fromHex("FF69B4")),
    Icon = "sparkles",
    Content = "欢迎使用被遗弃脚本\n移植到WindUI\n作者：Yuxingchen",
    Buttons = {
        { Title = "开始体验", Icon = "arrow-right", Variant = "Primary", Callback = function() end }
    }
})

local Window = WindUI:CreateWindow({
    Title = "<font color='#FFB6C1'>被</font><font color='#FFA0B5'>遗</font><font color='#FF8AA9'>弃</font><font color='#FF749D'> </font><font color='#FF5E91'>脚</font><font color='#FF4885'>本</font>",
    Icon = "rbxassetid://4483362748",
    Author = "Yuxingchen",
    Folder = "Abandoned_Script_Data",
    Size = UDim2.fromOffset(750, 550),
    Transparent = true,
    Theme = "Dark",
    UserEnabled = true,
    SideBarWidth = 200,
    HasOutline = true,
    ScrollBarEnabled = true
})

-- 主题颜色设置
WindUI.Themes.Dark.Toggle = Color3.fromHex("FF69B4")
WindUI.Themes.Dark.Checkbox = Color3.fromHex("FFB6C1")
WindUI.Themes.Dark.Button = Color3.fromHex("FF1493")
WindUI.Themes.Dark.Slider = Color3.fromHex("FF69B4")

-- 创建选项卡
local Tabs = {
    Main = Window:Tab({ Title = "主页", Icon = "home" }),
    Player = Window:Tab({ Title = "玩家", Icon = "user" }),
    Aimbot = Window:Tab({ Title = "自瞄", Icon = "target" }),
    ESP = Window:Tab({ Title = "绘制", Icon = "eye" }),
    Items = Window:Tab({ Title = "拾取", Icon = "package" }),
    Combat = Window:Tab({ Title = "战斗", Icon = "sword" }),
    Visual = Window:Tab({ Title = "画面", Icon = "sun" }),
    Settings = Window:Tab({ Title = "设置", Icon = "settings" })
}

-- ==================== 主页选项卡 ====================
local mainSection = Tabs.Main:Section({ Title = "欢迎", Icon = "heart", Opened = true })

mainSection:Paragraph({
    Title = "被遗弃脚本",
    Desc = "作者：小西\n移植：Yuxingchen\n版本：V2.0\n\n功能包含：\n- 速度调节/去前摇后摇\n- 亮度调节/除雾/无阴影\n- 各种角色专属自瞄\n- 血量条/距离/方框/骨骼绘制\n- 自动拾取医疗包/可乐\n- 自动修机/自动格挡\n- 披萨自动吸引/传送\n- 三角炸弹追踪\n- 无限体力/奔跑速度调节",
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

-- ==================== 玩家选项卡 ====================
local playerSection = Tabs.Player:Section({ Title = "移动调节", Icon = "move", Opened = true })

playerSection:Toggle({
    Title = "去除前摇/后摇/缓慢动作",
    Value = false,
    Callback = function(state)
        _env.NoStun = state
        if state then setupNoStun() end
    end
})

playerSection:Divider()

playerSection:Slider({
    Title = "速度调节",
    Value = { Min = 0, Max = 3, Default = 1 },
    Suffix = "x",
    Callback = function(value)
        _env.SpeedBoostValue = value
    end
})

playerSection:Toggle({
    Title = "启用速度",
    Value = false,
    Callback = function(state)
        _env.SpeedBoost = state
        if state then
            task.spawn(startSpeedBoost)
        end
    end
})

playerSection:Divider()

playerSection:Toggle({
    Title = "显示聊天框",
    Value = false,
    Desc = "需要每局开一次",
    Callback = function(state)
        game.TextChatService.ChatWindowConfiguration.Enabled = state
    end
})

-- 体力功能
local staminaSection = Tabs.Player:Section({ Title = "体力功能", Icon = "zap", Opened = true })

staminaSection:Toggle({
    Title = "无限体力",
    Value = false,
    Callback = function(state)
        baiSpr = state
        if state then
            startInfiniteStamina()
        else
            stopInfiniteStamina()
        end
    end
})

staminaSection:Slider({
    Title = "体力大小",
    Value = { Min = 0, Max = 99999, Default = 100 },
    Callback = function(value)
        StaminaSettings.MaxStamina = value
        updateStaminaSettings()
    end
})

staminaSection:Slider({
    Title = "体力恢复",
    Value = { Min = 0, Max = 250, Default = 25 },
    Callback = function(value)
        StaminaSettings.StaminaGain = value
        updateStaminaSettings()
    end
})

staminaSection:Slider({
    Title = "体力消耗",
    Value = { Min = 0, Max = 100, Default = 10 },
    Callback = function(value)
        StaminaSettings.StaminaLoss = value
        updateStaminaSettings()
    end
})

staminaSection:Slider({
    Title = "奔跑速度",
    Value = { Min = 0, Max = 200, Default = 28 },
    Callback = function(value)
        StaminaSettings.SprintSpeed = value
        updateStaminaSettings()
    end
})

-- ==================== 自瞄选项卡 ====================
local aimbotSurvivorSection = Tabs.Aimbot:Section({ Title = "幸存者自瞄", Icon = "users", Opened = true })

-- 机会自瞄
aimbotSurvivorSection:Toggle({
    Title = "机会自瞄",
    Value = false,
    Callback = function(state)
        CA = state
        if state then
            if game.Players.LocalPlayer.Character.Name ~= "Chance" then
                WindUI:Notify({ Title = "提示", Content = "你用的角色不是机会,无法生效", Duration = 3 })
                return
            end
            local RemoteEvent = game:GetService("ReplicatedStorage"):WaitForChild("Modules"):WaitForChild("Network"):WaitForChild("RemoteEvent")
            CAbotConnection = RemoteEvent.OnClientEvent:Connect(function(...)
                local args = {...}
                if args[1] == "UseActorAbility" and args[2] == "Shoot" then
                    local killerContainer = game.Workspace.Players:FindFirstChild("Killers")
                    if killerContainer then
                        local killer = killerContainer:FindFirstChildOfClass("Model")
                        if killer and killer:FindFirstChild("HumanoidRootPart") then
                            local killerHRP = killer.HumanoidRootPart
                            local playerHRP = game.Players.LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                            if playerHRP then
                                local endTime = tick() + 2
                                while tick() < endTime do
                                    game:GetService("RunService").RenderStepped:Wait()
                                    game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = killerHRP.CFrame + Vector3.new(0, 0, -2)
                                end
                            end
                        end
                    end
                end
            end)
        else
            if CAbotConnection then CAbotConnection:Disconnect(); CAbotConnection = nil end
        end
    end
})

-- 两次自瞄
aimbotSurvivorSection:Toggle({
    Title = "两次自瞄",
    Value = false,
    Callback = function(state)
        TWOTIME = state
        if state and game.Players.LocalPlayer.Character.Name ~= "TwoTime" then
            WindUI:Notify({ Title = "提示", Content = "角色不是Two Time，无法生效", Duration = 3 })
            return
        end
        if state then
            local soundIds = {"rbxassetid://86710781315432", "rbxassetid://99820161736138"}
            TWOloop = game.Players.LocalPlayer.Character.HumanoidRootPart.ChildAdded:Connect(function(child)
                if not TWOTIME then return end
                for _, v in pairs(soundIds) do
                    if child.Name == v then
                        local survivors = {}
                        for _, player in pairs(game:GetService("Players"):GetPlayers()) do
                            if player ~= game.Players.LocalPlayer then
                                local character = player.Character
                                if character and character:FindFirstChild("HumanoidRootPart") then
                                    table.insert(survivors, character)
                                end
                            end
                        end
                        local nearestSurvivor = nil
                        local shortestDistance = math.huge
                        for _, survivor in pairs(survivors) do
                            local survivorHRP = survivor.HumanoidRootPart
                            local playerHRP = game.Players.LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                            if playerHRP then
                                local distance = (survivorHRP.Position - playerHRP.Position).Magnitude
                                if distance < shortestDistance then
                                    shortestDistance = distance
                                    nearestSurvivor = survivor
                                end
                            end
                        end
                        if nearestSurvivor then
                            local nearestHRP = nearestSurvivor.HumanoidRootPart
                            local playerHRP = game.Players.LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                            if playerHRP then
                                local num = 1
                                local maxIterations = child.Name == "rbxassetid://79782181585087" and 220 or 100
                                while num <= maxIterations do
                                    task.wait(0.01)
                                    num = num + 1
                                    workspace.CurrentCamera.CFrame = CFrame.new(workspace.CurrentCamera.CFrame.Position, nearestHRP.Position)
                                    playerHRP.CFrame = CFrame.lookAt(playerHRP.Position, Vector3.new(nearestHRP.Position.X, nearestHRP.Position.Y, nearestHRP.Position.Z))
                                end
                            end
                        end
                    end
                end
            end)
        else
            if TWOloop then TWOloop:Disconnect(); TWOloop = nil end
        end
    end
})

-- 谢德利茨基自瞄
aimbotSurvivorSection:Toggle({
    Title = "谢德利茨基自瞄",
    Value = false,
    Callback = function(state)
        shedaim = state
        if state and game.Players.LocalPlayer.Character.Name ~= "Shedletsky" then
            WindUI:Notify({ Title = "提示", Content = "角色不是谢德利茨基,无法生效", Duration = 3 })
            return
        end
        if state then
            shedloop = game.Players.LocalPlayer.Character.Sword.ChildAdded:Connect(function(child)
                if not shedaim then return end
                if child:IsA("Sound") then
                    local FAN = child.Name
                    if FAN == "rbxassetid://12222225" or FAN == "83851356262523" then
                        local killersFolder = game.Workspace.Players:FindFirstChild("Killers")
                        if killersFolder then
                            local killer = killersFolder:FindFirstChildOfClass("Model")
                            if killer and killer:FindFirstChild("HumanoidRootPart") then
                                local killerHRP = killer.HumanoidRootPart
                                local playerHRP = game.Players.LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                                if playerHRP then
                                    local num = 1
                                    while num <= 100 do
                                        task.wait(0.01)
                                        num = num + 1
                                        workspace.CurrentCamera.CFrame = CFrame.new(workspace.CurrentCamera.CFrame.Position, killerHRP.Position)
                                        playerHRP.CFrame = CFrame.lookAt(playerHRP.Position, killerHRP.Position)
                                    end
                                end
                            end
                        end
                    end
                end
            end)
        else
            if shedloop then shedloop:Disconnect(); shedloop = nil end
        end
    end
})

local aimbotKillerSection = Tabs.Aimbot:Section({ Title = "杀手自瞄", Icon = "skull", Opened = true })

-- 1x4自瞄
aimbotKillerSection:Toggle({
    Title = "1x4自瞄",
    Value = false,
    Callback = function(state)
        aimbot1x1 = state
        if state and game.Players.LocalPlayer.Character.Name ~= "1x1x1x1" then
            WindUI:Notify({ Title = "提示", Content = "角色不是1x4，无法生效", Duration = 3 })
            return
        end
        if state then
            local soundIds = {"rbxassetid://79782181585087", "rbxassetid://128711903717226"}
            aimbot1x1loop = game.Players.LocalPlayer.Character.HumanoidRootPart.ChildAdded:Connect(function(child)
                if not aimbot1x1 then return end
                for _, v in pairs(soundIds) do
                    if child.Name == v then
                        local survivors = {}
                        for _, player in pairs(game:GetService("Players"):GetPlayers()) do
                            if player ~= game.Players.LocalPlayer then
                                local character = player.Character
                                if character and character:FindFirstChild("HumanoidRootPart") then
                                    table.insert(survivors, character)
                                end
                            end
                        end
                        local nearestSurvivor = nil
                        local shortestDistance = math.huge
                        for _, survivor in pairs(survivors) do
                            local survivorHRP = survivor.HumanoidRootPart
                            local playerHRP = game.Players.LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                            if playerHRP then
                                local distance = (survivorHRP.Position - playerHRP.Position).Magnitude
                                if distance < shortestDistance then
                                    shortestDistance = distance
                                    nearestSurvivor = survivor
                                end
                            end
                        end
                        if nearestSurvivor then
                            local nearestHRP = nearestSurvivor.HumanoidRootPart
                            local playerHRP = game.Players.LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                            if playerHRP then
                                local num = 1
                                while num <= 100 do
                                    task.wait(0.01)
                                    num = num + 1
                                    workspace.CurrentCamera.CFrame = CFrame.new(workspace.CurrentCamera.CFrame.Position, nearestHRP.Position)
                                    playerHRP.CFrame = CFrame.lookAt(playerHRP.Position, Vector3.new(nearestHRP.Position.X, nearestHRP.Position.Y, nearestHRP.Position.Z))
                                end
                            end
                        end
                    end
                end
            end)
        else
            if aimbot1x1loop then aimbot1x1loop:Disconnect(); aimbot1x1loop = nil end
        end
    end
})

-- 酷小孩自瞄
aimbotKillerSection:Toggle({
    Title = "酷小孩自瞄",
    Value = false,
    Callback = function(state)
        cool = state
        if state and game.Players.LocalPlayer.Character.Name ~= "c00lkidd" then
            WindUI:Notify({ Title = "提示", Content = "角色不是c00lkidd，无法生效", Duration = 3 })
            return
        end
        if state then
            local soundIds = {"rbxassetid://111033845010938", "rbxassetid://106484876889079"}
            coolloop = game.Players.LocalPlayer.Character.HumanoidRootPart.ChildAdded:Connect(function(child)
                if not cool then return end
                for _, v in pairs(soundIds) do
                    if child.Name == v then
                        local survivors = {}
                        for _, player in pairs(game:GetService("Players"):GetPlayers()) do
                            if player ~= game.Players.LocalPlayer then
                                local character = player.Character
                                if character and character:FindFirstChild("HumanoidRootPart") then
                                    table.insert(survivors, character)
                                end
                            end
                        end
                        local nearestSurvivor = nil
                        local shortestDistance = math.huge
                        for _, survivor in pairs(survivors) do
                            local survivorHRP = survivor.HumanoidRootPart
                            local playerHRP = game.Players.LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                            if playerHRP then
                                local distance = (survivorHRP.Position - playerHRP.Position).Magnitude
                                if distance < shortestDistance then
                                    shortestDistance = distance
                                    nearestSurvivor = survivor
                                end
                            end
                        end
                        if nearestSurvivor then
                            local nearestHRP = nearestSurvivor.HumanoidRootPart
                            local playerHRP = game.Players.LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                            if playerHRP then
                                local num = 1
                                local maxIterations = child.Name == "rbxassetid://79782181585087" and 220 or 100
                                while num <= maxIterations do
                                    task.wait(0.01)
                                    num = num + 1
                                    workspace.CurrentCamera.CFrame = CFrame.new(workspace.CurrentCamera.CFrame.Position, nearestHRP.Position)
                                end
                            end
                        end
                    end
                end
            end)
        else
            if coolloop then coolloop:Disconnect(); coolloop = nil end
        end
    end
})

-- 约翰自瞄
aimbotKillerSection:Toggle({
    Title = "约翰自瞄",
    Value = false,
    Callback = function(state)
        johnaim = state
        if state and game.Players.LocalPlayer.Character.Name ~= "JohnDoe" then
            WindUI:Notify({ Title = "提示", Content = "角色不是JohnDoe，无法生效", Duration = 3 })
            return
        end
        if state then
            local soundIds = {"rbxassetid://109525294317144"}
            johnloop = game.Players.LocalPlayer.Character.HumanoidRootPart.ChildAdded:Connect(function(child)
                if not johnaim then return end
                for _, v in pairs(soundIds) do
                    if child.Name == v then
                        local survivors = {}
                        for _, player in pairs(game:GetService("Players"):GetPlayers()) do
                            if player ~= game.Players.LocalPlayer then
                                local character = player.Character
                                if character and character:FindFirstChild("HumanoidRootPart") then
                                    table.insert(survivors, character)
                                end
                            end
                        end
                        local nearestSurvivor = nil
                        local shortestDistance = math.huge
                        for _, survivor in pairs(survivors) do
                            local survivorHRP = survivor.HumanoidRootPart
                            local playerHRP = game.Players.LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                            if playerHRP then
                                local distance = (survivorHRP.Position - playerHRP.Position).Magnitude
                                if distance < shortestDistance then
                                    shortestDistance = distance
                                    nearestSurvivor = survivor
                                end
                            end
                        end
                        if nearestSurvivor then
                            local nearestHRP = nearestSurvivor.HumanoidRootPart
                            local playerHRP = game.Players.LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                            if playerHRP then
                                local num = 1
                                while num <= 330 do
                                    task.wait(0.01)
                                    num = num + 1
                                    workspace.CurrentCamera.CFrame = CFrame.new(workspace.CurrentCamera.CFrame.Position, nearestHRP.Position)
                                    playerHRP.CFrame = CFrame.lookAt(playerHRP.Position, Vector3.new(nearestHRP.Position.X, nearestHRP.Position.Y, nearestHRP.Position.Z))
                                end
                            end
                        end
                    end
                end
            end)
        else
            if johnloop then johnloop:Disconnect(); johnloop = nil end
        end
    end
})

-- 杰森自瞄
aimbotKillerSection:Toggle({
    Title = "杰森自瞄",
    Value = false,
    Callback = function(state)
        jasonaim = state
        if state and game.Players.LocalPlayer.Character.Name ~= "Jason" then
            WindUI:Notify({ Title = "提示", Content = "角色不是Jason，无法生效", Duration = 3 })
            return
        end
        if state then
            local soundIds = {"rbxassetid://112809109188560", "rbxassetid://102228729296384"}
            jasonaimbotloop = game.Players.LocalPlayer.Character.HumanoidRootPart.ChildAdded:Connect(function(child)
                if not jasonaim then return end
                for _, v in pairs(soundIds) do
                    if child.Name == v then
                        local survivors = {}
                        for _, player in pairs(game:GetService("Players"):GetPlayers()) do
                            if player ~= game.Players.LocalPlayer then
                                local character = player.Character
                                if character and character:FindFirstChild("HumanoidRootPart") then
                                    table.insert(survivors, character)
                                end
                            end
                        end
                        local nearestSurvivor = nil
                        local shortestDistance = math.huge
                        for _, survivor in pairs(survivors) do
                            local survivorHRP = survivor.HumanoidRootPart
                            local playerHRP = game.Players.LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                            if playerHRP then
                                local distance = (survivorHRP.Position - playerHRP.Position).Magnitude
                                if distance < shortestDistance then
                                    shortestDistance = distance
                                    nearestSurvivor = survivor
                                end
                            end
                        end
                        if nearestSurvivor then
                            local nearestHRP = nearestSurvivor.HumanoidRootPart
                            local playerHRP = game.Players.LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                            if playerHRP then
                                local num = 1
                                while num <= 70 do
                                    task.wait(0.01)
                                    num = num + 1
                                    playerHRP.CFrame = CFrame.lookAt(playerHRP.Position, Vector3.new(nearestHRP.Position.X, nearestHRP.Position.Y, nearestHRP.Position.Z))
                                end
                            end
                        end
                    end
                end
            end)
        else
            if jasonaimbotloop then jasonaimbotloop:Disconnect(); jasonaimbotloop = nil end
        end
    end
})

-- ==================== 绘制选项卡 ====================
local espGeneralSection = Tabs.ESP:Section({ Title = "基础绘制", Icon = "eye", Opened = true })

-- 幸存者绘制开关
local survivorESPEnabled = false
local killerESPEnabled = false
local distanceESPEnabled = false
local healthBarESPEnabled = false
local boxESPEnabled = false
local skeletonESPEnabled = false
local tracerESPEnabled = false

-- 距离显示变量
local distanceLabels = {}
local distanceConnection = nil

-- 血量条变量
local healthBarDrawings = {}
local healthBarConnection = nil

-- 方框变量
local boxDrawings = {}
local boxConnection = nil

-- 骨骼变量
local skeletonDrawings = {}
local skeletonConnection = nil

-- 追踪线变量
local tracerDrawings = {}
local tracerConnection = nil

espGeneralSection:Toggle({
    Title = "幸存者绘制",
    Value = false,
    Callback = function(state)
        survivorESPEnabled = state
        -- 这里需要实现ESP绘制，简化版使用Highlight
        if state then
            local survivorsFolder = workspace.Players:FindFirstChild("Survivors")
            if survivorsFolder then
                for _, survivor in ipairs(survivorsFolder:GetChildren()) do
                    if survivor:IsA("Model") and survivor ~= game.Players.LocalPlayer.Character then
                        local highlight = Instance.new("Highlight")
                        highlight.Name = "SurvivorESP"
                        highlight.FillColor = Color3.fromRGB(0, 191, 255)
                        highlight.FillTransparency = 0.5
                        highlight.OutlineColor = Color3.fromRGB(0, 191, 255)
                        highlight.Parent = survivor
                    end
                end
            end
            workspace.Players.ChildAdded:Connect(function(child)
                if child.Name == "Survivors" then
                    child.ChildAdded:Connect(function(survivor)
                        if survivor:IsA("Model") and survivor ~= game.Players.LocalPlayer.Character then
                            local highlight = Instance.new("Highlight")
                            highlight.Name = "SurvivorESP"
                            highlight.FillColor = Color3.fromRGB(0, 191, 255)
                            highlight.FillTransparency = 0.5
                            highlight.Parent = survivor
                        end
                    end)
                end
            end)
        else
            for _, survivor in pairs(workspace.Players:GetDescendants()) do
                if survivor:IsA("Highlight") and survivor.Name == "SurvivorESP" then
                    survivor:Destroy()
                end
            end
        end
    end
})

espGeneralSection:Toggle({
    Title = "杀手绘制",
    Value = false,
    Callback = function(state)
        killerESPEnabled = state
        if state then
            local killersFolder = workspace.Players:FindFirstChild("Killers")
            if killersFolder then
                for _, killer in ipairs(killersFolder:GetChildren()) do
                    if killer:IsA("Model") then
                        local highlight = Instance.new("Highlight")
                        highlight.Name = "KillerESP"
                        highlight.FillColor = Color3.fromRGB(255, 0, 0)
                        highlight.FillTransparency = 0.5
                        highlight.Parent = killer
                    end
                end
            end
        else
            for _, killer in pairs(workspace.Players:GetDescendants()) do
                if killer:IsA("Highlight") and killer.Name == "KillerESP" then
                    killer:Destroy()
                end
            end
        end
    end
})

-- 距离绘制
espGeneralSection:Toggle({
    Title = "距离绘制",
    Value = false,
    Callback = function(state)
        distanceESPEnabled = state
        if distanceConnection then distanceConnection:Disconnect() end
        if state then
            distanceConnection = game:GetService("RunService").RenderStepped:Connect(function()
                local camera = workspace.CurrentCamera
                local localPlayer = game.Players.LocalPlayer
                local localChar = localPlayer.Character
                if not localChar or not localChar:FindFirstChild("HumanoidRootPart") then return end
                local localPos = localChar.HumanoidRootPart.Position
                
                local playersFolder = workspace.Players
                if playersFolder then
                    for _, folder in ipairs(playersFolder:GetChildren()) do
                        if folder.Name == "Survivors" or folder.Name == "Killers" then
                            for _, model in ipairs(folder:GetChildren()) do
                                if model:IsA("Model") and model ~= localChar then
                                    local hrp = model:FindFirstChild("HumanoidRootPart")
                                    if hrp then
                                        if not distanceLabels[model] then
                                            distanceLabels[model] = Drawing.new("Text")
                                            distanceLabels[model].Size = 14
                                            distanceLabels[model].Center = true
                                            distanceLabels[model].Outline = true
                                        end
                                        local screenPos, onScreen = camera:WorldToViewportPoint(hrp.Position - Vector3.new(0, 3, 0))
                                        if onScreen then
                                            local distance = math.floor((hrp.Position - localPos).Magnitude)
                                            distanceLabels[model].Position = Vector2.new(screenPos.X, screenPos.Y)
                                            distanceLabels[model].Text = tostring(distance) .. "m"
                                            distanceLabels[model].Color = folder.Name == "Survivors" and Color3.fromRGB(0, 191, 255) or Color3.fromRGB(255, 0, 0)
                                            distanceLabels[model].Visible = true
                                        else
                                            distanceLabels[model].Visible = false
                                        end
                                    end
                                end
                            end
                        end
                    end
                end
            end)
        else
            for _, label in pairs(distanceLabels) do
                if label then label:Remove() end
            end
            distanceLabels = {}
        end
    end
})

-- 方框绘制
espGeneralSection:Toggle({
    Title = "方框绘制",
    Value = false,
    Callback = function(state)
        boxESPEnabled = state
        if boxConnection then boxConnection:Disconnect() end
        if state then
            local function getBounds(character)
                local min = Vector3.new(math.huge, math.huge, math.huge)
                local max = Vector3.new(-math.huge, -math.huge, -math.huge)
                for _, part in character:GetChildren() do
                    if part:IsA("BasePart") then
                        local pos = part.Position
                        min = Vector3.new(math.min(min.X, pos.X), math.min(min.Y, pos.Y), math.min(min.Z, pos.Z))
                        max = Vector3.new(math.max(max.X, pos.X), math.max(max.Y, pos.Y), math.max(max.Z, pos.Z))
                    end
                end
                return min, max
            end
            
            boxConnection = game:GetService("RunService").RenderStepped:Connect(function()
                local camera = workspace.CurrentCamera
                local localPlayer = game.Players.LocalPlayer
                local playersFolder = workspace.Players
                
                if not playersFolder then return end
                
                for _, folder in ipairs(playersFolder:GetChildren()) do
                    if folder.Name == "Survivors" or folder.Name == "Killers" then
                        for _, model in ipairs(folder:GetChildren()) do
                            if model:IsA("Model") and model ~= localPlayer.Character then
                                local min, max = getBounds(model)
                                local points = {
                                    Vector3.new(min.X, min.Y, min.Z), Vector3.new(min.X, max.Y, min.Z),
                                    Vector3.new(max.X, min.Y, min.Z), Vector3.new(max.X, max.Y, min.Z),
                                    Vector3.new(min.X, min.Y, max.Z), Vector3.new(min.X, max.Y, max.Z),
                                    Vector3.new(max.X, min.Y, max.Z), Vector3.new(max.X, max.Y, max.Z),
                                }
                                
                                local min2d = Vector2.new(math.huge, math.huge)
                                local max2d = Vector2.new(-math.huge, -math.huge)
                                local visible = false
                                
                                for _, point in ipairs(points) do
                                    local screen, onScreen = camera:WorldToViewportPoint(point)
                                    if onScreen then
                                        visible = true
                                        local pos2d = Vector2.new(screen.X, screen.Y)
                                        min2d = Vector2.new(math.min(min2d.X, pos2d.X), math.min(min2d.Y, pos2d.Y))
                                        max2d = Vector2.new(math.max(max2d.X, pos2d.X), math.max(max2d.Y, pos2d.Y))
                                    end
                                end
                                
                                if not boxDrawings[model] then
                                    boxDrawings[model] = { box = Drawing.new("Square"), outline = Drawing.new("Square") }
                                    boxDrawings[model].box.Thickness = 1
                                    boxDrawings[model].box.Filled = false
                                    boxDrawings[model].outline.Thickness = 2
                                    boxDrawings[model].outline.Filled = false
                                end
                                
                                local box = boxDrawings[model].box
                                local outline = boxDrawings[model].outline
                                
                                if visible then
                                    local size = max2d - min2d
                                    box.Position = min2d
                                    box.Size = size
                                    box.Color = folder.Name == "Survivors" and Color3.fromRGB(0, 191, 255) or Color3.fromRGB(255, 0, 0)
                                    box.Visible = true
                                    outline.Position = min2d - Vector2.new(1, 1)
                                    outline.Size = size + Vector2.new(2, 2)
                                    outline.Color = Color3.new(0, 0, 0)
                                    outline.Visible = true
                                else
                                    box.Visible = false
                                    outline.Visible = false
                                end
                            end
                        end
                    end
                end
            end)
        else
            for _, data in pairs(boxDrawings) do
                if data.box then data.box:Remove() end
                if data.outline then data.outline:Remove() end
            end
            boxDrawings = {}
        end
    end
})

-- 骨骼绘制
espGeneralSection:Toggle({
    Title = "骨骼绘制",
    Value = false,
    Callback = function(state)
        skeletonESPEnabled = state
        if skeletonConnection then skeletonConnection:Disconnect() end
        if state then
            local function createSkeletonLines()
                return {
                    head = Drawing.new("Line"), torso = Drawing.new("Line"),
                    left_arm = Drawing.new("Line"), right_arm = Drawing.new("Line"),
                    left_leg = Drawing.new("Line"), right_leg = Drawing.new("Line")
                }
            end
            
            skeletonConnection = game:GetService("RunService").RenderStepped:Connect(function()
                local camera = workspace.CurrentCamera
                local playersFolder = workspace.Players
                
                if not playersFolder then return end
                
                for _, folder in ipairs(playersFolder:GetChildren()) do
                    if folder.Name == "Survivors" or folder.Name == "Killers" then
                        for _, model in ipairs(folder:GetChildren()) do
                            if model:IsA("Model") then
                                local parts = {
                                    head = model:FindFirstChild("Head"),
                                    upper = model:FindFirstChild("UpperTorso") or model:FindFirstChild("Torso"),
                                    lower = model:FindFirstChild("LowerTorso") or model:FindFirstChild("HumanoidRootPart"),
                                    left_arm = model:FindFirstChild("LeftUpperArm") or model:FindFirstChild("Left Arm"),
                                    right_arm = model:FindFirstChild("RightUpperArm") or model:FindFirstChild("Right Arm"),
                                    left_leg = model:FindFirstChild("LeftUpperLeg") or model:FindFirstChild("Left Leg"),
                                    right_leg = model:FindFirstChild("RightUpperLeg") or model:FindFirstChild("Right Leg")
                                }
                                
                                if parts.head and parts.upper and parts.lower and parts.left_arm and parts.right_arm and parts.left_leg and parts.right_leg then
                                    if not skeletonDrawings[model] then
                                        skeletonDrawings[model] = createSkeletonLines()
                                    end
                                    
                                    local skel = skeletonDrawings[model]
                                    local function toScreen(part)
                                        local pos, on = camera:WorldToViewportPoint(part.Position)
                                        return Vector2.new(pos.X, pos.Y), on
                                    end
                                    
                                    local headPos, headOn = toScreen(parts.head)
                                    local upperPos, upperOn = toScreen(parts.upper)
                                    local lowerPos, lowerOn = toScreen(parts.lower)
                                    local larmPos, larmOn = toScreen(parts.left_arm)
                                    local rarmPos, rarmOn = toScreen(parts.right_arm)
                                    local llegPos, llegOn = toScreen(parts.left_leg)
                                    local rlegPos, rlegOn = toScreen(parts.right_leg)
                                    
                                    if headOn and upperOn and lowerOn and larmOn and rarmOn and llegOn and rlegOn then
                                        skel.head.From, skel.head.To = headPos, upperPos
                                        skel.torso.From, skel.torso.To = upperPos, lowerPos
                                        skel.left_arm.From, skel.left_arm.To = upperPos, larmPos
                                        skel.right_arm.From, skel.right_arm.To = upperPos, rarmPos
                                        skel.left_leg.From, skel.left_leg.To = lowerPos, llegPos
                                        skel.right_leg.From, skel.right_leg.To = lowerPos, rlegPos
                                        
                                        for _, line in pairs(skel) do
                                            line.Color = folder.Name == "Survivors" and Color3.fromRGB(0, 191, 255) or Color3.fromRGB(255, 0, 0)
                                            line.Thickness = 1
                                            line.Visible = true
                                        end
                                    else
                                        for _, line in pairs(skel) do line.Visible = false end
                                    end
                                end
                            end
                        end
                    end
                end
            end)
        else
            for _, lines in pairs(skeletonDrawings) do
                for _, line in pairs(lines) do if line then line:Remove() end end
            end
            skeletonDrawings = {}
        end
    end
})

-- 天线绘制（追踪线）
espGeneralSection:Toggle({
    Title = "天线绘制",
    Value = false,
    Callback = function(state)
        tracerESPEnabled = state
        if tracerConnection then tracerConnection:Disconnect() end
        if state then
            tracerConnection = game:GetService("RunService").RenderStepped:Connect(function()
                local camera = workspace.CurrentCamera
                local playersFolder = workspace.Players
                
                if not playersFolder then return end
                
                for _, folder in ipairs(playersFolder:GetChildren()) do
                    if folder.Name == "Survivors" or folder.Name == "Killers" then
                        for _, model in ipairs(folder:GetChildren()) do
                            if model:IsA("Model") and model ~= game.Players.LocalPlayer.Character then
                                local hrp = model:FindFirstChild("HumanoidRootPart")
                                if hrp then
                                    local screenPos, onScreen = camera:WorldToViewportPoint(hrp.Position)
                                    if onScreen then
                                        if not tracerDrawings[model] then
                                            tracerDrawings[model] = Drawing.new("Line")
                                            tracerDrawings[model].Thickness = 1
                                        end
                                        local tracer = tracerDrawings[model]
                                        tracer.From = Vector2.new(camera.ViewportSize.X / 2, 0)
                                        tracer.To = Vector2.new(screenPos.X, screenPos.Y)
                                        tracer.Color = folder.Name == "Survivors" and Color3.fromRGB(0, 191, 255) or Color3.fromRGB(255, 0, 0)
                                        tracer.Visible = true
                                    elseif tracerDrawings[model] then
                                        tracerDrawings[model].Visible = false
                                    end
                                end
                            end
                        end
                    end
                end
            end)
        else
            for _, tracer in pairs(tracerDrawings) do if tracer then tracer:Remove() end end
            tracerDrawings = {}
        end
    end
})

-- ==================== 拾取选项卡 ====================
local itemsSection = Tabs.Items:Section({ Title = "自动拾取", Icon = "package", Opened = true })

itemsSection:Toggle({
    Title = "医疗包传送并拾取",
    Value = false,
    Callback = function(state)
        autoTeleportMedkitEnabled = state
        if state then startTeleportMedkit() else stopTeleportMedkit() end
    end
})

itemsSection:Toggle({
    Title = "可乐传送并拾取",
    Value = false,
    Callback = function(state)
        autoTeleportColaEnabled = state
        if state then startTeleportCola() else stopTeleportCola() end
    end
})

itemsSection:Divider()

itemsSection:Toggle({
    Title = "自动互动医疗包",
    Value = false,
    Callback = function(state)
        autoMedkitEnabled = state
        if state then startAutoMedkit() else stopAutoMedkit() end
    end
})

itemsSection:Toggle({
    Title = "自动互动可乐",
    Value = false,
    Callback = function(state)
        autoColaEnabled = state
        if state then startAutoCola() else stopAutoCola() end
    end
})

-- ==================== 战斗选项卡 ====================
local combatSection = Tabs.Combat:Section({ Title = "自动战斗", Icon = "sword", Opened = true })

combatSection:Toggle({
    Title = "自动格挡",
    Value = false,
    Callback = function(state)
        if state then startAutoBlock() else stopAutoBlock() end
    end
})

combatSection:Slider({
    Title = "格挡距离",
    Value = { Min = 5, Max = 30, Default = 15 },
    Callback = function(value)
        config.BlockDistance = value
    end
})

combatSection:Toggle({
    Title = "预判系统",
    Value = true,
    Callback = function(state)
        config.PredictEnabled = state
    end
})

combatSection:Slider({
    Title = "预判距离",
    Value = { Min = 0, Max = 10, Default = 2, Step = 0.5 },
    Callback = function(value)
        config.BasePredictAmount = value
    end
})

combatSection:Divider()

combatSection:Toggle({
    Title = "自动修机",
    Value = false,
    Callback = function(state)
        _G.AutoFixEnabled = state
        if state then startAutoFix() end
    end
})

combatSection:Slider({
    Title = "修机间隔",
    Value = { Min = 1, Max = 12, Default = 1.5, Step = 0.5 },
    Callback = function(value)
        _G.AutoGeneratorDelay = value
    end
})

-- ==================== 画面选项卡 ====================
local visualSection = Tabs.Visual:Section({ Title = "画面调节", Icon = "sun", Opened = true })

visualSection:Toggle({
    Title = "启用亮度调节",
    Value = false,
    Callback = function(state)
        _env.Fullbright = state
        setupFullbright()
    end
})

visualSection:Slider({
    Title = "亮度数值",
    Value = { Min = 0, Max = 3, Default = 0, Step = 0.1 },
    Callback = function(value)
        _env.Brightness = value
    end
})

visualSection:Toggle({
    Title = "无阴影",
    Value = false,
    Callback = function(state)
        _env.GlobalShadows = state
    end
})

visualSection:Toggle({
    Title = "除雾",
    Value = false,
    Callback = function(state)
        _env.NoFog = state
    end
})

visualSection:Divider()

visualSection:Toggle({
    Title = "视野调节",
    Value = false,
    Callback = function(state)
        _env.FOV = state
        setupFOV()
    end
})

visualSection:Slider({
    Title = "视野范围",
    Value = { Min = 70, Max = 120, Default = 70 },
    Callback = function(value)
        _env.FovValue = value
    end
})

-- ==================== 设置选项卡 ====================
local settingsSection = Tabs.Settings:Section({ Title = "UI设置", Icon = "settings", Opened = true })

settingsSection:Toggle({
    Title = "显示快捷菜单",
    Value = true,
    Callback = function(state)
        -- 可以添加快捷菜单显示功能
    end
})

settingsSection:Toggle({
    Title = "自定义光标",
    Value = true,
    Callback = function(state)
        -- 自定义光标功能
    end
})

settingsSection:Dropdown({
    Title = "通知位置",
    Values = { "左", "右" },
    Value = "右",
    Callback = function(value)
        -- 设置通知位置
    end
})

settingsSection:Button({
    Title = "删除UI",
    Callback = function()
        Window:Destroy()
    end
})

-- 窗口关闭清理
Window:OnClose(function()
    print("窗口关闭")
    -- 清理所有连接和线程
    if teleportMedkitThread then task.cancel(teleportMedkitThread) end
    if teleportColaThread then task.cancel(teleportColaThread) end
    if medkitThread then task.cancel(medkitThread) end
    if colaThread then task.cancel(colaThread) end
    if staminaConnection then staminaConnection:Disconnect() end
    if combatConnection then combatConnection:Disconnect() end
    if pizzaConnection then pizzaConnection:Disconnect() end
    if pizzaTPConnection then pizzaTPConnection:Disconnect() end
    if tripmineConnection then tripmineConnection:Disconnect() end
    if distanceConnection then distanceConnection:Disconnect() end
    if healthBarConnection then healthBarConnection:Disconnect() end
    if boxConnection then boxConnection:Disconnect() end
    if skeletonConnection then skeletonConnection:Disconnect() end
    if tracerConnection then tracerConnection:Disconnect() end
    if aimbot1x1loop then aimbot1x1loop:Disconnect() end
    if coolloop then coolloop:Disconnect() end
    if TWOloop then TWOloop:Disconnect() end
    if johnloop then johnloop:Disconnect() end
    if jasonaimbotloop then jasonaimbotloop:Disconnect() end
    if CAbotConnection then CAbotConnection:Disconnect() end
    if shedloop then shedloop:Disconnect() end
end)

print("被遗弃脚本已加载，按F键打开/关闭菜单")