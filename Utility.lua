-- ============================================
-- UTILITY - Funções Auxiliares
-- ============================================

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")
local CollectionService = game:GetService("CollectionService")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

local Signal = loadstring(game:HttpGet("https://raw.githubusercontent.com/alwayscont/utils/main/Signal.lua"))()
local Maid = loadstring(game:HttpGet("https://raw.githubusercontent.com/alwayscont/utils/main/Maid.lua"))()

local Utility = {}

Utility.onPlayerAdded = Signal.new()
Utility.onCharacterAdded = Signal.new()
Utility.onLocalCharacterAdded = Signal.new()

local playersData = {}

-- ============================================
-- FUNÇÕES AUXILIARES
-- ============================================

function Utility:countTable(t)
    local found = 0
    for i, v in pairs(t) do
        found = found + 1
    end
    return found
end

function Utility:roundVector(vector)
    return Vector3.new(vector.X, 0, vector.Z)
end

function Utility:find(t, callback)
    for i, v in pairs(t) do
        if callback(v, i) then
            return v, i
        end
    end
    return nil
end

function Utility:map(t, callback)
    local ret = {}
    for i, v in pairs(t) do
        local val = callback(v, i)
        if val then
            table.insert(ret, val)
        end
    end
    return ret
end

-- ============================================
-- GERENCIAMENTO DE PLAYERS
-- ============================================

local function onCharacterAdded(player)
    local playerData = playersData[player]
    if not playerData then return end

    local character = player.Character
    if not character then return end

    local localAlive = true
    table.clear(playerData.parts)

    Utility.listenToChildAdded(character, function(obj)
        if obj.Name == "Humanoid" then
            playerData.humanoid = obj
        elseif obj.Name == "HumanoidRootPart" then
            playerData.rootPart = obj
        elseif obj.Name == "Head" then
            playerData.head = obj
        end
    end)

    if player == LocalPlayer then
        Utility.listenToDescendantAdded(character, function(obj)
            if obj:IsA("BasePart") then
                table.insert(playerData.parts, obj)
                local con
                con = obj:GetPropertyChangedSignal("Parent"):Connect(function()
                    if obj.Parent then return end
                    con:Disconnect()
                    table.remove(playerData.parts, table.find(playerData.parts, obj))
                end)
            end
        end)
    end

    local function onPrimaryPartChanged()
        playerData.primaryPart = character.PrimaryPart
        playerData.alive = not not playerData.primaryPart
    end

    local hum = character:WaitForChild("Humanoid", 30)
    playerData.humanoid = hum
    if not playerData.humanoid then
        warn("[Utility] Player is missing humanoid", player.Name)
        return
    end

    character:GetPropertyChangedSignal("PrimaryPart"):Connect(onPrimaryPartChanged)
    if character.PrimaryPart then
        onPrimaryPartChanged()
    end

    playerData.character = character
    playerData.alive = true
    playerData.health = playerData.humanoid.Health
    playerData.maxHealth = playerData.humanoid.MaxHealth

    hum.Destroying:Connect(function()
        playerData.alive = false
        localAlive = false
    end)

    hum.Died:Connect(function()
        playerData.alive = false
        localAlive = false
    end)

    playerData.humanoid:GetPropertyChangedSignal("Health"):Connect(function()
        playerData.health = hum.Health
    end)

    playerData.humanoid:GetPropertyChangedSignal("MaxHealth"):Connect(function()
        playerData.maxHealth = hum.MaxHealth
    end)

    local function fire()
        if not localAlive then return end
        Utility.onCharacterAdded:Fire(playerData)
        if player == LocalPlayer then
            Utility.onLocalCharacterAdded:Fire(playerData)
        end
    end

    fire()
end

local function onPlayerAdded(player)
    local playerData = {
        player = player,
        team = player.Team,
        parts = {}
    }

    playersData[player] = playerData

    task.spawn(onCharacterAdded, player)

    player.CharacterAdded:Connect(function()
        onCharacterAdded(player)
    end)

    player:GetPropertyChangedSignal("Team"):Connect(function()
        playerData.team = player.Team
    end)

    Utility.onPlayerAdded:Fire(player)
end

local function onPlayerRemoving(player)
    playersData[player] = nil
end

for _, player in pairs(Players:GetPlayers()) do
    task.spawn(onPlayerAdded, player)
end

Players.PlayerAdded:Connect(onPlayerAdded)
Players.PlayerRemoving:Connect(onPlayerRemoving)

-- ============================================
-- FUNÇÕES DE UTILIDADE
-- ============================================

function Utility:getPlayerData(player)
    return playersData[player or LocalPlayer] or {}
end

