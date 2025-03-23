import "PimpYourText.UI.DiaryEntryNode";

GenericTooltip = class(Turbine.UI.Window);

function GenericTooltip:Constructor(parent, title, description)
    Turbine.UI.Window.Constructor(self);

    self:SetSize(300, 20);

    self:BuildBackground();
    self:UpdateBackground();
    self:SetZOrder(1000);

    self.tooltipTreeView = Turbine.UI.TreeView();
    self.tooltipTreeView:SetParent(self);
    self.tooltipTreeView:SetPosition(10, 10);
    self.tooltipTreeView:SetSize(self:GetWidth() - 20, 0);
    self.tooltipTreeView:SetIndentationWidth(15);
    self.tooltipTreeView:SetMouseVisible(false);

    if (parent ~= nil) then
        --self:SetParent(parent);
        parent.MouseEnter = function(a, e)
            local x = Turbine.UI.Display.GetMouseX();
            local y = Turbine.UI.Display.GetMouseY();
            if (x + 20 + self:GetWidth() > Turbine.UI.Display.GetWidth()) then
                x = Turbine.UI.Display.GetMouseX() -
                    self:GetWidth() - 10;
            end
            if (y + 5 + self:GetHeight() > Turbine.UI.Display.GetHeight()) then
                y = Turbine.UI.Display.GetMouseY() -
                    self:GetHeight() - 10;
            end
            self:SetPosition(x + 20, y + 5);
            self:SetVisible(true);
        end
        parent.MouseLeave = function(a, e)
            self:SetVisible(false);
        end
    end
    if (title ~= nil) then
        self:AddLayer(title, Turbine.UI.Color(197 / 255, 162 / 255, 57 / 255), nil, Turbine.UI.Lotro.Font.Verdana18,
            Turbine.UI.FontStyle.Outline, Turbine.UI.Color(0.3, 0.3, 0.3));
    end
    if (description ~= nil) then
        self:AddLayer(description, Turbine.UI.Color(1, 1, 1), nil, Turbine.UI.Lotro.Font.Verdana14);
    end
end

function GenericTooltip:AddLayer(text, color, layout, font, style, styleColor)
    local descriptionNode = DiaryEntryNode(self.tooltipTreeView:GetWidth());
    descriptionNode:SetFore(color, font, layout, style, styleColor);
    descriptionNode:UpdateText(text);
    self.tooltipTreeView:GetNodes():Add(descriptionNode);
    self:SetHeight(self:GetHeight() + descriptionNode:GetHeight());
    self.tooltipTreeView:SetHeight(self.tooltipTreeView:GetHeight() + descriptionNode:GetHeight());
    self:UpdateBackground();
end

function GenericTooltip:AddPictureHeader(picture, text, color, layout)
    local node = Turbine.UI.TreeNode();
    node:SetSize(self.tooltipTreeView:GetWidth(), 42);
    local icone = Turbine.UI.Label();
    icone:SetParent(node);
    icone:SetPosition(5, 5);
    icone:SetSize(32, 32);
    icone:SetBackground(picture or "PimpYourText/pictures/tooltips/default.jpg");
    icone:SetBlendMode(Turbine.UI.BlendMode.AlphaBlend);
    icone:SetMouseVisible(false);
    local itemName = Turbine.UI.Label();
    itemName:SetParent(self);
    itemName:SetPosition(55, 10);
    itemName:SetSize(self.tooltipTreeView:GetWidth() - 55 - 5, 42);
    itemName:SetTextAlignment(Turbine.UI.ContentAlignment.MiddleCenter);
    if (layout ~= nil) then itemName:SetTextAlignment(layout); end
    if (color ~= nil) then itemName:SetForeColor(color); end
    itemName:SetFont(Turbine.UI.Lotro.Font.TrajanPro23);
    itemName:SetBlendMode(Turbine.UI.BlendMode.AlphaBlend);
    itemName:SetMouseVisible(false);
    self.testScrollBar = Turbine.UI.Lotro.ScrollBar();
    self.testScrollBar:SetOrientation(Turbine.UI.Orientation.Vertical);
    self.testScrollBar:SetParent(self);
    self.testScrollBar:SetPosition(itemName:GetLeft() + itemName:GetWidth(), itemName:GetTop());
    self.testScrollBar:SetSize(10, itemName:GetHeight());
    itemName:SetVerticalScrollBar(self.testScrollBar);
    itemName:SetText(text);
    if (self.testScrollBar:IsVisible()) then
        itemName:SetFont(Turbine.UI.Lotro.Font.TrajanPro20);
        itemName:SetText(text);
        if (self.testScrollBar:IsVisible()) then
            itemName:SetFont(Turbine.UI.Lotro.Font.TrajanPro16);
            itemName:SetText(text);
            if (self.testScrollBar:IsVisible()) then
                itemName:SetFont(Turbine.UI.Lotro.Font.TrajanPro13);
                itemName:SetText(text);
            end
        end
    end
    self.tooltipTreeView:GetNodes():Add(node);
    self:SetHeight(self:GetHeight() + node:GetHeight());
    self.tooltipTreeView:SetHeight(self.tooltipTreeView:GetHeight() + node:GetHeight());
    self:UpdateBackground();
end

function GenericTooltip:BuildBackground()
    local backUp = Turbine.UI.Label();
    backUp:SetParent(self);
    backUp:SetPosition(0, 0);
    backUp:SetSize(300, 23);
    backUp:SetBackground("PimpYourText/pictures/tooltips/tooltip_top.tga");
    backUp:SetBlendMode(Turbine.UI.BlendMode.AlphaBlend);
    backUp:SetMouseVisible(false);

    self.backMid = Turbine.UI.Label();
    self.backMid:SetParent(self);
    self.backMid:SetPosition(0, 23);
    self.backMid:SetSize(300, 1);
    self.backMid:SetBackground("PimpYourText/pictures/tooltips/tooltip_mid.tga");
    self.backMid:SetMouseVisible(false);

    self.backBottom = Turbine.UI.Label();
    self.backBottom:SetParent(self);
    self.backBottom:SetSize(300, 23);
    self.backBottom:SetBackground("PimpYourText/pictures/tooltips/tooltip_bottom.tga");
    self.backBottom:SetMouseVisible(false);
end

function GenericTooltip:UpdateBackground()
    self.backMid:SetSize(300, self:GetHeight() - 46);
    self.backBottom:SetPosition(0, self:GetHeight() - 23);
end
