repeat wait() until game:IsLoaded()

wait(5)

local ohString1 = "SetTeam"
local ohString2 = "Marines"
game:GetService("ReplicatedStorage").Remotes.CommF_:InvokeServer(ohString1, ohString2)
wait(5)
_G.AutoCollectChest = true
_G.CancelTween2 = false
_G.StopTween = false
_G.AutoRejoin = false
_G.FpsBoost = true
_G.starthop = true
_G.AutoHopEnabled = true
_G.LastPosition = nil
_G.LastTimeChecked = tick()
_G.LastChestCollectedTime = tick()
_G.AutoJump = true
_G.Antikick = true
TweenSpeed = 350
getgenv().Setting = {
    ModeFarm = {
        StopItemLegendary = true
    }
}

if getgenv().Setting.WhiteScreen == true then
	    game:GetService("RunService"):Set3dRenderingEnabled(false)
elseif getgenv().Setting.WhiteScreen == false then
	    game:GetService("RunService"):Set3dRenderingEnabled(true)
end

--// Fps Boost
if getgenv().Setting.FpsBoost == true then
	pcall(function()
		game:GetService("Lighting").FantasySky:Destroy()
		local g = game
		local w = g.Workspace
		local l = g.Lighting
		local t = w.Terrain
		t.WaterWaveSize = 0
		t.WaterWaveSpeed = 0
		t.WaterReflectance = 0
		t.WaterTransparency = 0
		l.GlobalShadows = false
		l.FogEnd = 9e9
		l.Brightness = 0
		settings().Rendering.QualityLevel = "Level01"
		for i, v in pairs(g:GetDescendants()) do
			if v:IsA("Part") or v:IsA("Union") or v:IsA("CornerWedgePart") or v:IsA("TrussPart") then 
				v.Material = "Plastic"
				v.Reflectance = 0
			elseif v:IsA("Decal") or v:IsA("Texture") then
				v.Transparency = 1
			elseif v:IsA("ParticleEmitter") or v:IsA("Trail") then
				v.Lifetime = NumberRange.new(0)
			elseif v:IsA("Explosion") then
				v.BlastPressure = 1
				v.BlastRadius = 1
			elseif v:IsA("Fire") or v:IsA("SpotLight") or v:IsA("Smoke") or v:IsA("Sparkles") then
				v.Enabled = false
			elseif v:IsA("MeshPart") then
				v.Material = "Plastic"
				v.Reflectance = 0
				v.TextureID = 10385902758728957
			end
		end
		for i, e in pairs(l:GetChildren()) do
			if e:IsA("BlurEffect") or e:IsA("SunRaysEffect") or e:IsA("ColorCorrectionEffect") or e:IsA("BloomEffect") or e:IsA("DepthOfFieldEffect") then
				e.Enabled = false
			end
		end
		for i, v in pairs(game:GetService("Workspace").Camera:GetDescendants()) do
			if v.Name == ("Water;") then
				v.Transparency = 1
				v.Material = "Plastic"
			end
		end
	end)
end

-- Hàm Tween2 để di chuyển nhân vật với kiểm soát hủy
function Tween2(targetCFrame)
    local distance = (targetCFrame.Position - game.Players.LocalPlayer.Character.HumanoidRootPart.Position).Magnitude
    local speed = 350
    local tweenTime = distance / speed
    local tweenInfo = TweenInfo.new(tweenTime, Enum.EasingStyle.Linear)
    local tween = game:GetService("TweenService"):Create(game.Players.LocalPlayer.Character.HumanoidRootPart, tweenInfo, {CFrame = targetCFrame})
    tween:Play()
    if _G.CancelTween2 then
        tween:Cancel()
    end
    _G.Clip2 = true
    wait(tweenTime)
    _G.Clip2 = false
end

-- Hàm BTPZ cho teleport nhân vật
function BTPZ(targetCFrame)
    local character = game.Players.LocalPlayer.Character
    character.HumanoidRootPart.CFrame = targetCFrame
    task.wait()
    character.HumanoidRootPart.CFrame = targetCFrame
end

-- Hàm Tween cho việc di chuyển
function Tween(targetCFrame)
    local distance = (targetCFrame.Position - game.Players.LocalPlayer.Character.HumanoidRootPart.Position).Magnitude
    local speed = TweenSpeed
    local tweenTime = distance / speed
    local tweenInfo = TweenInfo.new(tweenTime, Enum.EasingStyle.Linear)
    local tween = game:GetService("TweenService"):Create(game.Players.LocalPlayer.Character.HumanoidRootPart, tweenInfo, {CFrame = targetCFrame})
    tween:Play()
    if _G.StopTween then
        tween:Cancel()
    end
