ColorPicker = class(Turbine.UI.Label);

function ColorPicker:Constructor()
    Turbine.UI.Label.Constructor(self);
    self:SetSize(174, 104);
    self:SetBackground("PimpYourText/pictures/ColorSelectorPane.tga");
    self:SetBlendMode(Turbine.UI.BlendMode.AlphaBlend);
    --self:SetMouseVisible(false);
    self:SetZOrder(10000);

    self.closeBtn = Turbine.UI.Label();
    self.closeBtn:SetParent(self);
    self.closeBtn:SetBackground("PimpYourText/pictures/close.jpg");
    self.closeBtn:SetSize(16, 16);
    self.closeBtn:SetPosition(153, 5);
    self.closeBtn.tooltip = GenericTooltip(self.closeBtn);
    self.closeBtn.tooltip:AddLayer(TranslateText("CLOSECOLOR_BTN"), Turbine.UI.Color(1, 1, 1), Turbine.UI.ContentAlignment.TopLeft,
        Turbine.UI.Lotro.Font.Verdana14, nil);
    self.closeBtn.MouseClick = function(sender, args)
        self:SetVisible(false);
    end

    self.removeBtn = Turbine.UI.Label();
    self.removeBtn:SetParent(self);
    self.removeBtn:SetBackground("PimpYourText/pictures/delete.jpg");
    self.removeBtn:SetSize(16, 16);
    self.removeBtn:SetPosition(153, 23);
    self.removeBtn.tooltip = GenericTooltip(self.removeBtn);
    self.removeBtn.tooltip:AddLayer(TranslateText("REMOVECOLOR_BTN"), Turbine.UI.Color(1, 1, 1), Turbine.UI.ContentAlignment.TopLeft,
        Turbine.UI.Lotro.Font.Verdana14, nil);
    self.removeBtn.MouseClick = function(sender, args)
        if (self.removeFct ~= nil) then
            self.removeFct();
        end
        self:SetVisible(false);
    end

    self.preview = ColorPreview();
    self.preview:SetParent(self);
    self.preview:SetPosition(5, 80);

    local rgblabel = Turbine.UI.Label();
    rgblabel:SetParent(self);
    rgblabel:SetPosition(58, 85);
    rgblabel:SetSize(30, 16);
    rgblabel:SetMultiline(false);
    rgblabel:SetFont(Turbine.UI.Lotro.Font.Verdana10);
    rgblabel:SetText("RGB:");
    self.colorArea = Turbine.UI.Lotro.TextBox();
    self.colorArea:SetParent(self);
    self.colorArea:SetSize(51, 16);
    self.colorArea:SetPosition(76, 82);
    self.colorArea:SetMultiline(false);
    self.colorArea:SetTextAlignment(Turbine.UI.ContentAlignment.MiddleCenter);
    self.colorArea:SetFont(Turbine.UI.Lotro.Font.Verdana12);
    self.colorArea.TextChanged = function()
        self:UpdateRGBPreview(false);
    end
    self.colorArea.FocusLost = function()
        self:UpdateRGBPreview(true);
    end
    self.rgbPreview = ColorPreview();
    self.rgbPreview:SetParent(self);
    self.rgbPreview:SetPosition(129, 79);
    self.rgbPreview.MouseClick = function()
        if (self.selectFct ~= nil) then
            self.selectFct(self.rgbPreview:GetRGB());
            self:SetVisible(false);
        end
    end
    self.rgbPreview.MouseEnter = function()
        self.preview:SetRGB(self.rgbPreview:GetRGB());
    end
    self.rgbPreview.MouseLeave = function()
        self.preview:SetRGB(self.defaultrgb);
    end
    self:BuildColorsPanes();
end

function ColorPicker:UpdateRGBPreview(isExit)
    if (string.len(self.colorArea:GetText()) ~= 6) then
        self.rgbPreview:SetRGB("FFFFFF");
        self.colorArea:SetForeColor(Turbine.UI.Color(1, 0, 0));
        return;
    end
    for i = 1, 6, 1 do
        local c = string.byte(self.colorArea:GetText(), i);
        if (not ((c >= 48 and c <= 57) or (c >= 65 and c <= 70) or (c >= 97 and c <= 102))) then
            self.rgbPreview:SetRGB("FFFFFF");
            self.colorArea:SetForeColor(Turbine.UI.Color(1, 0, 0));
            return;
        end
    end
    self.colorArea:SetForeColor(Turbine.UI.Color(1, 1, 1));
    self.rgbPreview:SetRGB(self.colorArea:GetText());
    if (self.updatePickerFct ~= nil) then
        self.updatePickerFct();
    end
end

function ColorPicker:BuildColorsPanes()
    local colors = {
        "FFFFFF", "FFFF00", "FF8300",
        "FF0000", "6D071A", "582900",
        "B53389", "FF5CCD", "00FF00",
        "095228", "B0F2B6", "00FFFF",
        "0000FF", "38E5DF", "D4AF37",
        "5A5A5A", "9E9E9E", "000000"
    };

    for i, j in pairs(colors) do
        local p = ColorPreview(j);
        p:SetParent(self);
        p:SetPosition(7 + math.fmod(i - 1, 6) * 24, 7 + math.floor((i - 1) / 6) * 24);
        p.MouseClick = function()
            if (self.selectFct ~= nil) then
                self.selectFct(p:GetRGB());
                self:SetVisible(false);
            end
        end
        p.MouseEnter = function()
            self.preview:SetRGB(p:GetRGB());
        end
        p.MouseLeave = function()
            self.preview:SetRGB(self.defaultrgb);
        end
    end
end

function ColorPicker:Reset(defaultrgb, canRemove, selectFct, removeFct)
    self.selectFct = selectFct;
    self.removeFct = removeFct;
    self.defaultrgb = defaultrgb;
    self.preview:SetRGB(defaultrgb);
    self.colorArea:SetText(defaultrgb);
    self.rgbPreview:SetRGB(defaultrgb);
    self.removeBtn:SetVisible(canRemove);
end
