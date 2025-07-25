-- Variáveis
local player = game.Players.LocalPlayer
local mouse = player:GetMouse()
local flyActive = false
local noclipActive = false
local menuPrincipal
local cheatsMenu
local selectedLanguage = "pt" -- opções: "pt", "en", "ru"
local flyControl = nil
local flyGyro = nil

-- Traduções
local texts = {
    title = { pt = "Sistema de Key", en = "Key System", ru = "Ключевая система" },
    prompt = { pt = "Insira a key: ", en = "Enter key:", ru = "Введите ключ:" },
    submit = { pt = "Enviar", en = "Submit", ru = "Отправить" },
    invalid = { pt = "Key inválida", en = "Invalid key", ru = "Неверный ключ" },
    welcome = { pt = "Bem-vindo ao script!", en = "Welcome to the script!", ru = "Добро пожаловать в скрипт!" },
    fly = { pt = "Fly", en = "Fly", ru = "Полёт" },
    noclip = { pt = "Noclip", en = "Noclip", ru = "Прохождение сквозь стены" },
    fling = { pt = "Fling", en = "Fling", ru = "Флинг" },
    close = { pt = "Fechar", en = "Close", ru = "Закрыть" },
    language = { pt = "Idioma", en = "Language", ru = "Язык" }
}

local function criarFrame(size, pos, color)
    local gui = Instance.new("ScreenGui", game.CoreGui)
    local frame = Instance.new("Frame", gui)
    frame.Size = size
    frame.Position = pos
    frame.BackgroundColor3 = color
    frame.BorderSizePixel = 0
    return frame
end

local function criarBotaoFechar(pai)
    local botao = Instance.new("TextButton", pai)
    botao.Size = UDim2.new(0, 80, 0, 25)
    botao.Position = UDim2.new(1, -85, 0, 5)
    botao.Text = texts.close[selectedLanguage]
    botao.Font = Enum.Font.SourceSansBold
    botao.TextSize = 16
    botao.BackgroundColor3 = Color3.fromRGB(200, 0, 0)
    botao.TextColor3 = Color3.new(1,1,1)
    botao.MouseButton1Click:Connect(function()
        pai:Destroy()
    end)
end

local function abrirMenuCheats()
    cheatsMenu = criarFrame(UDim2.new(0, 300, 0, 180), UDim2.new(0.5, -150, 0.5, -90), Color3.fromRGB(30,30,30))
    criarBotaoFechar(cheatsMenu)

    local botaoFly = Instance.new("TextButton", cheatsMenu)
    botaoFly.Size = UDim2.new(0, 260, 0, 30)
    botaoFly.Position = UDim2.new(0, 20, 0, 20)
    botaoFly.Text = texts.fly[selectedLanguage] .. ": OFF"
    botaoFly.Font = Enum.Font.SourceSansBold
    botaoFly.TextSize = 18
    botaoFly.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
    botaoFly.TextColor3 = Color3.new(1,1,1)

    botaoFly.MouseButton1Click:Connect(function()
        flyActive = not flyActive
        botaoFly.Text = texts.fly[selectedLanguage] .. ": " .. (flyActive and "ON" or "OFF")
        botaoFly.BackgroundColor3 = flyActive and Color3.fromRGB(0,255,0) or Color3.fromRGB(100,100,100)
        if flyActive then startFly() else stopFly() end
    end)

    local botaoNoclip = Instance.new("TextButton", cheatsMenu)
    botaoNoclip.Size = UDim2.new(0,260,0,30)
    botaoNoclip.Position = UDim2.new(0,20,0,60)
    botaoNoclip.Text = texts.noclip[selectedLanguage] .. ": OFF"
    botaoNoclip.Font = Enum.Font.SourceSansBold
    botaoNoclip.TextSize = 18
    botaoNoclip.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
    botaoNoclip.TextColor3 = Color3.new(1,1,1)

    botaoNoclip.MouseButton1Click:Connect(function()
        noclipActive = not noclipActive
        botaoNoclip.Text = texts.noclip[selectedLanguage] .. ": " .. (noclipActive and "ON" or "OFF")
        botaoNoclip.BackgroundColor3 = noclipActive and Color3.fromRGB(0,255,0) or Color3.fromRGB(100,100,100)
    end)

    local botaoFling = Instance.new("TextButton", cheatsMenu)
    botaoFling.Size = UDim2.new(0,260,0,30)
    botaoFling.Position = UDim2.new(0,20,0,100)
    botaoFling.Text = texts.fling[selectedLanguage]
    botaoFling.Font = Enum.Font.SourceSansBold
    botaoFling.TextSize = 18
    botaoFling.BackgroundColor3 = Color3.fromRGB(0, 100, 255)
    botaoFling.TextColor3 = Color3.new(1,1,1)

    botaoFling.MouseButton1Click:Connect(function()
        if not flyActive then
            flyActive = true
            startFly()
            botaoFly.Text = texts.fly[selectedLanguage] .. ": ON"
            botaoFly.BackgroundColor3 = Color3.fromRGB(0,255,0)
        end

        local character = player.Character or player.CharacterAdded:Wait()
        local hrp = character:WaitForChild("HumanoidRootPart")
        local bp = Instance.new("BodyVelocity")
        bp.Velocity = Vector3.new(0,0,0)
        bp.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
        bp.Parent = hrp

        local fling = Instance.new("BodyAngularVelocity")
        fling.AngularVelocity = Vector3.new(0, 9999, 0)
        fling.MaxTorque = Vector3.new(0, math.huge, 0)
        fling.P = math.huge
        fling.Parent = hrp

        botaoFling.Text = texts.fling[selectedLanguage] .. " ON"
        wait(2)
        fling:Destroy()
        bp:Destroy()
        botaoFling.Text = texts.fling[selectedLanguage]
    end)

    game:GetService("RunService").Stepped:Connect(function()
        if noclipActive and player.Character then
            for _, part in pairs(player.Character:GetDescendants()) do
                if part:IsA("BasePart") and part.CanCollide then
                    part.CanCollide = false
                end
            end
        end
    end)
