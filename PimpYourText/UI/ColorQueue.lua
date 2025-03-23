import "PimpYourText.UI.ColorPreview";
import "PimpYourText.UI.ColorPicker";

ColorQueue = class(Turbine.UI.Label);

function ColorQueue:Constructor(width, height, updateFct)
    self.updateFct = updateFct;
    self.maxColors = 1;
    self.minColors = 1;

    Turbine.UI.Label.Constructor(self);
    self:SetSize(width, height);

    self.previews = {};

    self.addIcone = Turbine.UI.Control();
    self.addIcone:SetParent(self);
    self.addIcone:SetBackground("PimpYourText/pictures/closeAdd.tga");
    self.addIcone.tooltip = GenericTooltip(self.addIcone);
    self.addIcone.tooltip:AddLayer(TranslateText("ADDICO_TOOLTIP"), Turbine.UI.Color(1, 1, 1), Turbine.UI.ContentAlignment.TopLeft,
        Turbine.UI.Lotro.Font.Verdana14, nil);
    self.addIcone:SetBlendMode(Turbine.UI.BlendMode.AlphaBlend);
    self.addIcone:SetSize(16, 16);
    self.addIcone.MouseClick = function(sender, args)
        self:CreatePreviewCmp(pos, "FFFFFF");
        self:UpdateQueuePositions();
        if (self.updateFct ~= nil) then self.updateFct(); end
    end
    self.addIcone:SetVisible(false);
    self:SetMouseVisible(false);
end

function ColorQueue:GetQueueList()
    local list = {};
    for i, j in pairs(self.previews) do
        table.insert(list, j:GetRGB());
        j:SetPosition(24 * (i - 1), 0);
    end
    return list;
end

function ColorQueue:SetPreset(rgbList, preset)
    if (preset == 2 or preset == 3 or preset == 4) then
        self.maxColors = 6;
        self.minColors = 2;
        if (rgbList == nil or table.getn(rgbList) < self.minColors or table.getn(rgbList) > self.maxColors) then
            rgbList = {
                "0000FF", "FFFFFF" };
        end
    else
        if (rgbList == nil) then rgbList = { "0000FF" }; end
        self.maxColors = 1;
        self.minColors = 1;
        if (rgbList == nil or table.getn(rgbList) ~= 1) then rgbList = { "0000FF" }; end
    end
    for i, v in ipairs(self.previews) do
        v:SetParent(nil);
        v = nil;
    end
    self.previews = {};

    for i, v in ipairs(rgbList) do
        self:CreatePreviewCmp(i, v);
    end
    self:UpdateQueuePositions();
end

function ColorQueue:ClickFct(previewCpt)
    if (self.colorPicker == nil) then
        self.colorPicker = ColorPicker();
        self.colorPicker:SetParent(self:GetParent());
    end
    self.colorPicker:SetPosition(self:GetLeft() + previewCpt:GetLeft() - 5, self:GetTop() + previewCpt:GetTop() - 80);
    changeFct = function(newrgb)
        previewCpt:SetRGB(newrgb);
        if (self.updateFct ~= nil) then self.updateFct(); end
    end
    removeFct = function()
        local found = false;
        for i, j in pairs(self.previews) do
            if (j == previewCpt) then
                j:SetParent(nil);
                j = nil;
                table.remove(self.previews, i);
                found = true;
            end
            if (self.updateFct ~= nil) then self.updateFct(); end
        end

        if (found == true) then
            self:UpdateQueuePositions();
        end
    end
    self.colorPicker:Reset(previewCpt:GetRGB(), self.minColors < table.getn(self.previews), changeFct, removeFct);
    self.colorPicker:SetVisible(true);
end

function ColorQueue:UpdateQueuePositions()
    for i, j in pairs(self.previews) do
        j:SetPosition(24 * (i - 1), 0);
    end
    self.addIcone:SetVisible(table.getn(self.previews) < self.maxColors);
    self.addIcone:SetPosition(24 * table.getn(self.previews), 2);
end

function ColorQueue:CreatePreviewCmp(pos, color)
    onClickFct = function(sender, args)
        self:ClickFct(sender, args);
    end
    local p = ColorPreview(color, onClickFct);
    p:SetParent(self);
    table.insert(self.previews, p);
end

function ColorQueue:SetRGB(rgb)
    if (rgb == nil or rgb == "") then rgb = self.rgbList[1]; end

    self.colorArea:SetText(rgb);

    for i = 1, table.getn(self.rgbList), 1 do
        if (self.rgbList[i] == rgb) then
            self.colorDropDown:SetLabel(self.colorList[i]);
            self:UpdatePreview();
            return;
        end
    end
    self.colorDropDown:SetLabel(self.colorList[table.getn(self.colorList)]);
    self:UpdatePreview();
end

function ColorQueue:UpdatePreview()
    if (string.len(self.colorArea:GetText()) ~= 6) then
        self.colorPreview:SetVisible(false);
        return;
    end
    local r = self:GetByte(self.colorArea:GetText() or "", 1);
    local g = self:GetByte(self.colorArea:GetText() or "", 2);
    local b = self:GetByte(self.colorArea:GetText() or "", 3);
    if (r ~= nil and r >= 0 and r <= 256 and g ~= nil and g >= 0 and g <= 256 and b ~= nil and b >= 0 and b <= 256) then
        self.colorPreview:SetBackColor(Turbine.UI.Color(r / 255, g / 255, b / 255));
        self.colorPreview:SetVisible(true);
    else
        self.colorPreview:SetVisible(false);
    end
end

function ColorQueue:GetRGB()
    return self.colorArea:GetText();
end

function ColorQueue:GetByte(rgb, w)
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
