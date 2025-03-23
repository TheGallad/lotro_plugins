import "PimpYourText.Utils.UTF";
import "PimpYourText.UI.DropDown";
import "PimpYourText.UI.GenericTooltip";
import "PimpYourText.UI.ColorQueue";


_G.PimpYourText = class(Turbine.UI.Lotro.Window);

function PimpYourText:Constructor()
    Turbine.UI.Lotro.Window.Constructor(self);

    self:SetSize(settings.mwindow_width or 350, settings.mwindow_height or 205);
    self:SetPosition(settings.main_x, settings.main_y);
    self:SetVisible(false);

    self:SetText("Pimp Your Text!");

    -- Build GUI and logicals
    self:CreateComponents();

    self.PositionChanged = function(sender, args)
        settings.main_x, settings.main_y = self:GetPosition();
        Savesettings();
    end

    self.Closed = function(sender, args)
        if (settings.autoShowLaunchingMessage ~= false) then
            Turbine.Shell.WriteLine(TranslateText("HIDE"));
        end
        self:Stop();
    end

    self.localBuffer = {};
    self:SwitchTab((settings.currenttab or 1) - 1, true);
    self:UpdateValidationButton();
    self.colorTypeDropDown:ItemChanged();
    self:UpdateResponsive();
end

function PimpYourText:CreateComponents()
    -- Custom text to send
    self.textArea = Turbine.UI.Lotro.TextBox();
    self.textArea:SetParent(self);
    self.textArea:SetPosition(25, 55);
    self.textArea:SetFont(Turbine.UI.Lotro.Font.Verdana16);

    self.textArea.FocusLost = function()
        self:UpdateValidationButton();
    end
    self.textArea.TextChanged = function()
        self:UpdateValidationButton();
    end
    -- API BUG => bad mgnt of scrollbars
    local scrollBar = Turbine.UI.Lotro.ScrollBar();
    scrollBar:SetOrientation(Turbine.UI.Orientation.Vertical);
    scrollBar:SetParent(self);
    scrollBar:SetPosition(self.textArea:GetLeft() + self.textArea:GetWidth(), self.textArea:GetTop());
    scrollBar:SetSize(10, self.textArea:GetHeight());
    self.textArea:SetVerticalScrollBar(scrollBar);

    -- Create childs GUIs
    self:CreateToolscomponents();
    self:CreateSwitchComponents();
    self:CreateColorComponents();
    self:CreateDestComponents();
    self:CreateGeneratorComponents();

    self.resizer = Turbine.UI.Label();
    self.resizer:SetParent(self);
    self.resizer:SetSize(45, 45);
    self.resizer:SetBlendMode(Turbine.UI.BlendMode.AlphaBlend);
    self.resizer:SetBackground("PimpYourText/pictures/panel_resize_icon.tga");
    self.resizer:SetZOrder(self:GetZOrder() + 10);
    self.resizer.MouseDown = function(sender, args)
        if (args.Button == Turbine.UI.MouseButton.Left) then
            sender.dragStartX = args.X;
            sender.dragStartY = args.Y;
            sender.dragging = true;
            sender.dragged = false;
        end
    end
    self.resizer.MouseUp = function(sender, args)
        if (args.Button == Turbine.UI.MouseButton.Left) then
            if (sender.dragging) then
                sender.dragging = false;
            end
            settings.mwindow_height = self:GetHeight();
            settings.mwindow_width = self:GetWidth();
            Savesettings();
        end
    end
    self.resizer.MouseMove = function(sender, args)
        if (sender.dragging) then
            local height = self:GetHeight() + args.Y - sender.dragStartY;
            local width = self:GetWidth() + args.X - sender.dragStartX;
            if (height > 207) then
                self:SetHeight(height);
                self:UpdateResponsive();
            end
            if (width > 350) then
                self:SetWidth(width);
                self:UpdateResponsive();
            end
            self:UpdateResponsive();
        end
    end
end

