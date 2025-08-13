game.Players.LocalPlayer:Kick("DM @domestic.abuse on discord, please.")

--[[
local library = loadstring(game:HttpGet('https://bauu.xyz/xsx.lua'))()
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local HttpService = game:GetService("HttpService")
local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

local moderatorIds = {
    2620089934, 85159204, 95419416, 96688361, 260036781,
    90807940, 9624991, 291643630, 71305063, 1095419,
    430335792, 9486667
}

local function checkForModerators()
    local detected = false
    for _, player in pairs(Players:GetPlayers()) do
        if table.find(moderatorIds, player.UserId) then
            detected = true
            library:Notify("Moderator detected: " .. player.Name .. " (ID: " .. player.UserId .. ")", 5, "warning")
        end
    end
    if detected then
        library:Notify("Moderator present in game! Use with caution!", 5, "error")
    end
    return detected
end

task.spawn(function()
    while true do
        checkForModerators()
        task.wait(3)
    end
end)

library:Init({
    version = "4.2",
    title = "V4.2",
    company = "RapeHook",
    keybind = Enum.KeyCode.Insert,
    BlurEffect = true
})

library:Watermark("RapeHook V4.2")
local FPSWatermark = library:Watermark("FPS")
RunService.RenderStepped:Connect(function(v) FPSWatermark:SetText("FPS: " .. math.round(1 / v)) end)
if _G.isRapehookLoaded then
    for _, connection in pairs(_G.RapehookConnections or {}) do connection:Disconnect() end
end
for i,v in pairs(1, 15) do
    library:Notify("RapeHook V4.2 loaded!", 10, "info")
end

_G.isRapehookLoaded = true
_G.RapehookConnections = {}

local ffaMode = false
local espEnabled = false
local skeletonEnabled = false
local chamsEnabled = false
local aimbotEnabled = false
local silentAimEnabled = false
local aimbotKey = Enum.UserInputType.MouseButton2
local aimbotSmoothing = 0.2
local fovSize = 100
local fovEnabled = false
local fovColor = Color3.fromRGB(0, 255, 0)
local hitChance = 100
local targetPart = "Head"
local flyBind = Enum.KeyCode.V
local viewmodelMaterial = Enum.Material.Plastic
local viewmodelColor = Color3.fromRGB(255, 255, 255)
local armColor = Color3.fromRGB(255, 255, 255)
local espColor = Color3.fromRGB(0, 255, 0)
local skeletonColor = Color3.fromRGB(0, 255, 0)
local chamsFillColor = Color3.fromRGB(0, 255, 0)
local chamsOutlineColor = Color3.fromRGB(0, 0, 0)
local chamsMaterial = Enum.Material.Plastic

local config = {}
local function updateConfig()
    config = {
        aimbotEnabled = aimbotEnabled,
        fovSize = fovSize,
        aimbotSmoothing = aimbotSmoothing,
        espEnabled = espEnabled,
        skeletonEnabled = skeletonEnabled,
        chamsEnabled = chamsEnabled,
        flyBind = flyBind.Name,
        hitChance = hitChance,
        fovEnabled = fovEnabled,
        silentAimEnabled = silentAimEnabled,
        viewmodelMaterial = tostring(viewmodelMaterial),
        viewmodelColor = { viewmodelColor.r * 255, viewmodelColor.g * 255, viewmodelColor.b * 255 },
        armColor = { armColor.r * 255, armColor.g * 255, armColor.b * 255 },
        espColor = { espColor.r * 255, espColor.g * 255, espColor.b * 255 },
        skeletonColor = { skeletonColor.r * 255, skeletonColor.g * 255, skeletonColor.b * 255 },
        chamsFillColor = { chamsFillColor.r * 255, chamsFillColor.g * 255, chamsFillColor.b * 255 },
        chamsOutlineColor = { chamsOutlineColor.r * 255, chamsOutlineColor.g * 255, chamsOutlineColor.b * 255 },
        chamsMaterial = tostring(chamsMaterial)
    }
end

local function isTeamMate(player) return not ffaMode and player.Team and player.Team == LocalPlayer.Team end

local function isVisible(targetPart)
    if not targetPart or not targetPart.Parent then return false end
    local rayOrigin = Camera.CFrame.Position
    local rayDirection = (targetPart.Position - rayOrigin).Unit * 999
    local raycastParams = RaycastParams.new()
    raycastParams.FilterDescendantsInstances = { LocalPlayer.Character }
    raycastParams.FilterType = Enum.RaycastFilterType.Blacklist
    local result = Workspace:Raycast(rayOrigin, rayDirection, raycastParams)
    return not result or result.Instance:IsDescendantOf(targetPart.Parent)
end

local function createBoxESP(player)
    if isTeamMate(player) then return end
    local espGroup = {
        BoxOuter = Drawing.new("Square"),
        BoxInner = Drawing.new("Square"),
        NameTag = Drawing.new("Text"),
        HealthBar = Drawing.new("Square"),
        HealthFill = Drawing.new("Square")
    }
    for _, drawing in pairs(espGroup) do
        drawing.Visible = false
        drawing.Transparency = 1
    end
    espGroup.BoxOuter.Thickness = 2
    espGroup.BoxOuter.Color = Color3.fromRGB(0, 0, 0)
    espGroup.BoxOuter.Filled = false
    espGroup.BoxInner.Thickness = 1
    espGroup.BoxInner.Color = espColor
    espGroup.BoxInner.Filled = false
    espGroup.NameTag.Color = Color3.fromRGB(255, 255, 255)
    espGroup.NameTag.Size = 14
    espGroup.NameTag.Center = true
    espGroup.NameTag.Outline = true
    espGroup.NameTag.OutlineColor = Color3.fromRGB(0, 0, 0)
    espGroup.HealthBar.Thickness = 1
    espGroup.HealthBar.Color = Color3.fromRGB(0, 0, 0)
    espGroup.HealthBar.Filled = true
    espGroup.HealthFill.Color = espColor
    espGroup.HealthFill.Filled = true

    local lastUpdate = tick()
    local function updateESP()
        if tick() - lastUpdate < 0.01 then return end
        lastUpdate = tick()
        espGroup.BoxInner.Color = espColor
        espGroup.HealthFill.Color = espColor
        if not espEnabled or isTeamMate(player) or not player.Character or not player.Character.Parent then
            for _, drawing in pairs(espGroup) do drawing.Visible = false end
            return
        end
        local humanoid = player.Character:FindFirstChild("Humanoid")
        local rootPart = player.Character:FindFirstChild("HumanoidRootPart")
        if not humanoid or not rootPart or humanoid.Health <= 0 then
            for _, drawing in pairs(espGroup) do drawing.Visible = false end
            return
        end
        local vector, onScreen = Camera:WorldToViewportPoint(rootPart.Position)
        if onScreen then
            local headPos = Camera:WorldToViewportPoint(player.Character.Head.Position + Vector3.new(0, 1, 0))
            local legPos = Camera:WorldToViewportPoint(rootPart.Position - Vector3.new(0, 3, 0))
            local height = math.abs(headPos.Y - legPos.Y)
            local width = height * 0.6
            local boxSize = Vector2.new(width, height)
            local boxPos = Vector2.new(vector.X - width / 2, vector.Y - height / 2)
            espGroup.BoxOuter.Size = boxSize + Vector2.new(4, 4)
            espGroup.BoxOuter.Position = boxPos - Vector2.new(2, 2)
            espGroup.BoxInner.Size = boxSize
            espGroup.BoxInner.Position = boxPos
            espGroup.NameTag.Position = Vector2.new(vector.X, boxPos.Y - 16)
            espGroup.NameTag.Text = player.Name
            local healthPercent = humanoid.Health / humanoid.MaxHealth
            espGroup.HealthBar.Size = Vector2.new(4, height + 4)
            espGroup.HealthBar.Position = Vector2.new(boxPos.X - 8, boxPos.Y - 2)
            espGroup.HealthFill.Size = Vector2.new(2, height * healthPercent)
            espGroup.HealthFill.Position = Vector2.new(boxPos.X - 7, boxPos.Y + height - (height * healthPercent) + 2)
            espGroup.HealthFill.Color = Color3.fromRGB(math.floor(255 * (1 - healthPercent)), math.floor(255 * healthPercent), 0)
            for _, drawing in pairs(espGroup) do drawing.Visible = true end
        else
            for _, drawing in pairs(espGroup) do drawing.Visible = false end
        end
    end
    table.insert(_G.RapehookConnections, RunService.RenderStepped:Connect(updateESP))
    player.CharacterRemoving:Connect(function()
        for _, drawing in pairs(espGroup) do drawing:Remove() end
    end)
end

local function createSkeletonESP(player)
    if isTeamMate(player) then return end
    local skeletonParts = {
        { "Head", "UpperTorso" }, { "UpperTorso", "LowerTorso" }, { "UpperTorso", "LeftUpperArm" }, { "UpperTorso", "RightUpperArm" },
        { "LeftUpperArm", "LeftLowerArm" }, { "RightUpperArm", "RightLowerArm" }, { "LowerTorso", "LeftUpperLeg" }, { "LowerTorso", "RightUpperLeg" },
        { "LeftUpperLeg", "LeftLowerLeg" }, { "RightUpperLeg", "RightLowerLeg" }
    }
    local skeletonLines = {}
    for _, pair in pairs(skeletonParts) do
        local line = Drawing.new("Line")
        line.Thickness = 1
        line.Color = skeletonColor
        line.Visible = false
        line.Transparency = 1
        skeletonLines[pair[1] .. "-" .. pair[2]] = line
    end
    local lastUpdate = tick()
    local function updateSkeleton()
        if tick() - lastUpdate < 0.05 then return end
        lastUpdate = tick()
        if not skeletonEnabled or isTeamMate(player) or not player.Character or not player.Character.Parent then
            for _, line in pairs(skeletonLines) do line.Visible = false end
            return
        end
        local humanoid = player.Character:FindFirstChild("Humanoid")
        if not humanoid or humanoid.Health <= 0 then
            for _, line in pairs(skeletonLines) do line.Visible = false end
            return
        end
        for _, pair in pairs(skeletonParts) do
            local part1 = player.Character:FindFirstChild(pair[1])
            local part2 = player.Character:FindFirstChild(pair[2])
            local line = skeletonLines[pair[1] .. "-" .. pair[2]]
            if part1 and part2 then
                local pos1, vis1 = Camera:WorldToViewportPoint(part1.Position)
                local pos2, vis2 = Camera:WorldToViewportPoint(part2.Position)
                line.Color = skeletonColor
                if vis1 and vis2 then
                    line.From = Vector2.new(pos1.X, pos1.Y)
                    line.To = Vector2.new(pos2.X, pos2.Y)
                    line.Visible = true
                else
                    line.Visible = false
                end
            else
                line.Visible = false
            end
        end
    end
    table.insert(_G.RapehookConnections, RunService.RenderStepped:Connect(updateSkeleton))
    player.CharacterRemoving:Connect(function()
        for _, line in pairs(skeletonLines) do line:Remove() end
    end)
end

local function createChams(player)
    if isTeamMate(player) then return end
    local highlight = Instance.new("Highlight")
    highlight.Name = "Chams"
    highlight.FillColor = chamsFillColor
    highlight.OutlineColor = chamsOutlineColor
    highlight.FillTransparency = 0.5
    highlight.OutlineTransparency = 0
    highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    highlight.Enabled = false
    highlight.Parent = game:GetService("CoreGui")
    highlight.Adornee = player.Character
    local function updateChams()
        highlight.FillColor = chamsFillColor
        highlight.OutlineColor = chamsOutlineColor
        highlight.Enabled = chamsEnabled and player.Character and not isTeamMate(player) and player.Character.Parent
    end
    table.insert(_G.RapehookConnections, RunService.RenderStepped:Connect(updateChams))
    player.CharacterRemoving:Connect(function() highlight:Destroy() end)
end

local whitelistedPlayers = { "IAmBeingDommedByMen", "miserablekitchen" }
local fovDrawing = Drawing.new("Circle")
fovDrawing.Thickness = 1
fovDrawing.NumSides = 100
fovDrawing.Radius = fovSize
fovDrawing.Filled = false
fovDrawing.Visible = false
fovDrawing.Transparency = 1
fovDrawing.Color = fovColor

local function getClosestEnemyInFOV()
    local closestPlayer, closestDistance = nil, math.huge
    local mousePos = UserInputService:GetMouseLocation()
    if not LocalPlayer.Character or not LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then return nil end
    for _, player in pairs(Players:GetPlayers()) do
        if player == LocalPlayer or isTeamMate(player) or table.find(whitelistedPlayers, player.Name) then continue end
        local character = player.Character
        if not character or not character.Parent then continue end
        local target = character:FindFirstChild(targetPart)
        local humanoid = character:FindFirstChild("Humanoid")
        if target and humanoid and humanoid.Health > 0 then
            local screenPos, onScreen = Camera:WorldToViewportPoint(target.Position)
            if onScreen then
                local distance = (Vector2.new(screenPos.X, screenPos.Y) - mousePos).Magnitude
                if distance < fovSize and distance < closestDistance and isVisible(target) then
                    closestDistance = distance
                    closestPlayer = player
                end
            end
        end
    end
    return closestPlayer
end

local function applySilentAim()
    if not silentAimEnabled or not UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) then return end
    if math.random(1, 100) > hitChance then return end
    local target = getClosestEnemyInFOV()
    if target and target.Character and target.Character:FindFirstChild(targetPart) then
        local targetPos = target.Character[targetPart].Position
        local rayOrigin = Camera.CFrame.Position
        local originalLook = Camera.CFrame.LookVector
        Camera.CFrame = CFrame.new(rayOrigin, targetPos)
        task.wait()
        Camera.CFrame = CFrame.new(rayOrigin, rayOrigin + originalLook)
    end
end

local function aimbotUpdate()
    if not Camera or not LocalPlayer.Character then return end
    fovDrawing.Position = UserInputService:GetMouseLocation()
    fovDrawing.Radius = fovSize
    fovDrawing.Color = fovColor
    fovDrawing.Visible = fovEnabled and aimbotEnabled
    if aimbotEnabled and UserInputService:IsMouseButtonPressed(aimbotKey) then
        local closestEnemy = getClosestEnemyInFOV()
        if closestEnemy and closestEnemy.Character then
            local target = closestEnemy.Character:FindFirstChild(targetPart) or closestEnemy.Character:FindFirstChild("Head")
            if target then
                local targetPos, onScreen = Camera:WorldToViewportPoint(target.Position)
                local mousePos = UserInputService:GetMouseLocation()
                if onScreen and (Vector2.new(targetPos.X, targetPos.Y) - mousePos).Magnitude <= fovSize then
                    local targetCFrame = CFrame.new(Camera.CFrame.Position, target.Position)
                    local newCFrame = Camera.CFrame:Lerp(targetCFrame, aimbotSmoothing)
                    Camera.CFrame = newCFrame
                end
            end
        end
    end
    applySilentAim()
end

local character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")
local rootPart = character:WaitForChild("HumanoidRootPart")
local flying = false
local noclipping = false
local speed = 50
local bodyVelocity, bodyGyro, noclipConnection

local function startFlying()
    if flying then return end
    flying = true
    bodyVelocity = Instance.new("BodyVelocity")
    bodyVelocity.Velocity = Vector3.new(0, 0, 0)
    bodyVelocity.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
    bodyVelocity.Parent = rootPart
    bodyGyro = Instance.new("BodyGyro")
    bodyGyro.P = 9e4
    bodyGyro.MaxTorque = Vector3.new(9e9, 9e9, 9e9)
    bodyGyro.CFrame = rootPart.CFrame
    bodyGyro.Parent = rootPart
    humanoid.PlatformStand = true
    task.spawn(function()
        while flying do
            local cam = Workspace.CurrentCamera
            local moveDirection = Vector3.new(0, 0, 0)
            if UserInputService:IsKeyDown(Enum.KeyCode.W) then moveDirection += cam.CFrame.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.S) then moveDirection -= cam.CFrame.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.A) then moveDirection -= cam.CFrame.RightVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.D) then moveDirection += cam.CFrame.RightVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.Space) then moveDirection += Vector3.new(0, 1, 0) end
            if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then moveDirection -= Vector3.new(0, 1, 0) end
            bodyVelocity.Velocity = moveDirection.Magnitude > 0 and moveDirection.Unit * speed or Vector3.new(0, 0, 0)
            bodyGyro.CFrame = cam.CFrame
            task.wait()
        end
    end)
