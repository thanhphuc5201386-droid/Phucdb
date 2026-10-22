
-- MINI TRANSLATOR | VI / EN
-- Dành cho môi trường Roblox có hỗ trợ Luau

local Players = game:GetService("Players")
local player = Players.LocalPlayer
if not player then return end

local playerGui = player:WaitForChild("PlayerGui")

local old = playerGui:FindFirstChild("MiniTranslator")
if old then old:Destroy() end

local dictionary = {
    ["Settings"] = "Cài đặt",
    ["Player"] = "Người chơi",
    ["Visual"] = "Hiển thị",
    ["Server"] = "Máy chủ",
    ["Auto"] = "Tự động",
    ["Misc"] = "Khác",
    ["Close"] = "Đóng",
    ["Open"] = "Mở",
    ["Enabled"] = "Đã bật",
    ["Disabled"] = "Đã tắt",
    ["Language"] = "Ngôn ngữ",
    ["Speed"] = "Tốc độ",
    ["Jump"] = "Nhảy",
    ["Teleport"] = "Dịch chuyển",
    ["Auto Block"] = "Tự động đỡ",
    ["Lock On"] = "Khóa mục tiêu",
    ["Select"] = "Chọn",
    ["Save"] = "Lưu",
    ["Cancel"] = "Hủy",
}

local reverse = {}
for en, vi in pairs(dictionary) do
    reverse[vi] = en
end

local originals = {}
local currentLanguage = "VI"

local gui = Instance.new("ScreenGui")
gui.Name = "MiniTranslator"
gui.ResetOnSpawn = false
gui.DisplayOrder = 999
gui.Parent = playerGui

local function corner(obj, radius)
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, radius)
    c.Parent = obj
end

local function makeButton(parent, text, size, position)
    local b = Instance.new("TextButton")
    b.Size = size
    b.Position = position
    b.BackgroundColor3 = Color3.fromRGB(45, 47, 60)
    b.TextColor3 = Color3.new(1, 1, 1)
    b.Text = text
    b.TextSize = 14
    b.Font = Enum.Font.GothamMedium
    b.Parent = parent
    corner(b, 8)
    return b
end

-- Nút nổi
local toggle = makeButton(
    gui, "文", UDim2.fromOffset(44, 44),
    UDim2.new(1, -58, 0.4, 0)
)
toggle.TextSize = 22
toggle.BackgroundColor3 = Color3.fromRGB(35, 105, 180)

-- Bảng chọn ngôn ngữ
local panel = Instance.new("Frame")
panel.Size = UDim2.fromOffset(210, 140)
panel.Position = UDim2.new(1, -225, 0.4, 50)
panel.BackgroundColor3 = Color3.fromRGB(25, 26, 35)
panel.Visible = false
panel.Parent = gui
corner(panel, 12)

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -16, 0, 35)
title.Position = UDim2.fromOffset(8, 3)
title.BackgroundTransparency = 1
title.Text = "CHỌN NGÔN NGỮ"
title.TextColor3 = Color3.new(1, 1, 1)
title.TextSize = 14
title.Font = Enum.Font.GothamBold
title.Parent = panel

local vi = makeButton(
    panel, "🇻🇳  Tiếng Việt",
    UDim2.new(1, -20, 0, 35),
    UDim2.fromOffset(10, 43)
)

local en = makeButton(
    panel, "🇺🇸  English",
    UDim2.new(1, -20, 0, 35),
    UDim2.fromOffset(10, 85)
)

-- Dịch giao diện mà script có quyền truy cập
local function translate(obj)
    if not (
        obj:IsA("TextLabel")
        or obj:IsA("TextButton")
        or obj:IsA("TextBox")
    ) then
        return
    end

    if obj:IsDescendantOf(gui) then
        return
    end

    if originals[obj] == nil then
        originals[obj] = obj.Text
    end

    local original = originals[obj]
    if currentLanguage == "VI" then
        obj.Text = dictionary[original] or original
    else
        obj.Text = reverse[original] or original
    end
end

local function setLanguage(lang)
    currentLanguage = lang

    for _, obj in ipairs(playerGui:GetDescendants()) do
        translate(obj)
    end

    vi.BackgroundColor3 =
        lang == "VI"
        and Color3.fromRGB(25, 125, 85)
        or Color3.fromRGB(45, 47, 60)

    en.BackgroundColor3 =
        lang == "EN"
        and Color3.fromRGB(25, 125, 85)
        or Color3.fromRGB(45, 47, 60)
end

toggle.Activated:Connect(function()
    panel.Visible = not panel.Visible
end)

vi.Activated:Connect(function()
    setLanguage("VI")
end)

en.Activated:Connect(function()
    setLanguage("EN")
end)

playerGui.DescendantAdded:Connect(function(obj)
    task.defer(function()
        if obj.Parent then
            translate(obj)
        end
    end)
end)

-- Kéo nút bằng chuột hoặc cảm ứng
local UIS = game:GetService("UserInputService")
local dragging, startInput, startPos

toggle.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch
        or input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        startInput = input.Position
        startPos = toggle.Position
    end
end)

UIS.InputChanged:Connect(function(input)
    if not dragging then return end

    if input.UserInputType == Enum.UserInputType.Touch
        or input.UserInputType == Enum.UserInputType.MouseMovement then
        local delta = input.Position - startInput

        toggle.Position = UDim2.new(
            startPos.X.Scale, startPos.X.Offset + delta.X,
            startPos.Y.Scale, startPos.Y.Offset + delta.Y
        )

        panel.Position = UDim2.new(
            toggle.Position.X.Scale,
            toggle.Position.X.Offset - 152,
            toggle.Position.Y.Scale,
            toggle.Position.Y.Offset + 48
        )
    end
end)

UIS.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch
        or input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = false
    end
end)

setLanguage("VI")