end

-- Hàm hủy Tween đang chạy
function CancelTween()
    _G.StopTween = true
    wait()
    Tween(game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame)
    wait()
    _G.StopTween = false
end

-- Hàm trang bị công cụ từ Backpack
function EquipTool(toolName)
    local backpack = game.Players.LocalPlayer.Backpack
    local tool = backpack:FindFirstChild(toolName)
    if tool then
        game.Players.LocalPlayer.Character.Humanoid:EquipTool(tool)
    end
end



spawn(function()
    while wait(1) do -- Đợi 1 giây giữa mỗi lần lặp
        if _G.AutoCollectChest then
            local collectionService = game:GetService("CollectionService")
            local chests = collectionService:GetTagged("_ChestTagged")
            local nearestChest = nil
            local nearestDistance = math.huge

            for _, chest in ipairs(chests) do
                local chestPosition = chest:GetPivot().Position
                local distance = (chestPosition - game.Players.LocalPlayer.Character.HumanoidRootPart.Position).Magnitude
                if not chest:GetAttribute("IsDisabled") and distance < nearestDistance then
                    nearestDistance = distance
                    nearestChest = chest
                end
            end

            if nearestChest then
                Tween2(CFrame.new(nearestChest:GetPivot().Position))
                _G.LastChestCollectedTime = tick() -- Cập nhật thời gian thu thập rương mới nhất
            elseif tick() - _G.LastChestCollectedTime > 60 then
                HopServer() -- Chuyển server nếu quá 60 giây không thu thập được rương
            end
        end
    end
end)
function CheckForSpecialItems()
    local startTime = tick()  -- Lưu thời gian bắt đầu kiểm tra
    local timeLimit = 20 * 60 -- Đặt giới hạn thời gian là 20 phút

    spawn(function()
        while true do
            wait(1)  -- Kiểm tra mỗi giây
            local currentTime = tick()
            local player = game.Players.LocalPlayer
            local hasSpecialItem = player.Backpack:FindFirstChild("Fist of Darkness") or
                                   player.Character:FindFirstChild("Fist of Darkness") or
                                   player.Backpack:FindFirstChild("God's Chalice") or
                                   player.Character:FindFirstChild("God's Chalice")

            -- Nếu tìm thấy item, reset đồng hồ
            if hasSpecialItem then
                startTime = tick()
            elseif (currentTime - startTime) > timeLimit then
                -- Nếu quá 20 phút không tìm thấy item, chuyển server
                HopServer()  -- Gọi hàm chuyển server
                startTime = tick()  -- Reset đồng hồ sau khi chuyển server
            end
        end
    end)
end
-- Gọi hàm kiểm tra item đặc biệt
CheckForSpecialItems()

-- Mã sử dụng trong spawn function để kiểm tra và điều chỉnh trạng thái tự động nhặt và chuyển server
spawn(function()
    while true do
        wait(2) -- Đợi 2 giây giữa mỗi lần kiểm tra
        local player = game.Players.LocalPlayer ----workspace.Enemies.Darkbeard
        local hasSpecialItem = player.Backpack:FindFirstChild("Fist of Darkness") or
                               player.Character:FindFirstChild("Fist of Darkness") or
                               player.Backpack:FindFirstChild("God's Chalice") or
                               player.Character:FindFirstChild("God's Chalice")

        if hasSpecialItem then
            if _G.AutoCollectChest or _G.AutoHopEnabled then
                _G.AutoCollectChest = false
                _G.AutoHopEnabled = false
            end
        else
            if not _G.AutoCollectChest or not _G.AutoHopEnabled then
                _G.AutoCollectChest = true
                _G.AutoHopEnabled = true -- Khôi phục tự động chuyển server và thu thập rương
            end
        end
    end
end)


spawn(function()
	while wait() do
	    if getgenv().Setting.AutoRejoin == true then
	        getgenv().rejoin = game:GetService("CoreGui").RobloxPromptGui.promptOverlay.ChildAdded:Connect(function(child)
                if child.Name == 'ErrorPrompt' and child:FindFirstChild('MessageArea') and child.MessageArea:FindFirstChild("ErrorFrame") then
                    game:GetService("TeleportService"):Teleport(game.PlaceId)
                end
            end)
	    end
	end
end)