function PimpYourText:CreateColorComponents()
    self.colorTypeList = { TranslateText("COLOR_T1"), TranslateText("COLOR_T2"), TranslateText("COLOR_T3"), TranslateText("COLOR_T4") };
    self.colorTypeDropDown = DropDown.Create(self.colorTypeList, self.colorTypeList[settings.mwindow_height or 1]);
    self.colorTypeDropDown:SetParent(self);
    self.colorTypeDropDown.myElementList = elementList;
    self.colorTypeDropDown:ApplyWidth(200);
    self.colorTypeDropDown.ItemChanged = function()
        for i = 1, table.getn(self.canalList), 1 do
            -- DAMNED LOOP replacing the combobox lack of returning infos
            if (self.colorTypeList[i] == self.colorTypeDropDown:GetText()) then
                local rgbList = nil;
                if (i == 2) then
                    if (table.getn(self.colorQueue:GetQueueList()) > 1) then
                        rgbList = self.colorQueue:GetQueueList();
                    elseif (settings.loadData ~= nil and settings.loadData[self.tabLabel.selectedValue] ~= nil and settings.loadData[self.tabLabel.selectedValue].rgbList ~= nil and table.getn(settings.loadData[self.tabLabel.selectedValue].rgbList) > 1) then
                        rgbList = settings.loadData[self.tabLabel.selectedValue].rgbList;
                    else
                        rgbList = settings.rainbowColors or
                            { "FF0000", "FFFF00", "00FF00", "38E5DF", "FF5CCD", "FF00FF" };
                    end
                elseif (i > 1 and table.getn(self.colorQueue:GetQueueList()) > 1) then
                    if (settings.loadData ~= nil and settings.loadData[self.tabLabel.selectedValue] ~= nil and settings.loadData[self.tabLabel.selectedValue].rgbList ~= nil) then
                        rgbList = settings.loadData[self.tabLabel.selectedValue].rgbList;
                    else
                        rgbList = self.colorQueue:GetQueueList();
                    end
                end
                self.colorQueue:SetPreset(rgbList, i);
                self.colorTypeId = i;
                self:UpdateValidationButton();
                break;
            end
        end
        self.addColorTagBtn:SetVisible(self.colorTypeId == 1 or self.colorTypeId == nil);
        self.addDefaultTagBtn:SetVisible(self.colorTypeId == 1 or self.colorTypeId == nil);
        self.addUnderTagBtn:SetVisible(self.colorTypeId == 1 or self.colorTypeId == nil);
        self.addUnderCTagBtn:SetVisible(self.colorTypeId == 1 or self.colorTypeId == nil);
        self.removeTagBtn:SetVisible(self.colorTypeId == 1 or self.colorTypeId == nil);
    end
    updateFct = function()
        self:UpdateValidationButton();
    end
    self.colorQueue = ColorQueue(210, 20, updateFct);
    self.colorQueue:SetParent(self);
end