end

local function stopFlying()
    if not flying then return end
    flying = false
    if bodyVelocity then bodyVelocity:Destroy() end
    if bodyGyro then bodyGyro:Destroy() end
    humanoid.PlatformStand = false
end

local function startNoclip()
    if noclipping then return end
    noclipping = true
    noclipConnection = RunService.Stepped:Connect(function()
        for _, part in pairs(character:GetDescendants()) do
            if part:IsA("BasePart") then part.CanCollide = false end
        end
    end)
end

local function stopNoclip()
    if not noclipping then return end
    noclipping = false
    if noclipConnection then noclipConnection:Disconnect() end
    for _, part in pairs(character:GetDescendants()) do
        if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then part.CanCollide = true end
    end
end

local function toggleFlightAndNoclip()
    if flying or noclipping then
        stopFlying()
        stopNoclip()
    else
        startFlying()
        startNoclip()
    end
end

local function updateViewmodel()
    local viewmodel = Workspace.Camera:FindFirstChild("Arms")
    if viewmodel then
        for _, part in pairs(viewmodel:GetDescendants()) do
            if part:IsA("BasePart") then
                if part.Name:lower():find("arm") then
                    part.Color = armColor
                else
                    part.Material = viewmodelMaterial
                    part.Color = viewmodelColor
                end
            end
        end
    end
