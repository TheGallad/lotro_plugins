import "PimpYourText.TurbineUtils";
import "PimpYourText.Utils";
import "PimpYourText.UI";

import "PimpYourText.Utils.Translate";

RtmCommand = Turbine.ShellCommand();

function RtmCommand:Execute(command, arguments)
    if (arguments == "?" or arguments == "help" or arguments == "man") then
        Turbine.Shell.WriteLine(RtmCommand:GetHelp());
    elseif (arguments == "show") then
        OpenPane();
    end
end

function RtmCommand:GetHelp()
    return TranslateText("HELP");
end

function RtmCommand:GetShortHelp()
    return "TODO.";
end

function OpenPane()
    if (pimpYourTxtDlg ~= nil) then
        pimpYourTxtDlg:SetVisible(true);
    end
end

function Savesettings()
    function SavesettingsConfirmation(sender, args)
        Turbine.Shell.WriteLine(TranslateText("SAVE_OK"));
    end

    DataSave(Turbine.DataScope.Account, "PimpYouText_settings", settings);
    if (quickLauncher) then quickLauncher:Applysettings(); end;
end

function Loadsettings()
    local tmpsettings = DataLoad(Turbine.DataScope.Account, "PimpYouText_settings");
    if (tmpsettings ~= nil) then
        settings = tmpsettings;
    else
        Reinitsettings();
    end
end

function Reinitsettings()
    settings = {};
    local width, height = Turbine.UI.Display.GetSize();
    local width2, height2;
    width2 = width / 2 - 300 / 2;
    height2 = height / 3 - 180 / 2;
    settings.main_x = width2;
    settings.main_y = height2;
    function ptr(sender, args)
        --
    end

    local tmpsettings = DataLoad(Turbine.DataScope.Account, "MortAuxTroupesDeGuerre_preferences", ptr);
    if (tmpsettings ~= nil) then
        settings.quicklaunch_x = tmpsettings.quicklaunch_x - 40;
        settings.quicklaunch_y = tmpsettings.quicklaunch_y;
    else
        settings.quicklaunch_x = width - 300;
        settings.quicklaunch_y = 20;
    end
    settings.defaultOpacity = 60;
    settings.canMoveQuickLauncher = false;
    settings.useQuickLauncher = true;
    settings.autoShowOnLaunch = false;
    settings.animateQuickLauncher = true;
    if (quickLauncher) then quickLauncher:Applysettings(); end;
end

InitTranslation();
Loadsettings();
--
optionsPanel = Turbine.UI.Control();
optionsPanel:SetSize(250, 20);
optionsButton = Turbine.UI.Lotro.Button();
optionsButton:SetSize(250, 20);
optionsButton:SetText(TranslateText("OPEN_CONFIG"));
optionsButton:SetParent(optionsPanel);
optionsButton.MouseClick = function(sender, args)
    local optionDialog = BuildConfigDialog();
    optionDialog:SetVisible(true);
end
plugin.GetOptionsPanel = function(self)
    return optionsPanel;
end
--

pimpYourTxtDlg = PimpYourText();
quickLauncher = QuickLauncher(pimpYourTxtDlg);
if (settings.useQuickLauncher) then
    quickLauncher:Start();
    quickLauncher:Applysettings();
end
if (settings.autoShowOnLaunch) then
    pimpYourTxtDlg:Start()
end

Turbine.Shell.AddCommand("PimpYourText", RtmCommand);
Turbine.Shell.AddCommand("PYT", RtmCommand);
