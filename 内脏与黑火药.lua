local hookEnabled = false
local oldNamecall
local hookButton

local function enableHook()
    if oldNamecall then return end
    local mt = getrawmetatable(game)
    setreadonly(mt, false)

    oldNamecall = mt.__namecall

    mt.__namecall = newcclosure(function(self, ...)
        local args = {...}
        local method = getnamecallmethod()

        if hookEnabled and method == "FireServer" and tostring(self) == "RemoteEvent" then
            if args[1] == "HitZombie" then
                args[4] = true
                args[6] = "Head" 
            end
        end

        return oldNamecall(self, unpack(args))
    end)
end

local function disableHook()
    hookEnabled = false
end

local gui = Instance.new("ScreenGui")
gui.Name = "gui"
gui.Parent = game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui")

Button = Instance.new("TextButton")
Button.Size = UDim2.new(0, 150, 0, 40)
Button.Position = UDim2.new(0.7, 0, 0.2, 0)
Button.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
Button.TextColor3 = Color3.new(1, 1, 1)
Button.Font = Enum.Font.SourceSansBold
Button.TextSize = 18
Button.Text = "开启GB自瞄"
Button.Draggable = true
Button.Parent = gui

Button.MouseButton1Click:Connect(function()
    hookEnabled = not hookEnabled
    if hookEnabled then
        Button.Text = "开启GB自瞄"
        Button.BackgroundColor3 = Color3.fromRGB(0, 120, 255)
        enableHook()
    else
        hookButton.Text = "开启GB自瞄"
        hookButton.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
        disableHook()
    end
end)