function CheckIfStuckAndHop()
    local player = game.Players.LocalPlayer
    local character = player.Character or player.CharacterAdded:Wait()
    local currentPosition = character and character:FindFirstChild("HumanoidRootPart") and character.HumanoidRootPart.Position

    if currentPosition then
        if _G.LastPosition then
            if (currentPosition - _G.LastPosition).Magnitude < 1 then -- Kiểm tra xem vị trí có thay đổi không
                if tick() - _G.LastTimeChecked > 15 then -- Đã đứng yên quá 15 giây
                    print("Đứng yên quá lâu, đang chuyển server...")
                    HopServer() -- Gọi hàm chuyển server
                    _G.LastTimeChecked = tick() -- Reset timer
                end
            else
                _G.LastPosition = currentPosition
                _G.LastTimeChecked = tick() -- Reset timer khi người chơi di chuyển
            end
        else
            _G.LastPosition = currentPosition
            _G.LastTimeChecked = tick()
        end
    end
end

-- Coroutine để liên tục kiểm tra vị trí người chơi
spawn(function()
    while wait(1) do -- Kiểm tra mỗi giây
        if _G.AutoHopEnabled then
            CheckIfStuckAndHop()
        end
    end
end)

function HopServer()
    local maxServerSize = 7 -- Giới hạn số người trong server để chuyển đến
    local serverFound = false -- Biến để kiểm tra xem đã chuyển server thành công chưa

    -- Chức năng tìm và chuyển đến server mới
    local function findAndJoinNewServer()
        local serverBrowserService = game:GetService("ReplicatedStorage").__ServerBrowser
        for i = 1, math.huge do
            local availableServers = serverBrowserService:InvokeServer(i)
            for jobId, serverInfo in pairs(availableServers) do
                if jobId ~= game.JobId and serverInfo["Count"] < maxServerSize then
                    serverBrowserService:InvokeServer("teleport", jobId)
                    serverFound = true
                    return true
                end
            end
        end
        return false
    end

    -- Thử chuyển đến server mới
    while not serverFound do
        findAndJoinNewServer()
        wait(0.4) -- Đợi một khoảng ngắn trước khi thử lại
    end
end


-- Hàm để kích hoạt nhân vật nhảy
function AutoJump()
    local player = game.Players.LocalPlayer
    local character = player.Character or player.CharacterAdded:Wait()
    local humanoid = character:FindFirstChildOfClass("Humanoid")

    while wait(math.random(17)) do  -- Chờ một khoảng thời gian ngẫu nhiên từ 6 đến 8 giây
        if humanoid and humanoid.Health > 0 then  -- Kiểm tra nếu nhân vật còn sống
            humanoid:ChangeState(Enum.HumanoidStateType.Jumping)  -- Kích hoạt trạng thái nhảy
        end
    end
end

-- Khởi chạy hàm tự động nhảy trong một coroutine riêng biệt
spawn(AutoJump)

-- Function ngăn chống kick khi đứng yên 20 phút
local function AntiKick()
while true do
wait(1)
if game.Players.LocalPlayer.Character and game.Players.LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
local v1518 = Instance.new("BillboardGui", game.Players.LocalPlayer.Character.HumanoidRootPart);
v1518.Name = "Esp";
v1518.ExtentsOffset = Vector3.new(0, 1, 0);
v1518.Size = UDim2.new(1, 300, 1, 50);
v1518.Adornee = game.Players.LocalPlayer.Character.HumanoidRootPart;
v1518.AlwaysOnTop = true;
local v1524 = Instance.new("TextLabel", v1518);
v1524.Font = "Code";
v1524.FontSize = "Size14";
v1524.TextWrapped = true;
v1524.Size = UDim2.new(1, 0, 1, 0);
v1524.TextYAlignment = "Top";
v1524.BackgroundTransparency = 1;
v1524.TextStrokeTransparency = 0.5;
v1524.TextColor3 = Color3.fromRGB(80, 245, 245);
v1524.Text = "taphoamizu.com";
end
if game.Players.LocalPlayer.Character.HumanoidRootPart.Velocity.Magnitude < 0.1 then
game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame + Vector3.new(0, 0, 0.01)
end
end
end

-- Gọi function
AntiKick()