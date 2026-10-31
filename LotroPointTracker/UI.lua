LotroPointTrackerWindow = class(Turbine.UI.Window)

--------------------------------------------------------------------------------
-- Palette {A, R, G, B}
-- Colors are stored as plain tables so the "earned LP" flash can mix them.
--------------------------------------------------------------------------------

local PANEL     = { 0.82, 0.06, 0.05, 0.04 } -- warm near-black glass
local GOLD      = { 0.95, 0.82, 0.64, 0.33 } -- outer frame
local BRONZE    = { 0.90, 0.45, 0.34, 0.18 } -- inner etched frame / divider
local ACCENT    = { 0.98, 0.92, 0.74, 0.38 } -- left accent bar
local LABEL     = { 0.90, 0.78, 0.72, 0.60 } -- muted parchment text
local VALUE     = { 1.00, 1.00, 0.88, 0.55 } -- character total (bright gold)
local VALUE_ALT = { 0.95, 0.94, 0.84, 0.62 } -- account total (soft gold)
local FLASH     = { 1.00, 1.00, 0.99, 0.90 } -- flash peak on earned LP

local FONT_LABEL   = Turbine.UI.Lotro.Font.TrajanPro14
local FONT_VALUE   = Turbine.UI.Lotro.Font.TrajanPro18
local FONT_VALUE_S = Turbine.UI.Lotro.Font.TrajanPro14

local FLASH_FRAMES = 45 -- ~0.75s at 60 fps

--------------------------------------------------------------------------------
-- Helpers
--------------------------------------------------------------------------------

local function RGBA(c)
    return Turbine.UI.Color(c[1], c[2], c[3], c[4])
end

--- t = 0 -> a, t = 1 -> b
local function Mix(a, b, t)
    return Turbine.UI.Color(
        a[1] + (b[1] - a[1]) * t,
        a[2] + (b[2] - a[2]) * t,
        a[3] + (b[3] - a[3]) * t,
        a[4] + (b[4] - a[4]) * t
    )
end

--- 1234567 -> "1,234,567"
local function FormatPoints(value)
    local formatted = tostring(math.floor(value or 0))
    while true do
        local replaced
        formatted, replaced = formatted:gsub("^(-?%d+)(%d%d%d)", "%1,%2")
        if replaced == 0 then break end
    end
    return formatted
end

local function Bar(parent, color)
    local bar = Turbine.UI.Control()
    bar:SetParent(parent)
    bar:SetBackColor(RGBA(color))
    bar:SetMouseVisible(false)
    return bar
end

local function TextLabel(parent, font, color, alignment)
    local label = Turbine.UI.Label()
    label:SetParent(parent)
    label:SetFont(font)
    label:SetForeColor(RGBA(color))
    label:SetTextAlignment(alignment)
    label:SetMouseVisible(false)
    return label
end

--------------------------------------------------------------------------------
-- Window
--------------------------------------------------------------------------------

---@param lpCounter {lp_char : number, lp_account : number}
---@param windowWidth number
---@param windowHeight number
function LotroPointTrackerWindow:Init(lpCounter, windowWidth, windowHeight)
    self.lpCounter = lpCounter or { lp_char = 0, lp_account = 0 }

    self.width = (type(windowWidth) == "number" and windowWidth > 0) and math.floor(windowWidth) or WIDTH
    self.height = (type(windowHeight) == "number" and windowHeight > 0) and math.floor(windowHeight) or HEIGHT
    if type(self.width) ~= "number" or self.width < 40 then self.width = 190 end
    if type(self.height) ~= "number" or self.height < 20 then self.height = 56 end

    self:SetPosition(X_POS, Y_POS)
    self:SetBackColor(RGBA(PANEL))
    self:SetMouseVisible(false)

    -- Decorative frame (positions are calculated in Layout)
    self.frameTop = Bar(self, GOLD)
    self.frameBottom = Bar(self, GOLD)
    self.frameLeft = Bar(self, GOLD)
    self.frameRight = Bar(self, GOLD)

    self.frameInnerTop = Bar(self, BRONZE)
    self.frameInnerBottom = Bar(self, BRONZE)
    self.frameInnerLeft = Bar(self, BRONZE)
    self.frameInnerRight = Bar(self, BRONZE)

    self.accentBar = Bar(self, ACCENT)
    self.divider = Bar(self, BRONZE)

    -- Counter rows
    self.charLabel = TextLabel(self, FONT_LABEL, LABEL, Turbine.UI.ContentAlignment.MiddleLeft)
    self.charValue = TextLabel(self, FONT_VALUE, VALUE, Turbine.UI.ContentAlignment.MiddleRight)
    self.accountLabel = TextLabel(self, FONT_LABEL, LABEL, Turbine.UI.ContentAlignment.MiddleLeft)
    self.accountValue = TextLabel(self, FONT_VALUE, VALUE_ALT, Turbine.UI.ContentAlignment.MiddleRight)

    self.charLabel:SetText("Character")
    self.accountLabel:SetText("Account")
    self.charValue:SetText(FormatPoints(self.lpCounter.lp_char))
    self.accountValue:SetText(FormatPoints(self.lpCounter.lp_account))

    -- Move control (only active when movement is enabled in the settings)
    self.moveControl = Turbine.UI.Control()
    self.moveControl:SetParent(self)
    self.moveControl:SetMouseVisible(MOVE)

    self.moveControl.MouseDown = function(sender, args)
        if args.Button == Turbine.UI.MouseButton.Left then
            self.dragging = true
            self.dragStartX = args.X
            self.dragStartY = args.Y
        end
    end

    self.moveControl.MouseUp = function(sender, args)
        if args.Button == Turbine.UI.MouseButton.Left and self.dragging then
            self.dragging = false
            X_POS = self:GetLeft()
            Y_POS = self:GetTop()
        end
    end

    self.moveControl.MouseMove = function(sender, args)
        if self.dragging then
            local x, y = self:GetPosition()
            x = x + (args.X - self.dragStartX)
            y = y + (args.Y - self.dragStartY)
            self:SetPosition(x, y)
        end
    end

    -- Flash animation control (fades the totals back to gold after LP is earned)
    self.flashRemaining = 0
    self.lastChar = self.lpCounter.lp_char or 0
    self.lastAccount = self.lpCounter.lp_account or 0

    self.flashControl = Turbine.UI.Control()
    self.flashControl:SetParent(self)
    self.flashControl:SetSize(1, 1)
    self.flashControl:SetMouseVisible(false)
    self.flashControl:SetWantsUpdates(false)

    local window = self
    function self.flashControl:Update()
        window.flashRemaining = window.flashRemaining - 1
        if window.flashRemaining <= 0 then
            window.charValue:SetForeColor(RGBA(VALUE))
            window.accountValue:SetForeColor(RGBA(VALUE_ALT))
            self:SetWantsUpdates(false)
        else
            local t = window.flashRemaining / FLASH_FRAMES
            window.charValue:SetForeColor(Mix(VALUE, FLASH, t))
            window.accountValue:SetForeColor(Mix(VALUE_ALT, FLASH, t))
        end
    end

    self:Layout()
