DiaryEntryNode = class(Turbine.UI.TreeNode);

function DiaryEntryNode:Constructor(width, vertSep, horSep, vertSep2, horSep2)
    self.vertSep = vertSep or 0;
    self.horSep = horSep or 0;
    self.vertSep2 = vertSep2 or self.vertSep;
    self.horSep2 = horSep2 or self.horSep;

    Turbine.UI.TreeNode.Constructor(self);
    self:SetSize(width, 22);
    self:SetBlendMode(Turbine.UI.BlendMode.AlphaBlend);
    self:SetMouseVisible(false);

    self.labelValue = Turbine.UI.Label();
    self.labelValue:SetParent(self);
    self.labelValue:SetSize(width - (self.vertSep + self.vertSep2), self.horSep + self.horSep2 + 2);
    self.labelValue:SetPosition(self.vertSep, self.vertSep);
    self.labelValue:SetFont(Turbine.UI.Lotro.Font.BookAntiqua22);
    self.labelValue:SetForeColor(Turbine.UI.Color(0, 0, 0));
    self.labelValue:SetMouseVisible(false);

    self.labelValuecrollBar = Turbine.UI.Lotro.ScrollBar();
    self.labelValuecrollBar:SetOrientation(Turbine.UI.Orientation.Vertical);
    self.labelValuecrollBar:SetParent(self);
    self.labelValuecrollBar:SetPosition(self.labelValue:GetLeft() + self.labelValue:GetWidth(), self.labelValue:GetTop());
    self.labelValuecrollBar:SetSize(10, self.labelValue:GetHeight());
    self.labelValue:SetVerticalScrollBar(self.labelValuecrollBar);
    self.labelValue:SetMouseVisible(false);
end

function DiaryEntryNode:SetFore(color, font, layout, style, styleColor)
    if (layout ~= nil) then self.labelValue:SetTextAlignment(layout); end
    if (font ~= nil) then self.labelValue:SetFont(font); end
    if (color ~= nil) then self.labelValue:SetForeColor(color); end
    if (style ~= nil) then self.labelValue:SetFontStyle(style); end
    if (styleColor ~= nil) then self.labelValue:SetOutlineColor(styleColor); end
end

function DiaryEntryNode:UpdateText(text)
    self.labelValue:SetText(text);
    self.labelValue:SetHeight(2);

    while self.labelValuecrollBar:IsVisible() do
        self.labelValue:SetHeight(self.labelValue:GetHeight() + 2);
    end
    self:SetHeight(self.horSep * 2 + self.labelValue:GetHeight());
end

function DiaryEntryNode:GetText()
    return self.labelValue:GetText();
end

function DiaryEntryNode:UpdatePicture(picture)
    self.labelValue:SetBackground(picture.picture);
    self:SetHeight(picture.height);
    self.labelValue:SetSize(picture.width, picture.height);
    self.labelValue:SetLeft((self:GetWidth() - picture.width) / 2);
end
