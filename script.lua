-- تحميل الخدمات الأساسية
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local SoundService = game:GetService("SoundService")
local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

-- دالة تشغيل صوت التنبيه مع الإشعارات
local function playNotificationSound()
    pcall(function()
        local sound = Instance.new("Sound")
        sound.SoundId = "rbxassetid://4590657391" -- صوت تنبيهي (Ding)
        sound.Volume = 1
        sound.Parent = SoundService
        sound:Play()
        sound.Ended:Connect(function()
            sound:Destroy()
        end)
    end)
end

-- تحميل مكتبة Rayfield
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

-- إنشاء النافذة الرئيسية
local Window = Rayfield:CreateWindow({
   Name = "كنوsm®",
   LoadingTitle = "جارٍ تحميل سكربت كنوsm®...",
   LoadingSubtitle = "جميع الحقوق محفوظة",
   ConfigurationSaving = { Enabled = false },
   KeySystem = false,
})

-- إنشاء التبويبات (Tabs)
local PlayerTab = Window:CreateTab("الشخصية والحركة", 4483362458)
local EspTab = Window:CreateTab("الكشف الشامل (ESP)", 4483362458)
local AimbotTab = Window:CreateTab("الايمبوت والدائرة (Aimbot)", 4483362458)
local HitboxTab = Window:CreateTab("الهيت بوكس", 4483362458)
local GhostTab = Window:CreateTab("الجدران والأرضية", 4483362458)

---------------------------------------------------------
-- إشعار أول ما يتفعل السكربت
---------------------------------------------------------
task.spawn(function()
    task.wait(1)
    playNotificationSound()
    Rayfield:Notify({
       Title = "كنوsm®",
       Content = "منور السكربت يا عسل و اذ ودك زياده من الابداع تفضل انستا 🤩: cp_qj",
       Duration = 6,
       Image = 4483362458,
    })
end)

---------------------------------------------------------
-- 1. ميزات الشخصية والحركة (Player Features)
---------------------------------------------------------
local walkSpeedEnabled = false
local defaultSpeed = 16
local targetSpeed = 50

local jumpPowerEnabled = false
local defaultJump = 50
local targetJump = 100

local noclipEnabled = false
local infJumpEnabled = false

-- السرعة والقفز
PlayerTab:CreateToggle({
   Name = "تفعيل تغيير السرعة",
   CurrentValue = false,
   Flag = "SpeedToggle",
   Callback = function(Value)
      walkSpeedEnabled = Value
      if not Value and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
         LocalPlayer.Character.Humanoid.WalkSpeed = defaultSpeed
      end
   end,
})

PlayerTab:CreateSlider({
   Name = "مستوى السرعة",
   Range = {16, 250},
   Increment = 2,
   Suffix = "سرعة",
   CurrentValue = 50,
   Flag = "SpeedSlider",
   Callback = function(Value)
      targetSpeed = Value
   end,
})

PlayerTab:CreateToggle({
   Name = "تفعيل زيادة قفزة اللاعب",
   CurrentValue = false,
   Flag = "JumpToggle",
   Callback = function(Value)
      jumpPowerEnabled = Value
      if not Value and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
         LocalPlayer.Character.Humanoid.JumpPower = defaultJump
      end
   end,
})

PlayerTab:CreateSlider({
   Name = "قوة القفز",
   Range = {50, 300},
   Increment = 5,
   Suffix = "قوة",
   CurrentValue = 100,
   Flag = "JumpSlider",
   Callback = function(Value)
      targetJump = Value
   end,
})

-- القفز اللانهائي (نط ورا بعض)
PlayerTab:CreateToggle({
   Name = "القفز اللانهائي (Inf Jump)",
   CurrentValue = false,
   Flag = "InfJumpToggle",
   Callback = function(Value)
      infJumpEnabled = Value
   end,
})

UserInputService.JumpRequest:Connect(function()
   if infJumpEnabled and LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid") then
      LocalPlayer.Character:FindFirstChildOfClass("Humanoid"):ChangeState(Enum.HumanoidStateType.Jumping)
   end
end)

