-- Biblioteca Orion
local OrionLib = loadstring(game:HttpGet(('https://raw.githubusercontent.com/shlexware/Orion/main/source')))()

local Window = OrionLib:MakeWindow({
    Name = "Custom Hub",
    HidePremium = false,
    SaveConfig = true,
    ConfigFolder = "CustomHubConfig"
})

-- Variáveis para controle dos toggles
local toggles = {
    pesca = false,
    esquerdaDireto = false,
    venda = false
}

-- Função para o Toggle Pesca
local function onPescaToggle(state)
    toggles.pesca = state
    if state then
        print("Pesca Ligada!")
        task.spawn(function()
            while toggles.pesca do
                local args = {
                    [1] = {
                        ["HitPosition"] = Vector3.new(2245.875, -5.974999904632568, -739.1121215820312)
                    }
                }
                game:GetService("ReplicatedStorage").Events.Tools.Charge:FireServer(unpack(args))
                wait(1)
                
                local args = {
                    [1] = {
                        ["Alpha"] = 0.9997050762176514,
                        ["ResponseTime"] = 1.3669916990038473
                    }
                }
                game:GetService("ReplicatedStorage").Events.Tools.Attack:FireServer(unpack(args))
                wait(15)
            end
        end)
    else
        print("Pesca Desligada!")
    end
end

-- Função para o Toggle Esquerda Direto
local function onEsquerdaDiretoToggle(state)
    toggles.esquerdaDireto = state
    if state then
        print("Esquerda Direto Ligado!")
        task.spawn(function()
            while toggles.esquerdaDireto do
                local args = {
                    [1] = {
                        ["Side"] = "Right"
                    }
                }
                game:GetService("ReplicatedStorage").Events.Tools.ChangeFishPull:FireServer(unpack(args))
                wait(0.1)

                local args = {
                    [1] = {
                        ["Side"] = "Right"
                    }
                }
                game:GetService("ReplicatedStorage").Events.Tools.ChangeFishPull:FireServer(unpack(args))
                wait(0.1)

                local args = {
                    [1] = {
                        ["Side"] = "Right"
                    }
                }
                game:GetService("ReplicatedStorage").Events.Tools.ChangeFishPull:FireServer(unpack(args))
                wait(0.1)

                local args = {
                    [1] = {
                        ["Side"] = "Right"
                    }
                }
                game:GetService("ReplicatedStorage").Events.Tools.ChangeFishPull:FireServer(unpack(args))
                wait(0.1)

                local args = {
                    [1] = {
                        ["Side"] = "Right"
                    }
                }
                game:GetService("ReplicatedStorage").Events.Tools.ChangeFishPull:FireServer(unpack(args))
                wait(0.1)

                local args = {
                    [1] = {
                        ["Side"] = "Right"
                    }
                }
                game:GetService("ReplicatedStorage").Events.Tools.ChangeFishPull:FireServer(unpack(args))
                wait(0.1)

                local args = {
                    [1] = {
                        ["Side"] = "Left"
                    }
                }
                game:GetService("ReplicatedStorage").Events.Tools.ChangeFishPull:FireServer(unpack(args))
                wait(0.1)

                local args = {
                    [1] = {
                        ["Side"] = "Left"
                    }
                }
                game:GetService("ReplicatedStorage").Events.Tools.ChangeFishPull:FireServer(unpack(args))
                wait(0.1)

                local args = {
                    [1] = {
                        ["Side"] = "Left"
                    }
                }
                game:GetService("ReplicatedStorage").Events.Tools.ChangeFishPull:FireServer(unpack(args))
                wait(0.1)

                local args = {
                    [1] = {
                        ["Side"] = "Left"
                    }
                }
                game:GetService("ReplicatedStorage").Events.Tools.ChangeFishPull:FireServer(unpack(args))
                wait(0.1)

                local args = {
                    [1] = {
                        ["Side"] = "Left"
                    }
                }
                game:GetService("ReplicatedStorage").Events.Tools.ChangeFishPull:FireServer(unpack(args))
                wait(0.1)

                local args = {
                    [1] = {
                        ["Side"] = "Left"
                    }
                }
                game:GetService("ReplicatedStorage").Events.Tools.ChangeFishPull:FireServer(unpack(args))
                wait(0.1)
            end
        end)
    else
        print("Esquerda Direto Desligado!")
    end
end

-- Função para o Toggle Venda
local function onVendaToggle(state)
    toggles.venda = state
    if state then
        print("Venda Ligada!")
        task.spawn(function()
            while toggles.venda do
                local args = {
                    [1] = "Deal",
                    [2] = 1
                }
                workspace.Map.Structures.Nautic_Sellary.TalkPart.Interact:FireServer(unpack(args))
                wait(10)
            end
        end)
    else
        print("Venda Desligada!")
    end
end

-- Aba Principal
local Tab = Window:MakeTab({
    Name = "Script",
    Icon = "rbxassetid://4483345998",
    PremiumOnly = false
})

-- Toggles
Tab:AddToggle({
    Name = "Pesca",
    Default = false,
    Callback = onPescaToggle
})

Tab:AddToggle({
    Name = "Esquerda Direto",
    Default = false,
    Callback = onEsquerdaDiretoToggle
})

Tab:AddToggle({
    Name = "Venda",
    Default = false,
    Callback = onVendaToggle
})

-- Inicializa a GUI
OrionLib:Init()

