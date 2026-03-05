if _G.XION_Script_Loaded then
    _G.XION_Execution_Count = (_G.XION_Execution_Count or 0) + 1
    return
end

_G.XION_Script_Loaded = true
_G.XION_Execution_Count = 1
game:GetService("StarterGui"):SetCore("SendNotification", {
  Title = "因为你检测到摧毁师",
  Text = "正在启动XIAOXI摧毁师",
  Icon = "rbxassetid://123691280552142",
  Duration = 1,
  Callback = bindable,
  Button1 = "谢谢使用",
  Button2 = "😘",
})
wait(1.5)
game:GetService("StarterGui"):SetCore("SendNotification", {
  Title = "可能会卡一下",
  Text = "卡密进群获取 ",
  Icon = "rbxassetid://123691280552142",
  Duration = 1,
  Callback = bindable,
  Button1 = "qq群：705378396",
  Button2 = "作者qq：3574769415",
})
local WindUI = loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"))()
local Window = WindUI:CreateWindow({
    Title = "XIAOXI脚本",
    Icon = "rbxassetid://123691280552142",
    Author = "by小西制作",
    AuthorImage = 90840643379863,
    Folder = "CloudHub",
    Size = UDim2.fromOffset(560, 360),
    KeySystem = {
        Key = { "我爱大司马", "小西nb", "宇星辰", "阵雨眉目" }, 
        Note = "请输入卡密",
        SaveKey = false,
    },
    Transparent = true,
    Background = "video:https://raw.githubusercontent.com/xiaoxi9008/chesksks/refs/heads/main/c4b2e0536c1c3cb8d947baae97dcf796.mp4",
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
        Title = "XIAOXI",
        Icon = "rbxassetid://123691280552142",
        CornerRadius = UDim.new(0, 13),
        StrokeThickness = 4,
        Color = ColorSequence.new({ColorSequenceKeypoint.new(0, Color3.fromRGB(186, 19, 19)),ColorSequenceKeypoint.new(1, Color3.fromRGB(8, 60, 129))}),
        Draggable = true
    }
)