-- Create Chanels components (DropDown box and textbox) and logical
function PimpYourText:CreateDestComponents()
    local label = Turbine.UI.Label();
    label:SetParent(self);
    label:SetPosition(15, 39);
    label:SetSize(150, 20);
    label:SetMultiline(false);
    label:SetText(TranslateText("CHANNEL"));

    -- Insert in this field your buddy' name
    self.destArea = Turbine.UI.Lotro.TextBox();
    self.destArea:SetParent(self);
    self.destArea:SetPosition(240, 33);
    self.destArea:SetSize(70, 20);
    self.destArea:SetMultiline(false);
    self.destArea:SetText("");
    self.destArea:SetEnabled(false);
    self.destArea:SetFont(Turbine.UI.Lotro.Font.Verdana14);
    self.destArea.FocusLost = function()
        -- Damn, your buddy has an empty name... too cruel to be real !
        if (string.len(self.destArea:GetText()) == 0) then
            Turbine.Shell.WriteLine(TranslateText("ERROR_DEST"));
        else
            self:UpdateValidationButton();
        end
    end
    self.destArea.TextChanged = function()
        self:UpdateValidationButton();
    end
    -- Combobox with channels list
    self.canalList = { TranslateText("CHANNEL_TALK"), TranslateText("CHANNEL_COMM"), TranslateText("CHANNEL_CONF"), TranslateText("CHANNEL_RAID"), TranslateText("CHANNEL_WORLD"), TranslateText(
        "CHANNEL_MI"), TranslateText("CHANNEL_OFF"), TranslateText("CHANNEL_MDJ"), TranslateText("CHANNEL_RDC"), TranslateText("CHANNEL_CUST1"), TranslateText("CHANNEL_CUST2"), TranslateText(
        "CHANNEL_CUST3"), TranslateText("CHANNEL_CUST4"), TranslateText("CHANNEL_CUST5"), TranslateText("CHANNEL_CUST6"), TranslateText("CHANNEL_CUST7"), TranslateText(
        "CHANNEL_CUST8") };
    self.commandList = { TranslateText("CHANNEL_TALK_C"), TranslateText("CHANNEL_COMM_C"), TranslateText("CHANNEL_CONF_C"), TranslateText("CHANNEL_RAID_C"), TranslateText(
        "CHANNEL_WORLD_C"), TranslateText("CHANNEL_MI_C"), TranslateText("CHANNEL_OFF_C"), TranslateText("CHANNEL_MDJ_C"), TranslateText("CHANNEL_RDC_C"), TranslateText(
        "CHANNEL_CUST1_C"), TranslateText("CHANNEL_CUST2_C"), TranslateText("CHANNEL_CUST3_C"), TranslateText("CHANNEL_CUST4_C"), TranslateText("CHANNEL_CUST5_C"), TranslateText(
        "CHANNEL_CUST6_C"), TranslateText("CHANNEL_CUST7_C"), TranslateText("CHANNEL_CUST8_C") };
    self.commandid = 1;
    if (settings.loadData ~= nil and settings.loadData.command ~= nil) then
        self.commandid = settings.loadData.command;
    end

    self.command = self.commandList[self.commandid];
    self.commandDropDown = DropDown.Create(self.canalList, self.canalList[self.commandid]);
    self.commandDropDown:SetParent(self);
    self.commandDropDown:SetPosition(80, self.destArea:GetTop());
    self.commandDropDown.myElementList = elementList;
    self.commandDropDown:ApplyWidth(150);
    self.commandDropDown:SetMaxItems(11);
    self.commandDropDown.ItemChanged = function()
        for i = 1, table.getn(self.canalList), 1 do
            -- DAMNED LOOP replacing the combobox lack of returning infos
            if (self.canalList[i] == self.commandDropDown:GetText()) then
                if (i == 6) then
                    self.destArea:Focus();
                end
                self.command = self.commandList[i];
                self:UpdateValidationButton();
                self.commandid = i;
                break;
            end
        end
        self.destArea:SetEnabled(self.commandid == 6);
        self.destArea:SetVisible(self.commandid == 6);
        self:UpdateValidationButton();
    end
    self.destArea:SetEnabled(self.commandid == 6);
    self.destArea:SetVisible(self.commandid == 6);
end

function PimpYourText:CreateSwitchComponents()
    self.tabLabel = Turbine.UI.Label();
    self.tabLabel:SetParent(self);
    self.tabLabel:SetFont(Turbine.UI.Lotro.Font.TrajanProBold16);
    self.tabLabel:SetTextAlignment(Turbine.UI.ContentAlignment.MiddleCenter);
    self.tabLabel:SetForeColor(Turbine.UI.Color(1, 223 / 255, 0));
    self.tabLabel:SetText("1");
    self.tabLabel.selectedValue = 1;
    self.tabLabel:SetPosition(8, 100);
    self.tabLabel:SetSize(16, 16);

    self.upBtn = Turbine.UI.Control();
    self.upBtn:SetParent(self);
    self.upBtn:SetBackground("PimpYourText/pictures/scrollbar_10_downarrow.tga");
    self.upBtn.tooltip = GenericTooltip(self.upBtn);
    self.upBtn.tooltip:AddLayer(TranslateText("TAB_UP"), Turbine.UI.Color(1, 1, 1), Turbine.UI.ContentAlignment.TopLeft,
        Turbine.UI.Lotro.Font.Verdana14, nil);
    self.upBtn:SetBlendMode(Turbine.UI.BlendMode.AlphaBlend);
    self.upBtn:SetPosition(11, self.tabLabel:GetTop() - 20);
    self.upBtn:SetSize(10, 10);
    self.upBtn.MouseClick = function(sender, args)
        self:SwitchTab(1);
    end

    self.downBtn = Turbine.UI.Control();
    self.downBtn:SetParent(self);
    self.downBtn:SetBackground("PimpYourText/pictures/scrollbar_10_uparrow.tga");
    self.downBtn.tooltip = GenericTooltip(self.downBtn);
    self.downBtn.tooltip:AddLayer(TranslateText("TAB_DOWN"), Turbine.UI.Color(1, 1, 1), Turbine.UI.ContentAlignment.TopLeft,
        Turbine.UI.Lotro.Font.Verdana14, nil);
    self.downBtn:SetBlendMode(Turbine.UI.BlendMode.AlphaBlend);
    self.downBtn:SetPosition(11, self.tabLabel:GetTop() + 25);
    self.downBtn:SetSize(10, 10);
    self.downBtn.MouseClick = function(sender, args)
        self:SwitchTab(-1);
    end
