-----------------------------------------------------------
-- 秋容脚本验证核心逻辑（LocalScript，适配多注入器）
-- 验证标记：注入器持久化目录下的"同意秋容脚本"文件夹
-----------------------------------------------------------
-- ================ 基础服务与变量 ================
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer or Players.PlayerAdded:Wait()
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
local RunService = game:GetService("RunService")
local Color3 = Color3
local UDim2 = UDim2
local Instance = Instance
local task = task
local Enum = Enum
-- 注入器文件操作兼容（核心：获取持久化路径）
local readFunc, writeFunc, getPathFunc
pcall(function()
    -- 适配忍者/Delta/Synapse等注入器
    if type(syn) == "table" then
        readFunc = syn.readfile or readfile
        writeFunc = syn.writefile or writefile
        getPathFunc = syn.datapath  -- 忍者注入器获取沙盒路径
    else
        -- 其他注入器兼容
        readFunc = readfile or readFile
        writeFunc = writefile or writeFile
        -- 尝试获取默认路径（如Krnl等）
        getPathFunc = function() return "Roblox/Scripts" end
    end
end)
-- ================ 验证文件夹核心逻辑 ================
-- 获取持久化文件夹路径（跨注入器兼容）
local function getVerifyFolderPath()
    local basePath
    if getPathFunc then
        -- 优先使用注入器提供的沙盒路径（如忍者的syn.datapath()）
        basePath = getPathFunc()
    else
        --  fallback路径（适配多数PC注入器）
        basePath = "C:/RobloxScripts"  -- 可根据系统自动调整
        pcall(function()
            -- 尝试检测系统类型（Windows/macOS）
            if game:GetService("RunService"):IsStudio() then
                basePath = "Roblox/Scripts"  -- Studio环境
            elseif string.find(game:GetService("MarketplaceService"):GetProductInfo(1).Name, "Mac") then
                basePath = "~/Library/Roblox/Scripts"  -- macOS路径
            end
        end)
    end
    -- 拼接完整文件夹路径
    return basePath .. "/同意秋容脚本"
end
-- 检查文件夹是否存在（跨注入器兼容）
local function folderExists()
    if not readFunc then return false end  -- 无文件操作能力则强制验证
    local folderPath = getVerifyFolderPath()
    -- 尝试读取文件夹（注入器通常通过检查路径是否可访问判断存在性）
    local success = pcall(function()
        -- 不同注入器判断方式可能不同，这里用"尝试读取"作为存在性检测
        readFunc(folderPath .. "/.verify")  -- 读取文件夹内的标记文件
    end)
    return success
end
-- 创建验证文件夹（跨注入器兼容）
local function createTargetFolder()
    if not writeFunc then return end  -- 无写入能力则跳过（不影响使用，仅下次仍需验证）
    local folderPath = getVerifyFolderPath()
    local success = pcall(function()
        -- 1. 创建文件夹（注入器通常支持通过写入空文件创建文件夹）
        writeFunc(folderPath .. "/.verify", "")  -- 写入空标记文件，自动创建父文件夹
        print("验证文件夹创建成功：" .. folderPath)
    end)
    if not success then
        -- 降级方案：若无法创建文件夹，临时用PlayerGui文件夹（仅当前会话有效）
        local tempFolder = Instance.new("Folder")
        tempFolder.Name = "同意秋容脚本"
        tempFolder.Parent = PlayerGui
        print("警告：持久化文件夹创建失败，使用临时文件夹（仅当前会话有效）")
    end
end
-- ================ 通用UI工具函数 ================
-- 创建屏幕GUI
local function createScreenGui(name)
    local gui = Instance.new("ScreenGui")
    gui.Name = name
    gui.IgnoreGuiInset = true
    gui.Parent = PlayerGui
    return gui
end
-- 创建带圆角的框架
local function createFrame(parent, size, position)
    local frame = Instance.new("Frame")
    frame.Size = size
    frame.Position = position
    frame.BackgroundColor3 = Color3.fromRGB(40, 40, 60)
    frame.BackgroundTransparency = 0.3
    frame.BorderSizePixel = 1
    frame.BorderColor3 = Color3.fromRGB(180, 160, 255)
    frame.Parent = parent
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 12)
    corner.Parent = frame
    return frame
end
-- 创建基础标签
local function createBasicLabel(parent, text, size, position)
    local label = Instance.new("TextLabel")
    label.Text = text
    label.Size = size
    label.Position = position
    label.TextColor3 = Color3.new(1, 1, 1)
    label.TextSize = 16
    label.BackgroundTransparency = 1
    label.Parent = parent
    return label
end
-- 创建普通标签
local function createLabel(parent, text, size, position)
    local label = Instance.new("TextLabel")
    label.Text = text
    label.Size = size
    label.Position = position
    label.TextColor3 = Color3.new(1, 1, 1)
    label.TextSize = 16
    label.BackgroundTransparency = 1
    label.Parent = parent
    return label
end
-- 创建按钮
local function createButton(parent, text, size, position, callback)
    local btn = Instance.new("TextButton")
    btn.Text = text
    btn.Size = size
    btn.Position = position
    btn.BackgroundColor3 = Color3.fromRGB(60, 60, 100)
    btn.TextColor3 = Color3.new(1, 1, 1)
    btn.TextSize = 14
    btn.Parent = parent
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 6)
    corner.Parent = btn
    if callback then
        btn.MouseButton1Click:Connect(callback)
    end
    return btn
end
-- 创建点击输入框
local function createClickToInput(parent, size, position, triggerText, placeholderText)
    local trigger = Instance.new("TextButton")
    trigger.Size = size
    trigger.Position = position
    trigger.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
    trigger.BackgroundTransparency = 0.7
    trigger.Text = triggerText
    trigger.TextColor3 = Color3.new(1, 1, 1)
    trigger.TextSize = 14
    trigger.Parent = parent
    local cornerTrigger = Instance.new("UICorner")
    cornerTrigger.CornerRadius = UDim.new(0, 6)
    cornerTrigger.Parent = trigger
    local box = Instance.new("TextBox")
    box.Size = size
    box.Position = position
    box.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
    box.BackgroundTransparency = 0.7
    box.TextColor3 = Color3.new(1, 1, 1)
    box.TextSize = 14
    box.PlaceholderText = placeholderText
    box.Visible = false
    box.Parent = parent
    local cornerBox = Instance.new("UICorner")
    cornerBox.CornerRadius = UDim.new(0, 6)
    cornerBox.Parent = box
    trigger.MouseButton1Click:Connect(function()
        trigger.Visible = false
        box.Visible = true
        box:CaptureFocus()
    end)
    return trigger, box
end
-- 播放临时音效
local function playTempSound(soundId)
    local fullSoundId = "rbxassetid://" .. tostring(soundId)
    local sound = Instance.new("Sound")
    sound.SoundId = fullSoundId
    sound.Volume = 1.0
    sound.Parent = workspace
    pcall(function()
        sound:Play()
        sound.Ended:Connect(function() sound:Destroy() end)
        task.delay(5, function() if sound.Parent then sound:Destroy() end end)
    end)
end
-- ================ 验证弹窗逻辑 ================
-- 快手号验证
local function Popup_VerifyKuaishou()
    local gui = createScreenGui("Popup_Kuaishou")
    local frame = createFrame(gui, UDim2.new(0, 420, 0, 240), UDim2.new(0.5, -210, 0.5, -120))
    createLabel(frame, "主播的快手号是什么？", UDim2.new(1, 0, 0, 35), UDim2.new(0, 0, 0, 25))
    
    local _, inputKuaishou = createClickToInput(
        frame, UDim2.new(1, -50, 0, 45), UDim2.new(0, 25, 0, 75),
        "点击输入快手号", "请输入正确的快手号"
    )
    
    local statusLabel = createLabel(frame, "", UDim2.new(1, 0, 0, 25), UDim2.new(0, 0, 0, 135))
    local done = false
    
    createButton(frame, "验证快手号", UDim2.new(0.45, 0, 0, 35), UDim2.new(0.1, 0, 0, 175), function()
        if inputKuaishou.Text == "xiaoxinb666" then
            done = true
            gui:Destroy()
        else
            statusLabel.Text = "作者快手号都不知道，配用这个脚本吗😡？快手号是CN_QRNBYYDS"
            statusLabel.TextColor3 = Color3.fromRGB(255, 60, 60)
        end
    end)
    
    createButton(frame, "退出脚本", UDim2.new(0.45, 0, 0, 35), UDim2.new(0.5, 0, 0, 175), function()
        gui:Destroy()
        error("用户主动退出，脚本停止运行")
    end)
    
    while not done do task.wait() end
end

    -- 标题（缩小50%：原22 → 11）
    local titleLabel = createBasicLabel(noticeFrame, "3.1汉化版 脚本公告", UDim2.new(1, 0, 0, 40), UDim2.new(0, 0, 0, 15))
    titleLabel.TextSize = 22 * 0.5  -- 仅公告标题缩小
    titleLabel.TextColor3 = Color3.fromRGB(255, 210, 0)
    titleLabel.TextXAlignment = Enum.TextXAlignment.Center
    
    -- 内容（缩小50%：原16 → 8）
    local contentLabel = createLabel(noticeFrame, "更新日志:\n8月21日05:35更新军事大亨去除GB失效脚本全自动农场脚本挂机即可\n8月21日10:07更新墨水游戏新版老外Xa包括使用教程获取方法和注意事项\n8月21日00:58更新WARMIX[PVP FPS 武器战斗射击枪]-保护房屋免受怪物侵害-保护总统\n8月22日18:17添加了chain服务器脚本\n9月12日更新墨水游戏汉化脚目前作者已学会汉化逐渐汉化中\n9月13日10:00更新新的墨水游戏汉化去除墨水游戏过期脚本去除ink-game正常版添加ink-game测试版汉化\n9月13日16:12全面取消汉化更新新的方法等待半天", 
        UDim2.new(1, -40, 0, 140), UDim2.new(0, 20, 0, 60))
    contentLabel.TextSize = 16 * 0.5  -- 仅公告内容缩小
    contentLabel.TextWrapped = true
    contentLabel.TextXAlignment = Enum.TextXAlignment.Left
    
    -- 关闭按钮
    local noticeDone = false
    createButton(noticeFrame, "我知道了", UDim2.new(0.5, 0, 0, 40), UDim2.new(0.25, 0, 1, -50), function()
        noticeDone = true
        noticeGui:Destroy()
    end)
    
    while not noticeDone do task.wait() end
end
-- ================ 执行流程 ================
local isFirstUse = not folderExists()  -- 检测持久化文件夹是否存在
if isFirstUse then
    -- 首次使用：执行验证 → 创建持久化文件夹 → 显示公告
    Popup_VerifyKuaishou()
    Popup_VerifyQQGroup()
    createTargetFolder()  -- 验证通过后创建文件夹（跨会话保留）
    showAnnouncement()
else
    -- 非首次使用：直接显示公告（跳过验证）
    print("检测到验证文件夹，跳过验证")
    showAnnouncement()
end
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local StarterGui = game:GetService("StarterGui")
local RunService = game:GetService("RunService")
local SoundService = game:GetService("SoundService")
local HttpService = game:GetService("HttpService") -- 新增HTTP服务引用
-- ====================== 配置与状态管理 ======================
local CONFIG = {
    TWEEN_DURATION = 0.25,       -- 动画时长
    UPDATE_INTERVAL = 0.5,       -- 玩家列表更新间隔
    UI_SCALE = { default = 0.8 },-- 默认缩放比例
    UI_COLORS = {                -- 主题色
        primary = Color3.fromRGB(60, 60, 100),
        secondary = Color3.fromRGB(50, 50, 70),
        accent = Color3.fromRGB(255, 230, 100),
        success = Color3.fromRGB(60, 100, 80),
        danger = Color3.fromRGB(150, 50, 50),
        localPlayer = Color3.fromRGB(100, 200, 255)
    },
    NOTIFICATION = {             -- 通知配置
        DURATION = 3,            -- 显示时长（秒）
        SOUND_ID = "rbxassetid://79348298352567", -- 叮咚音效
        CORNER_RADIUS = 12       -- 通知框圆角
    }
}
local UI_STATE = {
    scale = CONFIG.UI_SCALE.default,  -- 当前UI缩放比例
    activeMenu = "保存位置",          -- 初始激活菜单（面板标识，不可修改）
    menuPanels = {},                  -- 菜单面板缓存（键：面板标识，值：面板实例）
    isRunning = true,                 -- 脚本运行状态
    isScaling = false,                -- 缩放中标记
    mainPanel = nil,                  -- 主面板引用
    floatBtn = nil,                   -- 悬浮窗按钮
    topBar = nil,                     -- 顶部栏引用
    isDragging = false,               -- 拖动中标记
    isScrolling = false,              -- 滚动中标记
    dragStart = Vector2.new(0, 0),    -- 拖动起始位置
    panelStartPos = UDim2.new(0, 0, 0, 0), -- 面板初始位置
    scrollStartPositions = {},        -- 滚动起始位置缓存
    savedCoordinates = {},            -- 已保存坐标
    csvFilePath = "",                 -- CSV文件路径
    coordinateLoop = nil,             -- 坐标更新循环
    playerPositionLoop = nil,         -- 玩家位置更新循环
    playerSortMode = "name",          -- 玩家排序模式（name/distance）
    isToggleFeatureEnabled = false,   -- 穿墙功能开关状态（默认关闭）
    wallhackConnection = nil,          -- 存储角色部件监听连接
    characterAddedConn = nil,
    characterRemovingConn = nil
}
-- ====================== 工具函数 ======================
-- 创建圆角（适配缩放）
local function createCorner(parent, radius)
    if not parent or not parent:IsDescendantOf(game) then return end
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, radius * UI_STATE.scale)
    corner.Parent = parent
end
-- 创建文本标签（适配缩放）
local function createLabel(parent, props)
    if not parent or not parent:IsDescendantOf(game) then return nil end
    local label = Instance.new("TextLabel")
    label.Name = props.name or "Label"
    label.Size = props.size or UDim2.new(1, 0, 1, 0)
    label.Position = props.position or UDim2.new(0, 0, 0, 0)
    label.Text = props.text or ""
    label.TextColor3 = props.color or Color3.new(1, 1, 1)
    label.TextSize = (props.textSize or 14) * UI_STATE.scale
    label.TextXAlignment = props.xAlign or Enum.TextXAlignment.Left
    label.BackgroundTransparency = props.bgTransparency or 1
    label.BackgroundColor3 = props.bgColor or Color3.new(0, 0, 0)
    label.Font = props.font or Enum.Font.SourceSans
    label.Parent = parent
    label.Active = props.active or false
    if props.anchor then
        label.AnchorPoint = props.anchor
    end
    return label
end
-- 创建按钮（适配缩放 + 悬停动画）
local function createButton(parent, props)
    if not parent or not parent:IsDescendantOf(game) then return nil end
    local btn = Instance.new("TextButton")
    btn.Name = props.name or "Button"
    btn.Size = props.size or UDim2.new(1, 0, 0, 40 * UI_STATE.scale)
    btn.Position = props.position or UDim2.new(0, 0, 0, 0)
    btn.Text = props.text or "按钮"
    btn.TextColor3 = props.textColor or Color3.new(1, 1, 1)
    btn.TextSize = (props.textSize or 16) * UI_STATE.scale
    btn.BackgroundColor3 = props.bgColor or CONFIG.UI_COLORS.primary
    btn.BackgroundTransparency = props.bgTransparency or 0.8
    btn.Parent = parent
    btn.Active = props.active ~= nil and props.active or true
    btn.Selectable = props.selectable or false
    if props.anchor then
        btn.AnchorPoint = props.anchor
    end
    createCorner(btn, props.radius or 8)
    -- 悬停动画
    if props.hoverColor then
        btn.MouseEnter:Connect(function()
            if not UI_STATE.isDragging and not UI_STATE.isScrolling and btn:IsDescendantOf(game) then
                TweenService:Create(
                    btn,
                    TweenInfo.new(CONFIG.TWEEN_DURATION),
                    {BackgroundColor3 = props.hoverColor}
                ):Play()
            end
        end)
        btn.MouseLeave:Connect(function()
            if not UI_STATE.isDragging and not UI_STATE.isScrolling and btn:IsDescendantOf(game) then
                TweenService:Create(
                    btn,
                    TweenInfo.new(CONFIG.TWEEN_DURATION),
                    {BackgroundColor3 = props.bgColor}
                ):Play()
            end
        end)
    end
    -- 点击事件
    if props.onClick then
        btn.MouseButton1Click:Connect(function()
            task.defer(function()
                if not UI_STATE.isDragging and not UI_STATE.isScrolling and btn:IsDescendantOf(game) then
                    props.onClick()
                end
            end)
        end)
    end
    return btn