-- اختراق الجدران (Noclip)
PlayerTab:CreateToggle({
   Name = "اختراق الجدران (Noclip)",
   CurrentValue = false,
   Flag = "NoclipToggle",
   Callback = function(Value)
      noclipEnabled = Value
   end,
})

RunService.Stepped:Connect(function()
   if noclipEnabled and LocalPlayer.Character then
      for _, part in pairs(LocalPlayer.Character:GetDescendants()) do
         if part:IsA("BasePart") then
            part.CanCollide = false
         end
      end
   end
   
   -- تحديث السرعة والقفز باستمرار
   if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
      local hum = LocalPlayer.Character.Humanoid
      if walkSpeedEnabled then hum.WalkSpeed = targetSpeed end
      if jumpPowerEnabled then 
         hum.UseJumpPower = true 
         hum.JumpPower = targetJump 
      end
   end
end)

-- أدوات التنقل
PlayerTab:CreateButton({
   Name = "إعطاء أداة التنقل (Click Teleport Tool)",
   Callback = function()
      local tool = Instance.new("Tool")
      tool.Name = "أداة التنقل 🌀"
      tool.RequiresHandle = false
      tool.Activated:Connect(function()
         local mouse = LocalPlayer:GetMouse()
         if mouse.Hit and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
            LocalPlayer.Character.HumanoidRootPart.CFrame = mouse.Hit + Vector3.new(0, 3, 0)
         end
      end)
      tool.Parent = LocalPlayer.Backpack
   end,
})

---------------------------------------------------------
-- 2. ميزة الكشف المطور (Fixed ESP System)
---------------------------------------------------------
local espEnabled = false
local skeletonEnabled = true
local boxEspEnabled = true
local tracersEnabled = false
local rainbowEsp = true
local rainbowSpeed = 2
local espDrawings = {}

EspTab:CreateToggle({
   Name = "تفعيل الكشف العام (ESP)",
   CurrentValue = false,
   Flag = "EspMasterToggle",
   Callback = function(Value)
      espEnabled = Value
      if not espEnabled then
         for p, drawings in pairs(espDrawings) do
            for _, d in pairs(drawings) do
               if type(d) == "table" then
                  for _, line in pairs(d) do line:Remove() end
               else
                  d:Remove()
               end
            end
         end
         espDrawings = {}
      end
   end,
})

EspTab:CreateToggle({
   Name = "إظهار الهيكل العظمي (Skeleton)",
   CurrentValue = true,
   Flag = "SkeletonToggle",
   Callback = function(Value)
      skeletonEnabled = Value
   end,
})

EspTab:CreateToggle({
   Name = "إظهار الصندوق (Box ESP)",
   CurrentValue = true,
   Flag = "BoxToggle",
   Callback = function(Value)
      boxEspEnabled = Value
   end,
})

EspTab:CreateToggle({
   Name = "إظهار خطوط التتبع (Tracers)",
   CurrentValue = false,
   Flag = "TracersToggle",
   Callback = function(Value)
      tracersEnabled = Value
   end,
})

EspTab:CreateToggle({
   Name = "ألوان قوس قزح (Rainbow ESP)",
   CurrentValue = true,
   Flag = "RainbowEspToggle",
   Callback = function(Value)
      rainbowEsp = Value
   end,
})

EspTab:CreateSlider({
   Name = "سرعة تغير ألوان الكشف",
   Range = {0.5, 10},
   Increment = 0.5,
   Suffix = "سرعة",
   CurrentValue = 2,
   Flag = "EspRainbowSpeed",
   Callback = function(Value)
      rainbowSpeed = Value
   end,
})

-- إعدادات عظام R6 و R15 للكشف الدقيق
local R6Joints = {
   {"Head", "Torso"}, {"Torso", "Left Arm"}, {"Torso", "Right Arm"},
   {"Torso", "Left Leg"}, {"Torso", "Right Leg"}
}