local v3 = v2:Tab({
    Title = "静默功能",
    Icon = "crosshair",
    Locked = false
})
v3:Button({
    Title = "防踢",
    Callback = function()
        local v4 = next
        local v5, v6 = getgc(true)
        while true do
            local v7
            v6, v7 = v4(v5, v6)
            if v6 == nil then
                break
            end
            if typeof(v7) == "function" and (getfenv(v7).script and (getfenv(v7).script.Parent == nil and not isourclosure(v7))) then
                local v8 = debug.info(v7, "s")
                if v8 ~= "[C]" and not (v8:find("Network") or v8:find("PlayerGui.Client")) then
                    hookfunction(v7, function()
                        return coroutine.yield()
                    end)
                end
            end
        end
    end
})
local vu9 = game:GetService("Workspace")
local vu10 = game:GetService("Players")
local v11 = game:GetService("RunService")
local vu12 = vu10.LocalPlayer
local vu13 = vu9.CurrentCamera
local vu14 = false
local vu15 = "Head"
local vu16 = 250
local vu17 = false
local vu18 = 100
local vu19 = nil
local vu20 = nil
local vu21 = 0
local vu22 = 0.1
local vu23 = Drawing.new("Circle")
vu23.Visible = false
vu23.Radius = vu16
vu23.Color = Color3.fromRGB(255, 255, 255)
vu23.Thickness = 1
vu23.Transparency = 1
vu23.Filled = false
vu23.Position = Vector2.new(vu13.ViewportSize.X / 2, vu13.ViewportSize.Y / 2)
local v24 = vu13
vu13.GetPropertyChangedSignal(v24, "ViewportSize"):Connect(function()
    vu23.Position = Vector2.new(vu13.ViewportSize.X / 2, vu13.ViewportSize.Y / 2)
end)
local function vu42()
    if vu14 then
        local v25 = math.huge
        local v26 = vu13.CFrame
        local v27 = v26.Position
        local v28 = v26.LookVector
        local v29 = vu10
        local v30, v31, v32 = ipairs(v29:GetPlayers())
        local v33 = nil
        while true do
            local v34
            v32, v34 = v30(v31, v32)
            if v32 == nil then
                break
            end
            if v34 ~= vu12 then
                local v35 = v34.Character
                if v35 then
                    local v36
                    if vu15 ~= "\233\154\143\230\156\186" then
                        v36 = v35:FindFirstChild(vu15)
                    else
                        local v37 = {
                            "Head",
                            "HumanoidRootPart",
                            "Left Arm",
                            "Right Arm",
                            "Left Leg",
                            "Right Leg"
                        }
                        v36 = v35:FindFirstChild(v37[math.random(1, # v37)])
                    end
                    local v38 = v35:FindFirstChildOfClass("Humanoid")
                    if v36 and (v38 and (v38.Health > 0 and not v35:FindFirstChild("ForceField"))) then
                        local v39 = v36.Position - v27
                        local v40 = v39.Magnitude
                        if math.deg(math.acos(v28:Dot(v39.Unit))) <= vu16 / 10 and v40 < v25 then
                            if vu17 then
                                local v41 = RaycastParams.new()
                                v41.FilterDescendantsInstances = {
                                    vu12.Character,
                                    v35
                                }
                                v41.FilterType = Enum.RaycastFilterType.Blacklist
                                if not vu9:Raycast(v27, v39, v41) then
                                    v33 = v36
                                    v25 = v40
                                end
                            else
                                v33 = v36
                                v25 = v40
                            end
                        end
                    end
                end
            end
        end
        vu20 = v33
    else
        vu20 = nil
    end
end
v11.RenderStepped:Connect(function()
    if vu22 < tick() - vu21 then
        vu21 = tick()
        vu42()
    end
end)
local function vu43()
    return vu20
end
vu19 = hookmetamethod(game, "__namecall", function(p44, ...)
    local v45 = getnamecallmethod()
    if checkcaller() or (p44 ~= vu9 or v45 ~= "Raycast" and v45 ~= "FindPartOnRay") then
        return vu19(p44, ...)
    end
    local v46 = vu43()
    if v46 and math.random(1, 100) <= vu18 then
        local v47 = {
            ...
        }
        local v48 = nil
        local v49 = nil
        if v45 == "Raycast" then
            v48 = v47[1]
            v49 = v47[2]
        else
            local v50 = v47[1]
            if typeof(v50) == "Ray" then
                v48 = v50.Origin
                v49 = v50.Direction
            end
        end
        if v48 and v49 then
            return {
                Instance = v46,
                Position = v46.Position,
                Normal = (v46.Position - v48).Unit,
                Material = Enum.Material.Plastic
            }
        end
    end
    return vu19(p44, ...)
end)
local vu51 = false
local vu52 = Drawing.new("Line")
vu52.Visible = false
vu52.Thickness = 1
vu52.Transparency = 1
vu52.Color = Color3.fromRGB(255, 255, 255)
local function vu55(p53)
    local v54 = p53:FindFirstChild("PlayerStates")
    if v54 and v54:FindFirstChild("Team") then
        return v54.Team.Value
    else
        return nil
    end
end
local function vu59(p56)
    local v57 = vu55(vu12)
    local v58 = vu55(p56)
    return v57 ~= nil and v57 == v58
end
local function vu65(p60)
    local v61, v62 = vu13:WorldToViewportPoint(p60)
    if not v62 then
        return false
    end
    local v63 = v61.X - vu23.Position.X
    local v64 = v61.Y - vu23.Position.Y
    return v63 * v63 + v64 * v64 <= vu16 * vu16
end
v11.RenderStepped:Connect(function()
    if vu51 and vu14 then
        local v66 = vu20
        if v66 then
            local v67 = v66.Parent
            if v67 then
                local v68 = vu10:GetPlayerFromCharacter(v67)
                if v68 then
                    if vu59(v68) then
                        vu52.Visible = false
                        return
                    else
                        local v69 = v67:FindFirstChildOfClass("Humanoid")
                        if v69 and v69.Health > 0 then
                            if vu17 then
                                local v70 = RaycastParams.new()
                                v70.FilterDescendantsInstances = {
                                    vu12.Character,
                                    v67
                                }
                                v70.FilterType = Enum.RaycastFilterType.Blacklist
                                if vu9:Raycast(vu13.CFrame.Position, v66.Position - vu13.CFrame.Position, v70) then
                                    vu52.Visible = false
                                    return
                                end
                            end
                            if vu15 == "\233\154\143\230\156\186" then
                                v66 = v67:FindFirstChild("HumanoidRootPart") or v66
                            end
                            local v71 = v66.Position
                            if vu65(v71) then
                                local v72, v73 = vu13:WorldToViewportPoint(v71)
                                if v73 then
                                    vu52.From = Vector2.new(vu23.Position.X, vu23.Position.Y)
                                    vu52.To = Vector2.new(v72.X, v72.Y)
                                    vu52.Visible = true
                                else
                                    vu52.Visible = false
                                end
                            else
                                vu52.Visible = false
                                return
                            end
                        else
                            vu52.Visible = false
                            return
                        end
                    end
                else
                    vu52.Visible = false
                    return
                end
            else
                vu52.Visible = false
                return
            end
        else
            vu52.Visible = false
            return
        end
    else
        vu52.Visible = false
        return
    end
end)
v3:Toggle({
    Title = "打开静默",
    Value = false,
    Callback = function(p74)
        vu14 = p74
        vu23.Visible = p74
    end
})
v3:Slider({
    Title = "fov范围",
    Value = {
        Min = 100,
        Max = 300,
        Default = 250
    },
    Callback = function(p75)
        vu16 = tonumber(p75)
        vu23.Radius = vu16
    end
})
v3:Dropdown({
    Title = "默认部位",
    Multi = false,
    AllowNone = false,
    Value = "Head",
    Values = {
        "头部",
        "78",
        "左手臂",
        "右手臂",
        "左腿",
        "右退",
        "\233\154\143\230\156\186"
    },
    Callback = function(p76)
        vu15 = p76
    end
})
v3:Toggle({
    Title = "墙壁检测",
    Value = false,
    Callback = function(p77)
        vu17 = p77
    end
})
v3:Slider({
    Title = "秒杀概率",
    Value = {
        Min = 1,
        Max = 100,
        Default = 100
    },
    Callback = function(p78)
        vu18 = tonumber(p78)
    end
})
v3:Toggle({
    Title = "静默红线瞄到人自动开枪",
    Value = false,
    Callback = function(p79)
        vu51 = p79
        if not p79 then
            vu52.Visible = false
        end
    end
})
local v80 = v2:Tab({
    Title = "透视功能",
    Icon = "eye",
    Locked = false
})
local vu81 = game.Players.LocalPlayer
local vu82 = game:GetService("Players")
local vu83 = game:GetService("RunService")
local vu84 = false
local vu85 = false
local vu86 = false
local vu87 = {}
local vu88 = {}
local vu89 = {}
local vu90 = nil
local function vu93(p91)
    local v92 = p91:FindFirstChild("PlayerStates")
    if v92 and v92:FindFirstChild("Team") then
        return v92.Team.Value
    else
        return nil
    end
end
local function vu97(p94)
    local v95 = vu93(vu81)
    local v96 = vu93(p94)
    return v95 ~= nil and v95 == v96
end
local function vu103(p98)
    if p98.Character then
        local v99 = p98.Character:FindFirstChild("PlayerESP")
        if v99 then
            v99.FillColor = vu97(p98) and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 0, 0)
            v99.OutlineColor = v99.FillColor
        end
        local v100 = p98.Character:FindFirstChild("HumanoidRootPart")
        if v100 then
            local v101 = v100:FindFirstChild("HpESP")
            if v101 and v101:FindFirstChildOfClass("TextLabel") then
                v101:FindFirstChildOfClass("TextLabel").TextColor3 = vu97(p98) and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 0, 0)
            end
            local v102 = v100:FindFirstChild("DistanceESP")
            if v102 and v102:FindFirstChildOfClass("TextLabel") then
                v102:FindFirstChildOfClass("TextLabel").TextColor3 = vu97(p98) and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 0, 0)
            end
        end
    end
