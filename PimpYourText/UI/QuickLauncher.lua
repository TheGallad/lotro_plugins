import "PimpYourText.Utils.LerpValue";

_G.QuickLauncher = class(Turbine.UI.Window);

function QuickLauncher:Constructor(dialog)
    Turbine.UI.Window.Constructor(self);

    --self.defaultOpacity = 0.6;
    local width, height = Turbine.UI.Display.GetSize();
    self:SetSize(32, 32);
    self:SetPosition(settings.quicklaunch_x, settings.quicklaunch_y);
    self:SetOpacity(settings.defaultOpacity / 100);

    self.background = Turbine.UI.Label();
    self.background:SetParent(self);
    self.background:SetBackground("PimpYourText/pictures/background2.tga");
    self.background:SetPosition(0, 0);
    self.background:SetSize(132, 32);
    self.background:SetMouseVisible(false);
    self.background:SetBlendMode(Turbine.UI.BlendMode.AlphaBlend);

    local layer1 = Turbine.UI.Label();
    layer1:SetParent(self);
    layer1:SetBackground("PimpYourText/pictures/logo_layer.tga");
    layer1:SetPosition(0, 0);
    layer1:SetSize(32, 32);
    layer1:SetMouseVisible(false);
    layer1:SetBlendMode(Turbine.UI.BlendMode.AlphaBlend);

    self.MouseEnter = function(sender, args)
        --self.button:SetBackground("Chiran/Songbook/toggle_hover.tga");
        self:SetOpacity(1.0);
    end
    self.MouseLeave = function(sender, args)
        --self.button:SetBackground("Chiran/Songbook/toggle.tga");
        self:SetOpacity(settings.defaultOpacity / 100);
    end
    self.MouseDown = function(sender, args)
        if (args.Button == Turbine.UI.MouseButton.Left and settings.canMoveQuickLauncher) then
            sender.dragStartX = args.X;
            sender.dragStartY = args.Y;
            sender.dragging = true;
            sender.dragged = false;
            --self:SetBackColor( Turbine.UI.Color(0,0,1,0) );
        end
    end
    self.MouseUp = function(sender, args)
        if (args.Button == Turbine.UI.MouseButton.Left) then
            if (sender.dragging) then
                sender.dragging = false;
            end
            if not sender.dragged then
                dialog:SetVisible(not dialog:IsVisible());
            end
            ---self:SetBackColor( Turbine.UI.Color(0,0,0,0) );
            settings.quicklaunch_x, settings.quicklaunch_y = self:GetPosition();
            Savesettings();
            if (settings.OnUpdate ~= nil) then
                settings.OnUpdate();
            end
        end
    end
    self.MouseMove = function(sender, args)
        if (sender.dragging) then
            local left, top = self:GetPosition();
            self:SetPosition(left + (args.X - sender.dragStartX), top + args.Y - sender.dragStartY);
            sender.dragged = true;
            if (self:GetLeft() > Turbine.UI.Display.GetWidth() - 35) then
                self:SetLeft(Turbine.UI.Display.GetWidth() - 35);
            end
            if (self:GetLeft() < 0) then
                self:SetLeft(0);
            end
            if (self:GetTop() > Turbine.UI.Display.GetHeight() - 35) then
                self:SetTop(Turbine.UI.Display.GetHeight() - 35);
            end
            if (self:GetTop() < 0) then
                self:SetTop(0);
            end
        end
    end

    self.lastUpdate = 0;
    self.blinker = LerpValue();
    self.blinker.defaultTimer = 7;
    self.blinker:SetRate(100);
    self.blinker:SetValue(0);
    self.blinker:SetTarget(self.blinker.defaultTimer);

    self:Applysettings();

    -- Hide UI when F12 is pressed, code copied from Chiran sources
    local hideUI = false;
    local wasVisible;
    self:SetWantsKeyEvents(true);
    self.KeyDown = function(sender, args)
        if (args.Action == 268435635) then
            if not hideUI then
                hideUI = true;
                if self:IsVisible() then
                    wasVisible = true;
                    self:SetVisible(false);
                else
                    wasVisible = false;
                end
            else
                hideUI = false;
                if wasVisible then
                    self:SetVisible(true);
                end
            end
        end
    end
end

function QuickLauncher:Update(args)
    local delta = 0;
    local currentTime = Turbine.Engine.GetGameTime();

    if (self.lastUpdate > 0) then
        delta = currentTime - self.lastUpdate;
    end

    self.lastUpdate = currentTime;
    self.blinker:Update(delta);
    if (not self.blinker:NeedsUpdate()) then
        self.blinker:SetValue(0);
        local backpos = self.background:GetLeft() - 1;
        local dep = backpos + (self.background:GetWidth() - self:GetWidth()) / 2;
        if (dep < 0) then
            self.background:SetLeft(dep);
        else
            self.background:SetLeft(backpos);
        end
    end
end

function QuickLauncher:Applysettings()
    self:SetPosition(settings.quicklaunch_x, settings.quicklaunch_y);
    self:SetOpacity(settings.defaultOpacity / 100);
    self:SetWantsUpdates(settings.animateQuickLauncher);
    self:SetVisible(settings.useQuickLauncher);
end

function QuickLauncher:GetName()
    return "QuickLauncher";
end

function QuickLauncher:IsRunning()
    return (self ~= nil);
end

function QuickLauncher:Start()
    if (self ~= nil) then
        self:SetVisible(true);
        self:SetWantsUpdates(settings.animateQuickLauncher);
        return;
    end
end

function QuickLauncher:Stop()
    self:SetVisible(false);
    self:SetWantsUpdates(false);
    self = nil;
end