end

--- Recalculates the position and size of every element for the current
--- window size. Called on Init and Resize.
function LotroPointTrackerWindow:Layout()
    self:SetSize(self.width, self.height)
    self.moveControl:SetSize(self.width, self.height)

    -- outer gold frame
    self.frameTop:SetPosition(0, 0)
    self.frameTop:SetSize(self.width, 1)
    self.frameBottom:SetPosition(0, self.height - 1)
    self.frameBottom:SetSize(self.width, 1)
    self.frameLeft:SetPosition(0, 0)
    self.frameLeft:SetSize(1, self.height)
    self.frameRight:SetPosition(self.width - 1, 0)
    self.frameRight:SetSize(1, self.height)

    -- inner etched frame
    self.frameInnerTop:SetPosition(1, 1)
    self.frameInnerTop:SetSize(self.width - 2, 1)
    self.frameInnerBottom:SetPosition(1, self.height - 2)
    self.frameInnerBottom:SetSize(self.width - 2, 1)
    self.frameInnerLeft:SetPosition(1, 1)
    self.frameInnerLeft:SetSize(1, self.height - 2)
    self.frameInnerRight:SetPosition(self.width - 2, 1)
    self.frameInnerRight:SetSize(1, self.height - 2)

    -- left accent bar
    self.accentBar:SetPosition(0, 0)
    self.accentBar:SetSize(2, self.height)

    -- content rows
    local contentTop = 2
    local dividerSize = 1
    local rowHeight = math.floor((self.height - 4 - dividerSize) / 2)
    if rowHeight < 1 then rowHeight = 1 end

    local left = 6
    local right = 6
    local split = math.floor(self.width * 0.5)
    local labelWidth = split - left
    local valueWidth = self.width - split - right

    local row1Y = contentTop
    local row2Y = contentTop + rowHeight + dividerSize

    self.charLabel:SetPosition(left, row1Y)
    self.charLabel:SetSize(labelWidth, rowHeight)
    self.charValue:SetPosition(split, row1Y)
    self.charValue:SetSize(valueWidth, rowHeight)

    self.divider:SetPosition(left, contentTop + rowHeight)
    self.divider:SetSize(self.width - left - right, 1)

    self.accountLabel:SetPosition(left, row2Y)
    self.accountLabel:SetSize(labelWidth, rowHeight)
    self.accountValue:SetPosition(split, row2Y)
    self.accountValue:SetSize(valueWidth, rowHeight)

    -- the value font scales with the row height
    local valueFont = FONT_VALUE_S
    if rowHeight >= 24 then valueFont = FONT_VALUE end
    self.charValue:SetFont(valueFont)
    self.accountValue:SetFont(valueFont)
end

function LotroPointTrackerWindow:Resize(width, height)
    if type(width) == "number" and width >= 40 then self.width = math.floor(width) end
    if type(height) == "number" and height >= 20 then self.height = math.floor(height) end
    self:Layout()
end

--- Briefly flashes both totals in bright gold when LP is earned
function LotroPointTrackerWindow:StartFlash()
    self.flashRemaining = FLASH_FRAMES
    self.charValue:SetForeColor(RGBA(FLASH))
    self.accountValue:SetForeColor(RGBA(FLASH))
    self.flashControl:SetWantsUpdates(true)
end

---@param lpCounter {lp_char : number, lp_account : number}
function LotroPointTrackerWindow:UpdateCounter(lpCounter)
    -- NOTE: the caller mutates and passes the same table, so the previous
    -- totals are tracked as plain numbers, not as a table reference.
    local previousChar = self.lastChar or 0
    local previousAccount = self.lastAccount or 0

    self.lpCounter = lpCounter
    self.lastChar = lpCounter.lp_char or 0
    self.lastAccount = lpCounter.lp_account or 0

    if self.charValue ~= nil then
        self.charValue:SetText(FormatPoints(self.lastChar))
        self.accountValue:SetText(FormatPoints(self.lastAccount))

        if self.lastChar > previousChar or self.lastAccount > previousAccount then
            self:StartFlash()
        end
    end
end