local R15Joints = {
   {"Head", "UpperTorso"}, {"UpperTorso", "LowerTorso"},
   {"UpperTorso", "LeftUpperArm"}, {"LeftUpperArm", "LeftLowerArm"}, {"LeftLowerArm", "LeftHand"},
   {"UpperTorso", "RightUpperArm"}, {"RightUpperArm", "RightLowerArm"}, {"RightLowerArm", "RightHand"},
   {"LowerTorso", "LeftUpperLeg"}, {"LeftUpperLeg", "LeftLowerLeg"}, {"LeftLowerLeg", "LeftFoot"},
   {"LowerTorso", "RightUpperLeg"}, {"RightUpperLeg", "RightLowerLeg"}, {"RightLowerLeg", "RightFoot"}
}

local function removeEsp(player)
   if espDrawings[player] then
      for _, d in pairs(espDrawings[player]) do
         if type(d) == "table" then
            for _, line in pairs(d) do pcall(function() line:Remove() end) end
         else
            pcall(function() d:Remove() end)
         end
      end
      espDrawings[player] = nil
   end
end

RunService.RenderStepped:Connect(function()
   local currentColor = rainbowEsp and Color3.fromHSV((tick() * rainbowSpeed) % 1, 1, 1) or Color3.fromRGB(255, 0, 0)

   for _, player in pairs(Players:GetPlayers()) do
      if player ~= LocalPlayer then
         local char = player.Character
         local root = char and char:FindFirstChild("HumanoidRootPart")
         local hum = char and char:FindFirstChild("Humanoid")

         if espEnabled and char and root and hum and hum.Health > 0 then
            if not espDrawings[player] then
               espDrawings[player] = {
                  Box = Drawing.new("Square"),
                  Tracer = Drawing.new("Line"),
                  Name = Drawing.new("Text"),
                  Skeletons = {}
               }
               espDrawings[player].Box.Thickness = 1.5
               espDrawings[player].Box.Filled = false
               espDrawings[player].Tracer.Thickness = 1.5
               espDrawings[player].Name.Size = 14
               espDrawings[player].Name.Center = true
               espDrawings[player].Name.Outline = true
            end

            local d = espDrawings[player]
            local rootPos, onScreen = Camera:WorldToViewportPoint(root.Position)

            if onScreen then
               -- 1. رسم المربع (Box)
               if boxEspEnabled then
                  local head = char:FindFirstChild("Head")
                  if head then
                     local headPos = Camera:WorldToViewportPoint(head.Position + Vector3.new(0, 0.5, 0))
                     local legPos = Camera:WorldToViewportPoint(root.Position - Vector3.new(0, 3, 0))
                     local height = headPos.Y - legPos.Y
                     local width = height / 2

                     d.Box.Visible = true
                     d.Box.Size = Vector2.new(width, height)
                     d.Box.Position = Vector2.new(rootPos.X - width / 2, rootPos.Y - height / 2)
                     d.Box.Color = currentColor
                  end
               else
                  d.Box.Visible = false
               end

               -- 2. رسم خط التتبع (Tracer)
               if tracersEnabled then
                  d.Tracer.Visible = true
                  d.Tracer.From = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y)
                  d.Tracer.To = Vector2.new(rootPos.X, rootPos.Y)
                  d.Tracer.Color = currentColor
               else
                  d.Tracer.Visible = false
               end

               -- 3. اسم اللاعب والصحة
               d.Name.Visible = true
               d.Name.Position = Vector2.new(rootPos.X, rootPos.Y - 35)
               d.Name.Text = player.Name .. " [" .. math.floor(hum.Health) .. " HP]"
               d.Name.Color = currentColor

               -- 4. الهيكل العظمي الصحيح (Skeleton)
               if skeletonEnabled then
                  local joints = (hum.RigType == Enum.HumanoidRigType.R15) and R15Joints or R6Joints
                  for i, pair in ipairs(joints) do
                     local part1 = char:FindFirstChild(pair[1])
                     local part2 = char:FindFirstChild(pair[2])

                     if part1 and part2 then
                        if not d.Skeletons[i] then
                           d.Skeletons[i] = Drawing.new("Line")
                           d.Skeletons[i].Thickness = 1.5
                        end
                        local line = d.Skeletons[i]
                        local p1, vis1 = Camera:WorldToViewportPoint(part1.Position)
                        local p2, vis2 = Camera:WorldToViewportPoint(part2.Position)

                        if vis1 and vis2 then
                           line.Visible = true
                           line.From = Vector2.new(p1.X, p1.Y)
                           line.To = Vector2.new(p2.X, p2.Y)
                           line.Color = currentColor
                        else
                           line.Visible = false
                        end
                     end
                  end
               else
                  for _, line in pairs(d.Skeletons) do line.Visible = false end
               end
            else
               d.Box.Visible = false
               d.Tracer.Visible = false
               d.Name.Visible = false
               for _, line in pairs(d.Skeletons) do line.Visible = false end
            end
         else
            removeEsp(player)
         end
      end
   end
