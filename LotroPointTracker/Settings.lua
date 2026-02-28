Options = class(Turbine.UI.ListBox)

---@param window LotroPointTrackerWindow
function Options:Init(window)
    self.window = window

    self:SetSize(600, 600)
    self:AddItem(self:BuildHeader())
    self:AddItem(self:BuildSpacer())
    self:AddItem(self:BuildMoveControl())
    self:AddItem(self:BuildSpacer())
    self:AddItem(self:BuildWindowSizeControl())
end

function Options:BuildHeader()
    ---@class HeaderControl : Control
    ---@field label Label
    local header = Turbine.UI.Control()

    header:SetParent(self)
    header:SetSize(600, 50)

    header.label = Turbine.UI.Label()
    header.label:SetParent(header)
    header.label:SetSize(header:GetSize())
    header.label:SetTextAlignment(Turbine.UI.ContentAlignment.MiddleCenter)
    header.label:SetFont(Turbine.UI.Lotro.Font.BookAntiqua36)
    header.label:SetText("LotroPointTracker")

    return header
end

function Options:BuildMoveControl()
    ---@class MoveControl : Control
    ---@field checkBox CheckBox
    local moveControl = Turbine.UI.Control()

    moveControl:SetParent(self)
    moveControl:SetSize(600, 50)

    moveControl.checkBox = Turbine.UI.Lotro.CheckBox()
    moveControl.checkBox:SetParent(moveControl)
    moveControl.checkBox:SetLeft(50)
    moveControl.checkBox:SetWidth(moveControl:GetWidth() - 50)
    moveControl.checkBox:SetTextAlignment(Turbine.UI.ContentAlignment.MiddleLeft)
    moveControl.checkBox:SetFont(SETTINGSFONT)
    moveControl.checkBox:SetText(" If checked you can move the window")
    moveControl.checkBox:SetChecked(MOVE)

    moveControl.checkBox.CheckedChanged = function()
        if moveControl.checkBox:IsChecked() then
            MOVE = true
            self.window.moveControl:SetMouseVisible(true)
        else
            MOVE = false
            self.window.moveControl:SetMouseVisible(false)
        end
    end

    return moveControl
end

function Options:BuildWindowSizeControl()
    ---@class windowSizeControl : Control
    ---@field widthLabel Label
    ---@field heightLabel Label
    ---@field widthTextBox TextBox
    ---@field heightTextBox TextBox
    ---@field acceptButton Button
    local windowSizeControl = Turbine.UI.Control()

    windowSizeControl:SetParent(self)
    windowSizeControl:SetSize(600, 100)

    windowSizeControl.widthLabel = Turbine.UI.Label()
    windowSizeControl.widthLabel:SetParent(windowSizeControl)
    windowSizeControl.widthLabel:SetLeft(50)
    windowSizeControl.widthLabel:SetTextAlignment(Turbine.UI.ContentAlignment.TopLeft)
    windowSizeControl.widthLabel:SetFont(SETTINGSFONTSMALL)
    windowSizeControl.widthLabel:SetText("Width")

    windowSizeControl.widthTextBox = Turbine.UI.Lotro.TextBox()
    windowSizeControl.widthTextBox:SetParent(windowSizeControl)
    windowSizeControl.widthTextBox:SetWidth(50)
    windowSizeControl.widthTextBox:SetTop(20)
    windowSizeControl.widthTextBox:SetHeight(25)
    windowSizeControl.widthTextBox:SetLeft(50)
    windowSizeControl.widthTextBox:SetTextAlignment(Turbine.UI.ContentAlignment.MiddleCenter)
    windowSizeControl.widthTextBox:SetFont(SETTINGSFONT)
    windowSizeControl.widthTextBox:SetText(tostring(WIDTH))

    windowSizeControl.heightLabel = Turbine.UI.Label()
    windowSizeControl.heightLabel:SetParent(windowSizeControl)
    windowSizeControl.heightLabel:SetLeft(150)
    windowSizeControl.heightLabel:SetTextAlignment(Turbine.UI.ContentAlignment.TopLeft)
    windowSizeControl.heightLabel:SetFont(SETTINGSFONTSMALL)
    windowSizeControl.heightLabel:SetText("Height")

    windowSizeControl.heightTextBox = Turbine.UI.Lotro.TextBox()
    windowSizeControl.heightTextBox:SetParent(windowSizeControl)
    windowSizeControl.heightTextBox:SetWidth(50)
    windowSizeControl.heightTextBox:SetTop(20)
    windowSizeControl.heightTextBox:SetHeight(25)
    windowSizeControl.heightTextBox:SetLeft(150)
    windowSizeControl.heightTextBox:SetTextAlignment(Turbine.UI.ContentAlignment.MiddleCenter)
    windowSizeControl.heightTextBox:SetFont(SETTINGSFONT)
    windowSizeControl.heightTextBox:SetText(tostring(HEIGHT))

    windowSizeControl.acceptButton = Turbine.UI.Lotro.Button()
    windowSizeControl.acceptButton:SetParent(windowSizeControl)
    windowSizeControl.acceptButton:SetText("Accept")
    windowSizeControl.acceptButton:SetLeft(350)
    windowSizeControl.acceptButton:SetTop(30)
    windowSizeControl.acceptButton:SetWidth(100)
    windowSizeControl.acceptButton:SetHeight(20)

    windowSizeControl.acceptButton.Click = function()
        WIDTH = tonumber(windowSizeControl.widthTextBox:GetText())
        HEIGHT = tonumber(windowSizeControl.heightTextBox:GetText())
        self.window:Resize(WIDTH, HEIGHT)
        self:Save()
    end

    return windowSizeControl
end

function Options:BuildSpacer()
    ---@class SpacerControl : Control
    local spacer = Turbine.UI.Control()

    spacer:SetParent(self)
    spacer:SetSize(600, 30)

    return spacer
end

function Options:Save()
    local data = {x_pos = X_POS, y_pos = Y_POS, window_width = WIDTH, window_height = HEIGHT}
    local success = pcall(Turbine.PluginData.Save, Turbine.DataScope.Account, SETTINGS_FILE_NAME, data)
    if success then
        Turbine.Shell.WriteLine("Settings file is saved")
    else
        Turbine.Shell.WriteLine("An error has occurred while saving settings data")
    end
end

---@return {x_pos : number, y_pos : number, window_width : number, window_height : number}|nil
function Options:Load()
    local success, loadedSettingsData = pcall(Turbine.PluginData.Load, Turbine.DataScope.Account, SETTINGS_FILE_NAME)
    if not success then
        -- loadedData is an error if pcall returned false
        Turbine.Shell.WriteLine("Error loading settings file: " .. tostring(loadedSettingsData))
        return nil
    end
    if loadedSettingsData == nil then
        Turbine.Shell.WriteLine("File with saved settings data not found or data is not correct. Using default settings data.")
        return nil
    end
    Turbine.Shell.WriteLine("Settings file successfully loaded")
    return loadedSettingsData
end