end
-- 拖动绑定函数
local function bindDragToElement(element, target)
    if not element or not target then return end
    element.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or 
           input.UserInputType == Enum.UserInputType.Touch then
            UI_STATE.isDragging = true
            UI_STATE.dragStart = input.Position
            UI_STATE.panelStartPos = target.Position
        end
    end)
end
-- UI清理函数
local function cleanupOldUI()
    local localPlayer = Players.LocalPlayer
    if not localPlayer then return end
    local playerGui = localPlayer:FindFirstChild("PlayerGui")
    if not playerGui then return end
    
    -- 清理主UI
    if UI_STATE.mainPanel and UI_STATE.mainPanel:IsDescendantOf(game) then
        UI_STATE.mainPanel:Destroy()
    end
    
    -- 清理悬浮窗
    if UI_STATE.floatBtn and UI_STATE.floatBtn:IsDescendantOf(game) then
        UI_STATE.floatBtn:Destroy()
    end
    
    -- 清理通知和对话框
    for _, gui in ipairs(playerGui:GetChildren()) do
        if gui.Name:match("CustomNotification") or gui.Name == "ExecutionDialog" then
            gui:Destroy()
        end
    end
    
    -- 断开循环
    if UI_STATE.coordinateLoop then
        UI_STATE.coordinateLoop:Disconnect()
        UI_STATE.coordinateLoop = nil
    end
    if UI_STATE.playerPositionLoop then
        UI_STATE.playerPositionLoop:Disconnect()
        UI_STATE.playerPositionLoop = nil
    end
    -- 断开角色监听连接
    if UI_STATE.characterAddedConn then
        UI_STATE.characterAddedConn:Disconnect()
        UI_STATE.characterAddedConn = nil
    end
    if UI_STATE.characterRemovingConn then
        UI_STATE.characterRemovingConn:Disconnect()
        UI_STATE.characterRemovingConn = nil
    end
end
-- 角色销毁时的清理函数
local function onCharacterRemoving()
    -- 断开坐标更新循环
    if UI_STATE.coordinateLoop then
        UI_STATE.coordinateLoop:Disconnect()
        UI_STATE.coordinateLoop = nil
    end
    -- 断开玩家位置更新循环
    if UI_STATE.playerPositionLoop then
        UI_STATE.playerPositionLoop:Disconnect()
        UI_STATE.playerPositionLoop = nil
    end
    -- 断开穿墙功能连接
    if UI_STATE.wallhackConnection then
        UI_STATE.wallhackConnection:Disconnect()
        UI_STATE.wallhackConnection = nil
    end
    showNotification("角色已销毁", "脚本已暂停，等待角色重生...")
end
-- 角色重生时的初始化函数
local function onCharacterAdded(character)
    -- 等待角色加载完成
    local rootPart = character:WaitForChild("HumanoidRootPart", 10)
    local humanoid = character:WaitForChild("Humanoid", 10)
    
    if not rootPart or not humanoid then
        showNotification("角色加载失败", "无法获取角色关键部件")
        return
    end
    
    -- 重新启动坐标更新（如果当前在保存位置菜单）
    if UI_STATE.activeMenu == "保存位置" and UI_STATE.mainPanel and UI_STATE.mainPanel.Visible then
        if UI_STATE.coordinateLoop then
            UI_STATE.coordinateLoop:Disconnect()
        end
        UI_STATE.coordinateLoop = RunService.Heartbeat:Connect(function()
            local root = character:FindFirstChild("HumanoidRootPart")
            if root then
                local pos = root.Position
                local coordLabel = UI_STATE.mainPanel:FindFirstChild("CoordDisplay", true)
                if coordLabel then
                    coordLabel.Text = string.format("实时坐标：X: %.1f, Y: %.1f, Z: %.1f", pos.X, pos.Y, pos.Z)
                end
            end
        end)
    end
    
    -- 监听角色死亡事件
    humanoid.Died:Connect(function()
        onCharacterRemoving()
    end)
    
    showNotification("角色已加载", "脚本功能已恢复")
end
-- ====================== 右下角弹窗逻辑 ======================
local NOTIFICATION_DATA = {
    maxCount = 5, -- 最大叠加数量
    spacing = 6, -- 窗口间距
    width = 120, -- 窗口宽度
    height = 60, -- 窗口高度
    activeWindows = {} -- 存储当前活跃窗口（按序号排序）
}
local function updateWindowPositions()
    -- 遍历所有活跃窗口，按序号重新计算位置（序号1在最顶部）
    for index, windowData in ipairs(NOTIFICATION_DATA.activeWindows) do
        local frame = windowData.frame
        if frame and frame:IsDescendantOf(game) then
            -- 计算绝对Y坐标：序号越大越靠下，X轴紧贴右侧（仅留2像素缝隙）
            local targetY = -NOTIFICATION_DATA.height - 10 
                - (NOTIFICATION_DATA.height + NOTIFICATION_DATA.spacing) * (index - 1)
            frame.Position = UDim2.new(
                1, -NOTIFICATION_DATA.width - 2, -- 右侧仅留2像素缝隙
                1, targetY -- 基于序号的Y坐标（序号1最靠上）
            )
        end
    end
end
local function showNotification(title, text, duration)
    local localPlayer = Players.LocalPlayer
    if not localPlayer then return end
    local playerGui = localPlayer:FindFirstChild("PlayerGui")
    if not playerGui then return end
    -- 步骤1：移除超出上限的最旧窗口（最后一个）
    if #NOTIFICATION_DATA.activeWindows >= NOTIFICATION_DATA.maxCount then
        local oldestWindow = NOTIFICATION_DATA.activeWindows[#NOTIFICATION_DATA.activeWindows]
        if oldestWindow and oldestWindow.gui:IsDescendantOf(game) then
            oldestWindow.gui:Destroy()
        end
        table.remove(NOTIFICATION_DATA.activeWindows, #NOTIFICATION_DATA.activeWindows)
    end
    -- 步骤2：所有现有窗口序号+1（索引后移）
    for i = #NOTIFICATION_DATA.activeWindows, 1, -1 do
        NOTIFICATION_DATA.activeWindows[i].index = i + 1
    end
    -- 步骤3：创建新窗口（索引1，最顶部）
    local newIndex = 1
    local notificationGui = Instance.new("ScreenGui")
    notificationGui.Name = "CustomNotification_" .. newIndex
    notificationGui.IgnoreGuiInset = true
    notificationGui.Parent = playerGui
    -- 主窗口框架（初始位置紧贴右侧）
    local notificationFrame = Instance.new("Frame")
    notificationFrame.Name = "NotificationFrame"
    notificationFrame.Size = UDim2.new(0, NOTIFICATION_DATA.width * 0.8, 0, NOTIFICATION_DATA.height * 0.8)
    notificationFrame.Position = UDim2.new(
        1, -NOTIFICATION_DATA.width - 2, -- 初始X位置：右侧仅留2像素缝隙
        1, 10 -- 初始在屏幕外下方（准备滑入）
    )
    notificationFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 60)
    notificationFrame.BackgroundTransparency = 1
    notificationFrame.BorderSizePixel = 0
    notificationFrame.ClipsDescendants = true
    notificationFrame.Parent = notificationGui
    -- 圆角
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 6)
    corner.Parent = notificationFrame
    -- 标题和内容
    createLabel(notificationFrame, {
        name = "TitleLabel",
        size = UDim2.new(1, -8, 0, 20),
        position = UDim2.new(0, 4, 0, 3),
        text = title or "提示",
        color = Color3.fromRGB(255, 230, 100),
        textSize = 12,
        font = Enum.Font.SourceSansBold,
        textWrapped = true
    })
    createLabel(notificationFrame, {
        name = "ContentLabel",
        size = UDim2.new(1, -8, 0, 32),
        position = UDim2.new(0, 4, 0, 23),
        text = text or "",
        color = Color3.new(1, 1, 1),
        textSize = 10,
        textWrapped = true,
        textTruncate = Enum.TextTruncate.AtEnd
    })
    -- 音效
    pcall(function()
        local sound = Instance.new("Sound")
        sound.SoundId = CONFIG.NOTIFICATION.SOUND_ID
        sound.Volume = 0.5
        sound.Parent = notificationFrame
        sound:Play()
        sound.Ended:Connect(function() sound:Destroy() end)
    end)
    -- 存储新窗口数据（索引1）
    table.insert(NOTIFICATION_DATA.activeWindows, 1, {
        index = newIndex,
        gui = notificationGui,
        frame = notificationFrame
    })
    -- 立即更新所有窗口位置（强制叠加）
    updateWindowPositions()
    -- 弹出动画（滑入顶部位置）
    local popInTween = TweenService:Create(
        notificationFrame,
        TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
        {
            Size = UDim2.new(0, NOTIFICATION_DATA.width, 0, NOTIFICATION_DATA.height),
            BackgroundTransparency = 0.8
        }
    )
    popInTween:Play()
    -- 消失动画与清理
    task.wait(duration or CONFIG.NOTIFICATION.DURATION)
    local fadeOutTween = TweenService:Create(
        notificationFrame,
        TweenInfo.new(0.5, Enum.EasingStyle.Linear),
        {
            BackgroundTransparency = 1,
            Size = UDim2.new(0, NOTIFICATION_DATA.width * 0.8, 0, NOTIFICATION_DATA.height * 0.8)
        }
    )
    fadeOutTween:Play()
    fadeOutTween.Completed:Connect(function()
        -- 从活跃列表中移除当前窗口
        for i, windowData in ipairs(NOTIFICATION_DATA.activeWindows) do
            if windowData.gui == notificationGui then
                table.remove(NOTIFICATION_DATA.activeWindows, i)
                break
            end
        end
        notificationGui:Destroy()
        -- 重新编号并更新剩余窗口位置
        for i = 1, #NOTIFICATION_DATA.activeWindows do
            NOTIFICATION_DATA.activeWindows[i].index = i
        end
        updateWindowPositions() -- 强制更新位置，确保无空位
    end)
end
-- ====================== 文件读写（适配忍者注入器） ======================
local readFunc, writeFunc
pcall(function()
    -- 忍者注入器兼容处理
    if type(syn) == "table" then
        readFunc = syn.readfile or readfile
        writeFunc = syn.writefile or writefile
    else
        readFunc = readfile or readFile
        writeFunc = writefile or writeFile
    end
end)
local function initCSVPath()
    print("初始化CSV路径...")
    local success, result = pcall(function()
        -- 忍者注入器路径适配
        if type(syn) == "table" then
            return syn.datapath and syn.datapath() .. "/Roblox_Current_Coord.csv" 
                or "/sdcard/Delta/Scripts/Roblox_Current_Coord.csv"
        else
            return "Roblox_Current_Coord.csv"
        end
    end)
    UI_STATE.csvFilePath = success and result or "Roblox_Current_Coord.csv"
    print("坐标文件路径：", UI_STATE.csvFilePath)
end
local function readCSVFile()
    print("读取坐标文件：", UI_STATE.csvFilePath)
    if not readFunc then
        warn("当前注入器不支持文件读取，将使用空坐标列表")
        return {}
    end
    local success, content = pcall(readFunc, UI_STATE.csvFilePath)
    if not success or not content or content == "" then
        print("坐标文件读取失败（空列表）：", success and content or "无内容")
        return {}
    end
    local coords = {}
    local lines = content:split("\n")
    for i = 2, #lines do
        local line = lines[i]:gsub("\r", "")
        if line ~= "" then
            local safeLine = line:gsub("\\,", "\0")
            local parts = safeLine:split(",")
            if #parts == 4 then
                local name = parts[1]:gsub("\0", ",")
                local x, y, z = tonumber(parts[2]), tonumber(parts[3]), tonumber(parts[4])
                if x and y and z then
                    x = math.round(x * 100) / 100
                    y = math.round(y * 100) / 100
                    z = math.round(z * 100) / 100
                    table.insert(coords, {name = name, x = x, y = y, z = z})
                end
            end
        end
    end
    print("读取到", #coords, "条坐标")
    return coords
end
local function updateCSVFile()
    if not writeFunc then
        warn("当前注入器不支持文件写入")
        return false
    end
    local csv = "名称,X坐标,Y坐标,Z坐标\n"
    for _, coord in ipairs(UI_STATE.savedCoordinates) do
        local safeName = coord.name:gsub(",", "\\,")
        csv ..= string.format("%s,%.2f,%.2f,%.2f\n", safeName, coord.x, coord.y, coord.z)
    end
    local success, err = pcall(writeFunc, UI_STATE.csvFilePath, csv)
    if not success then
        warn("坐标写入失败: " .. err)
        return false
    end
    print("坐标文件已更新")
    return true
end
-- ====================== 悬浮窗创建 ======================
local function createFloatingButton()
    local localPlayer = Players.LocalPlayer
    if not localPlayer then return end
    local playerGui = localPlayer:FindFirstChild("PlayerGui")
    if not playerGui then return end
    if UI_STATE.floatBtn and UI_STATE.floatBtn:IsDescendantOf(game) then
        return
    end
    local floatGui = Instance.new("ScreenGui")
    floatGui.Name = "秋容脚本悬浮窗"
    floatGui.IgnoreGuiInset = true
    floatGui.Parent = playerGui
    -- 忍者注入器保护GUI
    pcall(function()
        if syn and syn.protect_gui then
            syn.protect_gui(floatGui)
        end
    end)
    local floatWidth = 60 * UI_STATE.scale
    local floatHeight = 30 * UI_STATE.scale
    UI_STATE.floatBtn = createButton(floatGui, {
        name = "FloatingButton",
        size = UDim2.new(0, floatWidth, 0, floatHeight),
        position = UDim2.new(1, -floatWidth - 2, 0.1, 0), -- 右侧仅留2像素缝隙
        text = "显示",
        bgColor = CONFIG.UI_COLORS.primary,
        radius = 15 * UI_STATE.scale,
        textSize = 14 * UI_STATE.scale,
        hoverColor = Color3.fromRGB(70, 70, 120),
        onClick = function()
            if UI_STATE.mainPanel then
                local isVisible = UI_STATE.mainPanel.Visible
                UI_STATE.mainPanel.Visible = not isVisible
                UI_STATE.floatBtn.Text = isVisible and "显示" or "隐藏"
                showNotification("主UI状态", "已" .. (isVisible and "隐藏" or "显示") .. "功能面板")
            else
                createMainUI()
                if UI_STATE.floatBtn and UI_STATE.floatBtn:IsDescendantOf(game) then
                    UI_STATE.floatBtn.Text = "隐藏"
                    showNotification("主UI加载完成", "功能面板已显示")
                end
            end
        end
    })
    -- 悬浮窗拖动逻辑
    local btnIsDragging = false
    local btnStartPos = UI_STATE.floatBtn and UI_STATE.floatBtn.Position or UDim2.new()
    if UI_STATE.floatBtn then
        UI_STATE.floatBtn.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or 
               input.UserInputType == Enum.UserInputType.Touch then
                btnIsDragging = true
                UI_STATE.dragStart = input.Position
                btnStartPos = UI_STATE.floatBtn.Position
            end
        end)
    end
    UserInputService.InputChanged:Connect(function(input)
        if btnIsDragging and (input.UserInputType == Enum.UserInputType.MouseMovement or 
           input.UserInputType == Enum.UserInputType.Touch) and UI_STATE.floatBtn and UI_STATE.floatBtn:IsDescendantOf(game) then
            local delta = input.Position - UI_STATE.dragStart
            UI_STATE.floatBtn.Position = UDim2.new(
                btnStartPos.X.Scale, btnStartPos.X.Offset + delta.X,
                btnStartPos.Y.Scale, btnStartPos.Y.Offset + delta.Y
            )
        end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if (input.UserInputType == Enum.UserInputType.MouseButton1 or 
            input.UserInputType == Enum.UserInputType.Touch) and btnIsDragging then
            btnIsDragging = false
        end
    end)
    print("悬浮窗创建成功（适配缩放）")
