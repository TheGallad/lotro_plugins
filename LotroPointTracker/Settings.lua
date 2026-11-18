Options = class(Turbine.UI.ListBox)

--------------------------------------------------------------------------------
-- Limits, defaults and presets
--------------------------------------------------------------------------------

local DEFAULT_WIDTH  = 190
local DEFAULT_HEIGHT = 56
local DEFAULT_Y_POS  = 50

local MIN_WIDTH      = 120
local MAX_WIDTH      = 800
local MIN_HEIGHT     = 36
local MAX_HEIGHT     = 200

local PRESETS = {
    { name = "Small",  width = 160, height = 40 },
    { name = "Normal", width = 190, height = 56 },
    { name = "Large",  width = 260, height = 80 },
}

local ACTION_ENTER  = 162
local ACTION_ESCAPE = 145

local COLOR_OK    = Turbine.UI.Color(0.45, 0.90, 0.45)
local COLOR_WARN  = Turbine.UI.Color(1.00, 0.82, 0.30)
local COLOR_ERROR = Turbine.UI.Color(1.00, 0.35, 0.30)
local COLOR_HINT  = Turbine.UI.Color(0.75, 0.75, 0.75)

--------------------------------------------------------------------------------
-- Helpers
--------------------------------------------------------------------------------

--- Returns value, problem. value is nil if the text is not a number;
--- otherwise it is rounded and clamped to [min, max] and problem tells
--- whether it had to be clamped ("small"/"large") or is nil when valid.
local function ParseSize(text, min, max)
    local value = tonumber(text)
    if value == nil then
        return nil, "nan"
    end
    value = math.floor(value + 0.5)
    if value < min then return min, "small" end
    if value > max then return max, "large" end
    return value, nil
end

local function CenteredX(width)
    return math.floor((Turbine.UI.Display.GetWidth() - width) / 2)
end

local function RangeText(name, min, max)
    return name .. " must be " .. min .. "-" .. max
end

local function SmallButton(parent, text, left, top, width)
    local button = Turbine.UI.Lotro.Button()
    button:SetParent(parent)
    button:SetText(text)
    button:SetPosition(left, top)
    button:SetSize(width, 20)
    return button
end

--------------------------------------------------------------------------------
-- Panel
--------------------------------------------------------------------------------

---@param window LotroPointTrackerWindow
function Options:Init(window)
    self.window = window

    -- repair missing values (e.g. a settings file saved with an invalid size)
    if type(WIDTH) ~= "number" then WIDTH = DEFAULT_WIDTH end
    if type(HEIGHT) ~= "number" then HEIGHT = DEFAULT_HEIGHT end
    if type(X_POS) ~= "number" then X_POS = CenteredX(WIDTH) end
    if type(Y_POS) ~= "number" then Y_POS = DEFAULT_Y_POS end

    -- last saved size, restored by Escape in the size fields
    self.savedWidth = WIDTH
    self.savedHeight = HEIGHT

    self:SetSize(600, 600)
    self:AddItem(self:BuildHeader())
    self:AddItem(self:BuildSpacer())
    self:AddItem(self:BuildMoveControl())
    self:AddItem(self:BuildSpacer())
    self:AddItem(self:BuildWindowSizeControl())
    self:AddItem(self:BuildPresetControl())
    self:AddItem(self:BuildPositionControl())

    -- keep the position text current while the tracker is dragged
    self.window.PositionChanged = function()
        self:UpdatePositionLabel()
    end
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
    moveControl.checkBox:SetText(" Unlock window (drag to move), locks again on reload")
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
    ---@field statusLabel Label
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
    windowSizeControl.widthTextBox:SetMultiline(false)

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
    windowSizeControl.heightTextBox:SetMultiline(false)

    windowSizeControl.acceptButton = Turbine.UI.Lotro.Button()
    windowSizeControl.acceptButton:SetParent(windowSizeControl)
    windowSizeControl.acceptButton:SetText("Accept")
    windowSizeControl.acceptButton:SetLeft(350)
    windowSizeControl.acceptButton:SetTop(30)
    windowSizeControl.acceptButton:SetWidth(100)
    windowSizeControl.acceptButton:SetHeight(20)

    -- validation errors and save confirmations are shown here instead of chat
    windowSizeControl.statusLabel = Turbine.UI.Label()
    windowSizeControl.statusLabel:SetParent(windowSizeControl)
    windowSizeControl.statusLabel:SetPosition(50, 55)
    windowSizeControl.statusLabel:SetSize(500, 20)
    windowSizeControl.statusLabel:SetTextAlignment(Turbine.UI.ContentAlignment.MiddleLeft)
    windowSizeControl.statusLabel:SetFont(SETTINGSFONTSMALL)

    self.widthTextBox = windowSizeControl.widthTextBox
    self.heightTextBox = windowSizeControl.heightTextBox
    self.statusLabel = windowSizeControl.statusLabel

    self:SetSizeFields(WIDTH, HEIGHT)
    self:SetStatus("Width " .. MIN_WIDTH .. "-" .. MAX_WIDTH .. ", height " .. MIN_HEIGHT .. "-" .. MAX_HEIGHT
        .. ". Enter saves, Escape reverts.", COLOR_HINT)

    windowSizeControl.acceptButton.Click = function()
        self:AcceptSize()
    end

    -- live preview while typing; only valid sizes are applied
    local function OnTextChanged()
        if not self.updatingFields then
            self:PreviewSize()
        end
    end
    windowSizeControl.widthTextBox.TextChanged = OnTextChanged
    windowSizeControl.heightTextBox.TextChanged = OnTextChanged

    local function OnKeyDown(sender, args)
        if args.Action == ACTION_ENTER then
            self:AcceptSize()
        elseif args.Action == ACTION_ESCAPE then
            self:RevertSize()
        end
    end
    windowSizeControl.widthTextBox.KeyDown = OnKeyDown
    windowSizeControl.heightTextBox.KeyDown = OnKeyDown

    return windowSizeControl
