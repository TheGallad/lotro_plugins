import "PimpYourText.UI.DropDown";

ConfigDialog = class(Turbine.UI.Lotro.Window);

configurationDialogInstance = nil;
function BuildConfigDialog()
    if (configurationDialogInstance == nil) then
        configurationDialogInstance = ConfigDialog();
    end
    return configurationDialogInstance;
end

function ConfigDialog:Constructor()
    Turbine.UI.Lotro.Window.Constructor(self);
    local width, height = Turbine.UI.Display.GetSize();
    self:SetSize(350, 215);
    self:SetPosition(width / 2 - self:GetWidth() / 2, height / 3 - self:GetHeight() / 2);
    self:SetText("Configuration");
    self:BuildBloc(self);

    return optionsPanel;
end

function ConfigDialog:BuildBloc(parent)
    local optDiversTitleLabel = Turbine.UI.Label();
    optDiversTitleLabel:SetParent(parent);
    optDiversTitleLabel:SetFont(Turbine.UI.Lotro.Font.TrajanPro15);
    optDiversTitleLabel:SetText(TranslateText("CONFIG1"));
    optDiversTitleLabel:SetPosition(15, 42);
    optDiversTitleLabel:SetSize(300, 20);
    optDiversTitleLabel:SetForeColor(Turbine.UI.Color(1, 1, 0.5));
    optDiversTitleLabel:SetMouseVisible(false);

    local defaultButton = Turbine.UI.Lotro.Button();
    defaultButton:SetParent(parent);
    defaultButton:SetPosition(15, 40);
    defaultButton:SetSize(250, 20);
    defaultButton:SetText(TranslateText("CONFIG_DEFAULT"));
    defaultButton:SetParent(optionsPanel);

    local canMoveQuicklauncherCheckbox = Turbine.UI.Lotro.CheckBox();
    canMoveQuicklauncherCheckbox:SetParent(parent);
    canMoveQuicklauncherCheckbox:SetMultiline(false);
    canMoveQuicklauncherCheckbox:SetPosition(15, 65);
    canMoveQuicklauncherCheckbox:SetSize(360, 20);
    canMoveQuicklauncherCheckbox:SetTextAlignment(Turbine.UI.ContentAlignment.MiddleLeft);
    canMoveQuicklauncherCheckbox:SetText(TranslateText("CONFIG_MOUSE"));
    canMoveQuicklauncherCheckbox:SetChecked(settings.canMoveQuickLauncher);
    canMoveQuicklauncherCheckbox:SetMouseVisible(false);
    canMoveQuicklauncherCheckbox.CheckedChanged = function(sender, args)
        settings.canMoveQuickLauncher = canMoveQuicklauncherCheckbox:IsChecked();
        Savesettings();
    end
    local useQuickLauncherCheckbox = Turbine.UI.Lotro.CheckBox();
    useQuickLauncherCheckbox:SetParent(parent);
    useQuickLauncherCheckbox:SetMultiline(false);
    useQuickLauncherCheckbox:SetPosition(15, 85);
    useQuickLauncherCheckbox:SetSize(360, 20);
    useQuickLauncherCheckbox:SetTextAlignment(Turbine.UI.ContentAlignment.MiddleLeft);
    useQuickLauncherCheckbox:SetText(TranslateText("CONFIG_SHOWLAUNCHER"));
    useQuickLauncherCheckbox:SetChecked(settings.useQuickLauncher);
    useQuickLauncherCheckbox:SetMouseVisible(false);
    useQuickLauncherCheckbox.CheckedChanged = function(sender, args)
        settings.useQuickLauncher = useQuickLauncherCheckbox:IsChecked();
        Savesettings();
    end
    local autoShowOnLaunchCheckbox = Turbine.UI.Lotro.CheckBox();
    autoShowOnLaunchCheckbox:SetParent(parent);
    autoShowOnLaunchCheckbox:SetMultiline(false);
    autoShowOnLaunchCheckbox:SetPosition(15, 105);
    autoShowOnLaunchCheckbox:SetSize(360, 20);
    autoShowOnLaunchCheckbox:SetTextAlignment(Turbine.UI.ContentAlignment.MiddleLeft);
    autoShowOnLaunchCheckbox:SetText(TranslateText("CONFIG_SHOWWINDOW"));
    autoShowOnLaunchCheckbox:SetChecked(settings.autoShowOnLaunch);
    autoShowOnLaunchCheckbox:SetMouseVisible(false);
    autoShowOnLaunchCheckbox.CheckedChanged = function(sender, args)
        settings.autoShowOnLaunch = autoShowOnLaunchCheckbox:IsChecked();
        Savesettings();
    end
    local animateQuickLaunchCheckbox = Turbine.UI.Lotro.CheckBox();
    animateQuickLaunchCheckbox:SetParent(parent);
    animateQuickLaunchCheckbox:SetMultiline(false);
    animateQuickLaunchCheckbox:SetPosition(15, 125);
    animateQuickLaunchCheckbox:SetSize(360, 20);
    animateQuickLaunchCheckbox:SetTextAlignment(Turbine.UI.ContentAlignment.MiddleLeft);
    animateQuickLaunchCheckbox:SetText(TranslateText("CONFIG_ANIMATE"));
    animateQuickLaunchCheckbox:SetChecked(settings.animateQuickLauncher);
    animateQuickLaunchCheckbox:SetMouseVisible(false);
    animateQuickLaunchCheckbox.CheckedChanged = function(sender, args)
        settings.animateQuickLauncher = animateQuickLaunchCheckbox:IsChecked();
        Savesettings();
    end

    -- local elementList = {};
    -- local selectedElement = nil;
    -- for i = 20, 90, 10 do
    -- local value = i.." %";
    -- table.insert(elementList, value);
    -- if(i==settings.defaultOpacity)then
    -- selectedElement = value;
    -- end
    -- end
    -- local opacityLabel = Turbine.UI.Label();
    -- opacityLabel:SetParent( parent );
    -- opacityLabel:SetMultiline( false );
    -- opacityLabel:SetPosition( 15, 151 );
    -- opacityLabel:SetSize( 360, 20 );
    -- opacityLabel:SetText( "Opacit\195\169 du lanceur :" );
    -- local opacityDropDown = DropDown.Create(elementList, selectedElement); -- table that contains the list, default selected value for the list
    -- opacityDropDown:SetParent(parent);
    -- opacityDropDown:SetPosition( 170, 146 );
    -- opacityDropDown.myElementList = elementList;
    -- opacityDropDown:ApplyWidth(75); -- set the width of the menu, this is not essential to include as the default is a good size.
    -- opacityDropDown:SetMaxItems(8); -- Number of items to display in the drop down before a scrollbar is needed.. default value is 7 where this is excluded.
    -- opacityDropDown:SetVisible(true);
    -- opacityDropDown.ItemChanged = function ()		
    -- local selectedOpacity = opacityDropDown:GetText();	
    -- local opacity = string.match(selectedOpacity, '%d+');		
    -- if(opacity ~= nil) then settings.defaultOpacity = tonumber(opacity); end
    -- Savesettings();	
    -- end		
    local opacityLabel = Turbine.UI.Label();
    opacityLabel:SetParent(parent);
    opacityLabel:SetMultiline(false);
    opacityLabel:SetPosition(15, 150);
    opacityLabel:SetSize(360, 20);
    opacityLabel:SetText(TranslateText("CONFIG_OPACITY"));
    local opacityTextBox = Turbine.UI.Label();
    opacityTextBox:SetParent(parent);
    opacityTextBox:SetMultiline(false);
    opacityTextBox:SetPosition(170, 150);
    opacityTextBox:SetSize(250, 20);
    opacityTextBox:SetEnabled(false);
    --opacityTextBox:SetFont( Turbine.UI.Lotro.Font.Verdana14 );
    opacityTextBox:SetForeColor(Turbine.UI.Color(1, 1, 0.5));
    opacityTextBox.customValue = tonumber(settings.defaultOpacity);
    opacityTextBox:SetText(settings.defaultOpacity .. " %");
    local opacityMinusButton = Turbine.UI.Lotro.Button();
    opacityMinusButton:SetParent(parent);
    opacityMinusButton:SetPosition(210, 145);
    opacityMinusButton:SetSize(16, 16);
    opacityMinusButton:SetText("-");
    local opacityAddButton = Turbine.UI.Lotro.Button();
    opacityAddButton:SetParent(parent);
    opacityAddButton:SetPosition(250, 145);
    opacityAddButton:SetSize(16, 16);
    opacityAddButton:SetText("+");
    opacityMinusButton:SetEnabled(opacityTextBox.customValue > 20);
    opacityAddButton:SetEnabled(opacityTextBox.customValue < 100);
    opacityMinusButton.MouseClick = function(sender, args)
        UpdateOpacity(opacityTextBox.customValue - 10);
    end
    opacityAddButton.MouseClick = function(sender, args)
        UpdateOpacity(opacityTextBox.customValue + 10);
    end
    local showClosingMessageCheckbox = Turbine.UI.Lotro.CheckBox();
    showClosingMessageCheckbox:SetParent(parent);
    showClosingMessageCheckbox:SetMultiline(false);
    showClosingMessageCheckbox:SetPosition(15, 165);
    showClosingMessageCheckbox:SetSize(360, 20);
    showClosingMessageCheckbox:SetTextAlignment(Turbine.UI.ContentAlignment.MiddleLeft);
    showClosingMessageCheckbox:SetText(TranslateText("CONFIG_SHOWCLOSMSG"));
    showClosingMessageCheckbox:SetChecked(settings.autoShowLaunchingMessage or true);
    showClosingMessageCheckbox:SetMouseVisible(false);
    showClosingMessageCheckbox.CheckedChanged = function(sender, args)
        settings.autoShowLaunchingMessage = showClosingMessageCheckbox:IsChecked();
        Savesettings();
    end
    function UpdateOpacity(value)
        if (value == nil) then
            return;
        elseif (value > 100) then
            opacityTextBox.customValue = 100;
        elseif (value < 20) then
            opacityTextBox.customValue = 20;
        else
            opacityTextBox.customValue = value
        end
        opacityTextBox:SetText(opacityTextBox.customValue .. " %");
        settings.defaultOpacity = string.match(opacityTextBox.customValue, '%d+');
        opacityMinusButton:SetEnabled(opacityTextBox.customValue > 20);
        opacityAddButton:SetEnabled(opacityTextBox.customValue < 100);
        Savesettings();
    end

    defaultButton.MouseClick = function(sender, args)
        Reinitsettings();
        UpdateOpacity(60);
        autoShowOnLaunchCheckbox:SetChecked(settings.autoShowOnLaunch);
        useQuickLauncherCheckbox:SetChecked(settings.useQuickLauncher);
        canMoveQuicklauncherCheckbox:SetChecked(settings.canMoveQuickLauncher);
        animateQuickLaunchCheckbox:SetChecked(settings.animateQuickLauncher);
    end
end