end

local AimbotTab = library:NewTab("Combat")
AimbotTab:NewSection("Aimbot Settings")
AimbotTab:NewToggle("Aimbot", false, function(v)
    aimbotEnabled = v
    updateConfig()
end):AddKeybind(Enum.UserInputType.MouseButton2)
AimbotTab:NewToggle("Show FOV", false, function(v)
    fovEnabled = v
    updateConfig()
end)
AimbotTab:NewToggle("Silent Aim", false, function(v)
    silentAimEnabled = v
    updateConfig()
end)
AimbotTab:NewSlider("FOV Size", "Adjust FOV circle size", true, "", { min = 50, max = 500, default = 100, step = 1 }, function(v)
    fovSize = v
    fovDrawing.Radius = v
    updateConfig()
end)
AimbotTab:NewSlider("Smoothing", "Adjust aimbot smoothing", true, "", { min = 0, max = 100, default = 20, step = 1 }, function(v)
    aimbotSmoothing = v
    updateConfig()
end)
AimbotTab:NewSlider("Hit Chance", "Adjust aimbot hit chance", true, "%", { min = 0, max = 100, default = 100, step = 1 }, function(v)
    hitChance = v
    updateConfig()
end)
AimbotTab:NewSelector("Target Part", "Head", { "Head", "Torso", "Random" }, function(v)
    targetPart = v == "Random" and (math.random() > 0.5 and "Head" or "Torso") or v
end)

