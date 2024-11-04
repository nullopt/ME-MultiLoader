local Timer = {
    timers = {}
}

function Timer:getTimerCount()
    -- loop through all the timers and count how many there are
    local count = 0
    for _, _ in pairs(self.timers) do
        count = count + 1
    end
    return count
end

function Timer:shouldRun(name)
    if not self.timers[name] then
        return true
    end
    return os.clock() >= self.timers[name]
end

function Timer:shouldRunStartsWith(name)
    -- should run if none of the timers that start with the given name are shouldRun
    for timerName, _ in pairs(self.timers) do
        if string.find(timerName, name) and not self:shouldRun(timerName) then
            return false
        end
    end
    return true
end

function Timer:shouldRunWithBaseDelay(name, baseDelay)
    if not self.timers[name] then
        self:createSleep(name, baseDelay)
        return false
    end
    return os.clock() >= self.timers[name]
end

function Timer:shouldRunWithRandomBaseDelay(name, minMs, maxMs)
    if not self.timers[name] then
        self:randomThreadedSleep(name, minMs, maxMs)
        return false
    end
    return os.clock() >= self.timers[name]
end

function Timer:randomThreadedSleep(name, minMs, maxMs)
    local randomDuration = math.random(minMs, maxMs)
    return self:createSleep(name, randomDuration)
end

function Timer:createSleep(name, duration)
    duration = duration / 1000
    local time = os.clock() + duration
    self.timers[name] = time
    return time
end

return Timer
