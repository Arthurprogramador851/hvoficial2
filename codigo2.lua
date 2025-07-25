local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local gui = Instance.new("ScreenGui")
gui.Name = "KeySystemGUI"
gui.ResetOnSpawn = false
gui.Parent = game.CoreGui

local flyActive = false
local flyConnection
local noclipActive = false

-- Função para criar botão de fechar
local function criarBotaoFechar(parent)
    local close = Instance.new("TextButton", parent)
    close.Size = UDim2.new(0, 25, 0, 25)
    close.Position = UDim2.new(1, -30, 0, 5)
    close.Text = "X"
    close.TextSize = 16
    close.Font = Enum.Font.SourceSansBold
    close.BackgroundColor3 = Color3.fromRGB(170, 0, 0)
    close.TextColor3 = Color3.new(1, 1, 1)
    close.AutoButtonColor = true
    close.MouseButton1Click:Connect(function()
        gui:Destroy()
    end)
end

-- Função para criar frames
local function criarFrame(tamanho, pos, cor)
    local frame = Instance.new("Frame")
    frame.Size = tamanho
    frame.Position = pos
    frame.BackgroundColor3 = cor
    frame.BorderSizePixel = 0
    frame.Parent = gui
    return frame
end

-- Fly antigo
local function startFly()
    if flyActive then return end
    local character = player.Character or player.CharacterAdded:Wait()
    local root = character:WaitForChild("HumanoidRootPart")

    flyActive = true

    local bv = Instance.new("BodyVelocity", root)
    bv.Name = "FlyVelocity"
    bv.Velocity = Vector3.new(0,0,0)
    bv.MaxForce = Vector3.new(1e5,1e5,1e5)

    local bg = Instance.new("BodyGyro", root)
    bg.Name = "FlyGyro"
    bg.MaxTorque = Vector3.new(1e5,1e5,1e5)
    bg.CFrame = workspace.CurrentCamera.CFrame

    flyConnection = RunService.RenderStepped:Connect(function()
        if not flyActive then return end
        local moveVector = Vector3.new()
        if UserInputService:IsKeyDown(Enum.KeyCode.W) then
            moveVector = moveVector + workspace.CurrentCamera.CFrame.LookVector
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.S) then
            moveVector = moveVector - workspace.CurrentCamera.CFrame.LookVector
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.A) then
            moveVector = moveVector - workspace.CurrentCamera.CFrame.RightVector
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.D) then
            moveVector = moveVector + workspace.CurrentCamera.CFrame.RightVector
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
            moveVector = moveVector + Vector3.new(0,1,0)
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then
            moveVector = moveVector - Vector3.new(0,1,0)
        end

        if moveVector.Magnitude > 0 then
            bv.Velocity = moveVector.Unit * 80
        else
            bv.Velocity = Vector3.new(0,0,0)
        end

        bg.CFrame = workspace.CurrentCamera.CFrame
    end)
end

local function stopFly()
    flyActive = false
    if flyConnection then
        flyConnection:Disconnect()
        flyConnection = nil
    end
    local character = player.Character
    if character and character:FindFirstChild("HumanoidRootPart") then
        local root = character.HumanoidRootPart
        local bv = root:FindFirstChild("FlyVelocity")
        if bv then bv:Destroy() end
        local bg = root:FindFirstChild("FlyGyro")
        if bg then bg:Destroy() end
    end
end

-- Noclip toggle
local function noclipToggle()
    noclipActive = not noclipActive
    local character = player.Character
    if character then
        for _, part in pairs(character:GetChildren()) do
            if part:IsA("BasePart") then
                part.CanCollide = not noclipActive
            end
        end
    end
    return noclipActive
end

-- Fling principal (rotaciona e adiciona força para jogar pessoas)
local function fling()
    local character = player.Character or player.CharacterAdded:Wait()
    local hrp = character:WaitForChild("HumanoidRootPart")

    local bp = Instance.new("BodyVelocity")
    bp.MaxForce = Vector3.new(1e5, 1e5, 1e5)
    bp.Velocity = Vector3.new(0,0,0)
    bp.Parent = hrp

    local bav = Instance.new("BodyAngularVelocity")
    bav.MaxTorque = Vector3.new(0, math.huge, 0)
    bav.AngularVelocity = Vector3.new(0, 9999, 0)
    bav.P = 1e4
    bav.Parent = hrp

    wait(2)

    bav:Destroy()
    bp:Destroy()
end