end

function PimpYourText:CreateToolscomponents()
    self.resetBtn = Turbine.UI.Label();
    self.resetBtn:SetParent(self);
    self.resetBtn:SetBackground("PimpYourText/pictures/delete.jpg");
    self.resetBtn:SetSize(16, 16);
    self.resetBtn:SetBlendMode(Turbine.UI.BlendMode.AlphaBlend);
    self.resetBtn.tooltip = GenericTooltip(self.resetBtn, TranslateText("RESET"), TranslateText("RESET_BTN"));
    self.resetBtn.MouseClick = function(sender, args)
        self.textArea:SetText("");
    end

    self.saveBtn = Turbine.UI.Label();
    self.saveBtn:SetParent(self);
    self.saveBtn:SetBackground("PimpYourText/pictures/plume.jpg");
    self.saveBtn:SetSize(16, 16);
    self.saveBtn.tooltip = GenericTooltip(self.saveBtn, TranslateText("SAVE"), TranslateText("SAVE_BTN"));
    self.saveBtn:SetBlendMode(Turbine.UI.BlendMode.AlphaBlend);
    self.saveBtn.MouseClick = function(sender, args)
        if (settings.loadData == nil) then settings.loadData = {}; end
        if (settings.loadData[self.tabLabel.selectedValue] == nil) then settings.loadData[self.tabLabel.selectedValue] = {}; end
        settings.loadData[self.tabLabel.selectedValue] = {
            colorTypeId = self.colorTypeId,
            text = self.textArea:GetText(),
            color = self.colorid,
            rgbList = self.colorQueue:GetQueueList(),
            command = self.commandid,
            dest = self.destArea:GetText(),
        };
        Savesettings();
    end
    self.addColorTagBtn = Turbine.UI.Label();
    self.addColorTagBtn:SetParent(self);
    self.addColorTagBtn:SetSize(20, 20);
    self.addColorTagBtn.tooltip = GenericTooltip(self.addColorTagBtn, TranslateText("CTAG1_BTN"), TranslateText("CTAG2_BTN"));
    self.addColorTagBtn:SetBackground("PimpYourText/pictures/tagCOpen.jpg");
    self.addColorTagBtn.MouseClick = function(sender, args)
        self.textArea:InsertText("<rgb=#" .. self.colorQueue:GetQueueList()[1] .. ">");
        self:UpdateValidationButton();
    end
    self.addDefaultTagBtn = Turbine.UI.Label();
    self.addDefaultTagBtn:SetParent(self);
    self.addDefaultTagBtn:SetSize(20, 20);
    self.addDefaultTagBtn.tooltip = GenericTooltip(self.addDefaultTagBtn, TranslateText("CFTAG1_BTN"), TranslateText("CFTAG2_BTN"));
    self.addDefaultTagBtn:SetBackground("PimpYourText/pictures/tagCClose.jpg");
    self.addDefaultTagBtn.MouseClick = function(sender, args)
        self.textArea:InsertText("</rgb>");
        self:UpdateValidationButton();
    end
    self.addUnderTagBtn = Turbine.UI.Label();
    self.addUnderTagBtn:SetParent(self);
    self.addUnderTagBtn:SetSize(20, 20);
    self.addUnderTagBtn.tooltip = GenericTooltip(self.addUnderTagBtn, TranslateText("UTAG1_BTN"), TranslateText("UTAG2_BTN"));
    self.addUnderTagBtn:SetBackground("PimpYourText/pictures/tagUOpen.jpg");
    self.addUnderTagBtn.MouseClick = function(sender, args)
        self.textArea:InsertText("<u>");
        self:UpdateValidationButton();
    end
    self.addUnderCTagBtn = Turbine.UI.Label();
    self.addUnderCTagBtn:SetParent(self);
    self.addUnderCTagBtn:SetSize(20, 20);
    self.addUnderCTagBtn.tooltip = GenericTooltip(self.addUnderCTagBtn, TranslateText("UFTAG1_BTN"), TranslateText("UFTAG2_BTN"));
    self.addUnderCTagBtn:SetBackground("PimpYourText/pictures/tagUClose.jpg");
    self.addUnderCTagBtn.MouseClick = function(sender, args)
        self.textArea:InsertText("</u>");
        self:UpdateValidationButton();
    end
    self.removeTagBtn = Turbine.UI.Label();
    self.removeTagBtn:SetParent(self);
    self.removeTagBtn:SetSize(20, 20);
    self.removeTagBtn.tooltip = GenericTooltip(self.removeTagBtn, TranslateText("RTAG1_BTN"), TranslateText("RTAG2_BTN"));
    self.removeTagBtn:SetBackground("PimpYourText/pictures/tag.jpg");
    self.removeTagBtn.MouseClick = function(sender, args)
        self.textArea:SetText(string.gsub(self.textArea:GetText(), "<.->", ""));
        self:UpdateValidationButton();
    end

    self.configBtn = Turbine.UI.Label();
    self.configBtn:SetParent(self);
    self.configBtn:SetBackground("PimpYourText/pictures/config.jpg");
    self.configBtn:SetSize(16, 16);
    self.configBtn.tooltip = GenericTooltip(self.configBtn, "Configuration", TranslateText("CONFIG_BTN"));
    self.configBtn.MouseClick = function(sender, args)
        local optionDialog = BuildConfigDialog();
        optionDialog:SetVisible(true);
    end
