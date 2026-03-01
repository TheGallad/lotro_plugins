import "Turbine.UI.Lotro"
import "LotroPointTracker.UI"
import "LotroPointTracker.Settings"

-- PreSets

FONT               = Turbine.UI.Lotro.Font.Verdana14
WIDTH              = 150
HEIGHT             = 30
X_POS              = Turbine.UI.Display.GetWidth() / 2
Y_POS              = 50
MOVE               = true
SETTINGSFONT       = Turbine.UI.Lotro.Font.BookAntiqua20
SETTINGSFONTSMALL  = Turbine.UI.Lotro.Font.BookAntiqua16

-- Global static variables

PLUGIN_VERSION     = "1.2.0"
DATA_FILE_NAME     = "LPT_Data"
SETTINGS_FILE_NAME = "LPT_Settings"

local PATTERN      = "You've earned (%d+) LOTRO Points."

local lpCounter    = { lp_char = 0, lp_account = 0 }

local function Save(scope, filename, params)
    local success = pcall(Turbine.PluginData.Save, scope, filename, params)
    if success then
        Turbine.Shell.WriteLine("File is saved")
    else
        Turbine.Shell.WriteLine("An error has occurred while saving data")
    end
end

---@return {lp : number}|nil
local function Load(scope, filename)
    local success, loadedData = pcall(Turbine.PluginData.Load, scope, filename)
    if not success then
        -- loadedData is an error if pcall returned false
        Turbine.Shell.WriteLine("Error loading file: " .. tostring(loadedData) .. ". Using default data.")
        return nil
    end
    if loadedData == nil then
        Turbine.Shell.WriteLine("File with saved data not found or data is not correct. Using default data.")
        return { lp = 0 }
    end
    Turbine.Shell.WriteLine("File successfully loaded")
    return loadedData
end

-- main block

Turbine.Shell.WriteLine("LotroPointTracker plugin v" .. PLUGIN_VERSION)

local loadedDataChar = Load(Turbine.DataScope.Character, DATA_FILE_NAME)
if loadedDataChar ~= nil then
    lpCounter.lp_char = loadedDataChar.lp
end
local loadedDataAccount = Load(Turbine.DataScope.Account, DATA_FILE_NAME)
if loadedDataAccount ~= nil then
    lpCounter.lp_account = loadedDataAccount.lp
end

local lotroPointTrackerWindow = LotroPointTrackerWindow()
local optionsPanel = Options()

local settings = optionsPanel:Load()
if settings ~= nil then
    X_POS = settings.x_pos
    Y_POS = settings.y_pos
    WIDTH = settings.window_width
    HEIGHT = settings.window_height
end

optionsPanel:Init(lotroPointTrackerWindow)
lotroPointTrackerWindow:Init(lpCounter, WIDTH, HEIGHT)
lotroPointTrackerWindow:SetVisible(true)

optionsPanel.SizeChanged = function(sender, args)
    local optionsPanelWidth = optionsPanel:GetWidth()
    optionsPanel:SetHeight(optionsPanelWidth)
end

-- hiding UI fix

local vitalHudVisible = true            -- the actual HUD state is not exposed to Lua so we have to assume the HUD is visible when the plugin loads
local vitalWindowVisible = true         -- used to retain the state of the window for when the HUD is toggled back on
lotroPointTrackerWindow.KeyDown = function(sender, args)
    if (args.Action == 0x100000B3) then -- toggle HUD (the HUD action is not defined in the Turbine.UI.Lotro.Action enumeration although it should be). 268435635 = 0x100000B3
        vitalHudVisible = not vitalHudVisible
        if vitalHudVisible then
            lotroPointTrackerWindow:SetVisible(vitalWindowVisible)
        else
            vitalWindowVisible = lotroPointTrackerWindow:IsVisible()
            lotroPointTrackerWindow:SetVisible(false)
        end
    end
end
lotroPointTrackerWindow:SetWantsKeyEvents(true) -- enable keyevents (Actions) for this control

-- Chat Handler

function Turbine.Chat.Received(sender, args)
    local _, _, points = string.find(args.Message, PATTERN)
    if args.ChatType == Turbine.ChatType.Advancement and points then
        lpCounter.lp_char = lpCounter.lp_char + tonumber(points)
        lpCounter.lp_account = lpCounter.lp_account + tonumber(points)
        if lotroPointTrackerWindow then
            lotroPointTrackerWindow:UpdateCounter(lpCounter)
        end
    end
end

-- command block

local lptCommand = Turbine.ShellCommand()

function lptCommand:Execute(args)
    if args == "reset_char" then
        lpCounter = { lp_char = 0, lp_account = lpCounter.lp_account }
        if lotroPointTrackerWindow then
            lotroPointTrackerWindow:UpdateCounter(lpCounter)
        end
        Turbine.Shell.WriteLine("Lotro Points counter for character reseted!")
    end
    if args == "reset_account" then
        lpCounter = { lp_char = lpCounter.lp_char, lp_account = 0 }
        if lotroPointTrackerWindow then
            lotroPointTrackerWindow:UpdateCounter(lpCounter)
        end
        Turbine.Shell.WriteLine("Lotro Points counter for account reseted!")
    end
    if args == "reset_all" then
        lpCounter = { lp_char = 0, lp_account = 0 }
        if lotroPointTrackerWindow then
            lotroPointTrackerWindow:UpdateCounter(lpCounter)
        end
        Turbine.Shell.WriteLine("Lotro Points counter for account and character reseted!")
    end
end

-- command register block

Turbine.Shell.AddCommand("lpt", lptCommand)

-- plugin functions implementation block

plugin.GetOptionsPanel = function()
    return optionsPanel
end

plugin.Unload = function()
    Save(Turbine.DataScope.Character, DATA_FILE_NAME, { lp = lpCounter.lp_char })
    Save(Turbine.DataScope.Account, DATA_FILE_NAME, { lp = lpCounter.lp_account })
    optionsPanel:Save()
    Turbine.Shell.RemoveCommand(lptCommand)
end
