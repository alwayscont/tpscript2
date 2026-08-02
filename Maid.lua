-- refeito apartir do aztup
local Signal = loadstring(game:HttpGet("https://raw.githubusercontent.com/alwayscont/utils/main/Signal.lua"))()

local Maid = {}
Maid.ClassName = "Maid"

--- Cria uma nova instância do Maid
function Maid.new()
    return setmetatable({
        _tasks = {},
        _Signal = Signal  -- Usa o Signal carregado internamente
    }, Maid)
end

--- Verifica se um valor é um Maid
function Maid.isMaid(value)
    return type(value) == "table" and value.ClassName == "Maid"
end

--- Metatabela para acessar propriedades
function Maid.__index(self, index)
    if Maid[index] then
        return Maid[index]
    else
        return self._tasks[index]
    end
end

--- Adiciona ou remove uma tarefa
function Maid:__newindex(index, newTask)
    if Maid[index] ~= nil then
        error(("'%s' é reservado"):format(tostring(index)), 2)
    end

    local tasks = self._tasks
    local oldTask = tasks[index]

    if oldTask == newTask then
        return
    end

    tasks[index] = newTask

    if oldTask then
        self:_CleanTask(oldTask)
    end
end

--- Limpa uma tarefa específica
function Maid:_CleanTask(task)
    local taskType = type(task)
    
    if taskType == "function" then
        task()
    elseif taskType == "table" then
        -- Usa o Signal armazenado internamente
        if self._Signal and self._Signal.isSignal and self._Signal.isSignal(task) then
            task:Destroy()
        elseif task.Destroy then
            task:Destroy()
        elseif task.Remove then
            task:Remove()
        end
    elseif taskType == "thread" then
        task.cancel(task)
    elseif typeof(task) == "RBXScriptConnection" then
        task:Disconnect()
    end
end

--- Adiciona uma tarefa com ID automático
function Maid:GiveTask(task)
    if not task then
        error("Tarefa não pode ser nil ou false", 2)
    end

    local taskId = #self._tasks + 1
    self[taskId] = task
    return taskId
end

--- Limpa todas as tarefas
function Maid:DoCleaning()
    local tasks = self._tasks

    for index, task in pairs(tasks) do
        if typeof(task) == "RBXScriptConnection" then
            tasks[index] = nil
            task:Disconnect()
        end
    end

    local index, taskData = next(tasks)
    while taskData ~= nil do
        tasks[index] = nil
        self:_CleanTask(taskData)
        index, taskData = next(tasks)
    end
end

--- Alias para DoCleaning
Maid.Destroy = Maid.DoCleaning

return Maid