end

-- Build the sending button
function PimpYourText:CreateGeneratorComponents()
    -- This is the Quickslot, the shortcut container
    self.qsValid = Turbine.UI.Lotro.Quickslot();
    self.qsValid:SetParent(self);
    self.qsValid:SetSize(78, 44);
    self.qsValid:SetPosition(260, 142);
    self.qsValid:SetVisible(true);
    self.qsValid:SetShortcut(Turbine.UI.Lotro.Shortcut(Turbine.UI.Lotro.ShortcutType.Alias,
        "/raid <rgb=#FF5CCD>TEMP MSG :P</rgb>")); -- rose = FF5CCD
    self.qsValid:SetAllowDrop(false);
    self.qsValid:SetEnabled(true);
    self.qsValid.ShortcutChanged = function()
        if (self.qsValid:GetShortcut() == nil or self.qsValid:GetShortcut():GetData() == "") then
            self:UpdateValidationButton();
        end
    end
    self.qsValid.MouseMove = function()
        self.qsValid:Focus();
    end
    self.qsValid.MouseEnter = function()
        self.qsValid:Focus();
    end

    -- A basic control on the quickslot for cosmetic purpose
    self.qsLbl = Turbine.UI.Control();
    self.qsLbl:SetParent(self);
    self.qsLbl:SetSize(self.qsValid:GetSize());
    self.qsLbl:SetPosition(self.qsValid:GetLeft(), self.qsValid:GetTop());
    self.qsLbl:SetMouseVisible(false);
    self.qsLbl:SetZOrder(10000);

    -- A basic label on the basic control for cosmetic purpose ++
    local c = Turbine.UI.Label()
    c:SetParent(self.qsLbl);
    c:SetPosition(1, 1);
    c:SetForeColor(Turbine.UI.Color(1, 223 / 255, 0));
    c:SetSize(self.qsLbl:GetWidth() - 2, self.qsLbl:GetHeight() - 2);
    c:SetFontStyle(Turbine.UI.FontStyle.Outline);
    c:SetTextAlignment(Turbine.UI.ContentAlignment.MiddleCenter);
    c:SetBlendMode(Turbine.UI.BlendMode.AlphaBlend);
    c:SetBackground("PimpYourText/pictures/role_button_normal.tga");
    c:SetMouseVisible(false);
    c:SetZOrder(10001);
    c:SetText(TranslateText("SENDMESSAGE"));
end