end

local function abrirMenuKeySystem()
    local menu = criarFrame(UDim2.new(0, 320, 0, 180), UDim2.new(0.5, -160, 0.5, -90), Color3.fromRGB(40,40,40))
    criarBotaoFechar(menu)

    local label = Instance.new("TextLabel", menu)
    label.Size = UDim2.new(1, -20, 0, 30)
    label.Position = UDim2.new(0, 10, 0, 10)
    label.Text = texts.prompt[selectedLanguage]
    label.TextColor3 = Color3.new(1,1,1)
    label.BackgroundTransparency = 1
    label.Font = Enum.Font.SourceSans
    label.TextSize = 18

    local input = Instance.new("TextBox", menu)
    input.Size = UDim2.new(1, -20, 0, 30)
    input.Position = UDim2.new(0, 10, 0, 50)
    input.PlaceholderText = "pizza"
    input.Font = Enum.Font.SourceSans
    input.TextSize = 18
    input.Text = ""

    local botao = Instance.new("TextButton", menu)
    botao.Size = UDim2.new(1, -20, 0, 30)
    botao.Position = UDim2.new(0, 10, 0, 90)
    botao.Text = texts.submit[selectedLanguage]
    botao.Font = Enum.Font.SourceSansBold
    botao.TextSize = 18
    botao.BackgroundColor3 = Color3.fromRGB(0, 150, 0)
    botao.TextColor3 = Color3.new(1,1,1)

    local idiomaBtn = Instance.new("TextButton", menu)
    idiomaBtn.Size = UDim2.new(0, 100, 0, 25)
    idiomaBtn.Position = UDim2.new(0, 10, 0, 130)
    idiomaBtn.Text = texts.language[selectedLanguage] .. ": PT"
    idiomaBtn.Font = Enum.Font.SourceSansBold
    idiomaBtn.TextSize = 16
    idiomaBtn.BackgroundColor3 = Color3.fromRGB(100,100,100)
    idiomaBtn.TextColor3 = Color3.new(1,1,1)

    local idiomas = {"pt", "en", "ru"}
    local atual = 1

    idiomaBtn.MouseButton1Click:Connect(function()
        atual = atual % #idiomas + 1
        selectedLanguage = idiomas[atual]
        idiomaBtn.Text = texts.language[selectedLanguage] .. ": " .. idiomas[atual]:upper()
        label.Text = texts.prompt[selectedLanguage]
        botao.Text = texts.submit[selectedLanguage]
    end)

    botao.MouseButton1Click:Connect(function()
        if input.Text:lower() == "pizza" then
            label.Text = texts.welcome[selectedLanguage]
            wait(2)
            menu:Destroy()
            abrirMenuCheats()
        else
            label.Text = texts.invalid[selectedLanguage]
        end
    end)
end

function startFly()
    local char = player.Character or player.CharacterAdded:Wait()
    local hrp = char:WaitForChild("HumanoidRootPart")

    flyControl = Instance.new("BodyVelocity")
    flyControl.Velocity = Vector3.new(0,0,0)
    flyControl.MaxForce = Vector3.new(9e9, 9e9, 9e9)
    flyControl.Parent = hrp

    flyGyro = Instance.new("BodyGyro")
    flyGyro.D = 10
    flyGyro.P = 10000
    flyGyro.MaxTorque = Vector3.new(9e9, 9e9, 9e9)
    flyGyro.CFrame = hrp.CFrame
    flyGyro.Parent = hrp

    coroutine.wrap(function()
        while flyActive do
            wait()
            local camCF = workspace.CurrentCamera.CFrame
            flyControl.Velocity = Vector3.new()
            if UserInputService:IsKeyDown(Enum.KeyCode.W) then flyControl.Velocity = flyControl.Velocity + camCF.LookVector * 100 end
            if UserInputService:IsKeyDown(Enum.KeyCode.S) then flyControl.Velocity = flyControl.Velocity - camCF.LookVector * 100 end
            if UserInputService:IsKeyDown(Enum.KeyCode.A) then flyControl.Velocity = flyControl.Velocity - camCF.RightVector * 100 end
            if UserInputService:IsKeyDown(Enum.KeyCode.D) then flyControl.Velocity = flyControl.Velocity + camCF.RightVector * 100 end
            flyGyro.CFrame = camCF
        end
        flyControl:Destroy()
        flyGyro:Destroy()
    end)()
end

function stopFly()
    flyActive = false
end

local UserInputService = game:GetService("UserInputService")

abrirMenuKeySystem()
