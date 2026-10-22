local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local VirtualInputManager = game:GetService("VirtualInputManager")
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")

local LocalPlayer = Players.LocalPlayer

-- 1. IMPORTANTE PARA AUTOEXEC: Espera o jogo carregar 100% no novo servidor
repeat task.wait() until game:IsLoaded()
task.wait(2) -- Pequena folga para estabilizar a conexão

-- Aguarda o personagem e o RootPart de forma segura
local character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local rootPart = character:WaitForChild("HumanoidRootPart", 10)
if not rootPart then
    LocalPlayer.CharacterAdded:Wait()
    rootPart = LocalPlayer.Character:WaitForChild("HumanoidRootPart")
end

-- CFrame de entrega/recuo após interagir
local RETURN_CFRAME = CFrame.new(20, 5.82999992, -28, 0, 0, -1, 1, 0, 0, 0, -1, 0)

-- Torna todos os ProximityPrompts instantâneos
local function makePromptsInstant()
    print("[Script] Configurando ProximityPrompts para instantâneo...")
    for _, obj in ipairs(Workspace:GetDescendants()) do
        if obj:IsA("ProximityPrompt") then
            obj.HoldDuration = 0
            obj.MaxActivationDistance = 9999
        end
    end

    Workspace.DescendantAdded:Connect(function(obj)
        if obj:IsA("ProximityPrompt") then
            obj.HoldDuration = 0
            obj.MaxActivationDistance = 9999
        end
    end)
end

makePromptsInstant()

-- Função de Auto Server Hop
local function serverHop()
    print("[ServerHop] Procurando um novo servidor...")
    local success, result = pcall(function()
        local url = "https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Asc&limit=100"
        local response = game:HttpGet(url)
        return HttpService:JSONDecode(response)
    end)

    if success and result and result.data then
        for _, server in ipairs(result.data) do
            if server.playing < server.maxPlayers and server.id ~= game.JobId then
                print("[ServerHop] Entrando no servidor ID: " .. server.id)
                TeleportService:TeleportToPlaceInstance(game.PlaceId, server.id, LocalPlayer)
                return
            end
        end
    end

    print("[ServerHop] Usando método padrão de Teleport...")
    TeleportService:Teleport(game.PlaceId, LocalPlayer)
end

-- Função para encontrar CFrame de um modelo/parte
local function getObjectCFrame(obj)
    if obj:IsA("BasePart") then
        return obj.CFrame
    elseif obj:IsA("Model") then
        if obj.PrimaryPart then
            return obj.PrimaryPart.CFrame
        else
            return obj:GetPivot()
        end
    end
    return nil
end

-- Função para forçar a interação via ProximityPrompt e simulando a tecla "E"
local function forceInteract(targetObj)
    local prompt = targetObj:FindFirstChildOfClass("ProximityPrompt") or targetObj:FindFirstChildWhichIsA("ProximityPrompt", true)
    
    if prompt then
        prompt.HoldDuration = 0
        prompt.MaxActivationDistance = 9999
        
        pcall(function()
            if fireproximityprompt then
                fireproximityprompt(prompt)
            end
        end)
        
        pcall(function()
            prompt:InputHoldBegin()
            task.wait(0.05)
            prompt:InputHoldEnd()
        end)
        
        print("-> ProximityPrompt acionado em: " .. targetObj.Name)
    else
        print("-> Nenhum prompt encontrado. Simulando a tecla 'E' diretamente...")
    end

    task.wait(0.1)
    VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.E, false, game)
    task.wait(0.2)
    VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.E, false, game)
end

-- Loop Principal de Teleporte Instantâneo
task.spawn(function()
    -- Fica tentando encontrar o Terreiro8 até ele carregar completamente no novo servidor
    local terreiro8 = nil
    local startTime = tick()
    
    print("[Script] Aguardando o mapa carregar...")
    while not terreiro8 do
        terreiro8 = Workspace:FindFirstChild("Terreiro8", true)
        if not terreiro8 then
            task.wait(0.5)
            -- Se demorar mais de 15 segundos, evita loop eterno caso o mapa mude
            if tick() - startTime > 15 then
                warn("[Erro] O mapa Terreiro8 demorou muito para carregar!")
                return
            end
        end
    end

    local nestsFolder = terreiro8:FindFirstChild("Nests")
    if not nestsFolder then
        warn("[Erro] Pasta 'Nests' não foi encontrada dentro de Terreiro8!")
        return
    end

    local nestsList = nestsFolder:GetChildren()
    print("[Script] " .. #nestsList .. " Nests encontrados. Iniciando rotina...")

    for i, nest in ipairs(nestsList) do
        local nestCF = getObjectCFrame(nest)
        
        if nestCF then
            print(string.format("[%d/%d] Teleportando para %s...", i, #nestsList, nest.Name))
            
            -- Atualiza a referência do rootPart caso tenha resetado
            local char = LocalPlayer.Character
            local rPart = char and char:FindFirstChild("HumanoidRootPart")
            if rPart then
                rPart.CFrame = nestCF + Vector3.new(0, 1.5, 0)
            end
            
            task.wait(0.3)
            forceInteract(nest)
            task.wait(0.2)
            
            local charAfter = LocalPlayer.Character
            local rPartAfter = charAfter and charAfter:FindFirstChild("HumanoidRootPart")
            if rPartAfter then
                print("-> Retornando para a coordenada indicada...")
                rPartAfter.CFrame = RETURN_CFRAME
            end
            task.wait(0.6)
        end
    end

    print("[Script] Processo de todos os Nests finalizado! Iniciando Server Hop...")
    task.wait(1)
    serverHop()
end)
