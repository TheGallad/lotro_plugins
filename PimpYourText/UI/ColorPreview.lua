ColorPreview = class(Turbine.UI.Label);

function ColorPreview:Constructor(rgb, clickFct)
    Turbine.UI.Label.Constructor(self);
    self:SetSize(20, 20);
    self:SetEnabled(false);
    self:SetRGB(rgb);

    self.mask = Turbine.UI.Label();
    self.mask:SetParent(self);
    self.mask:SetBlendMode(Turbine.UI.BlendMode.AlphaBlend);
    self.mask:SetSize(20, 20);
    self.mask:SetPosition(0, 0);
    self.mask:SetBackground("PimpYourText/pictures/ColorPreviewMask.tga");
    self.mask:SetMouseVisible(false);

    self.MouseClick = function(sender, args)
        if (clickFct ~= nil) then
            clickFct(self);
        end
    end

    self:SetMouseVisible(true);
end

function ColorPreview:SetRGB(rgb)
    self.rgb = rgb;
    local r = self:GetByte(rgb or "", 1);
    local g = self:GetByte(rgb or "", 2);
    local b = self:GetByte(rgb or "", 3);

    if (r ~= nil and r >= 0 and r <= 256 and g ~= nil and g >= 0 and g <= 256 and b ~= nil and b >= 0 and b <= 256) then
        self:SetBackColor(Turbine.UI.Color(r / 255, g / 255, b / 255));
    else
        Turbine.Shell.WriteLine("ERROR");
    end
end

function ColorPreview:GetRGB()
    return self.rgb;
end

function ColorPreview:GetByte(rgb, w)
    local c1 = string.byte(rgb, 1 + (w - 1) * 2);
    local c2 = string.byte(rgb, 1 + (w - 1) * 2 + 1);

    if (c2 == nil or c1 == nil) then return 0; end

    local val1 = 0; local val2 = 0;
    if (c2 >= 48 and c2 <= 57) then
        val2 = c2 - 48;
    elseif (c2 >= 65 and c2 <= 70) then
        val2 = 10 + c2 - 65;
    elseif (c2 >= 97 and c2 <= 102) then
        val2 = 10 + c2 - 97;
    end
    if (c1 >= 48 and c1 <= 57) then
        val1 = c1 - 48;
    elseif (c1 >= 65 and c1 <= 70) then
        val1 = 10 + c1 - 65;
    elseif (c1 >= 97 and c1 <= 102) then
        val1 = 10 + c1 - 97;
    end
    return 16 * val1 + val2;
end
