



local repo = "https://raw.githubusercontent.com/deividcomsono/Obsidian/main/"
local Library = loadstring(game:HttpGet(repo .. "Library.lua"))()
local ThemeManager = loadstring(game:HttpGet(repo .. "addons/ThemeManager.lua"))()
local SaveManager = loadstring(game:HttpGet(repo .. "addons/SaveManager.lua"))()

local Options = Library.Options
local Toggles = Library.Toggles

Library.ShowToggleFrameInKeybinds = true

local Window = Library:CreateWindow({
    Title = "NOL | 免费版",
    Footer = "加载器",
    Icon = "moon",
    NotifySide = "Right",
    ShowCustomCursor = true,
    AutoShow = true,
    Resizable = true,
    Center = true,
    TabPadding = 2,
    MenuFadeTime = 0.5,
    Position = UDim2.fromOffset(6, 6),
    Size = UDim2.fromOffset(620, 600),
    IconSize = UDim2.fromOffset(50, 50)
})

local ServerTab = Window:MakeTab({
    Name = "选择需要执行的服务器",
    Icon = "rbxassetid://4483345998"
})

ServerTab:AddButton({
    Name = "被遗弃",
    Callback = function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/.../被遗弃.lua"))()
    end
})

for Name, Link in next, Server do
    Tab:AddButton({
        Text = Name,
        Func = function()
            loadstring(game:HttpGet(Link))()  
            Library:Unload()  
        end,
        DoubleClick = false,
        Tooltip = '打开 NOL ' .. Name .. '脚本'
    })
end


local MenuGroup = Tabs["UI Settings"]:AddLeftGroupbox("调试功能")



local MenuGroup = Tabs["UI Settings"]:AddLeftGroupbox('菜单')
MenuGroup:AddButton("删除UI", function()
    Library:Unload()  
end)