function Utility:getCharacter(player)
    local playerData = self:getPlayerData(player)
    if not playerData.alive then return end
    local maxHealth, health = playerData.maxHealth, playerData.health
    return playerData.character, maxHealth, (health / maxHealth) * 100, math.floor(health), playerData.rootPart
end

function Utility:getRootPart(player)
    local playerData = self:getPlayerData(player)
    return playerData and playerData.rootPart
end

function Utility:isTeamMate(player)
    local playerData = self:getPlayerData(player)
    local myPlayerData = self:getPlayerData()
    return playerData.team and myPlayerData.team and playerData.team == myPlayerData.team
end

-- ============================================
-- LISTENERS
-- ============================================

function Utility.listenToChildAdded(folder, listener, options)
    options = options or {listenToDestroying = false}

    local createListener = typeof(listener) == "table" and listener.new or listener

    local function onChildAdded(child)
        local listenerObject = createListener(child)

        if options.listenToDestroying then
            child.Destroying:Connect(function()
                local removeListener = typeof(listener) == "table" and (listener.Destroy or listener.Remove) or listenerObject
                if typeof(removeListener) == "function" then
                    removeListener(child)
                end
            end)
        end
    end

    for _, child in pairs(folder:GetChildren()) do
        task.spawn(onChildAdded, child)
    end

    return folder.ChildAdded:Connect(onChildAdded)
end

function Utility.listenToChildRemoving(folder, listener)
    local createListener = typeof(listener) == "table" and listener.new or listener
    return folder.ChildRemoved:Connect(createListener)
end

function Utility.listenToDescendantAdded(folder, listener, options)
    options = options or {listenToDestroying = false}

    local createListener = typeof(listener) == "table" and listener.new or listener

    local function onDescendantAdded(child)
        local listenerObject = createListener(child)

        if options.listenToDestroying then
            child.Destroying:Connect(function()
                local removeListener = typeof(listener) == "table" and (listener.Destroy or listener.Remove) or listenerObject
                if typeof(removeListener) == "function" then
                    removeListener(child)
                end
            end)
        end
    end

    for _, child in pairs(folder:GetDescendants()) do
        task.spawn(onDescendantAdded, child)
    end

    return folder.DescendantAdded:Connect(onDescendantAdded)
end

function Utility.listenToDescendantRemoving(folder, listener)
    local createListener = typeof(listener) == "table" and listener.new or listener
    return folder.DescendantRemoving:Connect(createListener)
end

function Utility.listenToTagAdded(tagName, listener)
    for _, v in pairs(CollectionService:GetTagged(tagName)) do
        task.spawn(listener, v)
    end
    return CollectionService:GetInstanceAddedSignal(tagName):Connect(listener)
end

-- ============================================
-- CAST PLAYER (RAYCAST)
-- ============================================

local function castPlayer(origin, direction, rayParams, playerToFind)
    local distanceTravelled = 0

    while true do
        distanceTravelled = distanceTravelled + direction.Magnitude

        local target = workspace:Raycast(origin, direction, rayParams)

        if target then
            if target.Instance:IsDescendantOf(playerToFind) then
                return false
            elseif target.Instance.CanCollide then
                return true
            end
        elseif distanceTravelled > 2000 then
            return false
        end

        origin = origin + direction
    end
end

function Utility:getClosestCharacterWithEntityList(entityList, rayParams, options)
    rayParams = rayParams or RaycastParams.new()
    rayParams.FilterDescendantsInstances = {}

    options = options or {}
    options.maxDistance = options.maxDistance or math.huge

    local myChar = self:getCharacter(LocalPlayer)
    local myHead = myChar and myChar:FindFirstChild("Head")
    if not myHead then return end

    if rayParams.FilterType == Enum.RaycastFilterType.Blacklist then
        table.insert(rayParams.FilterDescendantsInstances, myHead.Parent)
    end

    local camera = workspace.CurrentCamera
    if not camera then return end

    local lastDistance = math.huge
    local lastPlayer = {}

    for _, player in pairs(entityList) do
        if player == myChar then continue end

        local humanoid = player:FindFirstChild("Humanoid")
        if not humanoid or humanoid.Health <= 0 then continue end

        local head = player:FindFirstChild("Head")
        if not head then continue end

        local newDistance = (myHead.Position - head.Position).Magnitude
        if newDistance > lastDistance or newDistance > options.maxDistance then continue end

        local isBehindWall = castPlayer(myHead.Position, (head.Position - myHead.Position).Unit * 100, rayParams, head.Parent)
        if isBehindWall then continue end

        lastPlayer = {Player = player, Character = player, Health = humanoid.Health}
        lastDistance = newDistance
    end

    return lastPlayer, lastDistance
end

return Utility
