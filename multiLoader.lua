--[[
    This script is used to load multiple scripts at once.
]]

local SCRIPT_MAP = require("scriptMap")

local API = require("api")
local GUI = require("ui.gui")
local TIMER = require("utilities.timer")

---@class ScriptClass
---@field scriptName string
---@field state string
---@field gui GUI
---@field init function(gui: GUI)
---@field draw function()
---@field loop function()
local ScriptClass = {}

---@class MultiLoader
---@field loopDelay number
---@field loadedScripts table<string, ScriptClass>
---@field gui GUI
local MultiLoader = {
    loopDelay = 1,
    ---@type table<string, ScriptClass>
    loadedScripts = {},
    gui = GUI
}

---@return nil
function MultiLoader:initGui()
    self.gui:init()
    self.gui:AddBackground("Background", 1.5, 1, ImColor.new(15, 13, 18))
    self.gui:AddLabel("MultiLoader_TITLE", "Nullopt - MultiLoader", ImColor.new(255, 255, 255))
    self.gui:AddCheckbox("MultiLoader_HIDE_SCRIPTS", "Hide Scripts")

    local categories = {}
    for key in pairs(SCRIPT_MAP) do
        table.insert(categories, key)
    end
    table.sort(categories)
    -- a lot of sorting because of the way lua handles tables
    for _, category in ipairs(categories) do
        self.gui:AddLabel("MultiLoader_CATEGORY_" .. category, category, ImColor.new(0, 255, 0))
        local scriptNames = {}
        for scriptName, _ in pairs(SCRIPT_MAP[category]) do
            table.insert(scriptNames, scriptName)
        end
        table.sort(scriptNames)
        for _, scriptName in ipairs(scriptNames) do
            self.gui:AddCheckbox("MultiLoader_SCRIPT_" .. scriptName, scriptName)
        end
    end
end

---@param loadedScriptName string
---@return string | nil
function MultiLoader:getScriptPathFromName(loadedScriptName)
    for _, scripts in pairs(SCRIPT_MAP) do
        for scriptName, scriptPath in pairs(scripts) do
            if scriptName == loadedScriptName then
                return scriptPath
            end
        end
    end
    return nil
end

---@return nil
function MultiLoader:drawLoop()
    -- loop through all the gui components and set their visibility based on the checkbox
    local hideScripts = self.gui:GetComponentValue("MultiLoader_HIDE_SCRIPTS") == true
    for _, component in pairs(self.gui.uiComponents) do
        local name = component[1]
        if string.find(name, "MultiLoader_SCRIPT_") or string.find(name, "MultiLoader_CATEGORY_") then
            self.gui:SetComponentVisibility(name, hideScripts)
        end
    end
    self.gui:Draw()

    -- loop through all the loaded scripts and call their draw function
    for _, loadedScript in pairs(MultiLoader.loadedScripts) do
        if loadedScript.draw then
            loadedScript:draw()
        end
    end
end

---@return nil
function MultiLoader:loadScripts()
    -- loop through all the gui components and load the scripts that are checked
    for _, component in pairs(self.gui.uiComponents) do
        local name = component[1]
        if string.find(name, "MultiLoader_SCRIPT_") then
            -- get the script name from the checkbox name
            local scriptName = string.sub(name, 20)
            local scriptPath = MultiLoader:getScriptPathFromName(scriptName)
            if scriptPath then
                -- check if the script is already loaded
                local alreadyLoaded = package.loaded[scriptPath] ~= nil
                if not self.gui:GetComponentValue(name) then
                    -- check if the script is already loaded
                    if alreadyLoaded then
                        -- unload the script
                        print("Unloading " .. scriptName)
                        MultiLoader.loadedScripts[scriptName] = nil
                        package.loaded[scriptPath] = nil
                        _G[scriptPath] = nil
                    end
                    goto continue
                end
                if not alreadyLoaded then
                    -- load the script
                    print("Loading " .. scriptName)
                    MultiLoader.loadedScripts[scriptName] = require(scriptPath)
                    -- init the script
                    MultiLoader.loadedScripts[scriptName]:init(self.gui)
                end
            end
        end
        ::continue::
    end
end

if API.Read_LoopyLoop() then
    -- init the gui
    MultiLoader:initGui()
    while API.Read_LoopyLoop() do
        --[[
            TODO: handle termination from the gui.
            it should check what script called the termination and then unload it.
        ]]
        -- draw the gui - runs every 10ms
        if TIMER:shouldRun("DRAW_GUI_LOOP") then
            MultiLoader:drawLoop()
            TIMER:createSleep("DRAW_GUI_LOOP", 10 / MultiLoader.loopDelay)
        end

        -- check what scripts to load from the checkbox values - runs every 100ms
        if TIMER:shouldRun("LOAD_SCRIPTS_LOOP") then
            MultiLoader:loadScripts()
            TIMER:createSleep("LOAD_SCRIPTS_LOOP", 1000 / MultiLoader.loopDelay)
        end

        -- loop through all the loaded scripts and call their loop function
        if TIMER:shouldRun("SCRIPT_LOOP") then
            for _, loadedScript in pairs(MultiLoader.loadedScripts) do
                if loadedScript.loop then
                    loadedScript:loop()
                end
            end
            TIMER:createSleep("SCRIPT_LOOP", 100 / MultiLoader.loopDelay)
        end

        -- 1ms sleep - adjust this to reduce cpu usage
        -- but know that the other timers will be affected
        API.RandomSleep2(MultiLoader.loopDelay, 0, 0)
    end
end

return MultiLoader
