import "Turbine.Gameplay"
import "LotroPointTracker.TurbineUtils"
import "LotroPointTracker.UI"

--[[ PreSets ]]
FONT              = Turbine.UI.Lotro.Font.Verdana14
WIDTH             = 100
HEIGHT            = 30
LEFT              = 1000
TOP               = 50
MOVE              = true
SETTINGSFONT      = Turbine.UI.Lotro.Font.BookAntiqua20
SETTINGSFONTSMALL = Turbine.UI.Lotro.Font.BookAntiqua16

--[[ Actual Values ]]
ACTUALWIDTH   = WIDTH
ACTUALHEIGHT  = HEIGHT

local PATTERN = "You've earned (%d+) LOTRO Points."
TotalPoints   = 0

local function Save(filename, params)
    local success = pcall(Turbine.PluginData.Save, Turbine.DataScope.Character, filename, params)
    if success then
        Turbine.Shell.WriteLine("File is saved")
    else
        Turbine.Shell.WriteLine("An error has occurred while saving data")
    end
end

local function Load(filename)
    local success, loadedData = pcall(Turbine.PluginData.Load, Turbine.DataScope.Character, filename)
    if not success then
        -- loadedData is an error if pcall returned false
        Turbine.Shell.WriteLine("Error loading file: " .. tostring(loadedData))
        return
    end
    if loadedData == nil then
        Turbine.Shell.WriteLine("File with saved data not found or data is not correct. Using default data.")
        return { total_points = 0 } -- return default table
    end
    Turbine.Shell.WriteLine("File successfully loaded")
    return loadedData
end

-- main block
Turbine.Shell.WriteLine("LotroPointTracker plugin. ver. 1.0.0")
TotalPoints = Load("lp_farm_session").total_points

local lotroPointTrackerWindow = LotroPointTrackerWindow()
lotroPointTrackerWindow:SetVisible(true)

-- hiding UI fix

local vitalHudVisible = true    -- the actual HUD state is not exposed to Lua so we have to assume the HUD is visible when the plugin loads
local vitalWindowVisible = true -- used to retain the state of the window for when the HUD is toggled back on
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
        TotalPoints = TotalPoints + tonumber(points)
        if lotroPointTrackerWindow then
            lotroPointTrackerWindow:UpdateCounter(TotalPoints)
        end
    end
end

-- command block

local resetCommand = Turbine.ShellCommand()

function resetCommand:Execute(args)
    if args == "reset" then
        TotalPoints = 0
        if lotroPointTrackerWindow then
            lotroPointTrackerWindow:UpdateCounter(0)
        end
        Turbine.Shell.WriteLine("Lotro Points counter reseted!")
    end
end

-- command register block

Turbine.Shell.AddCommand("lpc", resetCommand)

-- plugin functions implementation block

plugin.Unload = function(sender, args)
    Save("lp_farm_session", { total_points = TotalPoints })
    Turbine.Shell.RemoveCommand(resetCommand)
end