end
-- ====================== 菜单与内容创建 ======================
local function createMenuItem(parent, menuText, layoutOrder, onSwitch)
    local btn = createButton(parent, {
        name = "MenuButton_" .. menuText:gsub("%p", ""),
        size = UDim2.new(1, 0, 0, 50 * UI_STATE.scale),
        text = menuText,
        textSize = 16,
        bgColor = CONFIG.UI_COLORS.primary,
        hoverColor = Color3.fromRGB(70, 70, 120),
        radius = 8
    })
    if not btn then return nil end
    btn.LayoutOrder = layoutOrder
    local function setActive(active)
        -- 强制立即应用颜色，避免引擎延迟
        btn.BackgroundColor3 = active and Color3.fromRGB(80, 80, 130) or CONFIG.UI_COLORS.primary
        -- 手动触发刷新（解决Roblox UI渲染延迟）
        btn.BackgroundColor3 = btn.BackgroundColor3
    end
    -- 初始化时强制同步状态（根据当前活跃面板标识匹配）
    local currentActiveKey = UI_STATE.activeMenu
    local isActive = (btn.Name:gsub("MenuButton_", "") == currentActiveKey:gsub("%p", ""))
    setActive(isActive)
    
    btn.MouseButton1Click:Connect(function()
        if not UI_STATE.isDragging and not UI_STATE.isScrolling and btn:IsDescendantOf(game) then
            -- 执行切换面板逻辑
            onSwitch()
        end
    end)
    return btn
end
local function createSavedCoordItem(parent, data, layoutOrder)
    if not parent or not parent:IsDescendantOf(game) then return nil end
    local frame = Instance.new("Frame")
    frame.Name = "SavedCoord_" .. data.name .. "_" .. 
        math.round(data.x*100) .. "_" .. math.round(data.y*100) .. "_" .. math.round(data.z*100)
    frame.Size = UDim2.new(1, 0, 0, 50 * UI_STATE.scale)
    frame.LayoutOrder = layoutOrder
    frame.BackgroundColor3 = CONFIG.UI_COLORS.secondary
    frame.BackgroundTransparency = 0.7
    frame.Parent = parent
    frame.Active = false
    createCorner(frame, 6)
    createLabel(frame, {
        size = UDim2.new(0.6, -10 * UI_STATE.scale, 1, 0),
        position = UDim2.new(0, 10 * UI_STATE.scale, 0, 0),
        text = string.format("[%s] X: %.1f, Y: %.1f, Z: %.1f", data.name, data.x, data.y, data.z),
        textSize = 12,
        xAlign = Enum.TextXAlignment.Left
    })
    createButton(frame, {
        name = "DeleteBtn",
        size = UDim2.new(0.15, 0, 1, -6 * UI_STATE.scale),
        position = UDim2.new(0.65, 0, 0, 3 * UI_STATE.scale),
        text = "删除",
        textSize = 12,
        bgColor = CONFIG.UI_COLORS.danger,
        hoverColor = Color3.fromRGB(170, 70, 70),
        radius = 6,
        onClick = function()
            local targetName = data.name
            local targetX = math.round(data.x * 100) / 100
            local targetY = math.round(data.y * 100) / 100
            local targetZ = math.round(data.z * 100) / 100
            for i = #UI_STATE.savedCoordinates, 1, -1 do
                local item = UI_STATE.savedCoordinates[i]
                local itemX = math.round(item.x * 100) / 100
                local itemY = math.round(item.y * 100) / 100
                local itemZ = math.round(item.z * 100) / 100
                if item.name == targetName and itemX == targetX and itemY == targetY and itemZ == targetZ then
                    table.remove(UI_STATE.savedCoordinates, i)
                    local success = updateCSVFile()
                    frame:Destroy()
                    showNotification(
                        success and "删除成功" or "删除警告",
                        success and "已从文件中移除" or "UI已移除，文件同步失败"
                    )
                    return
                end
            end
            showNotification("删除失败", "未找到匹配坐标")
        end
    })
    createButton(frame, {
        name = "TeleportBtn",
        size = UDim2.new(0.15, 0, 1, -6 * UI_STATE.scale),
        position = UDim2.new(0.82, 0, 0, 3 * UI_STATE.scale),
        text = "传送",
        textSize = 12,
        bgColor = Color3.fromRGB(50, 100, 150),
        hoverColor = Color3.fromRGB(70, 120, 170),
        radius = 6,
        onClick = function()
            local player = Players.LocalPlayer
            local rootPart = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
            if rootPart then
                rootPart.CFrame = CFrame.new(data.x, data.y, data.z)
                showNotification("传送成功", "已传送到 " .. data.name)
            else
                showNotification("传送失败", "角色未加载")
            end
        end
    })
    return frame
end
local function createPlayerPositionItem(parent, playerName, position, isLocalPlayer, layoutOrder, distance)
    if isLocalPlayer then return nil end
    if not parent or not parent:IsDescendantOf(game) then return nil end
    local frame = Instance.new("Frame")
    frame.Name = "Player_" .. playerName
    frame.Size = UDim2.new(1, 0, 0, 60 * UI_STATE.scale)
    frame.LayoutOrder = layoutOrder
    frame.BackgroundColor3 = CONFIG.UI_COLORS.secondary
    frame.BackgroundTransparency = 0.7
    frame.Parent = parent
    frame.Active = false
    createCorner(frame, 6)
    local distanceText = distance and string.format(" 距离: %.1f", distance) or ""
    createLabel(frame, {
        size = UDim2.new(0.7, -10 * UI_STATE.scale, 1, 0),
        position = UDim2.new(0, 10 * UI_STATE.scale, 0, 0),
        text = string.format("[%s] X: %.1f, Y: %.1f, Z: %.1f%s", 
            playerName, position.X, position.Y, position.Z, distanceText),
        textSize = 12,
        color = Color3.new(1, 1, 1),
        xAlign = Enum.TextXAlignment.Left
    })
    local controlContainer = Instance.new("Frame")
    controlContainer.Name = "ControlContainer"
    controlContainer.Size = UDim2.new(0.25, 0, 0.8, 0)
    controlContainer.Position = UDim2.new(0.72, 0, 0.1, 0)
    controlContainer.BackgroundTransparency = 1
    controlContainer.Parent = frame
    createButton(controlContainer, {
        name = "TeleportBtn",
        size = UDim2.new(1, 0, 1, 0),
        text = "传送",
        textSize = 14,
        bgColor = Color3.fromRGB(50, 100, 150),
        hoverColor = Color3.fromRGB(70, 120, 170),
        radius = 6,
        onClick = function()
            local player = Players.LocalPlayer
            local rootPart = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
            local targetPlayer = Players:FindFirstChild(playerName)
            if not rootPart or not targetPlayer then
                showNotification("传送失败", "角色或目标未加载")
                return
            end
            local targetRoot = targetPlayer.Character and targetPlayer.Character:FindFirstChild("HumanoidRootPart")
            if targetRoot then
                rootPart.CFrame = targetRoot.CFrame
                showNotification("传送成功", "已传送到 " .. playerName)
            end
        end
    })
    return frame
