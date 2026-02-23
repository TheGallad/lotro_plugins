import "LotroPointTracker.TurbineUtils"

LotroPointTrackerWindow = class(Turbine.UI.Window)

function LotroPointTrackerWindow:Constructor()
    Turbine.UI.Window.Constructor(self)

    self.Points = TotalPoints

    self.width = WIDTH
    if (type(ACTUALWIDTH) == "number") then
        self.width = ACTUALWIDTH
    end

    self.height = HEIGHT
    if (type(ACTUALHEIGHT) == "number") then
        self.height = ACTUALHEIGHT
    end

    self:SetSize(self.width, self.height)
    self:SetPosition(LEFT, TOP)
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
    self.pointsLabel:SetText("LP: " .. tostring(self.Points))

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
            LEFT = self:GetLeft()
            TOP = self:GetTop()
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

function LotroPointTrackerWindow:Resize()
    self:SetSize(self.width, self.height)
    self.labelBack:SetSize(self.width, self.height)
    self.moveControl:SetWidth(self:GetWidth())
    self.moveControl:SetHeight(self:GetHeight())
end

function LotroPointTrackerWindow:UpdateCounter(counter)
    self.Points = counter
    if self.pointsLabel then
        self.pointsLabel:SetText("LP: " .. tostring(self.Points))
    end
end