-- Update the sending button
function PimpYourText:UpdateValidationButton()
    local text = FromUTF8(self.textArea:GetText());

    if (self.colorTypeId == 2) then
        text = string.gsub(text, "<.->", "");
        local rainbowList = self.colorQueue:GetQueueList() or
            { "FF0000", "FFFF00", "00FF00", "38E5DF", "FF5CCD", "FF00FF" };
        local str = "";
        local colorCount = table.getn(rainbowList);
        local dec = math.random(colorCount);
        for i = 1, text:len() do
            local c = text:sub(i, i);
            if (c == " " or c == "\n") then
                str = str .. c;
            else
                str = str .. "<rgb=#" .. rainbowList[(i + dec) % colorCount + 1] .. ">" .. c;
            end
        end
        text = str;
    elseif (self.colorTypeId == 3) then
        text = string.gsub(text, "<.->", "");
        local colors = self.colorQueue:GetQueueList();
        local str = "";
        for i = 1, table.getn(colors) - 1 do
            local taille = math.floor(text:len() / (table.getn(colors) - 1));
            local startId = 1 + (i - 1) * taille;
            local endId = i * taille;
            if (i == table.getn(colors) - 1) then
                endId = text:len();
            end
            local rgb1 = colors[i];
            local rgb2 = colors[i + 1];
            local r1 = self.colorQueue:GetByte(rgb1, 1);
            local g1 = self.colorQueue:GetByte(rgb1, 2);
            local b1 = self.colorQueue:GetByte(rgb1, 3);
            local r2 = self.colorQueue:GetByte(rgb2, 1);
            local g2 = self.colorQueue:GetByte(rgb2, 2);
            local b2 = self.colorQueue:GetByte(rgb2, 3);
            for j = startId, endId do
                local c = text:sub(j, j);
                if (c == " " or c == "\n") then
                    str = str .. c;
                else
                    local conv = self:ToRGB(
                        r1 + math.floor((j - startId) * (r2 - r1) / (endId - startId + 1)),
                        g1 + math.floor((j - startId) * (g2 - g1) / (endId - startId + 1)),
                        b1 + math.floor((j - startId) * (b2 - b1) / (endId - startId + 1)));
                    str = str .. "<rgb=#" .. (conv or rgb1) .. ">" .. c;
                end
            end
        end
        text = str;
    elseif (self.colorTypeId == 4) then
        text = string.gsub(text, "<.->", "");
        local str = "";
        local colors = self.colorQueue:GetQueueList();
        local size = 6;
        local colordec = 0;
        local r1 = 0; local g1 = 0; local b1 = 0; local r2 = 0; local g2 = 0; local b2 = 0; local rgb1 = nil; local rgb2 = nil;
        for i = 1, text:len() do
            local id = math.fmod(i - 1, size);
            local c = text:sub(i, i);
            if (id == 0) then
                local colorid1 = math.mod(colordec, table.getn(colors));
                local colorid2 = math.mod(colordec + 1, table.getn(colors));
                rgb1 = colors[colorid1 + 1];
                rgb2 = colors[colorid2 + 1];
                colordec = colordec + 1;
                r1 = self.colorQueue:GetByte(rgb1, 1);
                g1 = self.colorQueue:GetByte(rgb1, 2);
                b1 = self.colorQueue:GetByte(rgb1, 3);
                r2 = self.colorQueue:GetByte(rgb2, 1);
                g2 = self.colorQueue:GetByte(rgb2, 2);
                b2 = self.colorQueue:GetByte(rgb2, 3);
            end
            if (c == " " or c == "\n") then
                str = str .. c;
            else
                local conv = self:ToRGB(
                    r1 + math.floor(id * (r2 - r1) / (size)),
                    g1 + math.floor(id * (g2 - g1) / (size)),
                    b1 + math.floor(id * (b2 - b1) / (size)));
                str = str .. "<rgb=#" .. conv .. ">" .. c;
            end
        end
        text = str;
    end

    local finalcommand = self.command .. " " .. text;
    -- Apply MI command
    if (self.commandid == 6) then
        finalcommand = self.command .. " " .. self.destArea:GetText() .. " " .. text;
    end
    -- Apply Message of the Day command
    if (self.commandid == 8) then
        finalcommand = self.command .. " \"" .. text .. "\"";
    end

    local tmpShortcut = Turbine.UI.Lotro.Shortcut(Turbine.UI.Lotro.ShortcutType.Alias, "");
    tmpShortcut:SetData(finalcommand);

    self.qsValid:SetShortcut(tmpShortcut);
end