end
local function create1Content(container)
    if not container or not container:IsDescendantOf(game) then return function() end end
    local coordDisplay = Instance.new("Frame")
    coordDisplay.Name = "CoordDisplay"
    coordDisplay.Size = UDim2.new(1, 0, 0, 40 * UI_STATE.scale)
    coordDisplay.LayoutOrder = 1
    coordDisplay.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
    coordDisplay.BackgroundTransparency = 0.7
    coordDisplay.Parent = container
    createCorner(coordDisplay, 6)
    local coordLabel = createLabel(coordDisplay, {
        size = UDim2.new(1, -10 * UI_STATE.scale, 1, 0),
        position = UDim2.new(0, 10 * UI_STATE.scale, 0, 0),
        text = "实时坐标：X: ---, Y: ---, Z: ---",
        textSize = 14,
        xAlign = Enum.TextXAlignment.Left
    })
    local nameInput = Instance.new("TextBox")
    nameInput.Name = "NameInput"
    nameInput.Size = UDim2.new(1, 0, 0, 40 * UI_STATE.scale)
    nameInput.LayoutOrder = 2
    nameInput.PlaceholderText = "输入坐标名称"
    nameInput.Text = ""
    nameInput.TextColor3 = Color3.new(1, 1, 1)
    nameInput.PlaceholderColor3 = Color3.fromRGB(150, 150, 150)
    nameInput.TextSize = 14 * UI_STATE.scale
    nameInput.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
    nameInput.BackgroundTransparency = 0.7
    nameInput.Parent = container
    nameInput.Active = true
    nameInput.Selectable = true
    createCorner(nameInput, 6)
    -- 操作提示：坐标名称修改（按回车确认）
    nameInput.FocusLost:Connect(function(enterPressed)
        if enterPressed and nameInput.Text ~= "" then
            showNotification("名称已更新", "坐标名称设置为：" .. nameInput.Text)
        end
    end)
    createButton(container, {
        name = "SaveBtn",
        layoutOrder = 3,
        text = "保存到文件",
        bgColor = CONFIG.UI_COLORS.success,
        hoverColor = Color3.fromRGB(70, 110, 90),
        onClick = function()
            local player = Players.LocalPlayer
            local rootPart = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
            if not rootPart then
                showNotification("保存失败", "角色未加载")
                return
            end
            local name = nameInput.Text ~= "" and nameInput.Text or "未命名坐标"
            local exists = false
            for _, item in ipairs(UI_STATE.savedCoordinates) do
                if item.name == name then exists = true end
            end
            if exists then name = name .. "(" .. #UI_STATE.savedCoordinates + 1 .. ")" end
            local pos = rootPart.Position
            local x, y, z = math.round(pos.X*100)/100, math.round(pos.Y*100)/100, math.round(pos.Z*100)/100
            table.insert(UI_STATE.savedCoordinates, {name = name, x = x, y = y, z = z})
            
            local maxOrder = 5
            for _, child in ipairs(container:GetChildren()) do
                if child.Name:match("SavedCoord_") and child.LayoutOrder > maxOrder then
                    maxOrder = child.LayoutOrder
                end
            end
            createSavedCoordItem(container, UI_STATE.savedCoordinates[#UI_STATE.savedCoordinates], maxOrder + 1)
            local success = updateCSVFile()
            showNotification(
                success and "保存成功" or "保存失败",
                success and ("已保存到：" .. UI_STATE.csvFilePath) or "注入器不支持文件写入"
            )
            nameInput.Text = ""
        end
    })
    local divider = Instance.new("Frame")
    divider.Size = UDim2.new(1, 0, 0, 2 * UI_STATE.scale)
    divider.LayoutOrder = 4
    divider.BackgroundColor3 = Color3.fromRGB(100, 100, 120)
    divider.BackgroundTransparency = 0.5
    divider.Parent = container
    createLabel(container, {
        name = "SavedTitle",
        size = UDim2.new(1, 0, 0, 30 * UI_STATE.scale),
        layoutOrder = 5,
        text = "已保存的坐标",
        color = CONFIG.UI_COLORS.accent,
        textSize = 16,
        xAlign = Enum.TextXAlignment.Left
    })
    for i, coord in ipairs(UI_STATE.savedCoordinates) do
        createSavedCoordItem(container, coord, 6 + i)
    end
    return function(isVisible)
        if not isVisible then return end
        if UI_STATE.coordinateLoop then UI_STATE.coordinateLoop:Disconnect() end
        UI_STATE.coordinateLoop = RunService.Heartbeat:Connect(function()
            -- 增加多重安全检查
            if not coordLabel or not coordLabel:IsDescendantOf(game) then
                return
            end
            local player = Players.LocalPlayer
            if not player then return end
            local character = player.Character
            if not character then
                coordLabel.Text = "实时坐标：角色未生成"
                return
            end
            local rootPart = character:FindFirstChild("HumanoidRootPart")
            if rootPart then
                local pos = rootPart.Position
                coordLabel.Text = string.format("实时坐标：X: %.1f, Y: %.1f, Z: %.1f", pos.X, pos.Y, pos.Z)
            else
                coordLabel.Text = "实时坐标：角色加载中..."
            end
        end)
    end
end
local function create2Content(container)
    if not container or not container:IsDescendantOf(game) then return function() end end
    local controlFrame = Instance.new("Frame")
    controlFrame.Size = UDim2.new(1, 0, 0, 40 * UI_STATE.scale)
    controlFrame.LayoutOrder = 1
    controlFrame.BackgroundTransparency = 1
    controlFrame.Parent = container
    local function refreshPlayerList(container)
        for _, child in ipairs(container:GetChildren()) do
            if child.Name:match("Player_") then
                pcall(function() child:Destroy() end)
            end
        end
        local players = Players:GetPlayers()
        local localPlayer = Players.LocalPlayer
        local localPos = localPlayer.Character and 
            localPlayer.Character:FindFirstChild("HumanoidRootPart") and 
            localPlayer.Character.HumanoidRootPart.Position
        table.sort(players, function(a, b)
            if UI_STATE.playerSortMode == "distance" and localPos then
                local aPos = a.Character and a.Character:FindFirstChild("HumanoidRootPart")
                local bPos = b.Character and b.Character:FindFirstChild("HumanoidRootPart")
                if aPos and bPos then
                    return (aPos.Position - localPos).Magnitude < (bPos.Position - localPos).Magnitude
                end
            end
            return a.Name < b.Name
        end)
        local layoutIndex = 1
        for i, player in ipairs(players) do
            if player == localPlayer then continue end
            local character = player.Character
            local rootPart = character and character:FindFirstChild("HumanoidRootPart")
            local distance = localPos and rootPart and 
                math.round((rootPart.Position - localPos).Magnitude * 10) / 10 or nil
            if rootPart then
                createPlayerPositionItem(
                    container,
                    player.Name,
                    rootPart.Position,
                    false,
                    layoutIndex + 4,
                    distance
                )
                layoutIndex += 1
            else
                local frame = Instance.new("Frame")
                frame.Name = "Player_" .. player.Name
                frame.Size = UDim2.new(1, 0, 0, 45 * UI_STATE.scale)
                frame.LayoutOrder = layoutIndex + 4
                frame.BackgroundColor3 = Color3.fromRGB(70, 50, 50)
                frame.BackgroundTransparency = 0.7
                frame.Parent = container
                createCorner(frame, 6)
                createLabel(frame, {
                    size = UDim2.new(1, -10 * UI_STATE.scale, 1, 0),
                    position = UDim2.new(0, 10 * UI_STATE.scale, 0, 0),
                    text = "[" .. player.Name .. "] 角色未加载",
                    textSize = 12,
                    color = Color3.fromRGB(200, 100, 100),
                    xAlign = Enum.TextXAlignment.Left
                })
                layoutIndex += 1
            end
        end
        if layoutIndex == 1 then
            createLabel(container, {
                name = "NoOtherPlayers",
                size = UDim2.new(1, 0, 0, 40 * UI_STATE.scale),
                layoutOrder = 5,
                text = "当前没有其他玩家",
                color = Color3.fromRGB(200, 200, 200),
                textSize = 14,
                xAlign = Enum.TextXAlignment.Center
            })
        end
    end
    createButton(controlFrame, {
        name = "SortBtn",
        size = UDim2.new(0.5, 0, 1, 0),
        position = UDim2.new(0.25, 0, 0, 0),
        text = "按: " .. (UI_STATE.playerSortMode == "name" and "名称" or "距离"),
        bgColor = CONFIG.UI_COLORS.primary,
        hoverColor = Color3.fromRGB(70, 70, 120),
        onClick = function()
            UI_STATE.playerSortMode = UI_STATE.playerSortMode == "name" and "distance" or "name"
            local sortText = UI_STATE.playerSortMode == "name" and "名称" or "距离"
            controlFrame.SortBtn.Text = "按: " .. sortText
            refreshPlayerList(container)
            showNotification("排序方式更新", "玩家列表已按" .. sortText .. "排序")
        end
    })
    local divider = Instance.new("Frame")
    divider.Size = UDim2.new(1, 0, 0, 2 * UI_STATE.scale)
    divider.LayoutOrder = 2
    divider.BackgroundColor3 = Color3.fromRGB(100, 100, 120)
    divider.BackgroundTransparency = 0.5
    divider.Parent = container
    createLabel(container, {
        name = "PlayerTitle",
        size = UDim2.new(1, 0, 0, 30 * UI_STATE.scale),
        layoutOrder = 3,
        text = "其他玩家列表",
        color = CONFIG.UI_COLORS.accent,
        textSize = 16,
        xAlign = Enum.TextXAlignment.Left
    })
    return function(isVisible)
        if not isVisible then return end
        if UI_STATE.playerPositionLoop then UI_STATE.playerPositionLoop:Disconnect() end
        local lastUpdate = 0
        refreshPlayerList(container)
        UI_STATE.playerPositionLoop = RunService.Heartbeat:Connect(function(deltaTime)
            lastUpdate += deltaTime
            if lastUpdate >= CONFIG.UPDATE_INTERVAL then
                lastUpdate = 0
                refreshPlayerList(container)
            end
        end)
    end
end
-- 修改菜单3内容，添加执行按钮
-- ====================== 飞行 ======================
-- 新增：主菜单执行确认对话框
-- 优化后的执行确认对话框（支持显示功能说明）
local function createExecutionDialog(title, description, onConfirm)
    local localPlayer = Players.LocalPlayer
    if not localPlayer then return end
    local playerGui = localPlayer:FindFirstChild("PlayerGui")
    if not playerGui then return end
    local dialogGui = Instance.new("ScreenGui")
    dialogGui.Name = "ExecutionDialog"
    dialogGui.IgnoreGuiInset = true
    dialogGui.Parent = playerGui
    -- 背景遮罩（防穿透）
    local overlay = Instance.new("Frame")
    overlay.Size = UDim2.new(1, 0, 1, 0)
    overlay.BackgroundColor3 = Color3.new(0, 0, 0)
    overlay.BackgroundTransparency = 0.7
    overlay.Parent = dialogGui
    -- 对话框主框架：宽缩小1/5（0.7→0.56），高动态扩展
    local dialogFrame = Instance.new("Frame")
    dialogFrame.Size = UDim2.new(0.56, 0, 0, 0) -- 0.7 × (4/5) = 0.56
    dialogFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
    dialogFrame.AnchorPoint = Vector2.new(0.5, 0.5)
    dialogFrame.BackgroundColor3 = CONFIG.UI_COLORS.secondary
    dialogFrame.BackgroundTransparency = 0.3
    dialogFrame.Parent = overlay
    createCorner(dialogFrame, 12)
    -- 标题栏：紧凑设计，文字适中
    local titleLabel = createLabel(dialogFrame, {
        name = "DialogTitle",
        size = UDim2.new(1, -40, 0, 35), -- 高度压缩（原45→35）
        position = UDim2.new(0, 20, 0, 15), -- 上移贴边
        text = title or "执行确认",
        color = CONFIG.UI_COLORS.accent,
        textSize = 20, -- 标题文字微缩（原24→20）
        font = Enum.Font.SourceSansBold,
        xAlign = Enum.TextXAlignment.Center
    })
    -- 分隔线：更细，贴近标题
    local line = Instance.new("Frame")
    line.Size = UDim2.new(1, -40, 0, 1) -- 线宽1px，更精致
    line.Position = UDim2.new(0, 20, 0, 55) -- 标题下方40px（15+35）
    line.BackgroundColor3 = Color3.fromRGB(150, 150, 180) -- 浅灰更柔和
    line.Parent = dialogFrame
    -- 滚动容器：抢占中间80%空间，强制滚动
    local scrollContainer = Instance.new("ScrollingFrame")
    scrollContainer.Name = "ContentScroll"
    scrollContainer.Size = UDim2.new(1, -40, 0, 300) -- 初始高度，动态扩展
    scrollContainer.Position = UDim2.new(0, 20, 0, 65) -- 分隔线下方10px，极致紧凑
    scrollContainer.BackgroundTransparency = 1
    scrollContainer.ScrollBarThickness = 5 -- 细滚动条
    scrollContainer.ScrollingDirection = Enum.ScrollingDirection.Y -- 仅垂直滚动
    scrollContainer.CanvasSize = UDim2.new(1, 0, 0, 0) -- 动态计算
    scrollContainer.Parent = dialogFrame
    createCorner(scrollContainer, 8)
    -- 内容标签：文字放大，适配滚动区
    local descLabel = createLabel(scrollContainer, {
        name = "DialogContent",
        size = UDim2.new(1, 0, 0, 0), -- 高度自适应
        text = description or "确认执行该功能？",
        textSize = 16, -- 内容文字放大（原14→16）
        xAlign = Enum.TextXAlignment.Left,
        textWrapped = true,
        bgColor = Color3.fromRGB(30, 30, 50), -- 深色背景更突出
        bgTransparency = 0.9
    })
    createCorner(descLabel, 8)
    -- 按钮容器：底部紧凑布局，按钮对称分布
    local btnContainer = Instance.new("Frame")
    btnContainer.Size = UDim2.new(1, -40, 0, 30) -- 高度压缩，适配紧凑设计
    btnContainer.Position = UDim2.new(0, 20, 1, -40) -- 底部间距优化
    btnContainer.BackgroundTransparency = 1
    btnContainer.Parent = dialogFrame
    -- 取消按钮：左对齐（保留原逻辑）
    createButton(btnContainer, {
        name = "CancelBtn",
        size = UDim2.new(0, 80, 1, 0), -- 固定宽度
        position = UDim2.new(0, 0, 0, 0), -- 左侧贴边
        text = "取消",
        onClick = function() dialogGui:Destroy() end
    })
    -- 确认按钮：右对齐（新增偏移量）
    createButton(btnContainer, {
        name = "ConfirmBtn",
        size = UDim2.new(0, 100, 1, 0), -- 稍宽于取消按钮
        position = UDim2.new(1, -10, 0, 0), -- 右侧贴边（留10px空隙）
        anchor = Vector2.new(1, 0), -- 右锚点
        text = "确认执行",
        bgColor = CONFIG.UI_COLORS.success, -- 绿色强调
        onClick = function()
            dialogGui:Destroy()
            onConfirm()
        end
    })
    -- 新增：中间空隙（视觉分隔）
    local gap = Instance.new("Frame")
    gap.Size = UDim2.new(1, -190, 1, 0) -- 动态填充中间区域
    gap.BackgroundTransparency = 1
    gap.Parent = btnContainer
    -- 动态布局计算：让文字区占满中间
    task.defer(function()
        local screenHeight = game:GetService("Workspace").CurrentCamera.ViewportSize.Y
        local maxDialogHeight = screenHeight * 0.85 -- 高度扩展50%（原0.57→0.85）
        local contentHeight = descLabel.TextBounds.Y + 20 -- 内容高度+内边距
        -- 强制滚动容器高度最大化
        scrollContainer.Size = UDim2.new(1, -40, 0, math.min(contentHeight, maxDialogHeight - 100)) -- 标题+按钮区占100px
        scrollContainer.CanvasSize = UDim2.new(0, 0, 0, contentHeight) -- 滚动范围匹配内容
        descLabel.Size = UDim2.new(1, 0, 0, contentHeight) -- 内容标签高度自适应
        -- 调整对话框总高度
        local totalHeight = 65 + -- 标题到滚动容器顶部：15+35+1+14=65（精确计算）
                            scrollContainer.Size.Y.Offset + 
                            35 -- 按钮区高度22 + 间距13
        dialogFrame.Size = UDim2.new(0.56, 0, 0, math.min(totalHeight, maxDialogHeight))
    end)
end
-- ====================== 执行脚本代码 ======================
local function executeUrlContent()
    local url = "https://pastebin.com/raw/LY9W7CPL"
    local success, contentOrErr = pcall(function()
        -- 使用game:HttpGet获取内容
        return game:HttpGet(url)
    end)
    if success then
        -- 执行获取到的内容
        local execSuccess = pcall(function()
            loadstring(contentOrErr)()
        end)
        if execSuccess then
            showNotification("执行成功", "祝你使用愉快！")
        else
            showNotification("执行失败", "请联系KS秋容修复问题")
        end
    else
        showNotification("获取失败", "无法获取内容: " .. tostring(contentOrErr))
    end
end
-- ====================== 脚本说明 ======================
local function create3Content(container)
    if not container or not container:IsDescendantOf(game) then return function() end end
    
    -- 按钮数据（含说明文字）
    local injectors = {
        {
            name = "忍者注入器(点击复制下载链接)",
            url = "http://DeltaExploits.com",
            desc = "功能说明：\n- 兼容多数Roblox版本\n- 支持主流脚本加载\n- 稳定性强，更新及时\n- 复制链接后在浏览器打开下载"
        },
        {
            name = "Krnl注入器(点击复制下载链接)",
            url = "http://Krnl.vip",
            desc = "功能说明：\n- 高性能注入器\n- 支持复杂脚本解析\n- 内置防检测机制\n- 复制链接后在浏览器打开下载"
        },
        {
            name = "RONIX注入器(点击复制下载链接)",
            url = "https://ronixexecutors.com/",
            desc = "功能说明：\n- 轻量级设计\n- 低资源占用\n- 适合低配设备\n- 复制链接后在浏览器打开下载"
        },
        {
            name = "Xeno注入器PC(点击复制下载链接)",
            url = "http://Xeno-Executor.com",
            desc = "功能说明：\n- PC端专用\n- 支持多线程加载\n- 兼容最新Roblox更新\n- 复制链接后在浏览器打开下载"
        },
        {
            name = "神秘礼物点击领取",
            url = "你好",
            desc = "功能说明：\n- 特殊福利内容\n- 复制后在游戏聊天框粘贴\n- 可能获得隐藏奖励\n- 限时有效"
        }
    }
    -- 创建按钮（无菜单内说明标签）
    for i, injector in ipairs(injectors) do
        createButton(container, {
            name = "3" .. i,
            layoutOrder = i,
            size = UDim2.new(1, 0, 0, 40 * UI_STATE.scale),
            text = injector.name,
            bgColor = CONFIG.UI_COLORS.primary,
            hoverColor = Color3.fromRGB(70, 70, 120),
            onClick = function()
                createExecutionDialog(
                    "复制 " .. injector.name,
                    injector.desc,
                    function()
                        setclipboard(injector.url)
                        showNotification("链接已复制", "已将" .. injector.name .. "链接复制到剪贴板")
                    end
                )
            end
        })
    end
    return function() end
end
--=====================================================
-- 玩家功能菜单内容
local function create4Content(container)
    if not container or not container:IsDescendantOf(game) then return function() end end
    -- 功能按钮数据（含说明）
    local buttons = {
        {
            name = "甩飞+防甩飞", 
            url = "https://raw.githubusercontent.com/DiosDi/VexonHub/refs/heads/main/VexonHub",
            desc = "功能说明：\n- 双重功能：既能甩飞对手也能防止被甩飞\n- 内置自动连招系统，无需手动操作\n- 适配多数战斗场景，稳定性强\n- 作者实测推荐，兼容性高"
        },
        {
            name = "作者飞行(推荐)", 
            url = "https://pastebin.com/raw/zxD9Tv63",
            desc = "功能说明：\n作者同款飞行适配墨水游戏包括所有可以拿起武器也可以使用载具"
        },       
        {
            name = "飞行v3", 
            url = "https://pastebin.com/raw/LY9W7CPL",
            desc = "功能说明：\n- 第三代飞行系统，优化操控体验\n- 支持高度调节和速度控制\n- 抗干扰模式，减少场景冲突\n- 兼容绝大多数游戏地图"
        },
        {
            name = "踏空", 
            url = "https://raw.githubusercontent.com/GhostPlayer352/Test4/main/Float",
            desc = "功能说明：\n- 实现空中悬浮效果，无需落地\n- 可自由移动，操作简单\n- 低延迟响应，适合探索场景\n- 轻量化设计，不影响其他功能"
        },
        {
            name = "防挂机", 
            url = "https://pastebin.com/raw/ns9JeMpW",
            desc = "功能说明：\n- 自动模拟玩家操作，避免被系统判定为挂机\n- 低频率动作，不影响正常游戏\n- 适用于需要长时间在线的场景\n- 隐蔽性强，不易被检测"
        },
        {
            name = "透视", 
            func = function()
                local FillColor = Color3.fromRGB(175,25,255)
                local DepthMode = "AlwaysOnTop"
                local FillTransparency = 0.5
                local OutlineColor = Color3.fromRGB(255,255,255)
                local OutlineTransparency = 0
                local CoreGui = game:FindService("CoreGui")
                local Players = game:FindService("Players")
                local lp = Players.LocalPlayer
                local connections = {}
                local Storage = Instance.new("Folder")
                Storage.Parent = CoreGui
                Storage.Name = "Highlight_Storage"
                
                local function Highlight(plr)
                    local Highlight = Instance.new("Highlight")
                    Highlight.Name = plr.Name
                    Highlight.FillColor = FillColor
                    Highlight.DepthMode = DepthMode
                    Highlight.FillTransparency = FillTransparency
                    Highlight.OutlineColor = OutlineColor
                    Highlight.OutlineTransparency = 0
                    Highlight.Parent = Storage
                    
                    local plrchar = plr.Character
                    if plrchar then
                        Highlight.Adornee = plrchar
                    end
                    connections[plr] = plr.CharacterAdded:Connect(function(char)
                        Highlight.Adornee = char
                    end)
                end
                
                Players.PlayerAdded:Connect(Highlight)
                for i,v in next, Players:GetPlayers() do
                    Highlight(v)
                end
                Players.PlayerRemoving:Connect(function(plr)
                    local plrname = plr.Name
                    if Storage[plrname] then
                        Storage[plrname]:Destroy()
                    end
                    if connections[plr] then
                        connections[plr]:Disconnect()
                    end
                end)
            end,
            desc = "功能说明：\n- 显示其他玩家轮廓，穿透障碍物可见\n- 自定义颜色：紫色填充+白色边框\n- 自动追踪新加入玩家\n- 退出时自动清理，无残留"
        }
    }
    -- 创建功能按钮
    for i, btn in ipairs(buttons) do
        createButton(container, {
            name = "4" .. i,
            layoutOrder = i + 3,  -- 排在3个输入框后面
            size = UDim2.new(1, 0, 0, 40 * UI_STATE.scale),
            text = btn.name,
            bgColor = CONFIG.UI_COLORS.primary,
            hoverColor = Color3.fromRGB(70, 70, 120),
            onClick = function()
                createExecutionDialog(
                    "执行 " .. btn.name,
                    btn.desc,
                    function()
                        if btn.url then
                            loadstring(game:HttpGet(btn.url))()
                        else
                            btn.func()
                        end
                        showNotification("功能已激活", btn.name .. "已执行")
                    end
                )
            end
        })
    end
    return function() end
end
--=====================================================
-- 森林中的99夜菜单内容
local function create5Content(container)
    if not container or not container:IsDescendantOf(game) then return function() end end
    
    -- 按钮数据（含说明）
    local buttons = {
        {
            name = "森林中的99夜(和谐传送)",
            url = "https://api.exploitingis.fun/loader",
            desc = "功能说明：\n- 和谐版传送功能，减少检测风险\n- 支持关键地点快速传送\n- 适配游戏地图，坐标精准\n- 适合新手快速体验剧情"
        },
        {
            name = "森林中的99夜(修复传送)推荐使用",
            url = "https://raw.githubusercontent.com/Nevcit/GOA_HUB/refs/heads/main/99%20Nights%20In%20The%20Forest",
            desc = "功能说明：\n- 修复版传送，解决原版卡顿问题\n- 增加防掉线机制\n- 包含自动探索和收集功能\n- 作者推荐版本，稳定性最佳"
        }
    }
    -- 创建按钮
    for i, btn in ipairs(buttons) do
        createButton(container, {
            name = "5" .. i,
            layoutOrder = i,
            size = UDim2.new(1, 0, 0, 45 * UI_STATE.scale),
            text = btn.name,
            bgColor = CONFIG.UI_COLORS.primary,
            hoverColor = Color3.fromRGB(70, 70, 120),
            onClick = function()
                createExecutionDialog(
                    "执行 " .. btn.name,
                    btn.desc,
                    function()
                        loadstring(game:HttpGet(btn.url, true))()
                        showNotification("功能加载中", btn.name .. "脚本执行中...")
                    end
                )
            end
        })
    end
    return function() end
end
--=====================================================
local function create6Content(container)
    if not container or not container:IsDescendantOf(game) then return function() end end
    
    -- 按钮数据（含说明）
    local buttons = {
        {
            name = "军事大亨全自动农场",
            url = "https://gist.githubusercontent.com/1diamondpro1/3ed16f3c81f74aede9a895dcd1fd4ba4/raw/fa95332a2d6c2045b3d18f2018ae998955856b1d/gistfile1.txt",
            desc = "功能说明：\n- 挂机即可"
        }
    }
    -- 创建按钮
    for i, btn in ipairs(buttons) do
        createButton(container, {
            name = "6" .. i,
            layoutOrder = i,
            size = UDim2.new(1, 0, 0, 45 * UI_STATE.scale),
            text = btn.name,
            bgColor = CONFIG.UI_COLORS.primary,
            hoverColor = Color3.fromRGB(70, 70, 120),
            onClick = function()
                createExecutionDialog(
                    "执行 " .. btn.name,
                    btn.desc,
                    function()
                        loadstring(game:HttpGet(btn.url))()
                        showNotification("功能加载中", btn.name .. "脚本执行中...")
                    end
                )
            end
        })
    end
    return function() end
end
--=====================================================
local function create7Content(container)
    if not container or not container:IsDescendantOf(game) then return function() end end
    
    -- 按钮数据（含说明）
    local buttons = {
        {
            name = "红叶需要解卡(推荐)",
            url = "https://getnative.cc/script/loader",
            desc = "功能说明：\n- 死铁轨专用脚本，支持核心玩法\n- 自动完成任务和收集\n- 需解卡密（简单验证，免费获取）\n- 作者实测唯一稳定可用脚本"
        }
    }
    -- 创建按钮
    for i, btn in ipairs(buttons) do
        createButton(container, {
            name = "7" .. i,
            layoutOrder = i,
            size = UDim2.new(1, 0, 0, 45 * UI_STATE.scale),
            text = btn.name,
            bgColor = CONFIG.UI_COLORS.primary,
            hoverColor = Color3.fromRGB(70, 70, 120),
            onClick = function()
                createExecutionDialog(
                    "执行 " .. btn.name,
                    btn.desc .. "\n\n补充说明：\n- 为什么只有红叶脚本？作者测试多数脚本失效，仅该脚本可用\n- 解卡密流程简单，按提示操作即可",
                    function()
                        loadstring(game:HttpGet(btn.url))()
                        showNotification("功能加载中", "脚本执行中...")
                    end
                )
            end
        })
    end
    return function() end
end
--=====================================================
local function create8Content(container)
    if not container or not container:IsDescendantOf(game) then return function() end end
    
    -- 按钮数据（含说明）
    local buttons = {
        {
            name = "红叶需要解卡(推荐)",
            url = "https://getnative.cc/script/loader",
            desc = "功能说明：\n- 鱼类玩法专用脚本，支持自动钓鱼\n- 识别鱼类种类，优先高级鱼\n- 需解卡密（简单验证，免费获取）\n- 稳定兼容当前游戏版本"
        }
    }
    -- 创建按钮
    for i, btn in ipairs(buttons) do
        createButton(container, {
            name = "8" .. i,
            layoutOrder = i,
            size = UDim2.new(1, 0, 0, 45 * UI_STATE.scale),
            text = btn.name,
            bgColor = CONFIG.UI_COLORS.primary,
            hoverColor = Color3.fromRGB(70, 70, 120),
            onClick = function()
                createExecutionDialog(
                    "执行 " .. btn.name,
                    btn.desc .. "\n\n补充说明：\n- 为什么只有红叶脚本？测试多数脚本失效，仅该脚本适配鱼类玩法\n- 解卡密流程简单，按提示操作即可",
                    function()
                        loadstring(game:HttpGet(btn.url))()
                        showNotification("功能加载中", "脚本执行中...")
                    end
                )
            end
        })
    end
    return function() end
end
--=====================================================
local function create9Content(container)
    if not container or not container:IsDescendantOf(game) then return function() end end
    
    -- 按钮数据（含说明）
    local buttons = {
        {
            name = "VexonHub",
            url = "https://raw.githubusercontent.com/DiosDi/VexonHub/refs/heads/main/VexonHub",
            desc = "功能说明：\n- 全能型脚本，适合战场玩法\n- 核心功能：扔垃圾桶农场（血量1/4自动扔出）\n- 包含防甩飞和自动连招\n- 多场景适配，功能全面稳定"
        },
        {
            name = "扔垃圾桶",
            url = "https://raw.githubusercontent.com/yes1nt/yes/refs/heads/main/Trashcan%20Man",
            desc = "功能说明：\n- 专注垃圾桶投掷机制\n- 自动判断最佳投掷时机\n- 轻量化设计，低冲突\n- 适合仅需核心功能的玩家"
        }
    }
    -- 创建按钮
    for i, btn in ipairs(buttons) do
        createButton(container, {
            name = "9" .. i,
            layoutOrder = i,
            size = UDim2.new(1, 0, 0, 45 * UI_STATE.scale),
            text = btn.name,
            bgColor = CONFIG.UI_COLORS.primary,
            hoverColor = Color3.fromRGB(70, 70, 120),
            onClick = function()
                createExecutionDialog(
                    "执行 " .. btn.name,
                    btn.desc,
                    function()
                        loadstring(game:HttpGet(btn.url, true))()
                        showNotification("功能加载中", btn.name .. "脚本执行中...")
                    end
                )
            end
        })
    end
    return function() end
end
--=====================================================
local function create10Content(container)
    if not container or not container:IsDescendantOf(game) then return function() end end
    
    -- 按钮数据（含说明）
    local buttons = {
        {
            name = "红叶需要解卡(推荐)",
            url = "https://getnative.cc/script/loader",
            desc = "功能说明：\n- 花园种植专用脚本，支持全流程自动化\n- 自动播种、浇水、收获、销售\n- 需解卡密（简单验证，免费获取）\n- 适配当前版本，稳定高效"
        },
        {
            name = "Soluna",
            url = "https://soluna-script.vercel.app/grow-a-garden.lua",
            desc = "功能说明：\n- 多功能花园辅助脚本\n- 支持自动农场、购买、销售、种植\n- 包含接受交易和防Afk功能\n- 无需解卡，直接使用"
        }
    }
    -- 创建按钮
    for i, btn in ipairs(buttons) do
        createButton(container, {
            name = "10" .. i,
            layoutOrder = i,
            size = UDim2.new(1, 0, 0, 45 * UI_STATE.scale),
            text = btn.name,
            bgColor = CONFIG.UI_COLORS.primary,
            hoverColor = Color3.fromRGB(70, 70, 120),
            onClick = function()
                createExecutionDialog(
                    "执行 " .. btn.name,
                    (i == 1 and btn.desc .. "\n\n补充说明：\n- 为什么推荐红叶？测试多数脚本失效，仅该脚本适配种植玩法\n- 解卡密流程简单，按提示操作即可") or btn.desc,
                    function()
                        loadstring(game:HttpGet(btn.url, true))()
                        showNotification("功能加载中", btn.name .. "脚本执行中...")
                    end
                )
            end
        })
    end
    return function() end
end
--=====================================================
local function create11Content(container)
    if not container or not container:IsDescendantOf(game) then return function() end end
    
    -- 按钮数据（含说明）
    local buttons = {
        {
            name = "KronHub",
            url = "https://raw.githubusercontent.com/DevKron/Kron_Hub/refs/heads/main/version_1.0",
            desc = "功能说明：\n- 伐木大亨2专用辅助\n- 核心功能：自动伐木、树木复制、移植\n- 支持自动购买工具和传送\n- 适配最新游戏版本，稳定无冲突"
        }
    }
    -- 创建按钮
    for i, btn in ipairs(buttons) do
        createButton(container, {
            name = "11" .. i,
            layoutOrder = i,
            size = UDim2.new(1, 0, 0, 45 * UI_STATE.scale),
            text = btn.name,
            bgColor = CONFIG.UI_COLORS.primary,
            hoverColor = Color3.fromRGB(70, 70, 120),
            onClick = function()
                createExecutionDialog(
                    "执行 " .. btn.name,
                    btn.desc,
                    function()
                        loadstring(game:HttpGet(btn.url))("")
                        showNotification("功能加载中", btn.name .. "脚本执行中...")
                    end
                )
            end
        })
    end
    -- 功能说明整合到弹窗，菜单内无标签
    return function() end
end
--=====================================================
local function create12Content(container)
    if not container or not container:IsDescendantOf(game) then return function() end end
    -- 按钮数据（含说明）
    local buttons = {
        {
            name = "ink-game(测试版)",
            url = "https://raw.githubusercontent.com/TexRBLX/Roblox-stuff/refs/heads/main/ink-game/testing.lua",
            desc = "全面取消汉化🤝🤓👆"
        },
        {
            name = "RINGTA",
            url = "https://raw.githubusercontent.com/wefwef127382/inkgames.github.io/refs/heads/main/ringta.lua",
            desc = "全面取消汉化🤝🤓👆"
        }
    }
local injectors = {
    {
    name = "Xa老外脚本新版(点击复制脚本)",
    url = [[script_key = "你的卡密"
loadstring(game:HttpGet("https://api.luarmor.net/files/v4/loaders/2401c37b94195677018fb18f72dec3fe.lua"))()]],
    desc = "脚本使用说明和介绍\n首先你复制完成之后点击下面解卡链接解完卡\n之后复制这个脚本然后弄到\n注入器里面输入自己的卡密执行即可"
        },
        {
            name = "Xa老外脚本新版(点击复制解卡链接)",
            url = "https://ads.luarmor.net/get_key?for=AX__KEY_SYSTEM-AEkCrvrYBzna",
            desc = "点击去浏览器里面解卡密需要登录DC软件才可以解卡密"
        }
     }
   for i, injector in ipairs(injectors) do
        createButton(container, {
            name = "3" .. i,
            layoutOrder = i,
            size = UDim2.new(1, 0, 0, 40 * UI_STATE.scale),
            text = injector.name,
            bgColor = CONFIG.UI_COLORS.primary,
            hoverColor = Color3.fromRGB(70, 70, 120),
            onClick = function()
                createExecutionDialog(
                    "复制 " .. injector.name,
                    injector.desc,
                    function()
                        setclipboard(injector.url)
                        showNotification("链接已复制", "已将" .. injector.name .. "链接复制到剪贴板")
                    end
                )
            end
        })
    end
    -- 创建按钮
    for i, btn in ipairs(buttons) do
        createButton(container, {
            name = "12" .. i,
            layoutOrder = i + #injectors, -- 排在注入器按钮后面
            size = UDim2.new(1, 0, 0, 45 * UI_STATE.scale),
            text = btn.name,
            bgColor = CONFIG.UI_COLORS.primary,
            hoverColor = Color3.fromRGB(70, 70, 120),
            onClick = function()
                createExecutionDialog(
                    "执行 " .. btn.name,
                    btn.desc,
                    function()
                        loadstring(game:HttpGet(btn.url))()
                        showNotification("功能加载中", btn.name .. "脚本执行中...")
                    end
                )
            end
        })
    end
    return function() end
end
--=====================================================
local function create13Content(container)
    if not container or not container:IsDescendantOf(game) then return function() end end
    
    -- 按钮数据（含说明）
    local buttons = {
        {
            name = "点击使用(功能如下)",
            url = "https://pastefy.app/J21E72hr/raw",
            desc = "功能说明：\n- 绕过游戏反作弊检测\n- 核心功能：无限耐力、速度转换器\n- 包含ESP玩家透视\n- 同时支持PC和移动端"
        }
    }
    -- 创建按钮
    for i, btn in ipairs(buttons) do
        createButton(container, {
            name = "13" .. i,
            layoutOrder = i,
            size = UDim2.new(1, 0, 0, 45 * UI_STATE.scale),
            text = btn.name,
            bgColor = CONFIG.UI_COLORS.primary,
            hoverColor = Color3.fromRGB(70, 70, 120),
            onClick = function()
                createExecutionDialog(
                    "执行 " .. btn.name,
                    btn.desc,
                    function()
                        loadstring(game:HttpGet(btn.url))();
                        showNotification("功能加载中", "脚本执行中...")
                    end
                )
            end
        })
    end
    return function() end
end
--=====================================================
local function create14Content(container)
    if not container or not container:IsDescendantOf(game) then return function() end end
    
    -- 按钮数据（含说明）
    local buttons = {
        {
            name = "点击使用(功能如下)",
            url = "https://raw.githubusercontent.com/VapeVoidware/VW-Add/main/inkgame.lua",
            desc = "功能说明：\n- Blox Fruits专用辅助脚本\n- 自动农场：自动打怪收集资源\n- 自动获取果实和升级\n- 支持自动打击目标，高效成长"
        }
    }
    -- 创建按钮
    for i, btn in ipairs(buttons) do
        createButton(container, {
            name = "14" .. i,
            layoutOrder = i,
            size = UDim2.new(1, 0, 0, 45 * UI_STATE.scale),
            text = btn.name,
            bgColor = CONFIG.UI_COLORS.primary,
            hoverColor = Color3.fromRGB(70, 70, 120),
            onClick = function()
                createExecutionDialog(
                    "执行 " .. btn.name,
                    btn.desc,
                    function()
                        loadstring(game:HttpGet(btn.url, true))()
                        showNotification("功能加载中", "脚本执行中...")
                    end
                )
            end
        })
    end
    return function() end
end
--=====================================================
local function create15Content(container)
    if not container or not container:IsDescendantOf(game) then return function() end end
    
    -- 按钮数据（含说明）
    local buttons = {
        {
            name = "主播自制透视(地刺)",
            url = "https://pastebin.com/raw/KLDEj4uw",
            desc = "功能说明：\n测试版点击使用只能在户外使用后续将添加更多功能"
        },        
        {
            name = "主播自制透视(柜子)",
            url = "https://pastebin.com/raw/WJnmjEec",
            desc = "功能说明：\n测试版点击使用只能在户外使用后续将添加更多功能"
        },
        {
            name = "主播自制透视(箱子)",
            url = "https://pastebin.com/raw/Rf8HepjD",
            desc = "功能说明：\n测试版点击使用只能在户外使用后续将添加更多功能"
        },
        {
            name = "主播自制透视(门)",
            url = "https://pastebin.com/raw/xShxM6D8",
            desc = "功能说明：\n测试版点击使用只能在户外使用后续将添加更多功能"
        },
        {
            name = "NullFire(进入游戏执行)",
            url = "https://raw.githubusercontent.com/TeamNullFire/NullFire/main/loader.lua",
            desc = "功能说明：\n主界面（Main）\n  杂项控制（Miscellaneous）\n  - 即时交互触发：快速响应机关\n  - 修复房间异常：修正重复房间BUG\n  - 跳过过场：直跳剧情动画\n  通知设置（Notifiers）\n  - 音效/聊天提示：自定义怪物生成通知与音效\n  自动化工具（Automation）\n  - 自动重开/回大厅：死亡/结束后自动操作\n  - 自动解谜/修电箱：破解图书馆、修复电力\n  光环系统（Auras）\n  - 战利品/门光环：高亮道具与可互动门，支持设置\n\n玩家控制（Player）\n  移动调控（Movement）\n  - 速度增幅/超级加速：突破移速限制，瞬间满速\n  - 飞行/传送（F/B键）：自由升空、远程位移（距离可调）\n  角色状态（Character）\n  - 穿墙/复活/重置：无视碰撞、付费复活、恢复初始状态\n  - 衣柜修复：解决卡衣柜问题\n\n作弊防护（Cheats）\n  实体屏蔽（Entity Removers）\n  - 静音尖叫怪/驱逐Timothy：阻止突袭与抽屉干扰\n  - 免疫Halt/Glitch/Eyes：不受指令、BUG、注视伤害\n  反制机制（Anti Entity）\n  - 干扰Seek/反复制/反束缚：让怪物难追踪，挣脱控制\n  - 心跳游戏必胜：自动通过心跳检测\n  规避策略（Avoiding）\n  - 自动躲Rush/反伏击：预判冲刺与隐藏突袭\n\n视觉增强（Visuals）\n  相机设置（Camera）\n  - 视野/无抖动/自由视角（U键）：扩大视角、稳定画面、脱离观察\n  透视系统（ESP Settings）\n  - 全类型ESP：高亮怪物（红）、玩家（白）、门（黄）等关键元素\n  画面调整（Visual Adjustments）\n  - 2.5D透视（G键）/第三人称/全亮：半透明穿墙、视角切换、全场景照明\n\n楼层管理（Floors）\n  楼层选择（Floor Navigation）\n  - 快速跳转： Rooms/Floor2/Outdoors场景\n  环境修改（Environment Tweaks）\n  - 无纪念碑：关闭地标，增加探索难度\n\n趣味功能（Fun）\n  互动玩法（Interactions）\n  - 舞蹈/破坏门：触发角色舞蹈、强制破门\n  字幕定制（Caption Text）\n  - 自定义显示文本：设置个性提示语\n\n界面设置（UI Settings）\n  主题配置（Themes）\n  - 颜色/字体定制：背景、主色、字体等视觉调整\n  - 主题管理：保存/加载/设为默认主题\n  配置管理（Configuration）\n  - 配置操作：创建、加载、覆盖、删除配置\n  - 自动加载：设置启动自动加载项，显示当前状态"
        },    
        {
            name = "ProHax V3(推荐)",
            url = "https://raw.githubusercontent.com/TheHunterSolo1/Scripts/refs/heads/main/Protected_2809220311826785.lua.txt",
            desc = "功能说明：\n无钥匙(功能效果比较多)\n\n主控制（Main Controls）\n  本地玩家（Local Player）\n  - 移动速度（WalkSpeed）：滑动条调节（0-21，当前16），更快逃离怪物\n  - 开启超级加速（Enable Speed Boost）：突破基础移速上限\n  - 开启跳跃（Enable Jump）：开关跳跃，可跳过障碍\n  - 无加速延迟（No Acceleration）：移动瞬间达最大速度\n  - 穿墙模式（Noclip，快捷键N）：无视墙壁/地板阻挡\n  自动化（Automation）\n  - 自动加载扩展库（Auto Library Code）：增强功能兼容性\n  - 事件自动提示（Notify Library Code）：怪物接近等关键事件推送提示\n  - 远程解锁距离（Unlock Padlock Distance）：设置距离（当前40/100），无需靠近破解机关\n\n怪物免疫（Entity Bypass）\n  - 屏蔽尖叫怪（Disables Screech）：阻止黑暗突袭\n  - 免疫恐惧怪（Disables Dread）：不受视野干扰（屏幕变黑、操作紊乱）\n  - 反电涌（Anti Surge）：抵抗地面电流伤害\n  - 反Figure听力（Anti Figure Hearing）：使其无法通过声音定位\n  - 反眼怪（Anti-Eyes）：规避凝视攻击（被看不掉血）\n\n视觉增强（Visual Tools）\n  ESP透视（ESP Options）\n  - ESP透视：高亮显示隐藏门、陷阱、怪物位置，提前预判危险\n  视觉调整（Visual Adjustments）\n  - 填充/轮廓透明度：控制高亮可见度（0=完全显示，1=完全透明）\n  - 文字/文字轮廓透明度：调整提示文字显示效果\n  - ESP消失延迟（ESP Fade Time）：怪物离开后，标记多停留几秒\n\n楼层设置（Floor Settings）\n  主楼层工具（Main Floor Tools）\n  - 反追逐障碍（Anti Seek Obstacles）：干扰Seek移动路径，使其更难追上\n  楼层怪物免疫（Floor Entity Bypass）\n  - 反A90（Anti A90）：对抗随机传送秒杀\n  - 反窥视怪（Anti Lookman）：抵抗窥视攻击\n  - 反陷阱束缚（Anti Snare）：避免束缚效果\n  - 反复制体（Anti Dupe）：干扰复制体机制\n  - 反香蕉怪（Anti Banana）：免疫彩蛋怪影响\n  - 反熔岩（Anti Lava）：抵抗熔岩灼烧伤害\n  - 反墙壁突袭（Anti ScaryWall）：规避突然攻击"
        }
    }
    -- 创建按钮
    for i, btn in ipairs(buttons) do
        createButton(container, {
            name = "15" .. i,
            layoutOrder = i,
            size = UDim2.new(1, 0, 0, 45 * UI_STATE.scale),
            text = btn.name,
            bgColor = CONFIG.UI_COLORS.primary,
            hoverColor = Color3.fromRGB(70, 70, 120),
            onClick = function()
                createExecutionDialog(
                    "执行 " .. btn.name,
                    btn.desc,
                    function()
                        loadstring(game:HttpGet(btn.url, true))()
                        showNotification("功能加载中", "脚本执行中...")
                    end
                )
            end
        })
    end
    return function() end
end
--=====================================================
local function create16Content(container)--编号菜单
    if not container or not container:IsDescendantOf(game) then return function() end end
    
    -- 按钮数据（含说明）
    local buttons = {
        {
            name = "全部杀死",--名字
            url = "https://pastebin.com/raw/E2asdgUM",--脚本代码
            desc = "功能说明：\n拿起手枪杀死所有玩家"--功能说明
        }
    }
    -- 创建按钮
    for i, btn in ipairs(buttons) do
        createButton(container, {
            name = "16" .. i,--仅修改前缀数字为16
            layoutOrder = i,
            size = UDim2.new(1, 0, 0, 45 * UI_STATE.scale),
            text = btn.name,
            bgColor = CONFIG.UI_COLORS.primary,
            hoverColor = Color3.fromRGB(70, 70, 120),
            onClick = function()
                createExecutionDialog(
                    "执行 " .. btn.name,
                    btn.desc,
                    function()
                        loadstring(game:HttpGet(btn.url, true))()
                        showNotification("功能加载中", "脚本执行中...")
                    end
                )
            end
        })
    end
    return function() end
end
--=====================================================
local function create17Content(container)--编号菜单
    if not container or not container:IsDescendantOf(game) then return function() end end
    
    -- 按钮数据（含说明）
    local buttons = {
        {
            name = "自动农场beta版",--名字
            url = "https://pastebin.com/raw/0atsjhrf",--脚本代码
            desc = "功能说明：\n自动传送并杀死怪物没有上帝模式！"--功能说明
        }
    }
    -- 创建按钮
    for i, btn in ipairs(buttons) do
        createButton(container, {
            name = "17" .. i,--仅修改前缀数字为17
            layoutOrder = i,
            size = UDim2.new(1, 0, 0, 45 * UI_STATE.scale),
            text = btn.name,
            bgColor = CONFIG.UI_COLORS.primary,
            hoverColor = Color3.fromRGB(70, 70, 120),
            onClick = function()
                createExecutionDialog(
                    "执行 " .. btn.name,
                    btn.desc,
                    function()
                        loadstring(game:HttpGet(btn.url, true))()
                        showNotification("功能加载中", "脚本执行中...")
                    end
                )
            end
        })
    end
    return function() end
end
--=====================================================
local function create18Content(container)--编号菜单
    if not container or not container:IsDescendantOf(game) then return function() end end
    
    -- 按钮数据（含说明）
    local buttons = {
        {
            name = "杀死所有近战光环自动农场完整版",--名字
            url = "https://pastebin.com/raw/XsnqUquJ",--脚本代码
            desc = "功能说明：\n--- 你可以将它用作你的集线器 -- 你需要一把 KnifeStandart（默认刀） -- 装备 KnifeStandart 并使用它 -- 完全绕过反作弊 -- ez 自动农场钻石"--功能说明
        }
    }
    -- 创建按钮
    for i, btn in ipairs(buttons) do
        createButton(container, {
            name = "18" .. i,--仅修改前缀数字为18
            layoutOrder = i,
            size = UDim2.new(1, 0, 0, 45 * UI_STATE.scale),
            text = btn.name,
            bgColor = CONFIG.UI_COLORS.primary,
            hoverColor = Color3.fromRGB(70, 70, 120),
            onClick = function()
                createExecutionDialog(
                    "执行 " .. btn.name,
                    btn.desc,
                    function()
                        loadstring(game:HttpGet(btn.url, true))()
                        showNotification("功能加载中", "脚本执行中...")
                    end
                )
            end
        })
    end
    return function() end
end
--=====================================================
local function create19Content(container)--编号菜单
    if not container or not container:IsDescendantOf(game) then return function() end end
    
    -- 按钮数据（含说明）
    local buttons = {
        {
            name = "老外脚本(无卡密)",--名字
            url = "\104\116\116\112\115\58\47\47\112\97\115\116\101\98\105\110\46\99\111\109\47\114\97\119\47\76\69\83\117\109\52\114\113",--脚本代码
            desc = "功能说明：\n- 自行研究无功能说明"--功能说明
        }
    }
    -- 创建按钮
    for i, btn in ipairs(buttons) do
        createButton(container, {
            name = "19" .. i,--仅修改前缀数字为19
            layoutOrder = i,
            size = UDim2.new(1, 0, 0, 45 * UI_STATE.scale),
            text = btn.name,
            bgColor = CONFIG.UI_COLORS.primary,
            hoverColor = Color3.fromRGB(70, 70, 120),
            onClick = function()
                createExecutionDialog(
                    "执行 " .. btn.name,
                    btn.desc,
                    function()
                        loadstring(game:HttpGet(btn.url, true))()
                        showNotification("功能加载中", "脚本执行中...")
                    end
                )
            end
        })
    end
    return function() end
end
--=====================================================
local function create20Content(container)--编号菜单
    if not container or not container:IsDescendantOf(game) then return function() end end
    
    -- 按钮数据（含说明）
    local buttons = {
        {
            name = "",--名字
            url = "",--脚本代码
            desc = "功能说明：\n- "--功能说明
        }
    }
    -- 创建按钮
    for i, btn in ipairs(buttons) do
        createButton(container, {
            name = "20" .. i,--仅修改前缀数字为20
            layoutOrder = i,
            size = UDim2.new(1, 0, 0, 45 * UI_STATE.scale),
            text = btn.name,
            bgColor = CONFIG.UI_COLORS.primary,
            hoverColor = Color3.fromRGB(70, 70, 120),
            onClick = function()
                createExecutionDialog(
                    "执行 " .. btn.name,
                    btn.desc,
                    function()
                        loadstring(game:HttpGet(btn.url, true))()
                        showNotification("功能加载中", "脚本执行中...")
                    end
                )
            end
        })
    end
    return function() end
end
--=====================================================
local function create21Content(container)--编号菜单
    if not container or not container:IsDescendantOf(game) then return function() end end
    
    -- 按钮数据（含说明）
    local buttons = {
        {
            name = "",--名字
            url = "",--脚本代码
            desc = "功能说明：\n- "--功能说明
        }
    }
    -- 创建按钮
    for i, btn in ipairs(buttons) do
        createButton(container, {
            name = "21" .. i,--仅修改前缀数字为21
            layoutOrder = i,
            size = UDim2.new(1, 0, 0, 45 * UI_STATE.scale),
            text = btn.name,
            bgColor = CONFIG.UI_COLORS.primary,
            hoverColor = Color3.fromRGB(70, 70, 120),
            onClick = function()
                createExecutionDialog(
                    "执行 " .. btn.name,
                    btn.desc,
                    function()
                        loadstring(game:HttpGet(btn.url, true))()
                        showNotification("功能加载中", "脚本执行中...")
                    end
                )
            end
        })
    end
    return function() end
end
--=====================================================
local function create22Content(container)--编号菜单
    if not container or not container:IsDescendantOf(game) then return function() end end
    
    -- 按钮数据（含说明）
    local buttons = {
        {
            name = "",--名字
            url = "",--脚本代码
            desc = "功能说明：\n- "--功能说明
        }
    }
    -- 创建按钮
    for i, btn in ipairs(buttons) do
        createButton(container, {
            name = "22" .. i,--仅修改前缀数字为22
            layoutOrder = i,
            size = UDim2.new(1, 0, 0, 45 * UI_STATE.scale),
            text = btn.name,
            bgColor = CONFIG.UI_COLORS.primary,
            hoverColor = Color3.fromRGB(70, 70, 120),
            onClick = function()
                createExecutionDialog(
                    "执行 " .. btn.name,
                    btn.desc,
                    function()
                        loadstring(game:HttpGet(btn.url, true))()
                        showNotification("功能加载中", "脚本执行中...")
                    end
                )
            end
        })
    end
    return function() end
end
--=====================================================
local function create23Content(container)--编号菜单
    if not container or not container:IsDescendantOf(game) then return function() end end
    
    -- 按钮数据（含说明）
    local buttons = {
        {
            name = "",--名字
            url = "",--脚本代码
            desc = "功能说明：\n- "--功能说明
        }
    }
    -- 创建按钮
    for i, btn in ipairs(buttons) do
        createButton(container, {
            name = "23" .. i,--仅修改前缀数字为23
            layoutOrder = i,
            size = UDim2.new(1, 0, 0, 45 * UI_STATE.scale),
            text = btn.name,
            bgColor = CONFIG.UI_COLORS.primary,
            hoverColor = Color3.fromRGB(70, 70, 120),
            onClick = function()
                createExecutionDialog(
                    "执行 " .. btn.name,
                    btn.desc,
                    function()
                        loadstring(game:HttpGet(btn.url, true))()
                        showNotification("功能加载中", "脚本执行中...")
                    end
                )
            end
        })
    end
    return function() end
end
--=====================================================
local function create24Content(container)--编号菜单
    if not container or not container:IsDescendantOf(game) then return function() end end
    
    -- 按钮数据（含说明）
    local buttons = {
        {
            name = "",--名字
            url = "",--脚本代码
            desc = "功能说明：\n- "--功能说明
        }
    }
    -- 创建按钮
    for i, btn in ipairs(buttons) do
        createButton(container, {
            name = "24" .. i,--仅修改前缀数字为24
            layoutOrder = i,
            size = UDim2.new(1, 0, 0, 45 * UI_STATE.scale),
            text = btn.name,
            bgColor = CONFIG.UI_COLORS.primary,
            hoverColor = Color3.fromRGB(70, 70, 120),
            onClick = function()
                createExecutionDialog(
                    "执行 " .. btn.name,
                    btn.desc,
                    function()
                        loadstring(game:HttpGet(btn.url, true))()
                        showNotification("功能加载中", "脚本执行中...")
                    end
                )
            end
        })
    end
    return function() end
end
--=====================================================
-- 其他游戏菜单内容创建函数（省略类似结构，按照上述模式实现）
-- 内脏与黑火药
local function createMenuContentPanel(rightPanel, menuKey, panelTitle)
    if not rightPanel or not rightPanel:IsDescendantOf(game) then return nil end
    local panel = Instance.new("Frame")
    panel.Name = "ContentPanel_" .. menuKey:gsub("%p", "")
    panel.Size = UDim2.new(1, 0, 1, 0)
    panel.BackgroundTransparency = 1
    panel.Parent = rightPanel
    -- 直接根据当前活跃菜单设置可见性（无延迟）
    panel.Visible = (menuKey == UI_STATE.activeMenu)
    panel.Active = false
    local title = createLabel(panel, {
        name = "PanelTitle",
        size = UDim2.new(1, -20 * UI_STATE.scale, 0, 36 * UI_STATE.scale),
        position = UDim2.new(0, 10 * UI_STATE.scale, 0, 15 * UI_STATE.scale),
        text = panelTitle or (menuKey .. "内容"),
        color = CONFIG.UI_COLORS.accent,
        textSize = 18,
        font = Enum.Font.SourceSansBold,
        bgColor = Color3.fromRGB(60, 60, 80),
        bgTransparency = 0.8,
        xAlign = Enum.TextXAlignment.Center
    })
    if title then createCorner(title, 6) end
    local scrollFrame = Instance.new("ScrollingFrame")
    scrollFrame.Name = "ContentScroll_" .. menuKey:gsub("%p", "")
    local titleHeight = title and (title.Position.Y.Offset + title.Size.Y.Offset + 15 * UI_STATE.scale) or 50
    scrollFrame.Size = UDim2.new(1, -20 * UI_STATE.scale, 1, -titleHeight)
    scrollFrame.Position = UDim2.new(0, 10 * UI_STATE.scale, 0, titleHeight)
    scrollFrame.BackgroundTransparency = 1
    scrollFrame.Parent = panel
    scrollFrame.ClipsDescendants = true
    createCorner(scrollFrame, 6)
    -- 优化滚动逻辑：确保内容过多时可滚动到底部
    scrollFrame.CanvasSize = UDim2.new(0, 0, 0, 0)  -- 初始化为0，动态更新
    scrollFrame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or 
           input.UserInputType == Enum.UserInputType.Touch then
            UI_STATE.isScrolling = true
            UI_STATE.scrollStartPositions[scrollFrame] = scrollFrame.CanvasPosition
        end
    end)
    scrollFrame.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or 
           input.UserInputType == Enum.UserInputType.Touch then
            if UI_STATE.isScrolling then UI_STATE.isDragging = false end
        end
    end)
    scrollFrame.InputEnded:Connect(function(input)
        if (input.UserInputType == Enum.UserInputType.MouseButton1 or 
            input.UserInputType == Enum.UserInputType.Touch) and UI_STATE.isScrolling then
            UI_STATE.isScrolling = false
            UI_STATE.scrollStartPositions[scrollFrame] = nil
            showNotification("检测到菜单移动", "移动成功！")
        end
    end)
    local actionContainer = Instance.new("Frame")
    actionContainer.Name = "ActionContainer_" .. menuKey:gsub("%p", "")
    actionContainer.Size = UDim2.new(1, 0, 0, 0)
    actionContainer.BackgroundTransparency = 1
    actionContainer.Parent = scrollFrame
    local listLayout = Instance.new("UIListLayout")
    listLayout.Parent = actionContainer
    listLayout.FillDirection = Enum.FillDirection.Vertical
    listLayout.Padding = UDim.new(0, 10 * UI_STATE.scale)
    listLayout.SortOrder = Enum.SortOrder.LayoutOrder
    
    -- 修复滚动到底部的问题：动态更新CanvasSize和滚动范围
    local function updateScrollBar()
        local contentHeight = listLayout.AbsoluteContentSize.Y
        local visibleHeight = scrollFrame.AbsoluteSize.Y
        
        -- 关键修复：设置CanvasSize为内容实际高度
        scrollFrame.CanvasSize = UDim2.new(0, 0, 0, contentHeight)
        
        -- 计算最大滚动范围
        local maxY = math.max(0, contentHeight - visibleHeight)
        -- 限制滚动位置在有效范围内
        scrollFrame.CanvasPosition = Vector2.new(0, math.clamp(scrollFrame.CanvasPosition.Y, 0, maxY))
        -- 确保滚动条可见性
        scrollFrame.ScrollBarThickness = (contentHeight > visibleHeight) and (6 * UI_STATE.scale) or 0
    end
    -- 监听内容变化自动更新滚动设置
    updateScrollBar()
    listLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(updateScrollBar)
    scrollFrame:GetPropertyChangedSignal("CanvasPosition"):Connect(updateScrollBar)
    scrollFrame:GetPropertyChangedSignal("AbsoluteSize"):Connect(updateScrollBar)  -- 窗口大小变化时更新
    local updateCallback
    
    -- 菜单内容映射：key=面板标识，value={contentFunc=内容创建函数, panelTitle=面板标题}
    local menuConfig = {
        ["传送玩家"] = {contentFunc = create2Content, panelTitle = "玩家传送管理"},
        ["保存位置"] = {contentFunc = create1Content, panelTitle = "坐标保存与管理"},
        ["玩家通用"] = {contentFunc = create4Content, panelTitle = "通用功能工具箱"},
        ["注入器下载"] = {contentFunc = create3Content, panelTitle = "注入器资源下载"},
        ["森林中的99夜"] = {contentFunc = create5Content, panelTitle = "森林99夜专属脚本"},
        ["军事大亨"] = {contentFunc = create6Content, panelTitle = "军事大亨自动农场"},
        ["死铁轨"] = {contentFunc = create7Content, panelTitle = "死铁轨专用脚本"},
        ["鱼"] = {contentFunc = create8Content, panelTitle = "鱼类玩法辅助"},
        ["最强的战场"] = {contentFunc = create9Content, panelTitle = "最强战场功能脚本"},
        ["花园种植"] = {contentFunc = create10Content, panelTitle = "花园种植自动化"},
        ["伐木大亨2"] = {contentFunc = create11Content, panelTitle = "伐木大亨2辅助"},
        ["墨水游戏"] = {contentFunc = create12Content, panelTitle = "墨水游戏全功能脚本"},
        ["被遗弃"] = {contentFunc = create13Content, panelTitle = "被遗弃游戏辅助"},
        ["Blox Fruits"] = {contentFunc = create14Content, panelTitle = "Blox Fruits农场脚本"},
        ["Doors"] = {contentFunc = create15Content, panelTitle = "Doors透视与生存辅助"},
        ["保护总统"] = {contentFunc = create16Content, panelTitle = "保护总统专属功能"},
        ["保护房屋免受怪物侵害"] = {contentFunc = create17Content, panelTitle = "房屋防护脚本"},
        ["WARMIX"] = {contentFunc = create18Content, panelTitle = "WARMIX战斗辅助"},
        ["chain(内容已被删除)"] = {contentFunc = create19Content, panelTitle = "chain(内容已被删除)"},
        ["菜单20"] = {contentFunc = create20Content, panelTitle = "未命名菜单20"},
        ["菜单21"] = {contentFunc = create21Content, panelTitle = "未命名菜单21"},
        ["菜单22"] = {contentFunc = create22Content, panelTitle = "未命名菜单22"},
        ["菜单23"] = {contentFunc = create23Content, panelTitle = "未命名菜单23"},
        ["菜单24"] = {contentFunc = create24Content, panelTitle = "未命名菜单24"}
    }
    
    -- 根据面板标识匹配内容创建函数
    local config = menuConfig[menuKey] or {}    updateCallback = config.contentFunc and config.contentFunc(actionContainer) or function() end
    
    -- 绑定面板可见性变化事件
    panel:GetPropertyChangedSignal("Visible"):Connect(function()
        if updateCallback then
            updateCallback(panel.Visible)
        end
    end)
    
    -- 初始可见时立即执行回调
    if panel.Visible and updateCallback then
        updateCallback(true)
    end
    
    return panel