end)

Players.PlayerRemoving:Connect(removeEsp)

---------------------------------------------------------
-- 3. ميزة الايمبوت والدائرة (Aimbot & FOV) - متوافقة مع الجوال
---------------------------------------------------------
local aimbotEnabled = false
local showFovCircle = false
local fovRadius = 150
local aimbotSmoothness = 3
local targetPartName = "Head"

AimbotTab:CreateToggle({
   Name = "تفعيل الايمبوت الذكي",
   CurrentValue = false,
   Flag = "AimbotToggle",
   Callback = function(Value)
      aimbotEnabled = Value
   end,
})

AimbotTab:CreateToggle({
   Name = "إظهار دائرة النطاق (FOV Circle)",
   CurrentValue = false,
   Flag = "FovToggle",
   Callback = function(Value)
      showFovCircle = Value
   end,
})

AimbotTab:CreateSlider({
   Name = "حجم نطاق الايمبوت (FOV)",
   Range = {50, 500},
   Increment = 10,
   Suffix = "حجم",
   CurrentValue = 150,
   Flag = "FovSizeSlider",
   Callback = function(Value)
      fovRadius = Value
   end,
})

AimbotTab:CreateSlider({
   Name = "نعومة حركة الايمبوت (Smoothness)",
   Range = {1, 10},
   Increment = 1,
   Suffix = "نعومة",
   CurrentValue = 3,
   Flag = "SmoothnessSlider",
   Callback = function(Value)
      aimbotSmoothness = Value
   end,
})

-- رسم دائرة الـ FOV وتثبيتها في منتصف الشاشة لتلائم الجوال والكمبيوتر
local fovCircleDraw = Drawing.new("Circle")
fovCircleDraw.Visible = false
fovCircleDraw.Filled = false
fovCircleDraw.Thickness = 2
fovCircleDraw.Color = Color3.fromRGB(0, 255, 150)
fovCircleDraw.Transparency = 1

RunService.RenderStepped:Connect(function()
   local screenCenter = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)

   if showFovCircle then
      fovCircleDraw.Visible = true
      fovCircleDraw.Position = screenCenter
      fovCircleDraw.Radius = fovRadius
   else
      fovCircleDraw.Visible = false
   end

   if aimbotEnabled then
      local closestTarget = nil
      local shortestDist = fovRadius

      for _, player in pairs(Players:GetPlayers()) do
         if player ~= LocalPlayer and player.Character then
            local char = player.Character
            local part = char:FindFirstChild(targetPartName) or char:FindFirstChild("Head")
            local humanoid = char:FindFirstChild("Humanoid")

            if part and humanoid and humanoid.Health > 0 then
               local screenPoint, onScreen = Camera:WorldToViewportPoint(part.Position)
               if onScreen then
                  local dist = (Vector2.new(screenPoint.X, screenPoint.Y) - screenCenter).Magnitude
                  if dist < shortestDist then
                     shortestDist = dist
                     closestTarget = part
                  end
               end
            end
         end
      end

      if closestTarget then
         local targetPos = closestTarget.Position
         if aimbotSmoothness <= 1 then
            Camera.CFrame = CFrame.new(Camera.CFrame.Position, targetPos)
         else
            local currentCF = Camera.CFrame
            local targetCF = CFrame.new(currentCF.Position, targetPos)
            Camera.CFrame = currentCF:Lerp(targetCF, 1 / aimbotSmoothness)
         end
      end
   end