-- Menu de cheats
local function abrirMenuCheats()
    local cheatsMenu = criarFrame(UDim2.new(0,300,0,180), UDim2.new(0.5, -150, 0.5, 60), Color3.fromRGB(35,35,35))
    criarBotaoFechar(cheatsMenu)

    local titulo = Instance.new("TextLabel", cheatsMenu)
    titulo.Size = UDim2.new(1,0,0,30)
    titulo.Text = "Cheats"
    titulo.TextColor3 = Color3.new(1,1,1)
    titulo.BackgroundTransparency = 1
    titulo.Font = Enum.Font.SourceSansBold
    titulo.TextSize = 24

    local botaoFly = Instance.new("TextButton", cheatsMenu)
    botaoFly.Size = UDim2.new(0,120,0,30)
    botaoFly.Position = UDim2.new(0,10,0,50)
    botaoFly.Text = "Fly"
    botaoFly.Font = Enum.Font.SourceSansBold
    botaoFly.TextSize = 18
    botaoFly.BackgroundColor3 = Color3.fromRGB(0,170,0)
    botaoFly.TextColor3 = Color3.new(1,1,1)

    local botaoNoclip = Instance.new("TextButton", cheatsMenu)
    botaoNoclip.Size = UDim2.new(0,120,0,30)
    botaoNoclip.Position = UDim2.new(0,160,0,50)
    botaoNoclip.Text = "Noclip"
    botaoNoclip.Font = Enum.Font.SourceSansBold
    botaoNoclip.TextSize = 18
    botaoNoclip.BackgroundColor3 = Color3.fromRGB(0,170,0)
    botaoNoclip.TextColor3 = Color3.new(1,1,1)

    local botaoFling = Instance.new("TextButton", cheatsMenu)
    botaoFling.Size = UDim2.new(0,260,0,30)
    botaoFling.Position = UDim2.new(0,20,0,100)
    botaoFling.Text = "Fling"
    botaoFling.Font = Enum.Font.SourceSansBold
    botaoFling.TextSize = 18
    botaoFling.BackgroundColor3 = Color3.fromRGB(0, 100, 255)
    botaoFling.TextColor3 = Color3.new(1,1,1)

    botaoFly.MouseButton1Click:Connect(function()
        if flyActive then
            stopFly()
            botaoFly.Text = "Fly"
            botaoFly.BackgroundColor3 = Color3.fromRGB(0,170,0)
        else
            startFly()
            botaoFly.Text = "Fly: ON"
            botaoFly.BackgroundColor3 = Color3.fromRGB(0,255,0)
        end
    end)

    botaoNoclip.MouseButton1Click:Connect(function()
        local ativo = noclipToggle()
        if ativo then
            botaoNoclip.Text = "Noclip: ON"
            botaoNoclip.BackgroundColor3 = Color3.fromRGB(0,255,0)
        else
            botaoNoclip.Text = "Noclip"
            botaoNoclip.BackgroundColor3 = Color3.fromRGB(0,170,0)
        end
    end)

    botaoFling.MouseButton1Click:Connect(function()
        fling()
        botaoFling.Text = "Fling: ON"
        wait(2)
        botaoFling.Text = "Fling"
    end)
end

-- Menu key system
local function abrirMenuKeySystem()
    local frame = criarFrame(UDim2.new(0, 300, 0, 150), UDim2.new(0.5, -150, 0.5, -75), Color3.fromRGB(40,40,40))
    criarBotaoFechar(frame)

    local title = Instance.new("TextLabel", frame)
    title.Size = UDim2.new(1, 0, 0, 30)
    title.Text = "Key System"
    title.TextColor3 = Color3.new(1,1,1)
    title.BackgroundTransparency = 1
    title.Font = Enum.Font.SourceSansBold
    title.TextSize = 24

    local input = Instance.new("TextBox", frame)
    input.Size = UDim2.new(1, -20, 0, 30)
    input.Position = UDim2.new(0, 10, 0, 50)
    input.PlaceholderText = "Digite a key aqui..."
    input.Text = ""
    input.TextSize = 18
    input.Font = Enum.Font.SourceSans
    input.BackgroundColor3 = Color3.fromRGB(70,70,70)
    input.TextColor3 = Color3.new(1,1,1)

    local botao = Instance.new("TextButton", frame)
    botao.Size = UDim2.new(1, -20, 0, 30)
    botao.Position = UDim2.new(0, 10, 0, 90)
    botao.Text = "Verificar"
    botao.TextSize = 18
    botao.Font = Enum.Font.SourceSansBold
    botao.BackgroundColor3 = Color3.fromRGB(0,170,0)
    botao.TextColor3 = Color3.new(1,1,1)

    botao.MouseButton1Click:Connect(function()
        if input.Text:lower() == "pizza" then
            frame:Destroy()
            abrirMenuCheats()
        else
            botao.Text = "Key incorreta!"
            botao.BackgroundColor3 = Color3.fromRGB(170,0,0)
            wait(2)
            botao.Text = "Verificar"
            botao.BackgroundColor3 = Color3.fromRGB(0,170,0)
        end
    end)
end

abrirMenuKeySystem()