function PimpYourText:ToRGB(r, g, b)
    local str = "";
    local a1; local a2;
    a1 = math.floor(r / 16);
    a2 = math.fmod(r, 16);
    if (a1 < 10) then str = str .. string.char(a1 + 48); else str = str .. string.char(a1 + 55); end
    if (a2 < 10) then str = str .. string.char(a2 + 48); else str = str .. string.char(a2 + 55); end
    a1 = math.floor(g / 16); a2 = math.fmod(g, 16);
    if (a1 < 10) then str = str .. string.char(a1 + 48); else str = str .. string.char(a1 + 55); end
    if (a2 < 10) then str = str .. string.char(a2 + 48); else str = str .. string.char(a2 + 55); end
    a1 = math.floor(b / 16); a2 = math.fmod(b, 16);
    if (a1 < 10) then str = str .. string.char(a1 + 48); else str = str .. string.char(a1 + 55); end
    if (a2 < 10) then str = str .. string.char(a2 + 48); else str = str .. string.char(a2 + 55); end
    return str;
end

-- reload components data
function PimpYourText:SwitchTab(delta, firstload)
    if (delta == nil) then return; end;

    local previousTabId = self.tabLabel.selectedValue;
    self.tabLabel.selectedValue = 1 + (self.tabLabel.selectedValue - 1 + delta) % 8;
    self.tabLabel:SetText(self.tabLabel.selectedValue);
    local loadDefaultValues = false;

    if (previousTabId == self.tabLabel.selectedValue) then -- on recharge depuis les fichiers de config
        if (settings.loadData ~= nil and settings.loadData[self.tabLabel.selectedValue] ~= nil) then
            self.textArea:SetText(settings.loadData[self.tabLabel.selectedValue].text);
            self.destArea:SetText(settings.loadData[self.tabLabel.selectedValue or 1].dest);
            self.commandid = settings.loadData[self.tabLabel.selectedValue or 1].command;
            self.command = self.commandList[self.commandid or 1];
            self.commandDropDown:SetLabel(self.canalList[self.commandid]);
            self.colorTypeId = settings.loadData[self.tabLabel.selectedValue].colorTypeId;
            self.colorTypeDropDown:SetLabel(self.colorTypeList[self.colorTypeId or 1]);
            self.colorQueue:SetPreset(settings.loadData[self.tabLabel.selectedValue or 1].rgbList, self.colorTypeId);
            self.colorTypeDropDown:SetLabel(self.colorTypeList[self.colorTypeId or 1]);
        else -- default values
            loadDefaultValues = true;
        end
    else
        if (firstload ~= true) then
            if (self.localBuffer[previousTabId] == nil) then self.localBuffer[previousTabId] = {}; end
            self.localBuffer[previousTabId].text = self.textArea:GetText();
            self.localBuffer[previousTabId].command = self.commandid;
            self.localBuffer[previousTabId].dest = self.destArea:GetText();
            self.localBuffer[previousTabId].colorTypeId = self.colorTypeId;
            self.localBuffer[previousTabId].rgbList = self.colorQueue:GetQueueList();
        end
        if (self.localBuffer[self.tabLabel.selectedValue] ~= nil and self.localBuffer[self.tabLabel.selectedValue].text ~= nil) then
            -- chargement des données depuis le buffer / self.localBuffer[self.tabLabel.selectedValue]
            self.textArea:SetText(self.localBuffer[self.tabLabel.selectedValue].text);
            self.destArea:SetText(self.localBuffer[self.tabLabel.selectedValue].dest);
            self.commandid = self.localBuffer[self.tabLabel.selectedValue].command;
            self.commandDropDown:SetLabel(self.canalList[self.commandid]);
            self.command = self.commandList[self.commandid];
            self.colorTypeId = self.localBuffer[self.tabLabel.selectedValue].colorTypeId;
            self.colorTypeDropDown:SetLabel(self.colorTypeList[self.colorTypeId or 1]);
            self.colorQueue:SetPreset(self.localBuffer[self.tabLabel.selectedValue].rgbList, self.colorTypeId);
        elseif (settings.loadData ~= nil and settings.loadData[self.tabLabel.selectedValue] ~= nil) then
            -- chargement des données depuis le fichier de sauvegarde
            self.textArea:SetText(settings.loadData[self.tabLabel.selectedValue].text);
            self.destArea:SetText(settings.loadData[self.tabLabel.selectedValue].dest);
            self.commandid = settings.loadData[self.tabLabel.selectedValue].command;
            self.commandDropDown:SetLabel(self.canalList[self.commandid]);
            self.command = self.commandList[self.commandid];
            self.colorTypeId = settings.loadData[self.tabLabel.selectedValue].colorTypeId or 1;
            self.colorTypeDropDown:SetLabel(self.colorTypeList[self.colorTypeId or 1]);
            self.colorQueue:SetPreset(settings.loadData[self.tabLabel.selectedValue].rgbList, self.colorTypeId);
        else
            loadDefaultValues = true;
        end
    end


    if loadDefaultValues == true then
        self.textArea:SetText(TranslateText("DEFAULT_TXT"));
        self.destArea:SetText("");
        self.commandid = 1;
        self.commandDropDown:SetLabel(self.canalList[self.commandid]);
        self.command = self.commandList[self.commandid];
        self.colorTypeId = 1;
        self.colorTypeDropDown:SetLabel(self.colorTypeList[self.colorTypeId or 1]);
    end
    self.addColorTagBtn:SetVisible(self.colorTypeId == 1 or self.colorTypeId == nil);
    self.addDefaultTagBtn:SetVisible(self.colorTypeId == 1 or self.colorTypeId == nil);
    self.addUnderTagBtn:SetVisible(self.colorTypeId == 1 or self.colorTypeId == nil);
    self.addUnderCTagBtn:SetVisible(self.colorTypeId == 1 or self.colorTypeId == nil);
    self.removeTagBtn:SetVisible(self.colorTypeId == 1 or self.colorTypeId == nil);
    self.destArea:SetEnabled(self.commandid == table.getn(self.canalList));
    self.destArea:SetVisible(self.commandid == table.getn(self.canalList));
    self:UpdateValidationButton();

    settings.currenttab = self.tabLabel.selectedValue;
    Savesettings();