local VisualsTab = library:NewTab("Visuals")
VisualsTab:NewSection("ESP Settings")
VisualsTab:NewToggle("Box ESP", false, function(v)
    espEnabled = v
    updateConfig()
end)
VisualsTab:NewButton("Cycle ESP Color", function()
    espColor = Color3.fromRGB(math.random(0, 255), math.random(0, 255), math.random(0, 255))
    updateConfig()
end)
VisualsTab:NewToggle("Skeleton ESP", false, function(v)
    skeletonEnabled = v
    updateConfig()
end)
VisualsTab:NewButton("Cycle Skeleton Color", function()
    skeletonColor = Color3.fromRGB(math.random(0, 255), math.random(0, 255), math.random(0, 255))
    updateConfig()
end)
VisualsTab:NewToggle("Chams", false, function(v)
    chamsEnabled = v
    updateConfig()
end)
VisualsTab:NewButton("Cycle Chams Fill", function()
    chamsFillColor = Color3.fromRGB(math.random(0, 255), math.random(0, 255), math.random(0, 255))
    updateConfig()
end)
VisualsTab:NewButton("Cycle Chams Outline", function()
    chamsOutlineColor = Color3.fromRGB(math.random(0, 255), math.random(0, 255), math.random(0, 255))
    updateConfig()
end)
local materials = { "Plastic", "Metal", "Neon", "Wood", "Glass" }
VisualsTab:NewSelector("Chams Material", "Plastic", materials, function(v)
    chamsMaterial = Enum.Material[v]
    updateConfig()
end)