end
local function vu109(pu104)
    if pu104 ~= vu81 then
        local function vu107(p105)
            if p105:FindFirstChild("PlayerESP") then
                return
            elseif p105:FindFirstChild("HumanoidRootPart") then
                local v106 = Instance.new("Highlight")
                v106.Name = "PlayerESP"
                v106.Adornee = p105
                v106.FillColor = vu97(pu104) and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 0, 0)
                v106.OutlineColor = v106.FillColor
                v106.FillTransparency = 0.6
                v106.OutlineTransparency = 0
                v106.Parent = p105
            end
        end
        if pu104.Character then
            vu107(pu104.Character)
        end
        vu87[pu104] = pu104.CharacterAdded:Connect(function(p108)
            repeat
                task.wait()
            until p108:FindFirstChild("HumanoidRootPart")
            vu107(p108)
            vu103(pu104)
        end)
    end
end
local function vu116()
    local v110 = vu82
    local v111, v112, v113 = ipairs(v110:GetPlayers())
    while true do
        local v114
        v113, v114 = v111(v112, v113)
        if v113 == nil then
            break
        end
        if v114.Character then
            local v115 = v114.Character:FindFirstChild("PlayerESP")
            if v115 then
                v115:Destroy()
            end
        end
    end
end
local function vu123()
    local v117 = vu82
    local v118, v119, v120 = ipairs(v117:GetPlayers())
    while true do
        local v121
        v120, v121 = v118(v119, v120)
        if v120 == nil then
            break
        end
        vu109(v121)
    end
    vu87.PlayerAdded = vu82.PlayerAdded:Connect(function(p122)
        vu109(p122)
    end)