end

function PimpYourText:GetName()
    return "PimpYourText";
end

function PimpYourText:IsRunning()
    return (self ~= nil);
end

function PimpYourText:Start()
    if (self ~= nil) then
        self:SetVisible(true);
    end
end

function PimpYourText:Stop()
    self = nil;
end

function PimpYourText:UpdateResponsive()
    self.destArea:SetWidth(self:GetWidth() - 140 - 135);
    self.resizer:SetPosition(self:GetWidth() - 45, self:GetHeight() - 45);
    self.textArea:SetSize(self:GetWidth() - self.textArea:GetLeft() * 2 - 10, self:GetHeight() - 120);
    self.textArea:GetVerticalScrollBar():SetLeft(self.textArea:GetLeft() + self.textArea:GetWidth());
    self.textArea:GetVerticalScrollBar():SetHeight(self.textArea:GetHeight());
    self.tabLabel:SetTop(self.textArea:GetTop() + self.textArea:GetHeight() / 2 - self.tabLabel:GetHeight() / 2);
    self.upBtn:SetTop(self.tabLabel:GetTop() - 20);
    self.downBtn:SetTop(self.tabLabel:GetTop() + 25);

    self.qsValid:SetPosition(self:GetWidth() - self.qsValid:GetWidth() - 40,
        self:GetHeight() - self.qsValid:GetHeight() -
        16);
    self.qsLbl:SetPosition(self.qsValid:GetLeft(), self.qsValid:GetTop());

    self.saveBtn:SetPosition(self:GetWidth() - 23,
        self.textArea:GetTop() + self.textArea:GetHeight() / 2 - self.saveBtn:GetHeight() / 2);
    self.resetBtn:SetPosition(self.saveBtn:GetLeft(), self.saveBtn:GetTop() + 18);
    self.configBtn:SetPosition(self.saveBtn:GetLeft(), self:GetHeight() - 57);

    self.colorTypeDropDown:SetPosition(self.textArea:GetLeft(), self:GetHeight() - 60 + 24);
    self.colorQueue:SetPosition(self.textArea:GetLeft(), self:GetHeight() - 60);
    if (self.colorQueue.colorPicker ~= nil) then self.colorQueue.colorPicker:SetVisible(false); end

    self.removeTagBtn:SetPosition(self.colorTypeDropDown:GetLeft() + self.colorTypeDropDown:GetWidth() - 20,
        self.colorQueue:GetTop());
    self.addUnderCTagBtn:SetPosition(self.removeTagBtn:GetLeft() - 35, self.colorQueue:GetTop());
    self.addUnderTagBtn:SetPosition(self.addUnderCTagBtn:GetLeft() - 24, self.colorQueue:GetTop());
    self.addDefaultTagBtn:SetPosition(self.addUnderTagBtn:GetLeft() - 35, self.colorQueue:GetTop());
    self.addColorTagBtn:SetPosition(self.addDefaultTagBtn:GetLeft() - 24, self.colorQueue:GetTop());
end
