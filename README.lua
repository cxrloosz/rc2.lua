-- rc2 corrigido: carrega após trocar de servidor e nunca fica travado

local SCRIPT_URL = "https://raw.githubusercontent.com/cxrloosz/rc2.lua/refs/heads/main/README.lua"
local MAX_RUNTIME = 120 -- segundos: se passar disso, força o hop

-- Evita rodar duas vezes no mesmo servidor (autoexec + queue)
repeat task.wait() until game:IsLoaded()

-- Sistema de parada (persiste mesmo com a fila do queue_on_teleport)
local STOP_FILE = "rc2_stop.txt"
local function isStopped()
    if getgenv and getgenv().RC2_STOP then return true end
    local ok, exists = pcall(function() return isfile and isfile(STOP_FILE) end)
    return ok and exists == true
end

if isStopped() then
    warn("[RC2] Script parado. Para reativar, apague o arquivo rc2_stop.txt.")
    return
end

-- Trava por servidor: só bloqueia se JÁ rodou NESTE servidor (JobId)
if getgenv then
    if getgenv().RC2_JOB == game.JobId then return end
    getgenv().RC2_JOB = game.JobId
end

local Players = game:GetService("Players")
repeat task.wait() until Players.LocalPlayer
local LocalPlayer = Players.LocalPlayer
local Workspace = game:GetService("Workspace")
local VirtualInputManager = game:GetService("VirtualInputManager")
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")
local UserInputService = game:GetService("UserInputService")

-- Pressione END para parar tudo
local function stopAll()
    if getgenv then getgenv().RC2_STOP = true end
    pcall(function() if writefile then writefile(STOP_FILE, "stop") end end)
    warn("[RC2] PARADO. Nenhum novo hop será feito.")
end
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if not gameProcessed and input.KeyCode == Enum.KeyCode.End then
        stopAll()
    end
end)

-- 1) Enfileira o script ANTES de qualquer coisa
local qf = queue_on_teleport or queueonteleport
    or (syn and syn.queue_on_teleport)
    or (fluxus and fluxus.queue_on_teleport)

local function queueScript()
    if not qf then return end
    pcall(qf, ([[
        repeat task.wait() until game:IsLoaded()
        task.wait(2)
        loadstring(game:HttpGet("%s"))()
    ]]):format(SCRIPT_URL))
end

if qf then
    queueScript()
else
    warn("[RC2] Executor sem queue_on_teleport. Coloque o script na pasta autoexec!")
end

task.wait(2)

local RETURN_CFRAME = CFrame.new(20, 5.83, -28, 0, 0, -1, 1, 0, 0, 0, -1, 0)

-- 2) Server hop robusto
local hopping = false
local function serverHop()
    if hopping or isStopped() then return end
    hopping = true
    print("[RC2] Procurando novo servidor...")

    local candidates = {}
    local cursor = ""
    for _ = 1, 3 do -- até 3 páginas
        local ok, result = pcall(function()
            local url = "https://games.roblox.com/v1/games/" .. game.PlaceId
                .. "/servers/Public?sortOrder=Asc&limit=100"
                .. (cursor ~= "" and ("&cursor=" .. cursor) or "")
            return HttpService:JSONDecode(game:HttpGet(url))
        end)
        if not ok or not result or not result.data then break end
        for _, s in ipairs(result.data) do
            if s.id ~= game.JobId and s.playing < s.maxPlayers - 1 then
                table.insert(candidates, s.id)
            end
        end
        cursor = result.nextPageCursor or ""
        if cursor == "" then break end
    end

    hopping = false
    if isStopped() then return end
    queueScript() -- garante a fila logo antes de sair
    if #candidates > 0 then
        local id = candidates[math.random(#candidates)]
        pcall(TeleportService.TeleportToPlaceInstance, TeleportService, game.PlaceId, id, LocalPlayer)
    else
        pcall(TeleportService.Teleport, TeleportService, game.PlaceId, LocalPlayer)
    end
end

-- 3) Se o teleporte falhar, tenta de novo
TeleportService.TeleportInitFailed:Connect(function(_, _, msg)
    warn("[RC2] Teleporte falhou: " .. tostring(msg))
    task.wait(3)
    serverHop()
end)

-- 4) Failsafe: se travar por qualquer motivo, troca de servidor
task.delay(MAX_RUNTIME, function()
    warn("[RC2] Tempo limite atingido, trocando de servidor.")
    serverHop()
end)

-- ProximityPrompts instantâneos
local function fixPrompt(obj)
    if obj:IsA("ProximityPrompt") then
        obj.HoldDuration = 0
        obj.MaxActivationDistance = 9999
    end
end
for _, obj in ipairs(Workspace:GetDescendants()) do fixPrompt(obj) end
Workspace.DescendantAdded:Connect(fixPrompt)

local function getObjectCFrame(obj)
    if obj:IsA("BasePart") then return obj.CFrame end
    if obj:IsA("Model") then
        return obj.PrimaryPart and obj.PrimaryPart.CFrame or obj:GetPivot()
    end
end

local function forceInteract(target)
    local prompt = target:FindFirstChildWhichIsA("ProximityPrompt", true)
    if prompt then
        fixPrompt(prompt)
        pcall(function() if fireproximityprompt then fireproximityprompt(prompt) end end)
        pcall(function()
            prompt:InputHoldBegin()
            task.wait(0.05)
            prompt:InputHoldEnd()
        end)
    end
    task.wait(0.1)
    VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.E, false, game)
    task.wait(0.2)
    VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.E, false, game)
end

local function getRoot()
    local char = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    return char:WaitForChild("HumanoidRootPart", 10)
end

-- 5) Rotina principal (qualquer falha cai no hop)
task.spawn(function()
    getRoot()

    local terreiro8
    local start = tick()
    while not terreiro8 and tick() - start < 30 do
        terreiro8 = Workspace:FindFirstChild("Terreiro8", true)
        if not terreiro8 then task.wait(0.5) end
    end

    local nests = terreiro8 and terreiro8:FindFirstChild("Nests")
    if not nests then
        warn("[RC2] Terreiro8/Nests não encontrado, trocando de servidor.")
        return serverHop()
    end

    local list = nests:GetChildren()
    print("[RC2] " .. #list .. " Nests encontrados.")

    for i, nest in ipairs(list) do
        if isStopped() then
            warn("[RC2] Rotina interrompida.")
            return
        end
        local cf = getObjectCFrame(nest)
        if cf then
            local root = getRoot()
            if root then root.CFrame = cf + Vector3.new(0, 1.5, 0) end
            task.wait(0.3)
            forceInteract(nest)
            task.wait(0.2)
            root = getRoot()
            if root then root.CFrame = RETURN_CFRAME end
            task.wait(0.6)
        end
    end

    print("[RC2] Finalizado, trocando de servidor...")
    task.wait(1)
    serverHop()
end)
