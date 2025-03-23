ComboBox = class(Turbine.UI.Control);

function ComboBox:Constructor(width, height, list, defaultSelection)
    Turbine.UI.Control.Constructor(self);
    self:SetSize(width, height);
    self:SetBackColor(Turbine.UI.Color(0.63, 0.63, 0.63));
    self:SetPosition(0, 0);
    self:SetVisible(true);
    self:SetMouseVisible(false);

    local BlackBox = Turbine.UI.Window();
    BlackBox:SetParent(self);
    BlackBox:SetSize(width - 4, height - 4);
    BlackBox:SetPosition(2, 2);
    BlackBox:SetBackColor(Turbine.UI.Color(0, 0, 0));
    BlackBox:SetVisible(true);

    local tempLabel = Turbine.UI.Label();
    tempLabel:SetParent(BlackBox);
    tempLabel:SetSize(BlackBox:GetWidth(), BlackBox:GetHeight());
    tempLabel:SetPosition(0, 0);
    tempLabel:SetBackColor(Turbine.UI.Color(0, 0, 0));
    tempLabel:SetForeColor(Turbine.UI.Color((229 / 255), (209 / 255), (136 / 255)));
    tempLabel:SetTextAlignment(Turbine.UI.ContentAlignment.MiddleCenter);
    tempLabel:SetFont(Turbine.UI.Lotro.Font.TrajanPro14);
    tempLabel:SetText(Default);
    tempLabel:SetMouseVisible(false);

    -- Drop down arrow shown in the control.
    local arrow = Turbine.UI.Control();
    arrow:SetParent(BlackBox);
    arrow:SetSize(14, 14);
    arrow:SetPosition((BlackBox:GetWidth() - 13), (BlackBox:GetHeight() - 14));
    arrow:SetBackground(0x41007e18);
    arrow:SetStretchMode(2);
    arrow:SetMouseVisible(false);


    BlackBox.MouseEnter = function(sender, args)
        --if BLDDMENUENABLED == true then
        arrow:SetBackground(0x41007e1b);
        tempLabel:SetOutlineColor(Turbine.UI.Color(0.85, 0.65, 0));
        tempLabel:SetForeColor(Turbine.UI.Color(1, 1, 1));
        tempLabel:SetFontStyle(8);
        --end
    end

    -- Returns the menu to normal state as the mouse leaves.
    BlackBox.MouseLeave = function(sender, args)
        --if BLDDMENUENABLED == true then
        arrow:SetBackground(0x41007e18);
        tempLabel:SetOutlineColor(Turbine.UI.Color(0, 0, 0));
        tempLabel:SetForeColor(Turbine.UI.Color((229 / 255), (209 / 255), (136 / 255)));
        tempLabel:SetFontStyle(0);
        --end
    end
end
