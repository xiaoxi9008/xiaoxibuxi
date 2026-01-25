

-- 基础服务定义
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")
local StarterGui = game:GetService("StarterGui")
local VirtualUser = game:GetService("VirtualUser")

local LocalPlayer = Players.LocalPlayer
local CurrentCamera = Workspace.CurrentCamera

-- 加载 UI 库
local UI_Library_URL = "https://raw.githubusercontent.com/114514lzkill/ui/refs/heads/main/ui.lua"
local Library = loadstring(game:HttpGet(UI_Library_URL))()

-- 创建窗口
local Window = Library:CreateWindow({
    ["Folder"] = "MyTestHub",
    ["Title"] = "小西v2脚本",
    ["Author"] = "wind ui",
    ["Icon"] = "rbxassetid://7734068321",
    HideSearchBar = false,
})

-------------------------------------------------------------------------
-- Tab: 公告 (Announcements)
-------------------------------------------------------------------------
local Tab_Notice = Window:Tab({
    ["Locked"] = false,
    ["Title"] = "公告",
    ["Icon"] = "rbxassetid://115466270141583",
})

Tab_Notice:Section({
    TextSize = 17,
    ["Title"] = "作者小西，QQ群3574769415",
    TextXAlignment = "Left",
})

-- Tab: 支持服务器 (小西脚本)
-------------------------------------------------------------------------
local Tab_Ohio = Window:Tab({
    ["Locked"] = false,
    ["Title"] = "支持的服务器",
    ["Icon"] = "rbxassetid://11949291636",
})

Tab_Ohio:Button({
    ["Title"] = "小西被遗弃",
    ["Desc"] = "内侧",
    ["Callback"] = function()
        loadstring(game:HttpGet("https://github.com/xiaoxi9008/Xiaoxi/blob/main/%E8%A2%AB%E9%81%97%E5%BC%83.lua"))()
    end
})

Tab_Ohio:Button({
    ["Title"] = "小西通用",
    ["Desc"] = "通用脚本",
    ["Callback"] = function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/xiaoxi9008/Xiaoxi/refs/heads/main/A.%E7%9A%AE%E8%84%9A%E6%9C%AC%E4%B8%BB%E8%84%9A%E6%9C%AC.lua"))()
    end
}) 

Tab_Ohio:Button({
    ["Title"] = "小西终极战场",
    ["Desc"] = "终极脚本",
    ["Callback"] = function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/xiaoxi9008/Xiaoxi/refs/heads/main/Kanl%E6%9C%80%E6%96%B0%E7%BB%88%E6%9E%81%E6%88%98%E5%9C%BA%E6%BA%90%E7%A0%81.lua"))()
    end
})

Tab_Ohio:Button({
    ["Title"] = "小西99夜",
    ["Desc"] = "99夜脚本",
    ["Callback"] = function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/xiaoxi9008/Xiaoxi/refs/heads/main/99%E5%A4%9C.lua"))()
    end
})

Tab_Ohio:Button({
    ["Title"] = "小西自然灾害",
    ["Desc"] = "自然灾害脚本",
    ["Callback"] = function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/xiaoxi9008/Xiaoxi/refs/heads/main/%E8%87%AA%E7%84%B6%E7%81%BE%E5%AE%B3.lua"))()
    end
})