end)

---------------------------------------------------------
-- 4. ميزة الهيت بوكس (Hitbox) - مفصول ومضبوط نهائياً
---------------------------------------------------------
local headHitboxEnabled = false
local headHitboxSize = 10

local bodyHitboxEnabled = false
local bodyHitboxSize = 10

local originalPartSizes = {}

local function restoreOriginalSizes()
    for part, size in pairs(originalPartSizes) do
        if part and part.Parent then
            pcall(function()
                part.Size = size
                part.Transparency = 0
            end)
        end
    end
    originalPartSizes = {}
end

local headToggleObj = nil
local bodyToggleObj = nil

-- 1. هيت بوكس الرأس
headToggleObj = HitboxTab:CreateToggle({
   Name = "تفعيل هيت بوكس الرأس",
   CurrentValue = false,
   Flag = "HeadHitboxToggle",
   Callback = function(Value)
      headHitboxEnabled = Value
      if Value then
         bodyHitboxEnabled = false
         if bodyToggleObj and bodyToggleObj.Set then
            bodyToggleObj:Set(false)
         end
      else
         restoreOriginalSizes()
      end
   end,
})

HitboxTab:CreateSlider({
   Name = "حجم هيت بوكس الرأس",
   Range = {2, 50},
   Increment = 2,
   Suffix = "الحجم",
   CurrentValue = 10,
   Flag = "HeadHitboxSize",
   Callback = function(Value)
      headHitboxSize = Value
   end,
})

-- 2. هيت بوكس الجسم
bodyToggleObj = HitboxTab:CreateToggle({
   Name = "تفعيل هيت بوكس الجسم",
   CurrentValue = false,
   Flag = "BodyHitboxToggle",
   Callback = function(Value)
      bodyHitboxEnabled = Value
      if Value then
         headHitboxEnabled = false
         if headToggleObj and headToggleObj.Set then
            headToggleObj:Set(false)
         end
      else
         restoreOriginalSizes()
      end
   end,
})

HitboxTab:CreateSlider({
   Name = "حجم هيت بوكس الجسم",
   Range = {2, 50},
   Increment = 2,
   Suffix = "الحجم",
   CurrentValue = 10,
   Flag = "BodyHitboxSize",
   Callback = function(Value)
      bodyHitboxSize = Value
   end,
})

-- حلقة الهيت بوكس المحسنة لمنع التعليق
RunService.RenderStepped:Connect(function()
    if headHitboxEnabled or bodyHitboxEnabled then
        for _, player in pairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Character then
                if headHitboxEnabled then
                    local head = player.Character:FindFirstChild("Head")
                    if head then
                        if not originalPartSizes[head] then
                            originalPartSizes[head] = head.Size
                        end
                        head.Size = Vector3.new(headHitboxSize, headHitboxSize, headHitboxSize)
                        head.Transparency = 0.7
                        head.Massless = true
                    end
                elseif bodyHitboxEnabled then
                    for _, part in pairs(player.Character:GetChildren()) do
                        if part:IsA("BasePart") and part.Name ~= "Head" then
                            if not originalPartSizes[part] then
                                originalPartSizes[part] = part.Size
                            end
                            part.Size = Vector3.new(bodyHitboxSize, bodyHitboxSize, bodyHitboxSize)
                            part.Transparency = 0.7
                            part.Massless = true
                        end
                    end
                end
            end
        end
    else
        if next(originalPartSizes) ~= nil then
            restoreOriginalSizes()
        end
    end
end)

---------------------------------------------------------
-- 5. ميزة الجدران الوهمية والأرضية (Ghost Walls)
---------------------------------------------------------
local ghostEnabled = false
local originalStates = {}
local magicFloor = nil
local floorLoop = nil
local initialFloorY = 0

local function IsPlayerCharacter(part)
	for _, player in pairs(Players:GetPlayers()) do
		if player.Character and part:IsDescendantOf(player.Character) then
			return true
		end
	end
	return false
end

GhostTab:CreateToggle({
   Name = "تفعيل Ghost Walls + الأرضية الثابتة",
   Current
