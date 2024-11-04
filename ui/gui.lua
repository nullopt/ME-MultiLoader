local API = require("api")
---@class GUI
local GUI = {
    terminate = false,
    ---@type FFPOINT
    basePosition = FFPOINT.new(100, 100, 0),
    backgroundSize = FFPOINT.new(400, 100, 0),
    uiComponents = {},
    ---@type IG_answer
    moveWindowLabel = nil,
    ---@type IG_answer
    moveWindowCheckbox = nil,
}

function GUI:init()
end

function GUI:GetComponentAmount()
    local amount = 0
    for i, v in pairs(GUI.uiComponents) do
        amount = amount + 1
    end
    return amount
end

function GUI:GetVisibleComponentAmount()
    local amount = 0
    for i, v in pairs(GUI.uiComponents) do
        if v[4] == false then
            amount = amount + 1
        end
    end
    return amount
end

function GUI:GetComponentByName(componentName)
    for i, v in pairs(GUI.uiComponents) do
        if v[1] == componentName then
            return v;
        end
    end
end

---@param comboBoxName string
---@return string | nil
function GUI:OnComboBoxSelectedChange(comboBoxName)
    local comboBox = self:GetComponent(comboBoxName)
    if not comboBox then
        return nil
    end
    -- update the selected script value once the scriptSelector has been clicked
    if comboBox.return_click then
        print(comboBoxName .. ".return_click: " .. tostring(comboBox.return_click))
        comboBox.return_click = false
        if comboBox.int_value <= 0 or comboBox.int_value >= #comboBox.stringsArr then
            return nil
        end
        return comboBox.stringsArr[comboBox.int_value + 1]
    end
end

---@param name string
---@param widthMultiplier number
---@param heightMultiplier number
---@param colour ImColor
---@return nil
function GUI:AddBackground(name, widthMultiplier, heightMultiplier, colour)
    widthMultiplier = widthMultiplier or 1
    heightMultiplier = heightMultiplier or 1
    colour = colour or ImColor.new(15, 13, 18, 255)

    local background = API.CreateIG_answer();
    background.box_name = "Background" .. self:GetComponentAmount();
    self.backgroundSize = FFPOINT.new(400 * widthMultiplier, 100 * heightMultiplier, 0)
    background.box_size = self.backgroundSize
    background.colour = colour

    self.uiComponents[self:GetComponentAmount() + 1] = { name, background, "Background", false }

    self.moveWindowLabel = API.CreateIG_answer()
    self.moveWindowLabel.box_name = "MoveWindowLabel"
    self.moveWindowLabel.string_value = "Move"
    self.moveWindowLabel.colour = ImColor.new(255, 255, 255)
    -- move window checkbox
    self.moveWindowCheckbox = API.CreateIG_answer()
end

---@param name string
---@param text string
---@param colour ImColor
---@return nil
function GUI:AddLabel(name, text, colour)
    colour = colour or ImColor.new(255, 255, 255)

    local label = API.CreateIG_answer()
    label.box_name = "Label" .. self:GetComponentAmount()
    label.colour = colour;
    label.string_value = text

    self.uiComponents[self:GetComponentAmount() + 1] = { name, label, "Label", false }
end

---@param name string
---@param text string
---@return nil
function GUI:AddCheckbox(name, text)
    local checkbox = API.CreateIG_answer()
    checkbox.box_name = text

    self.uiComponents[self:GetComponentAmount() + 1] = { name, checkbox, "CheckBox", false }
end

---@param name string
---@param options table
---@return nil
function GUI:AddComboBox(name, text, options)
    local comboBox = API.CreateIG_answer()
    comboBox.box_name = text
    comboBox.stringsArr = options
    comboBox.box_size = FFPOINT.new(400, 0, 0)

    self.uiComponents[self:GetComponentAmount() + 1] = { name, comboBox, "ComboBox", false }
end

---@param name string
---@param options table
---@return nil
function GUI:AddListBox(name, text, options)
    local listBox = API.CreateIG_answer()
    listBox.box_name = text
    listBox.stringsArr = options
    listBox.box_size = FFPOINT.new(400, 400, 0)

    self.uiComponents[self:GetComponentAmount() + 1] = { name, listBox, "ListBox", false }
