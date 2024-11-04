local API = require("api")
local TIMER = require("utilities.timer")

--[[
    Fungus Ash Generator
    This script will pick glowing fungus in the haunted mine and drop it.
    It will then loot all the ashes that drop.
    -- Use the Underworld Grimoire 1+ to auto bank the ashes
]]
local AshGenerator = {
    scriptName = "[NULLOPT] Fungus Ash Generator",
    ---@type GUI
    gui = nil,
    counterControl = nil,
    state = "IDLE",
    ashesGenerated = 0,
    fungusObjectId = { 4933 },
    fungusObjectLocation = WPOINT.new(2781, 4488, 0),
    fungusId = { 4075 },
    ashId = { 592 },
    dropKey = '-', -- '-'
}

function AshGenerator:init(gui)
    self.gui = gui
    self.gui:AddLabel("ASHES_GENERATED_LABEL", "Ash Generated", ImColor.new(255, 255, 255))
    print("Fungus Ash Generator initialized.")
end

function AshGenerator:draw()
    self.gui:UpdateLabelText("ASHES_GENERATED_LABEL", "Ash Generated: " .. self.ashesGenerated)
end

function AshGenerator:getState()
    if not self:isFungusPicked() then
        return "PICKING_FUNGUS"
    end
    if not API.LootWindowOpen_2() then
        return "OPENING_LOOT_WINDOW"
    end
    if API.LootWindowOpen_2() then
        return "LOOTING"
    end
    return "IDLE"
end

function AshGenerator:ashesOnGround()
    return API.FindGItemBool_(self.ashId)
end

function AshGenerator:hasFungus()
    return API.InvItemFound1(self.fungusId)
end

function AshGenerator:isFungusPicked()
    local fungus = API.GetAllObjArray2(self.fungusObjectId, 1, { 12 }, self.fungusObjectLocation)
    if fungus == nil or #fungus == 0 then
        return false
    end
    return fungus[1].Bool1 == 1
end

function AshGenerator:pickFungus()
    return API.DoAction_Object2(0x2d, API.OFF_ACT_GeneralObject_route0, self.fungusObjectId, 5,
        self.fungusObjectLocation);
end

function AshGenerator:dropFungus()
    API.KeyboardPress(self.dropKey, 5, 25)
end

function AshGenerator:loop()
    self.state = self:getState()

    if TIMER:shouldRunWithRandomBaseDelay("ASH_GENERATOR", 600, 1200) then
        if self.state == "PICKING_FUNGUS" then
            -- pick fungus, drop fungus and loot all in one tick
            if self:pickFungus() then
                self.ashesGenerated = self.ashesGenerated + 1
            end
            self:dropFungus()
            API.DoAction_LootAll_Button()
        elseif self.state == "OPENING_LOOT_WINDOW" then
            API.DoAction_G_Items1(0x2d, self.fungusId, 1);
        elseif self.state == "LOOTING" then
            API.DoAction_LootAll_Button()
        end
        TIMER:randomThreadedSleep("ASH_GENERATOR", 600, 1200)
    end
end

return AshGenerator
