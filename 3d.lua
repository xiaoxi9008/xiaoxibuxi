-- 纯3D立体悬浮UI脚本（无音乐/可视化）
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

-- 等待本地玩家
local player = Players.LocalPlayer
while not player do task.wait() end
local camera = workspace.CurrentCamera or workspace:WaitForChild("Camera")

-- 清理旧UI
local oldGui = player.PlayerGui:FindFirstChild("3D_Stereo_UI")
if oldGui then oldGui:Destroy() end

-- 创建主ScreenGui
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "3D_Stereo_UI"
ScreenGui.Parent = player.PlayerGui
ScreenGui.IgnoreGuiInset = true
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

-- ==============================================
-- 主面板（带悬浮效果）
-- ==============================================
local MainPanel = Instance.new("Frame")
MainPanel.Name = "MainPanel"
MainPanel.Size = UDim2.new(0, 220, 0, 280)
MainPanel.Position = UDim2.new(0.55, 0, 0.3, 0)
MainPanel.BackgroundColor3 = Color3.new(0.1, 0.12, 0.15)
MainPanel.BackgroundTransparency = 0.2
MainPanel.BorderSizePixel = 0
MainPanel.Parent = ScreenGui

-- 圆角
local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 10)
MainCorner.Parent = MainPanel

-- 标题栏
local TitleBar = Instance.new("Frame")
TitleBar.Size = UDim2.new(1, 0, 0, 35)
TitleBar.BackgroundColor3 = Color3.new(0.06, 0.07, 0.1)
TitleBar.Parent = MainPanel

local TitleCorner = Instance.new("UICorner")
TitleCorner.CornerRadius = UDim.new(0, 10)
TitleCorner.TopLeftMode = Enum.UICornerType.Trimmable
TitleCorner.TopRightMode = Enum.UICornerType.Trimmable
TitleCorner.Parent = TitleBar

local TitleIcon = Instance.new("ImageLabel")
TitleIcon.Size = UDim2.new(0, 28, 0, 28)
TitleIcon.Position = UDim2.new(0, 5, 0, 3.5)
TitleIcon.Image = "rbxassetid://15219101936" -- 悬浮图标
TitleIcon.BackgroundTransparency = 1
TitleIcon.Parent = TitleBar

local TitleText = Instance.new("TextLabel")
TitleText.Text = "Link"
TitleText.Size = UDim2.new(1, -45, 1, 0)
TitleText.Position = UDim2.new(0, 40, 0, 0)
TitleText.TextColor3 = Color3.new(0, 0.85, 1)
TitleText.Font = Enum.Font.GothamBold
TitleText.TextSize = 15
TitleText.BackgroundTransparency = 1
TitleText.Parent = TitleBar

-- 面板内容区域（可自定义添加按钮/文本）
local ContentArea = Instance.new("Frame")
ContentArea.Size = UDim2.new(1, -20, 1, -45)
ContentArea.Position = UDim2.new(0, 10, 0, 40)
ContentArea.BackgroundTransparency = 1
ContentArea.Parent = MainPanel

local PlaceholderText = Instance.new("TextLabel")
PlaceholderText.Text = "3D 立体面板"
PlaceholderText.Size = UDim2.new(1, 0, 1, 0)
PlaceholderText.TextColor3 = Color3.new(0.7, 0.75, 0.8)
PlaceholderText.Font = Enum.Font.Gotham
PlaceholderText.TextSize = 14
PlaceholderText.TextXAlignment = Enum.TextXAlignment.Center
PlaceholderText.BackgroundTransparency = 1
PlaceholderText.Parent = ContentArea

-- ==============================================
-- 小悬浮图标面板（匹配你截图的Link图标）
-- ==============================================
local MiniPanel = Instance.new("ImageLabel")
MiniPanel.Name = "MiniPanel"
MiniPanel.Size = UDim2.new(0, 50, 0, 50)
MiniPanel.Position = UDim2.new(0.45, 0, 0.35, 0)
MiniPanel.Image = "rbxassetid://15219101936" -- 悬浮图标
MiniPanel.BackgroundTransparency = 1
MiniPanel.Parent = ScreenGui

-- ==============================================
-- 3D悬浮+倾斜动画
-- ==============================================
RunService.RenderStepped:Connect(function(dt)
    -- 主面板轻微悬浮摇摆
    MainPanel.Rotation = math.sin(os.clock() * 1.5) * 1.2
    MainPanel.Position = UDim2.new(0.55, 0, 0.3 + math.sin(os.clock() * 2) * 0.01, 0)
    
    -- 小图标面板更活泼的悬浮
    MiniPanel.Rotation = math.sin(os.clock() * 3) * 3
    MiniPanel.Position = UDim2.new(0.45, 0, 0.35 + math.sin(os.clock() * 3) * 0.015, 0)
end)

-- ==============================================
-- 拖拽功能（可拖动面板移动）
-- ==============================================
local function makeDraggable(guiObject)
    local dragging = false
    local dragStart, startPos

    local function onInputBegan(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = guiObject.Position
        end
    end

    local function onInputChanged(input)
        if dragging then
            local delta = input.Position - dragStart
            guiObject.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end

    local function onInputEnded(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end

    guiObject.InputBegan:Connect(onInputBegan)
    UserInputService.InputChanged:Connect(onInputChanged)
    UserInputService.InputEnded:Connect(onInputEnded)
end

-- 给两个面板都加上拖拽
makeDraggable(MainPanel)
makeDraggable(MiniPanel)

print("✅ 纯3D立体UI加载完成")