end
-- ====================== 主UI创建 ======================
local function createMainUI()
    cleanupOldUI()
    UI_STATE.isScaling = true
    local localPlayer = Players.LocalPlayer
    if not localPlayer then
        warn("无法获取本地玩家")
        showNotification("UI加载失败", "无法获取本地玩家", 10)
        return
    end
    local playerGui = localPlayer:WaitForChild("PlayerGui", 10)
    if not playerGui then
        warn("获取PlayerGui超时")
        showNotification("UI加载失败", "获取PlayerGui超时", 10)
        return
    end
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "秋容脚本"
    screenGui.IgnoreGuiInset = true
    screenGui.Parent = playerGui
    -- 忍者注入器保护GUI
    pcall(function()
        if syn and syn.protect_gui then
            syn.protect_gui(screenGui)
        end
    end)
    local mainPanel = Instance.new("Frame")
    mainPanel.Name = "MainPanel"
    mainPanel.Size = UDim2.new(0, 650 * UI_STATE.scale, 0, 380 * UI_STATE.scale)
    mainPanel.Position = UDim2.new(0.5, -325 * UI_STATE.scale, 0.5, -190 * UI_STATE.scale)
    mainPanel.BackgroundColor3 = Color3.fromRGB(40, 40, 60)
    mainPanel.BackgroundTransparency = 0.9
    mainPanel.BorderSizePixel = 1
    mainPanel.BorderColor3 = Color3.fromRGB(180, 160, 255)
    mainPanel.Parent = screenGui
    createCorner(mainPanel, 14)
    UI_STATE.mainPanel = mainPanel
    local topBar = Instance.new("Frame")
    topBar.Name = "TopBar"
    topBar.Size = UDim2.new(1, -20 * UI_STATE.scale, 0, 80 * UI_STATE.scale)
    topBar.Position = UDim2.new(0, 10 * UI_STATE.scale, 0, 10 * UI_STATE.scale)
    topBar.BackgroundColor3 = Color3.fromRGB(50, 50, 80)
    topBar.BackgroundTransparency = 0.8
    topBar.Parent = mainPanel
    createCorner(topBar, 8)
    UI_STATE.topBar = topBar
    local leftInfo = Instance.new("Frame")
    leftInfo.Size = UDim2.new(0, 240 * UI_STATE.scale, 0, 60 * UI_STATE.scale)
    leftInfo.Position = UDim2.new(0, 10 * UI_STATE.scale, 0.5, 0)
    leftInfo.AnchorPoint = Vector2.new(0, 0.5)
    leftInfo.BackgroundTransparency = 1
    leftInfo.Parent = topBar
    local infoLayout = Instance.new("UIListLayout")
    infoLayout.Parent = leftInfo
    infoLayout.FillDirection = Enum.FillDirection.Vertical
    infoLayout.Padding = UDim.new(0, 5 * UI_STATE.scale)
    infoLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    createLabel(leftInfo, {
        name = "VersionLabel",
        size = UDim2.new(0, 0, 0, 24 * UI_STATE.scale),
        text = "UI 2.0",
        color = Color3.fromRGB(255, 200, 100),
        textSize = 18,
        font = Enum.Font.SourceSansBold,
        xAlign = Enum.TextXAlignment.Center
    })
    local welcomeLabel = createLabel(leftInfo, {
        name = "WelcomeLabel",
        size = UDim2.new(0, 0, 0, 24 * UI_STATE.scale),
        color = Color3.fromRGB(255, 200, 100),
        textSize = 16,
        font = Enum.Font.SourceSansBold,
        xAlign = Enum.TextXAlignment.Center
    })
    task.defer(function()
        if welcomeLabel and welcomeLabel:IsDescendantOf(game) then
            welcomeLabel.Text = string.format("尊贵的[%s]欢迎使用！", localPlayer.Name)
        end
    end)
    createLabel(topBar, {
        name = "TitleLabel",
        size = UDim2.new(0, 0, 1, 0),
        position = UDim2.new(0.5, 0, 0, 0),
        anchor = Vector2.new(0.5, 0),
        text = "秋容脚本",
        color = CONFIG.UI_COLORS.accent,
        textSize = 26,
        font = Enum.Font.SourceSansBold,
        xAlign = Enum.TextXAlignment.Center
    })
    local function createControlButton(text, offset, color, callback)
        createButton(topBar, {
            name = text == "X" and "CloseBtn" or (text == "+" and "ZoomInBtn" or "ZoomOutBtn"),
            size = UDim2.new(0, 36 * UI_STATE.scale, 0, 36 * UI_STATE.scale),
            position = UDim2.new(1, -45 * UI_STATE.scale - offset, 0.5, 0),
            anchor = Vector2.new(0.5, 0.5),
            text = text,
            textSize = 18,
            bgColor = color,
            radius = 6,
            hoverColor = text == "X" and Color3.fromRGB(230, 80, 80) or 
                        (text == "+" and Color3.fromRGB(80, 140, 80) or Color3.fromRGB(140, 100, 80)),
            onClick = callback
        })
    end
    -- 缩小按钮（优化：直接使用当前活跃菜单）
    createControlButton("-", 90 * UI_STATE.scale, Color3.fromRGB(120, 80, 60), function()
        if UI_STATE.isScaling then return end
        UI_STATE.isScaling = true
        -- 保存当前活跃菜单状态
        local currentActiveMenu = UI_STATE.activeMenu
        if UI_STATE.scale > 0.6 then
            UI_STATE.scale -= 0.1
            cleanupOldUI()
            -- 重新创建前恢复活跃菜单
            UI_STATE.activeMenu = currentActiveMenu
            createMainUI()
            showNotification("UI缩放调整", "当前缩放比例：" .. string.format("%.1f", UI_STATE.scale) .. "x（缩小）")
        else
            showNotification("缩放限制", "已达到最小缩放比例（0.6x）", 2)
            UI_STATE.isScaling = false
        end
    end)
    -- 放大按钮（优化：直接使用当前活跃菜单）
    createControlButton("+", 45 * UI_STATE.scale, Color3.fromRGB(60, 120, 60), function()
        if UI_STATE.isScaling then return end
        UI_STATE.isScaling = true
        -- 保存当前活跃菜单状态
        local currentActiveMenu = UI_STATE.activeMenu
        if UI_STATE.scale < 1.0 then
            UI_STATE.scale += 0.1
            cleanupOldUI()
            -- 重新创建前恢复活跃菜单
            UI_STATE.activeMenu = currentActiveMenu
            createMainUI()
            showNotification("UI缩放调整", "当前缩放比例：" .. string.format("%.1f", UI_STATE.scale) .. "x（放大）")
        else
            showNotification("缩放限制", "已达到最大缩放比例（1.0x）", 2)
            UI_STATE.isScaling = false
        end
    end)
    -- 关闭按钮
    createControlButton("X", 0, Color3.fromRGB(210, 60, 60), function()
        cleanupOldUI()
        UI_STATE.isRunning = false
        showNotification("脚本已关闭", "秋容脚本已退出运行", 3)
    end)
    local leftWidth = 180 * UI_STATE.scale
    local leftScroll = Instance.new("ScrollingFrame")
    leftScroll.Name = "LeftScrollFrame"
    leftScroll.Size = UDim2.new(0, leftWidth, 1, - (topBar.Position.Y.Offset + topBar.Size.Y.Offset + 10 * UI_STATE.scale))
    leftScroll.Position = UDim2.new(0, 10 * UI_STATE.scale, 0, topBar.Position.Y.Offset + topBar.Size.Y.Offset + 10 * UI_STATE.scale)
    leftScroll.BackgroundColor3 = Color3.fromRGB(40, 40, 60)
    leftScroll.BackgroundTransparency = 0.8
    leftScroll.Parent = mainPanel
    leftScroll.ClipsDescendants = true
    createCorner(leftScroll, 12)
    local leftContainer = Instance.new("Frame")
    leftContainer.Name = "LeftMenuContainer"
    leftContainer.Size = UDim2.new(1, 0, 0, 0)
    leftContainer.BackgroundTransparency = 1
    leftContainer.Parent = leftScroll
    local leftLayout = Instance.new("UIListLayout")
    leftLayout.Parent = leftContainer
    leftLayout.FillDirection = Enum.FillDirection.Vertical
    leftLayout.Padding = UDim.new(0, 8 * UI_STATE.scale)
    leftLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    leftLayout.SortOrder = Enum.SortOrder.LayoutOrder
    local leftPadding = Instance.new("UIPadding")
    leftPadding.PaddingTop = UDim.new(0, 8 * UI_STATE.scale)
    leftPadding.PaddingBottom = UDim.new(0, 8 * UI_STATE.scale)
    leftPadding.Parent = leftContainer
    local function updateLeftScroll()
        local contentHeight = leftLayout.AbsoluteContentSize.Y
        local visibleHeight = leftScroll.AbsoluteSize.Y
        leftScroll.CanvasSize = UDim2.new(0, 0, 0, contentHeight)
        leftScroll.ScrollBarThickness = (contentHeight > visibleHeight) and (6 * UI_STATE.scale) or 0
        local maxY = math.max(0, contentHeight - visibleHeight)
        leftScroll.CanvasPosition = Vector2.new(0, math.clamp(leftScroll.CanvasPosition.Y, 0, maxY))
    end
    updateLeftScroll()
    leftLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(updateLeftScroll)
    leftScroll:GetPropertyChangedSignal("CanvasPosition"):Connect(updateLeftScroll)
    local rightPanel = Instance.new("Frame")
    rightPanel.Name = "RightPanel"
    rightPanel.Size = UDim2.new(1, - (leftWidth + 20 * UI_STATE.scale), 1, - (topBar.Position.Y.Offset + topBar.Size.Y.Offset + 10 * UI_STATE.scale))
    rightPanel.Position = UDim2.new(0, leftWidth + 20 * UI_STATE.scale, 0, topBar.Position.Y.Offset + topBar.Size.Y.Offset + 10 * UI_STATE.scale)
    rightPanel.BackgroundColor3 = Color3.fromRGB(50, 50, 70)
    rightPanel.BackgroundTransparency = 0.8
    rightPanel.Parent = mainPanel
    createCorner(rightPanel, 12)
