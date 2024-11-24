local API = require("api")
local TIMER = require("utilities.timer")
local EVENTS = require("ME-EventSystem.events")

--[[
    Wilderness Agility
    This script will run the wilderness agility course.
    Start it near the pipe.
    -- Uses the event system to manage the state of the script [BETA]
    -- TODO: handle eating when low hp
    -- TODO: handle auto-world hop if pkers nearby
]]
local WILDERNESS_AGILITY = {
    scriptName = "[NULLOPT] Wilderness Agility",
    state = "IDLE",
    ---@type GUI
    gui = nil,
    courseStep = 1,
    previousAnimationId = nil,
    ladderId = 32015,
    pipeAnimationCount = 0,
    steppingStonesAnimationCount = 0,
    obstaclesIds = {
        [1] = 65362, -- pipe
        [2] = 64696, -- rope swing
        [3] = 64699, -- stepping stones
        [4] = 64698, -- log balance
        [5] = 65734, -- cliff
    },
    stepDelays = {
        [1] = 0,
        [2] = 0,
        [3] = 0,
        [4] = 4200,
        [5] = 0,
    },
    successAnimationIds = {
        [1] = 10580, -- x2
        [2] = 751,
        [3] = 741,   -- x6
        [4] = 9908,
        [5] = 3378,
    },
    failureAnimationIds = {
        [1] = 0,
        [2] = 18353, -- check
        [3] = 764,
        [4] = 764,
        [5] = 0,
    },
    failureResetLocations = {
        [2] = WPOINT.new(3005, 3953, 0), -- rope swing
        [4] = WPOINT.new(3002, 3945, 0), -- log balance
    },
    miscAnimationIds = {
        CLIMB_LADDER = 828, -- climb ladder
    },
}

function WILDERNESS_AGILITY:init(gui)
    self.gui = gui
    -- subscribe to player animation change
    EVENTS:subscribe(EVENTS.events.onPlayerAnimationChange, function(player, animationId)
        self:onPlayerAnimationChange(player, animationId)
    end)

    print("Wilderness Agility loaded")

    -- start the script by clicking on the pipe
    API.DoAction_Object1(0xb5, API.OFF_ACT_GeneralObject_route0, { self.obstaclesIds[1] }, 50)
end

function WILDERNESS_AGILITY:unload()
    EVENTS:unsubscribe(EVENTS.events.onPlayerAnimationChange)
    print("Wilderness Agility unloaded")
end

---@param player AllObject
---@param animationId number
function WILDERNESS_AGILITY:onPlayerAnimationChange(player, animationId)
    if player.Name ~= API.GetLocalPlayerName() then
        -- not our player, ignore
        return
    end

    if animationId == self.failureAnimationIds[self.courseStep] then
        self:handleFailure()
        -- stop the script accidentally moving on to the next step
        self.previousAnimationId = nil
        return
    end

    -- handle climb ladder
    if animationId == self.miscAnimationIds.CLIMB_LADDER then
        TIMER:scheduleTask("NEXT_STEP", self:getFailureDelay(), function()
            API.DoAction_WalkerW(self.failureResetLocations[self.courseStep])
            API.WaitUntilMovingEnds(5, 5) -- hacky way to wait until we are at the rope swing
            API.DoAction_Object1(0xb5, API.OFF_ACT_GeneralObject_route0, { self.obstaclesIds[self.courseStep] }, 50)
        end)
        return
    end

    if animationId == self.successAnimationIds[self.courseStep] then
        self:handleSuccess(animationId)
        return
    end

    if animationId == -1 then
        -- check if the previous animation was a success animation
        if self.previousAnimationId == self.successAnimationIds[self.courseStep] then
            self.previousAnimationId = nil
            print("Success animation for step " .. self.courseStep)
            -- move on to the next course step
            TIMER:scheduleTask("NEXT_STEP", self:getStepDelay(), function()
                self.courseStep = (self.courseStep % 5) + 1
                print("Moving to step " .. self.courseStep)
                API.DoAction_Object1(0xb5, API.OFF_ACT_GeneralObject_route0, { self.obstaclesIds[self.courseStep] }, 50)
            end)
        end
        return
    end
end

function WILDERNESS_AGILITY:handleSuccess(animationId)
    if animationId == self.successAnimationIds[self.courseStep] then
        -- handle 2x animation for pipe
        if self.courseStep == 1 then
            self.pipeAnimationCount = self.pipeAnimationCount + 1
            if self.pipeAnimationCount == 2 then
                -- reset the animation count for the next lap
                self.pipeAnimationCount = 0
            else
                return
            end
        end

        if self.courseStep == 3 then
            self.steppingStonesAnimationCount = self.steppingStonesAnimationCount + 1
            if self.steppingStonesAnimationCount == 6 then
                -- reset the animation count for the next lap
                self.steppingStonesAnimationCount = 0
            else
                return
            end
        end

        -- set the previous animation id, so we can check if the next animation is a success animation
        self.previousAnimationId = animationId
    end
end

function WILDERNESS_AGILITY:handleFailure()
    print("Failed step " .. self.courseStep)
    -- 2 and 4 send us down to the pit, so handle it here
    if self.courseStep == 2 or self.courseStep == 4 then
        TIMER:scheduleTask("CLIMB_LADDER", self:getFailureDelay(), function()
            API.DoAction_Object1(0x34, API.OFF_ACT_GeneralObject_route0, { self.ladderId }, 50)
        end)
    end

    if self.courseStep == 3 then
        self.steppingStonesAnimationCount = 0
        TIMER:scheduleTask("NEXT_STEP", self:getFailureDelay(), function()
            API.DoAction_Object1(0xb5, API.OFF_ACT_GeneralObject_route0, { self.obstaclesIds[self.courseStep] }, 50)
        end)
    end
end

function WILDERNESS_AGILITY:getStepDelay()
    local randomDelay = math.random(0, 1200) -- 0 - 2 ticks
    return self.stepDelays[self.courseStep] + randomDelay
end

function WILDERNESS_AGILITY:getFailureDelay()
    local randomDelay = math.random(1200, 2400) -- 1 - 3 ticks
    return randomDelay
end

return WILDERNESS_AGILITY
