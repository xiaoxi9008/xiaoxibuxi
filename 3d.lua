-- 服务获取
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local SoundService = game:GetService("SoundService")

-- 本地玩家与相机
local player = Players.LocalPlayer
local camera = workspace.CurrentCamera

-- 创建 3D 界面容器
local screenGui = Instance.new("ScreenGui")
screenGui.Parent = player.PlayerGui
screenGui.IgnoreGuiInset = true

local mainContainer = Instance.new("Frame")
mainContainer.Name = "VisionAudioPro"
mainContainer.Size = UDim2.new(0, 300, 0, 200)
mainContainer.Position = UDim2.new(0.5, -150, 0.5, -100)
mainContainer.BackgroundColor3 = Color3.new(0.1, 0.1, 0.15)
mainContainer.BackgroundTransparency = 0.2
mainContainer.BorderSizePixel = 0
mainContainer.Parent = screenGui

-- 标题栏
local titleBar = Instance.new("Frame")
titleBar.Size = UDim2.new(1, 0, 0, 30)
titleBar.BackgroundColor3 = Color3.new(0.05, 0.05, 0.1)
titleBar.Parent = mainContainer

local titleLabel = Instance.new("TextLabel")
titleLabel.Text = "Vision Audio Pro"
titleLabel.Size = UDim2.new(1, -40, 1, 0)
titleLabel.Position = UDim2.new(0, 40, 0, 0)
titleLabel.TextColor3 = Color3.new(0, 0.8, 1)
titleLabel.Font = Enum.Font.GothamBold
titleLabel.TextSize = 14
titleLabel.BackgroundTransparency = 1
titleLabel.Parent = titleBar

local icon = Instance.new("ImageLabel")
icon.Size = UDim2.new(0, 30, 0, 30)
icon.Position = UDim2.new(0, 5, 0, 0)
icon.Image = "rbxassetid://123456789" -- 替换为你的图标ID
icon.BackgroundTransparency = 1
icon.Parent = titleBar

-- 音量滑块
local volumeSlider = Instance.new("Frame")
volumeSlider.Size = UDim2.new(0.8, 0, 0, 10)
volumeSlider.Position = UDim2.new(0.1, 0, 0.7, 0)
volumeSlider.BackgroundColor3 = Color3.new(0.2, 0.2, 0.3)
volumeSlider.Parent = mainContainer

local volumeFill = Instance.new("Frame")
volumeFill.Size = UDim2.new(0.5, 0, 1, 0)
volumeFill.BackgroundColor3 = Color3.new(0, 0.8, 1)
volumeFill.Parent = volumeSlider

-- 音频可视化条（3D 弧形）
local visualizerContainer = Instance.new("Frame")
visualizerContainer.Size = UDim2.new(1, 0, 0, 80)
visualizerContainer.Position = UDim2.new(0, 0, 1, 10)
visualizerContainer.BackgroundTransparency = 1
visualizerContainer.Parent = screenGui

local barCount = 32
local barWidth = 15
local maxBarHeight = 60

for i = 1, barCount do
    local bar = Instance.new("Frame")
    bar.Name = "Bar_"..i
    bar.Size = UDim2.new(0, barWidth, 0, 10)
    bar.Position = UDim2.new(i/barCount, -barWidth/2, 0.5, 0)
    bar.AnchorPoint = Vector2.new(0.5, 1)
    bar.BackgroundColor3 = Color3.new(0, 0.8, 1)
    bar.BackgroundTransparency = 0.2
    bar.Parent = visualizerContainer
end

-- 3D 悬浮效果（让 UI 跟随相机并轻微倾斜）
RunService.RenderStepped:Connect(function()
    -- 让界面始终面向相机
    mainContainer.Position = UDim2.new(0.5, 0, 0.5, 0)
    mainContainer.Rotation = math.sin(os.clock() * 2) * 2 -- 轻微左右摇摆
    
    -- 模拟音频可视化（实际项目中可替换为真实音频数据）
    for i, bar in ipairs(visualizerContainer:GetChildren()) do
        if bar:IsA("Frame") then
            local height = math.random(10, maxBarHeight)
            bar.Size = UDim2.new(0, barWidth, 0, height)
            bar.BackgroundTransparency = 1 - (height / maxBarHeight)
        end
    end
end)

-- 播放测试音频
local testSound = Instance.new("Sound")
testSound.SoundId = "rbxassetid://184687259" -- 替换为你的音频ID
testSound.Volume = 0.5
testSound.Looped = true
testSound.Parent = SoundService
testSound:Play()