local MiscTab = library:NewTab("Misc")
MiscTab:NewSection("Miscellaneous")
MiscTab:NewButton("Anticheat Disabler", function() print("soon") end)
MiscTab:NewToggle("FFA Mode", false, function(v) ffaMode = v end)
MiscTab:NewKeybind("Fly Bind", Enum.KeyCode.V, function(k)
    flyBind = Enum.KeyCode[k]
    updateConfig()
end)
MiscTab:NewSelector("Viewmodel Material", "Plastic", materials, function(v)
    viewmodelMaterial = Enum.Material[v]
    updateViewmodel()
    updateConfig()
end)
MiscTab:NewButton("Cycle Weapon Color", function()
    viewmodelColor = Color3.fromRGB(math.random(0, 255), math.random(0, 255), math.random(0, 255))
    updateViewmodel()
    updateConfig()
end)
MiscTab:NewButton("Cycle Arm Color", function()
    armColor = Color3.fromRGB(math.random(0, 255), math.random(0, 255), math.random(0, 255))
    updateViewmodel()
    updateConfig()
end)

local ConfigTab = library:NewTab("Config")
ConfigTab:NewSection("Configuration")
ConfigTab:NewButton("Save Config", function()
    local configString = HttpService:JSONEncode(config)
    if writefile then
        writefile("Rapehook_config.json", configString)
    else
        setclipboard(configString)
        library:Notify("Config copied to clipboard", 3)
    end
end)
ConfigTab:NewButton("Load Config", function()
    local configString = readfile and readfile("Rapehook_config.json")
    if configString then
        local success, decoded = pcall(function() return HttpService:JSONDecode(configString) end)
        if success then
            config = decoded
            aimbotEnabled = config.aimbotEnabled
            fovSize = config.fovSize
            aimbotSmoothing = config.aimbotSmoothing
            espEnabled = config.espEnabled
            skeletonEnabled = config.skeletonEnabled
            chamsEnabled = config.chamsEnabled
            flyBind = Enum.KeyCode[config.flyBind]
            hitChance = config.hitChance
            fovEnabled = config.fovEnabled
            silentAimEnabled = config.silentAimEnabled
            viewmodelMaterial = Enum.Material[config.viewmodelMaterial]
            viewmodelColor = Color3.fromRGB(unpack(config.viewmodelColor))
            armColor = Color3.fromRGB(unpack(config.armColor))
            espColor = Color3.fromRGB(unpack(config.espColor))
            skeletonColor = Color3.fromRGB(unpack(config.skeletonColor))
            chamsFillColor = Color3.fromRGB(unpack(config.chamsFillColor))
            chamsOutlineColor = Color3.fromRGB(unpack(config.chamsOutlineColor))
            chamsMaterial = Enum.Material[config.chamsMaterial]
            fovDrawing.Radius = fovSize
            library:Notify("Config loaded successfully", 3, "success")
        else
            library:Notify("Failed to decode config", 3, "error")
        end
    else
        library:Notify("No config file found", 3, "error")
    end
end)

