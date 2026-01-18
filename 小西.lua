-- 更完整的穿墙+飞行脚本
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local camera = workspace.CurrentCamera

-- 配置
local SPEED = 50
local FLY_SPEED = 100
local toggleKey = Enum.KeyCode.F
local noclipKey = Enum.KeyCode.N

-- 状态
local isFlying = false
local isNoclipping = false
local flyConnection
local noclipConnection
local bodyGyro
local bodyVelocity

-- 初始化
local function initializeCharacter(character)
    local humanoidRootPart = character:WaitForChild("HumanoidRootPart")
    local humanoid = character:WaitForChild("Humanoid")
    
    -- 创建飞行控制对象
    bodyGyro = Instance.new("BodyGyro")
    bodyGyro.P = 10000
    bodyGyro.D = 1000
    bodyGyro.MaxTorque = Vector3.new(40000, 40000, 40000)
    bodyGyro.CFrame = humanoidRootPart.CFrame
    bodyGyro.Parent = humanoidRootPart
    
    bodyVelocity = Instance.new("BodyVelocity")
    bodyVelocity.MaxForce = Vector3.new(40000, 40000, 40000)
    bodyVelocity.Velocity = Vector3.new(0, 0, 0)
    bodyVelocity.Parent = humanoidRootPart
end

-- 飞行模式
local function toggleFlying()
    isFlying = not isFlying
    
    if isFlying then
        print("飞行模式已启用")
        local character = player.Character
        if not character then return end
        
        local humanoid = character:FindFirstChild("Humanoid")
        if humanoid then
            humanoid.PlatformStand = true
        end
        
        flyConnection = RunService.RenderStepped:Connect(function(delta)
            if not character or not isFlying then return end
            
            local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
            if not humanoidRootPart then return end
            
            -- 控制输入
            local moveVector = Vector3.new(0, 0, 0)
            
            if UserInputService:IsKeyDown(Enum.KeyCode.W) then
                moveVector = moveVector + camera.CFrame.LookVector
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.S) then
                moveVector = moveVector - camera.CFrame.LookVector
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.A) then
                moveVector = moveVector - camera.CFrame.RightVector
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.D) then
                moveVector = moveVector + camera.CFrame.RightVector
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
                moveVector = moveVector + Vector3.new(0, 1, 0)
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then
                moveVector = moveVector - Vector3.new(0, 1, 0)
            end
            
            if bodyGyro then
                bodyGyro.CFrame = camera.CFrame
            end
            
            if bodyVelocity then
                if moveVector.Magnitude > 0 then
                    moveVector = moveVector.Unit * FLY_SPEED
                end
                bodyVelocity.Velocity = moveVector
            end
        end)
    else
        print("飞行模式已禁用")
        if flyConnection then
            flyConnection:Disconnect()
            flyConnection = nil
        end
        
        local character = player.Character
        if character then
            local humanoid = character:FindFirstChild("Humanoid")
            if humanoid then
                humanoid.PlatformStand = false
            end
            
            if bodyGyro then bodyGyro:Destroy() end
            if bodyVelocity then bodyVelocity:Destroy() end
        end
    end
end

-- 穿墙模式
local function toggleNoclip()
    isNoclipping = not isNoclipping
    
    if isNoclipping then
        print("穿墙模式已启用")
        noclipConnection = RunService.Stepped:Connect(function()
            local character = player.Character
            if character and isNoclipping then
                for _, part in pairs(character:GetDescendants()) do
                    if part:IsA("BasePart") then
                        part.CanCollide = false
                    end
                end
            end
        end)
    else
        print("穿墙模式已禁用")
        if noclipConnection then
            noclipConnection:Disconnect()
            noclipConnection = nil
        end
        
        local character = player.Character
        if character then
            for _, part in pairs(character:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.CanCollide = true
                end
            end
        end
    end
end

-- 按键绑定
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if not gameProcessed then
        if input.KeyCode == toggleKey then
            toggleFlying()
        elseif input.KeyCode == noclipKey then
            toggleNoclip()
        end
    end
end)

-- 初始化
player.CharacterAdded:Connect(initializeCharacter)
if player.Character then
    initializeCharacter(player.Character)
end