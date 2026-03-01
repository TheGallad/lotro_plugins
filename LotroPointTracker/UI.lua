LotroPointTrackerWindow = class(Turbine.UI.Window)

---@param lpCounter {lp_char : number, lp_account : number}
---@param windowWidth number
---@param windowHeight number
function LotroPointTrackerWindow:Init(lpCounter, windowWidth, windowHeight)
    self.lpCounter = lpCounter

    self.width = WIDTH
    if (type(windowWidth) == "number") then
        self.width = windowWidth
    end

    self.height = HEIGHT
    if (type(windowHeight) == "number") then
        self.height = windowHeight
    end

    self:SetSize(self.width, self.height)
    self:SetPosition(X_POS, Y_POS)
    self:SetBackColor(Turbine.UI.Color.Black)
    self:SetMouseVisible(false)

    -- Label Background
    self.labelBack = Turbine.UI.Window()
    self.labelBack:SetParent(self)
    self.labelBack:SetSize(self.width, self.height)
    self.labelBack:SetVisible(true)
    self.labelBack:SetMouseVisible(false)

    -- Point label
    self.pointsLabel = Turbine.UI.Label()
    self.pointsLabel:SetParent(self.labelBack)
    self.pointsLabel:SetSize(self.width, self.height)
    self.pointsLabel:SetTextAlignment(Turbine.UI.ContentAlignment.MiddleLeft)
    self.pointsLabel:SetFont(FONT)
    self.pointsLabel:SetFontStyle(Turbine.UI.FontStyle.Outline)
    self.pointsLabel:SetMouseVisible(false)
    self.pointsLabel:SetText(
        "LP (char): " .. tostring(self.lpCounter.lp_char) .. "\n" ..
        "LP (account): " .. tostring(self.lpCounter.lp_account)
    )

    -- MoveControl
    self.moveControl = Turbine.UI.Control()
    self.moveControl:SetParent(self)
    self.moveControl:SetWidth(self:GetWidth())
    self.moveControl:SetHeight(self:GetHeight())
    self.moveControl:SetMouseVisible(MOVE)

    self.moveControl.MouseDown = function(sender, args)
        if args.Button == Turbine.UI.MouseButton.Left then
            self.dragging = true
            self.dragStartX = args.X
            self.dragStartY = args.Y
        end
    end

    self.moveControl.MouseUp = function(sender, args)
        if args.Button == Turbine.UI.MouseButton.Left then
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
end

function LotroPointTrackerWindow:Resize(width, height)
    self.width = width
    self.height = height
    self:SetSize(self.width, self.height)
    self.labelBack:SetSize(self.width, self.height)
    self.moveControl:SetWidth(self:GetWidth())
    self.moveControl:SetHeight(self:GetHeight())
end

---@param lpCounter {lp_char : number, lp_account : number}
function LotroPointTrackerWindow:UpdateCounter(lpCounter)
    self.lpCounter = lpCounter
    if self.pointsLabel then
        self.pointsLabel:SetText(
            "LP (char): " .. tostring(self.lpCounter.lp_char) .. "\n" ..
            "LP (account): " .. tostring(self.lpCounter.lp_account)
        )
    end
end