-- 1. 提取“切换面板可见性”的通用逻辑
local function setActivePanel(targetKey)
    -- 1. 切换面板可见性
    for key, panel in pairs(UI_STATE.menuPanels) do
        if panel and panel:IsDescendantOf(game) then
            panel.Visible = (key == targetKey)
        end
    end
    -- 2. 强制同步更新所有菜单按钮状态（与面板切换严格同步）
    if leftContainer and leftContainer:IsDescendantOf(game) then
        for _, child in ipairs(leftContainer:GetChildren()) do
            if child:IsA("TextButton") and child.Name:match("MenuButton_") then
                local btnMenuKey = child.Name:gsub("MenuButton_", "")
                local targetKeyClean = targetKey:gsub("%p", "")
                child.BackgroundColor3 = btnMenuKey == targetKeyClean and 
                    Color3.fromRGB(80, 80, 130) or CONFIG.UI_COLORS.primary
                -- 强制刷新
                child.BackgroundColor3 = child.BackgroundColor3
            end
        end
    end
    -- 3. 更新当前活跃菜单标识
    UI_STATE.activeMenu = targetKey
end
-- 2. 菜单配置：左侧显示文本 + 面板标识 + 布局顺序 + 面板标题
local menuList = {
    {menuText = "玩家传送", menuKey = "传送玩家", layoutOrder = 1},
    {menuText = "坐标管理", menuKey = "保存位置", layoutOrder = 2},
    {menuText = "通用功能", menuKey = "玩家通用", layoutOrder = 3},
    {menuText = "注入器下载", menuKey = "注入器下载", layoutOrder = 4},
    {menuText = "森林99夜", menuKey = "森林中的99夜", layoutOrder = 5},
    {menuText = "军事大亨", menuKey = "军事大亨", layoutOrder = 6},
    {menuText = "死铁轨", menuKey = "死铁轨", layoutOrder = 7},
    {menuText = "鱼类玩法", menuKey = "鱼", layoutOrder = 8},
    {menuText = "最强战场", menuKey = "最强的战场", layoutOrder = 9},
    {menuText = "花园种植", menuKey = "花园种植", layoutOrder = 10},
    {menuText = "伐木大亨2", menuKey = "伐木大亨2", layoutOrder = 11},
    {menuText = "墨水游戏", menuKey = "墨水游戏", layoutOrder = 12},
    {menuText = "被遗弃", menuKey = "被遗弃", layoutOrder = 13},
    {menuText = "Blox Fruits", menuKey = "Blox Fruits", layoutOrder = 14},
    {menuText = "Doors", menuKey = "Doors", layoutOrder = 15},
    {menuText = "保护总统", menuKey = "保护总统", layoutOrder = 16},
    {menuText = "房屋防护", menuKey = "保护房屋免受怪物侵害", layoutOrder = 17},
    {menuText = "WARMIX", menuKey = "WARMIX", layoutOrder = 18},
    {menuText = "chain(内容已被删除)", menuKey = "chain(内容已被删除)", layoutOrder = 19},
    {menuText = "菜单20", menuKey = "菜单20", layoutOrder = 20},
    {menuText = "菜单21", menuKey = "菜单21", layoutOrder = 21},
    {menuText = "菜单22", menuKey = "菜单22", layoutOrder = 22},
    {menuText = "菜单23", menuKey = "菜单23", layoutOrder = 23},
    {menuText = "菜单24", menuKey = "菜单24", layoutOrder = 24}
}
-- 3. 批量创建菜单（按钮 + 面板）
local menuConfig = {
    ["传送玩家"] = {contentFunc = create2Content, panelTitle = "玩家传送"},
    ["保存位置"] = {contentFunc = create1Content, panelTitle = "坐标保存"},
    ["玩家通用"] = {contentFunc = create4Content, panelTitle = "通用功能"},
    ["注入器下载"] = {contentFunc = create3Content, panelTitle = "注入器下载网址"},
    ["森林中的99夜"] = {contentFunc = create5Content, panelTitle = "服务器森林99夜"},
    ["军事大亨"] = {contentFunc = create6Content, panelTitle = "服务器军事大亨"},
    ["死铁轨"] = {contentFunc = create7Content, panelTitle = "服务器死铁轨"},
    ["鱼"] = {contentFunc = create8Content, panelTitle = "服务器鱼"},
    ["最强的战场"] = {contentFunc = create9Content, panelTitle = "服务器最强战场"},
    ["花园种植"] = {contentFunc = create10Content, panelTitle = "服务器花园种植"},
    ["伐木大亨2"] = {contentFunc = create11Content, panelTitle = "服务器伐木大亨2"},
    ["墨水游戏"] = {contentFunc = create12Content, panelTitle = "服务器墨水游戏"},
    ["被遗弃"] = {contentFunc = create13Content, panelTitle = "服务器被遗弃"},
    ["Blox Fruits"] = {contentFunc = create14Content, panelTitle = "服务器Blox Fruits"},
    ["Doors"] = {contentFunc = create15Content, panelTitle = "服务器Doors"},
    ["保护总统"] = {contentFunc = create16Content, panelTitle = "服务器保护总统"},
    ["保护房屋免受怪物侵害"] = {contentFunc = create17Content, panelTitle = "服务器房屋防护"},
    ["WARMIX"] = {contentFunc = create18Content, panelTitle = "服务器WARMIX[PVP FPS 武器战斗射击枪]"},
    ["chain(内容已被删除)"] = {contentFunc = create19Content, panelTitle = "服务器chain"},
    ["菜单20"] = {contentFunc = create20Content, panelTitle = "看你妈呢还没弄未命名菜单20"},
    ["菜单21"] = {contentFunc = create21Content, panelTitle = "看你妈呢还没弄未命名菜单21"},
    ["菜单22"] = {contentFunc = create22Content, panelTitle = "看你妈呢还没弄未命名菜单22"},
    ["菜单23"] = {contentFunc = create23Content, panelTitle = "看你妈呢还没弄未命名菜单23"},
    ["菜单24"] = {contentFunc = create24Content, panelTitle = "看你妈呢还没弄未命名菜单24"}
}
-- 创建菜单按钮和面板
for _, menu in ipairs(menuList) do
    local config = menuConfig[menu.menuKey] or {}
    -- 创建面板并缓存
    UI_STATE.menuPanels[menu.menuKey] = createMenuContentPanel(rightPanel, menu.menuKey, config.panelTitle)
    -- 创建菜单项并绑定切换事件
    createMenuItem(leftContainer, menu.menuText, menu.layoutOrder, function()
        setActivePanel(menu.menuKey)
        showNotification("菜单切换成功", "当前菜单：" .. menu.menuText)
    end)
