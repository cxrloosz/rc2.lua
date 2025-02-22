-- Biblioteca Fluent
local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()

local Window =
    Fluent:CreateWindow(
    {
        Title = "Fishing Hub " .. Fluent.Version,
        TabWidth = 160,
        Size = UDim2.fromOffset(580, 460),
        Theme = "Dark"
    }
)

local Tabs = {
    Main = Window:AddTab({Title = "Script"}),
    Settings = Window:AddTab({Title = "Settings", Icon = "settings"})
}

-- Descrição
Tabs.Main:AddParagraph({Title = "Fishing Hub", Content = "Automatize sua pesca!"})

-- Variáveis para controle dos loops
local toggles = {
    pesca = false,
    esquerdaDireita = false,
    venda = false
}

-- Funções das ações
local function pescaAction()
    while toggles.pesca and task.wait(0) do
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
end

local function esquerdaDireitaAction()
    while toggles.esquerdaDireita and task.wait(0) do
        local sides = {"Right", "Right", "Right", "Right", "Right", "Right", "Left", "Left", "Left", "Left", "Left", "Left"}
        for _, side in ipairs(sides) do
            local args = {
                [1] = {
                    ["Side"] = side
                }
            }
            game:GetService("ReplicatedStorage").Events.Tools.ChangeFishPull:FireServer(unpack(args))
            wait(0.1)
        end
    end
end

local function vendaAction()
    while toggles.venda and task.wait(10) do
        local args = {
            [1] = "Deal",
            [2] = 1
        }
        workspace.Map.Structures.Nautic_Sellary.TalkPart.Interact:FireServer(unpack(args))
    end
end

-- Função para criar toggles
local function createToggle(id, title, description)
    return Tabs.Main:AddToggle(
        id,
        {
            Title = title,
            Description = description,
            Default = false,
            Callback = function(state)
                toggles[id] = state
                print(title .. (state and " Ligado!" or " Desligado!"))
                if state then
                    task.spawn(
                        function()
                            if id == "pesca" then
                                pescaAction()
                            elseif id == "esquerdaDireita" then
                                esquerdaDireitaAction()
                            elseif id == "venda" then
                                vendaAction()
                            end
                        end
                    )
                end
            end
        }
    )
end

-- Criando os toggles
createToggle("pesca", "Pesca", "Liga/desliga a pesca automática")
createToggle("esquerdaDireita", "Esquerda Direita", "Liga/desliga o movimento de esquerda e direita")
createToggle("venda", "Venda", "Liga/desliga a venda automática de peixes")
