-- ==========================================
-- UNIFIED RO-GHOUL KAJIRI BOSS FARM HUB
-- ==========================================

-- 1. Create the Visual GUI Interface
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- Wait for the PlayerGui container to safely load into the game instance
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "RoGhoulKajiriHub"
ScreenGui.ResetOnSpawn = false -- Crucial: This keeps your GUI on screen if you die!
ScreenGui.Parent = PlayerGui

local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 300, 0, 180)
MainFrame.Position = UDim2.new(0.5, -150, 0.5, -90)
MainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui

local TitleLabel = Instance.new("TextLabel")
TitleLabel.Size = UDim2.new(1, 0, 0, 40)
TitleLabel.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
TitleLabel.Text = "   Kajiri Gyakusatsu Farm"
TitleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
TitleLabel.Font = Enum.Font.SourceSansBold
TitleLabel.TextSize = 16
TitleLabel.Parent = MainFrame

local CloseButton = Instance.new("TextButton")
CloseButton.Name = "CloseButton"
CloseButton.Size = UDim2.new(0, 30, 0, 30)
CloseButton.Position = UDim2.new(1, -35, 0, 5)
CloseButton.BackgroundColor3 = Color3.fromRGB(60, 30, 30)
CloseButton.Text = "X"
CloseButton.TextColor3 = Color3.fromRGB(255, 100, 100)
CloseButton.Font = Enum.Font.SourceSansBold
CloseButton.TextSize = 14
CloseButton.Parent = MainFrame

local ToggleButton = Instance.new("TextButton")
ToggleButton.Size = UDim2.new(0, 260, 0, 50)
ToggleButton.Position = UDim2.new(0, 20, 0, 70)
ToggleButton.BackgroundColor3 = Color3.fromRGB(180, 50, 50)
ToggleButton.Text = "Farm Status: INACTIVE"
ToggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
ToggleButton.Font = Enum.Font.SourceSansBold
ToggleButton.TextSize = 16
ToggleButton.Parent = MainFrame

-- 2. State & Core Logic Setup
_G.CustomFarm = false
local TweenService = game:GetService("TweenService")

local AttackPositions = {
    CFrame.new(0, 16, -12), 
    CFrame.new(16, 14, 0),  
    CFrame.new(-16, 14, 0), 
    CFrame.new(0, 18, 16)   
}
local currentPositionIndex = 1

local function isFSkillReady()
    local folder = LocalPlayer:FindFirstChild("PlayerFolder")
    if folder and folder:FindFirstChild("Special3CD") then
        return folder.Special3CD.Value == 0
    end
    return false
end

local function moveToCoord(targetCFrame)
    local char = LocalPlayer.Character
    if char and char:FindFirstChild("HumanoidRootPart") then
        local tweenInfo = TweenInfo.new(0.4, Enum.EasingStyle.Linear)
        local tween = TweenService:Create(char.HumanoidRootPart, tweenInfo, {CFrame = targetCFrame})
        tween:Play()
        tween.Completed:Wait()
    end
end

-- Close GUI Event Handler
CloseButton.MouseButton1Click:Connect(function()
    _G.CustomFarm = false 
    ScreenGui:Destroy() 
end)

-- 3. Toggle Activation Handling
ToggleButton.MouseButton1Click:Connect(function()
    _G.CustomFarm = not _G.CustomFarm
    
    if _G.CustomFarm then
        ToggleButton.BackgroundColor3 = Color3.fromRGB(50, 180, 50)
        ToggleButton.Text = "Farm Status: ACTIVE"
        
        task.spawn(function()
            while _G.CustomFarm do
                task.wait(0.1)
                
                local boss = workspace:FindFirstChild("Gyakusatsu") or workspace:FindFirstChild("Gaku Katsu")
                if boss and boss:FindFirstChild("Humanoid") and boss.Humanoid.Health > 0 and boss:FindFirstChild("HumanoidRootPart") then
                    
                    local selectedOffset = AttackPositions[currentPositionIndex]
                    local targetFlyCoord = boss.HumanoidRootPart.CFrame * selectedOffset
                    moveToCoord(targetFlyCoord)
                    
                    local quinque = LocalPlayer.Backpack:FindFirstChild("Kajiri") or LocalPlayer.Character:FindFirstChild("Kajiri")
                    if quinque then
                        if quinque.Parent == LocalPlayer.Backpack then
                            LocalPlayer.Character.Humanoid:EquipTool(quinque)
                        end
                        
                        if isFSkillReady() then
                            quinque:Activate()
                            task.wait(0.5) 
                            
                            currentPositionIndex = currentPositionIndex + 1
                            if currentPositionIndex > #AttackPositions then
                                currentPositionIndex = 1
                            end
                        end
                    end
                else
                    task.wait(1) 
                end
            end
        end)
    else
        ToggleButton.BackgroundColor3 = Color3.fromRGB(180, 50, 50)
        ToggleButton.Text = "Farm Status: INACTIVE"
    end
end)