end
updateLeftScroll()
    -- 立即激活初始菜单（无延迟）
    local initActiveKey = UI_STATE.activeMenu
    local initPanel = UI_STATE.menuPanels[initActiveKey]
    if initPanel and initPanel:IsDescendantOf(game) then
        initPanel.Visible = true
        -- 同步激活对应菜单按钮
        setActivePanel(initActiveKey)
    end
    -- 绑定拖动事件
    bindDragToElement(topBar, mainPanel)
    bindDragToElement(mainPanel, mainPanel)
    bindDragToElement(rightPanel, mainPanel)
    UserInputService.InputChanged:Connect(function(input)
        if UI_STATE.isDragging and not UI_STATE.isScrolling and 
           (input.UserInputType == Enum.UserInputType.MouseMovement or 
            input.UserInputType == Enum.UserInputType.Touch) and
           mainPanel:IsDescendantOf(game) then
            local delta = input.Position - UI_STATE.dragStart
            mainPanel.Position = UDim2.new(
                UI_STATE.panelStartPos.X.Scale, UI_STATE.panelStartPos.X.Offset + delta.X,
                UI_STATE.panelStartPos.Y.Scale, UI_STATE.panelStartPos.Y.Offset + delta.Y
            )
        end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if (input.UserInputType == Enum.UserInputType.MouseButton1 or 
            input.UserInputType == Enum.UserInputType.Touch) and UI_STATE.isDragging then
            UI_STATE.isDragging = false
        end
    end)
    createFloatingButton()
    UI_STATE.isScaling = false
    print("主UI创建成功")