table.insert(_G.RapehookConnections, RunService.RenderStepped:Connect(aimbotUpdate))
table.insert(_G.RapehookConnections, RunService.RenderStepped:Connect(function()
    if Workspace.Camera then updateViewmodel() end
end))
table.insert(_G.RapehookConnections, UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if input.KeyCode == flyBind then toggleFlightAndNoclip() end
end))

for _, player in pairs(Players:GetPlayers()) do
    if player ~= LocalPlayer then
        createBoxESP(player)
        createSkeletonESP(player)
        createChams(player)
    end
end
table.insert(_G.RapehookConnections, Players.PlayerAdded:Connect(function(player)
    createBoxESP(player)
    createSkeletonESP(player)
    createChams(player)
end))

LocalPlayer.CharacterAdded:Connect(function(char)
    character = char
    humanoid = char:WaitForChild("Humanoid")
    rootPart = char:WaitForChild("HumanoidRootPart")
    if flying or noclipping then
        stopFlying()
        stopNoclip()
        task.wait(0.1)
        if flying then startFlying() end
        if noclipping then startNoclip() end
    end
end)

local function cleanup()
    fovDrawing:Remove()
    for _, connection in pairs(_G.RapehookConnections) do
        connection:Disconnect()
    end
    _G.isRapehookLoaded = false
end

LocalPlayer.OnTeleport:Connect(cleanup)
game:GetService("CoreGui").ChildRemoved:Connect(function(child)
    if child.Name == "RapeHook" then cleanup() end
end)

]]--