end

function Options:BuildPresetControl()
    ---@class PresetControl : Control
    local presetControl = Turbine.UI.Control()

    presetControl:SetParent(self)
    presetControl:SetSize(600, 40)

    local label = Turbine.UI.Label()
    label:SetParent(presetControl)
    label:SetPosition(50, 0)
    label:SetSize(80, 20)
    label:SetTextAlignment(Turbine.UI.ContentAlignment.MiddleLeft)
    label:SetFont(SETTINGSFONTSMALL)
    label:SetText("Presets")

    for i, preset in ipairs(PRESETS) do
        local button = SmallButton(presetControl,
            preset.name .. " (" .. preset.width .. "x" .. preset.height .. ")",
            130 + (i - 1) * 140, 0, 130)
        button.Click = function()
            self:ApplySize(preset.width, preset.height)
            self:SaveWithStatus("Saved: " .. preset.name .. " size")
        end
    end

    return presetControl
end

function Options:BuildPositionControl()
    ---@class PositionControl : Control
    local positionControl = Turbine.UI.Control()

    positionControl:SetParent(self)
    positionControl:SetSize(600, 40)

    self.positionLabel = Turbine.UI.Label()
    self.positionLabel:SetParent(positionControl)
    self.positionLabel:SetPosition(50, 0)
    self.positionLabel:SetSize(200, 20)
    self.positionLabel:SetTextAlignment(Turbine.UI.ContentAlignment.MiddleLeft)
    self.positionLabel:SetFont(SETTINGSFONTSMALL)
    -- the tracker is positioned only after the options panel is built
    self:UpdatePositionLabel(X_POS, Y_POS)

    local centerButton = SmallButton(positionControl, "Center horizontally", 270, 0, 140)
    centerButton.Click = function()
        X_POS = CenteredX(WIDTH)
        self.window:SetPosition(X_POS, Y_POS)
        self:UpdatePositionLabel()
        self:SaveWithStatus("Saved: window centered")
    end

    local resetButton = SmallButton(positionControl, "Reset to defaults", 420, 0, 130)
    resetButton.Click = function()
        self:ApplySize(DEFAULT_WIDTH, DEFAULT_HEIGHT)
        X_POS = CenteredX(DEFAULT_WIDTH)
        Y_POS = DEFAULT_Y_POS
        self.window:SetPosition(X_POS, Y_POS)
        self:UpdatePositionLabel()
        self:SaveWithStatus("Saved: default size and position")
    end

    return positionControl
end

function Options:BuildSpacer()
    ---@class SpacerControl : Control
    local spacer = Turbine.UI.Control()

    spacer:SetParent(self)
    spacer:SetSize(600, 30)

    return spacer
end

--------------------------------------------------------------------------------
-- Size handling
--------------------------------------------------------------------------------

function Options:SetStatus(text, color)
    if self.statusLabel == nil then return end
    self.statusLabel:SetForeColor(color or COLOR_HINT)
    self.statusLabel:SetText(text)
end