end
local function vu128()
    vu116()
    local v124, v125, v126 = pairs(vu87)
    while true do
        local vu127
        v126, vu127 = v124(v125, v126)
        if v126 == nil then
            break
        end
        if vu127 then
            pcall(function()
                vu127:Disconnect()
            end)
        end
    end
    vu87 = {}
end
v80:Toggle({
    Title = "开启人物ESP",
    Value = false,
    Callback = function(p129)
        vu84 = p129
        if p129 then
            vu123()
        else
            vu128()
        end
    end
})
local function vu138(pu130)
    if pu130 ~= vu81 then
        local function vu136(p131)
            local vu132 = p131:FindFirstChildOfClass("Humanoid")
            local v133 = p131:FindFirstChild("HumanoidRootPart")
            if vu132 and v133 then
                if not v133:FindFirstChild(" ") then
                    local v134 = Instance.new("BillboardGui")
                    v134.Name = "HpESP"
                    v134.AlwaysOnTop = true
                    v134.Size = UDim2.new(0, 200, 0, 25)
                    v134.StudsOffset = Vector3.new(0, - 15, 0)
                    v134.Parent = v133
                    local vu135 = Instance.new("TextLabel")
                    vu135.BackgroundTransparency = 1
                    vu135.Size = UDim2.new(1, 0, 1, 0)
                    vu135.TextColor3 = vu97(pu130) and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 0, 0)
                    vu135.TextSize = 13
                    vu135.Font = Enum.Font.SourceSansBold
                    vu135.Text = "HP:" .. math.floor(vu132.Health)
                    vu135.Parent = v134
                    vu132.HealthChanged:Connect(function()
                        if vu135 then
                            vu135.Text = "HP:" .. math.floor(vu132.Health)
                        end
                    end)
                end
            else
                return
            end
        end
        if pu130.Character then
            vu136(pu130.Character)
        end
        vu88[pu130] = pu130.CharacterAdded:Connect(function(p137)
            repeat
                task.wait()
            until p137:FindFirstChild("HumanoidRootPart") and p137:FindFirstChildOfClass("Humanoid")
            vu136(p137)
            vu103(pu130)
        end)
    end
end
local function vu146()
    local v139 = vu82
    local v140, v141, v142 = ipairs(v139:GetPlayers())
    while true do
        local v143
        v142, v143 = v140(v141, v142)
        if v142 == nil then
            break
        end
        if v143 ~= vu81 and v143.Character then
            local v144 = v143.Character:FindFirstChild("HumanoidRootPart")
            if v144 then
                local v145 = v144:FindFirstChild("HpESP")
                if v145 then
                    v145:Destroy()
                end
            end
        end
    end
