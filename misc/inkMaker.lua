local API = require("api")
local TIMER = require("utilities.timer")

--[[
    Ink Maker
    This script will make regular ink from ashes and vials of water.
    -- Start this script at kili's bank chest with your most recent preset containing all the items you need.
]]
local InkMaker = {
    scriptName = "[NULLOPT] inkMaker",
    state = "IDLE",
    gui = nil,
    ashesId = 592,
    vialsOfWaterId = 227,
    lesserNecroplasmId = 55599,
    bankId = 127271,
    ---@type InterfaceComp5[]
    itemProductionInterfaceIds = {
        InterfaceComp5.new(1371, 7, -1, 0),
        InterfaceComp5.new(1371, 0, -1, 0),
    }
}

function InkMaker:init(gui)
    self.gui = gui
end

function InkMaker:getAshesCount()
    return API.InvItemcount_1(self.ashesId)
end

function InkMaker:getVialsOfWaterCount()
    return API.InvItemcount_1(self.vialsOfWaterId)
end

function InkMaker:getLesserNecroplasmCount()
    local count = API.InvItemcount_1(self.lesserNecroplasmId)
    if count > 0 then
        return API.InvStackSize(self.lesserNecroplasmId)
    else
        return 0
    end
end

function InkMaker:hasAshesAndVialsOfWater()
    local ashesCount = self:getAshesCount()
    local vialsOfWaterCount = self:getVialsOfWaterCount()
    return ashesCount > 0 and vialsOfWaterCount > 0
end

function InkMaker:hasAshesAndVialsOfWaterEqual()
    local ashesCount = self:getAshesCount()
    local vialsOfWaterCount = self:getVialsOfWaterCount()
    return ashesCount == vialsOfWaterCount
end

function InkMaker:isItemProductionInterfacePresent()
    local result = API.ScanForInterfaceTest2Get(true, self.itemProductionInterfaceIds)
    if #result > 0 then
        return true
    else
        return false
    end
end

function InkMaker:makeInk()
    ---@diagnostic disable-next-line: missing-parameter
    API.DoAction_Interface(0xffffffff, 0xffffffff, 0, 1370, 30, -1, API.OFF_ACT_GeneralInterface_Choose_option)
end

function InkMaker:clickLesserNecroplasm()
    API.DoAction_Inventory1(self.lesserNecroplasmId, 0, 1, API.OFF_ACT_GeneralInterface_route)
end

function InkMaker:loadPreset()
    API.DoAction_Object1(0x33, API.OFF_ACT_GeneralObject_route3, { self.bankId }, 50)
end

function InkMaker:getState()
    -- TODO: Implement this
    if self:getLesserNecroplasmCount() < 20 then
        return "NO_LESSER_NECROPLASM"
    end
    if API.isProcessing() then
        return "PROCESSING"
    else
        if self:isItemProductionInterfacePresent() then
            return "ITEM_PRODUCTION_INTERFACE_OPEN"
        end
        if self:hasAshesAndVialsOfWater() then
            if self:hasAshesAndVialsOfWaterEqual() then
                return "CLICK_MAKE_INK"
            else
                return "OUT_OF_ASHES_OR_VIAILS_OF_WATER" -- ??
            end
        else
            return "LOADING_PRESET"
        end
    end
end

function InkMaker:loop()
    self.state = self:getState()

    if TIMER:shouldRunStartsWith("INK_MAKER") then
        if self.state == "NO_LESSER_NECROPLASM" or self.state == "OUT_OF_ASHES_OR_VIAILS_OF_WATER" then
            print("NO_LESSER_NECROPLASM or OUT_OF_ASHES_OR_VIAILS_OF_WATER")
            self.gui.terminate = true
            goto continue
        elseif self.state == "PROCESSING" then
            goto continue
        elseif self.state == "ITEM_PRODUCTION_INTERFACE_OPEN" then
            self:makeInk()
        elseif self.state == "CLICK_MAKE_INK" then
            self:clickLesserNecroplasm()
        elseif self.state == "LOADING_PRESET" then
            self:loadPreset()
        end
        ::continue::
        TIMER:randomThreadedSleep("INK_MAKER", 1200, 1400)
    end
end

return InkMaker