--- Writes values into the size fields without triggering the live preview.
function Options:SetSizeFields(width, height)
    self.updatingFields = true
    self.widthTextBox:SetText(tostring(width))
    self.heightTextBox:SetText(tostring(height))
    self.updatingFields = false
end

function Options:ApplySize(width, height)
    WIDTH = width
    HEIGHT = height
    self.window:Resize(WIDTH, HEIGHT)
    self:SetSizeFields(WIDTH, HEIGHT)
end

--- Applies the typed size immediately if it is valid; otherwise only explains
--- what is wrong and leaves the window as it is.
function Options:PreviewSize()
    local width, widthProblem = ParseSize(self.widthTextBox:GetText(), MIN_WIDTH, MAX_WIDTH)
    local height, heightProblem = ParseSize(self.heightTextBox:GetText(), MIN_HEIGHT, MAX_HEIGHT)

    if widthProblem ~= nil then
        self:SetStatus(RangeText("Width", MIN_WIDTH, MAX_WIDTH), COLOR_ERROR)
        return
    end
    if heightProblem ~= nil then
        self:SetStatus(RangeText("Height", MIN_HEIGHT, MAX_HEIGHT), COLOR_ERROR)
        return
    end

    WIDTH = width
    HEIGHT = height
    self.window:Resize(WIDTH, HEIGHT)
    self:SetStatus("Preview " .. width .. "x" .. height .. ". Press Accept or Enter to save", COLOR_HINT)
end

--- Validates, clamps, applies and saves the typed size.
function Options:AcceptSize()
    local width, widthProblem = ParseSize(self.widthTextBox:GetText(), MIN_WIDTH, MAX_WIDTH)
    local height, heightProblem = ParseSize(self.heightTextBox:GetText(), MIN_HEIGHT, MAX_HEIGHT)

    if width == nil or height == nil then
        local name = (width == nil) and "Width" or "Height"
        local min = (width == nil) and MIN_WIDTH or MIN_HEIGHT
        local max = (width == nil) and MAX_WIDTH or MAX_HEIGHT
        self:SetSizeFields(WIDTH, HEIGHT)
        self:SetStatus(name .. " is not a number (" .. min .. "-" .. max .. "). Kept " .. WIDTH .. "x" .. HEIGHT,
            COLOR_ERROR)
        return
    end

    self:ApplySize(width, height)

    local adjusted = {}
    if widthProblem ~= nil then
        table.insert(adjusted, "width to " .. width .. " (" .. MIN_WIDTH .. "-" .. MAX_WIDTH .. ")")
    end
    if heightProblem ~= nil then
        table.insert(adjusted, "height to " .. height .. " (" .. MIN_HEIGHT .. "-" .. MAX_HEIGHT .. ")")
    end

    if self:Save() then
        if #adjusted > 0 then
            self:SetStatus("Saved. Adjusted " .. table.concat(adjusted, ", "), COLOR_WARN)
        else
            self:SetStatus("Saved: " .. width .. "x" .. height, COLOR_OK)
        end
    else
        self:SetStatus("Could not save settings", COLOR_ERROR)
    end
end

--- Escape: go back to the last saved size.
function Options:RevertSize()
    self:ApplySize(self.savedWidth or WIDTH, self.savedHeight or HEIGHT)
    self:SetStatus("Reverted to " .. WIDTH .. "x" .. HEIGHT, COLOR_HINT)
end

--- x, y default to the tracker's current position.
function Options:UpdatePositionLabel(x, y)
    if self.positionLabel == nil then return end
    if x == nil or y == nil then
        x, y = self.window:GetPosition()
    end
    self.positionLabel:SetText("Position: " .. tostring(x) .. ", " .. tostring(y))
end

--------------------------------------------------------------------------------
-- Persistence
--------------------------------------------------------------------------------

function Options:SaveWithStatus(message)
    if self:Save() then
        self:SetStatus(message, COLOR_OK)
    else
        self:SetStatus("Could not save settings", COLOR_ERROR)
    end
end

--- Saves the settings; reports only failures to chat. Returns true on success.
function Options:Save()
    local data = {x_pos = X_POS, y_pos = Y_POS, window_width = WIDTH, window_height = HEIGHT}
    local success = pcall(Turbine.PluginData.Save, Turbine.DataScope.Account, SETTINGS_FILE_NAME, data)
    if success then
        self.savedWidth = WIDTH
        self.savedHeight = HEIGHT
    else
        Turbine.Shell.WriteLine("An error has occurred while saving settings data")
    end
    return success
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
