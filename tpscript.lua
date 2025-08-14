-- Criação da UI
local ScreenGui = Instance.new("ScreenGui")
local Frame = Instance.new("Frame")
local Button1 = Instance.new("TextButton") -- ESDEATH
local Button2 = Instance.new("TextButton") -- AKAINU
local Button3 = Instance.new("TextButton") -- FREEZA
local CloseButton = Instance.new("TextButton") -- Botão para fechar a UI

-- Configurações do ScreenGui
ScreenGui.Parent = game.Players.LocalPlayer:WaitForChild("PlayerGui")

-- Configurações do Frame
Frame.Parent = ScreenGui
Frame.Size = UDim2.new(0.3, 0, 0.5, 0)
Frame.Position = UDim2.new(0.35, 0, 0.25, 0)
Frame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)

-- Configurações do Botão 1 (ESDEATH)
Button1.Parent = Frame
Button1.Size = UDim2.new(1, 0, 0.2, 0)
Button1.Position = UDim2.new(0, 0, 0, 0)
Button1.Text = "ESDEATH"
Button1.BackgroundColor3 = Color3.fromRGB(0, 170, 255)

-- Configurações do Botão 2 (AKAINU)
Button2.Parent = Frame
Button2.Size = UDim2.new(1, 0, 0.2, 0)
Button2.Position = UDim2.new(0, 0, 0.25, 0)
Button2.Text = "AKAINU"
Button2.BackgroundColor3 = Color3.fromRGB(255, 0, 0)

-- Configurações do Botão 3 (FREEZA)
Button3.Parent = Frame
Button3.Size = UDim2.new(1, 0, 0.2, 0)
Button3.Position = UDim2.new(0, 0, 0.5, 0)
Button3.Text = "FREEZA"
Button3.BackgroundColor3 = Color3.fromRGB(255, 255, 0)

-- Configurações do Botão de Fechar
CloseButton.Parent = Frame
CloseButton.Size = UDim2.new(1, 0, 0.2, 0)
CloseButton.Position = UDim2.new(0, 0, 0.75, 0)
CloseButton.Text = "FECHAR"
CloseButton.BackgroundColor3 = Color3.fromRGB(255, 100, 100)

-- Função para teletransportar o jogador
function teleportPlayer(player, newPosition)
    -- Teleporta o jogador para a nova posição
    player.Character.HumanoidRootPart.CFrame = CFrame.new(newPosition)
end

-- Função para o botão FREEZA
Button3.MouseButton1Click:Connect(function()
    local player = game.Players.LocalPlayer -- Obtém o jogador local
    local newPosition = Vector3.new(557.6903686523438, 229.95848083496094, 380.848388671875) -- Define a nova posição para FREEZA
    teleportPlayer(player, newPosition) -- Chama a função para teletransportar
end)

-- Função para o botão AKAINU
Button2.MouseButton1Click:Connect(function()
    local player = game.Players.LocalPlayer -- Obtém o jogador local
    local newPosition = Vector3.new(422.55010986328125, 229.95848083496094, 463.5858459472656) -- Define a nova posição para AKAINU
    teleportPlayer(player, newPosition) -- Chama a função para teletransportar
end)

-- Função para o botão ESDEATH
Button1.MouseButton1Click:Connect(function()
    local player = game.Players.LocalPlayer -- Obtém o jogador local
    local newPosition = Vector3.new(261.3486633300781, 229.95848083496094, 457.2412719726562) -- Define a nova posição para ESDEATH
    teleportPlayer(player, newPosition) -- Chama a função para teletransportar
end)

-- Função para fechar a UI
CloseButton.MouseButton1Click:Connect(function()
    ScreenGui:Destroy() -- Destroi o ScreenGui, fechando a UI permanentemente
end)