end
local function vu153()
    local v147 = vu82
    local v148, v149, v150 = ipairs(v147:GetPlayers())
    while true do
        local v151
        v150, v151 = v148(v149, v150)
        if v150 == nil then
            break
        end
        vu138(v151)
    end
    vu88.PlayerAdded = vu82.PlayerAdded:Connect(function(p152)
        vu138(p152)
    end)
end
local function vu158()
    vu146()
    local v154, v155, v156 = pairs(vu88)
    while true do
        local vu157
        v156, vu157 = v154(v155, v156)
        if v156 == nil then
            break
        end
        if vu157 then
            pcall(function()
                vu157:Disconnect()
            end)
        end
    end
    vu88 = {}
end
v80:Toggle({
    Title = "显示血量ESP",
    Value = false,
    Callback = function(p159)
        vu85 = p159
        if p159 then
            vu153()
        else
            vu158()
        end
    end
})
local function vu164(p160)
    if p160.Character then
        local v161 = p160.Character:FindFirstChild("Head")
        if v161 then
            if not v161:FindFirstChild("DistanceESP") then
                local v162 = Instance.new("BillboardGui")
                v162.Name = "DistanceESP"
                v162.AlwaysOnTop = true
                v162.Size = UDim2.new(0, 200, 0, 25)
                v162.StudsOffset = Vector3.new(0, 15, 0)
                v162.Parent = v161
                local v163 = Instance.new("TextLabel")
                v163.BackgroundTransparency = 1
                v163.Size = UDim2.new(1, 0, 1, 0)
                v163.TextColor3 = vu97(p160) and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 0, 0)
                v163.TextSize = 13
                v163.Font = Enum.Font.SourceSansBold
                v163.Parent = v162
                vu89[p160] = v163
            end
        else
            return
        end
    else
        return
    end
end
local function vu166(p165)
    if vu89[p165] then
        if vu89[p165].Parent then
            vu89[p165].Parent:Destroy()
        end
        vu89[p165] = nil
    end
end
local function vu174()
    local v167 = vu81.Character
    if v167 and v167:FindFirstChild("HumanoidRootPart") then
        local v168 = vu82
        local v169, v170, v171 = ipairs(v168:GetPlayers())
        while true do
            local v172
            v171, v172 = v169(v170, v171)
            if v171 == nil then
                break
            end
            if v172 ~= vu81 and v172.Character and v172.Character:FindFirstChild("HumanoidRootPart") then
                vu164(v172)
                local v173 = (v167.HumanoidRootPart.Position - v172.Character.HumanoidRootPart.Position).Magnitude
                if vu89[v172] then
                    vu89[v172].Text = "stun:" .. math.floor(v173)
                end
                vu103(v172)
            end
        end
    end
end
local function vu176()
    vu90 = vu83.RenderStepped:Connect(vu174)
    vu82.PlayerAdded:Connect(function(pu175)
        pu175.CharacterAdded:Connect(function()
            if vu86 then
                vu164(pu175)
            end
        end)
    end)
end
local function vu181()
    local v177, v178, v179 = pairs(vu89)
    while true do
        local v180
        v179, v180 = v177(v178, v179)
        if v179 == nil then
            break
        end
        vu166(v179)
    end
    if vu90 then
        vu90:Disconnect()
    end
    vu89 = {}
end
v80:Toggle({
    Title = "显示人物距离",
    Value = false,
    Callback = function(p182)
        vu86 = p182
        if p182 then
            vu176()
        else
            vu181()
        end
    end
})
local v183 = v2:Tab({
    Title = "设置",
    Icon = "设置",
    Locked = false
})
local v184, v185, v186 = pairs(vu1:GetThemes())
local v187 = {}
while true do
    local v188
    v186, v188 = v184(v185, v186)
    if v186 == nil then
        break
    end
    table.insert(v187, v186)
end
v183:Dropdown({
    Title = "自定义背景颜色",
    Multi = false,
    AllowNone = false,
    Value = nil,
    Values = v187,
    Callback = function(p189)
        vu1:SetTheme(p189)
    end
})