end

function GUI:Draw()
    local visibleComponentAmount = self:GetVisibleComponentAmount()
    -- draw the move checkbox in the topright corner

    for i = 1, self:GetComponentAmount() do
        ---@type IG_answer
        local component = self.uiComponents[i][2]
        ---@type string
        local componentKind = self.uiComponents[i][3]
        local hidden = self.uiComponents[i][4] == true
        if hidden then
            component.remove = true
            goto continue
        else
            component.remove = false
        end
        if componentKind == "Background" then
            component.box_start = self.basePosition
            local newHeight = component.box_start.y + (25 * (math.max(1, visibleComponentAmount)))
            local newWidth = component.box_start.x + 400
            component.box_size = FFPOINT.new(newWidth, newHeight, 0)
            API.DrawSquareFilled(component)
            self.moveWindowLabel.box_start = FFPOINT.new(newWidth - 60, component.box_start.y + 8, 0)
            API.DrawTextAt(self.moveWindowLabel)
            self.moveWindowCheckbox.box_start = FFPOINT.new(newWidth - 35, component.box_start.y, 0)
            API.DrawCheckbox(self.moveWindowCheckbox)
        elseif componentKind == "Label" then
            component.box_start = FFPOINT.new(self.basePosition.x + 10, (self.basePosition.y + 10) + ((i - 2) * 25),
                0)
            API.DrawTextAt(component)
        elseif componentKind == "CheckBox" then
            component.box_start = FFPOINT.new(self.basePosition.x + 2.5,
                self.basePosition.y + ((i - 2) * 25), 0)
            API.DrawCheckbox(component)
        elseif componentKind == "ComboBox" then
            component.box_start = FFPOINT.new(self.basePosition.x + 2.5,
                self.basePosition.y + ((i - 2) * 25), 0)
            API.DrawComboBox(component, false)
        elseif componentKind == "ListBox" then
            component.box_start = FFPOINT.new(self.basePosition.x + 10,
                (self.basePosition.y + 10) + ((i - 2) * 25), 0)
            API.DrawListBox(component, false)
        end
        ::continue::
    end
    local moveWindow = self.moveWindowCheckbox.return_click == true
    if moveWindow then
        local mousePos = API.GetMLoc()
        -- TODO: make this dynamic
        self.basePosition = FFPOINT.new(mousePos.x - 380, mousePos.y - 14, 0)
    end
end

---@param componentName string
---@return IG_answer
function GUI:GetComponent(componentName)
    return self:GetComponentByName(componentName)[2]
end

---@param componentName string
---@return string | boolean | nil
function GUI:GetComponentValue(componentName)
    local componentArr = self:GetComponentByName(componentName)
    local componentKind = componentArr[3]
    ---@type IG_answer
    local component = componentArr[2]

    if componentKind == "Label" then
        return component.string_value
    elseif componentKind == "CheckBox" then
        return component.return_click
    elseif componentKind == "ComboBox" and component.string_value ~= "None" then
        return component.string_value
    elseif componentKind == "ListBox" and component.string_value ~= "None" then
        return component.string_value
    end

    return nil
end

---@param componentName string
---@param value string | boolean
---@return nil
function GUI:SetComponentValue(componentName, value)
    local component = self:GetComponentByName(componentName)
    if component then
        local componentKind = component[3]
        if componentKind == "Label" then
            component[2].string_value = value
        elseif componentKind == "CheckBox" then
            component[2].return_click = value
        elseif componentKind == "ComboBox" and component.string_value ~= "None" then
            component[2].string_value = value
        elseif componentKind == "ListBox" and component.string_value ~= "None" then
            component[2].string_value = value
        end
    end
end

function GUI:SetComponentVisibility(componentName, hidden)
    local component = self:GetComponentByName(componentName)
    if component then
        component[4] = hidden
    end
end

---@param labelName string
---@param newText string
---@return nil
function GUI:UpdateLabelText(labelName, newText)
    self:GetComponentByName(labelName)[2].string_value = newText
end

return GUI