end
local function initScript()
    local localPlayer = Players.LocalPlayer
    if not localPlayer then
        localPlayer = Players:GetPropertyChangedSignal("LocalPlayer"):Wait()
        if not localPlayer then
            warn("无法获取本地玩家")
            return
        end
    end
    initCSVPath()
    -- 初始化角色监听
    -- 断开已有连接（防止重复监听）
    if UI_STATE.characterAddedConn then
        UI_STATE.characterAddedConn:Disconnect()
    end
    if UI_STATE.characterRemovingConn then
        UI_STATE.characterRemovingConn:Disconnect()
    end
    -- 监听角色添加
    UI_STATE.characterAddedConn = localPlayer.CharacterAdded:Connect(onCharacterAdded)
    -- 监听角色移除
    UI_STATE.characterRemovingConn = localPlayer.CharacterRemoving:Connect(onCharacterRemoving)
    -- 如果已有角色，立即初始化
    if localPlayer.Character then
        task.spawn(onCharacterAdded, localPlayer.Character)
    end
    UI_STATE.savedCoordinates = readCSVFile()
    local success, err = pcall(createMainUI)
    if not success then
        local fullError = debug.traceback(err)
        warn("创建UI失败：\n" .. fullError)
        showNotification("UI加载失败", "错误：\n" .. fullError:sub(1, 100) .. "...", 10)
        local playerGui = localPlayer:FindFirstChild("PlayerGui")
        if playerGui then
            local errorGui = Instance.new("ScreenGui")
            errorGui.Name = "UI加载错误提示"
            errorGui.Parent = playerGui
            -- 忍者注入器保护错误GUI
            pcall(function()
                if syn and syn.protect_gui then
                    syn.protect_gui(errorGui)
                end
            end)
            createLabel(errorGui, {
                name = "ErrorLabel",
                size = UDim2.new(1, 0, 1, 0),
                text = "UI加载失败：\n" .. fullError,
                color = Color3.new(1, 0, 0),
                textSize = 14,
                textWrapped = true,
                xAlign = Enum.TextXAlignment.Left
            })
        end
        return
    end
    showNotification("UI2.0加载成功", "尊贵的用户欢迎使用秋容脚本")
    print("初始化完成")
end
local success, errorMsg = pcall(initScript)
if not success then
    local fullError = debug.traceback(errorMsg)
    warn("脚本启动失败：\n" .. fullError)
    pcall(function()
        local player = Players.LocalPlayer
        if player and player:FindFirstChild("PlayerGui") then
            local gui = Instance.new("ScreenGui")
            gui.Parent = player.PlayerGui
            -- 忍者注入器保护错误GUI
            pcall(function()
                if syn and syn.protect_gui then
                    syn.protect_gui(gui)
                end
            end)
            createLabel(gui, {
                name = "ErrorLabel",
                size = UDim2.new(1, 0, 1, 0),
                text = "脚本启动失败：\n" .. fullError,
                color = Color3.new(1, 0, 0),
                textSize = 14,
                textWrapped = true,
                xAlign = Enum.TextXAlignment.Left
            })
        end
    end)
end
--[[local function create16Content(container)--编号菜单你只需要写这个数字
    if not container or not container:IsDescendantOf(game) then return function() end end
    
    -- 按钮数据（含说明）
    local buttons = {
        {
            name = "",--名字
            url = "",--脚本代码
            desc = "功能说明：\n- "--功能说明
        }
    }
    -- 创建按钮
    for i, btn in ipairs(buttons) do
        createButton(container, {
            name = "16" .. i,--这里得填编号菜单你只需要写这个数字，然后其余的不变
            layoutOrder = i,
            size = UDim2.new(1, 0, 0, 45 * UI_STATE.scale),
            text = btn.name,
            bgColor = CONFIG.UI_COLORS.primary,
            hoverColor = Color3.fromRGB(70, 70, 120),
            onClick = function()
                createExecutionDialog(
                    "执行 " .. btn.name,
                    btn.desc,
                    function()
                        loadstring(game:HttpGet(btn.url, true))()
                        showNotification("功能加载中", "脚本执行中...")
                    end
                )
            end
        })
    end
    return function() end
end]]