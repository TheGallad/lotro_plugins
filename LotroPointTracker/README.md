# Lotro Point Tracker

## Main functionalities

- Remembers the amount of LP earned by the character
- Saves the amount of LP to a file for each character
- Displays the LP amount in a special window

## Changelog

### v1.1.0

- Add settings to save window position and ability to move this window
- Snap the x-position of window to the screen width
- Rename lpc command to lpt, because plugin has name Lotro Point Tracker (LPT)
- Rename save files
- Fix minor warnings of Lua diagnostics
- Remove unused imports
- Refactor code

### v1.2.0

- Add account LP counter
- Add new commands. Now it is possible to reset LP counter for char, for account and both
- Refactor code

### v1.2.1

- Fix reset command
- Add more details to save and load messages

### v1.2.2

- Fix an error when Message is nil

### v1.3.0

- Redesign the tracker window in LOTRO style: translucent dark panel with a gold outer frame and an etched bronze inner frame
- Show character and account totals on two separate rows (Trajan font, muted parchment labels, right-aligned gold values)
- Add thousand separators to the displayed totals (1,250 instead of 1250)
- Add a golden flash animation on both totals when LOTRO Points are earned
- Window is locked (not movable) by default, matching the "small fixed window at the top of the screen" concept; movement can still be enabled in the plugin settings
- New default window size (190x56); the layout and value font automatically adapt to the size set in the settings
- Properly center the window horizontally on the screen on first launch

### v1.3.1

- Minor fixes

### Unreleased @gallad - choose new version here :)

- Fix the value font shrinking after the first earned LP ([#4](https://github.com/TheGallad/lotro_plugins/issues/4)). The layout switched the font but a LOTRO Label only re-renders with a new font on the next `SetText`, so the startup text kept the old font until the counter changed. The layout now re-applies the text right after changing the font (this also makes size changes from the settings visible immediately)
- The large value font (TrajanPro18) is now used from a row height of 17px (window height 40px and above) instead of 24px; smaller windows use TrajanPro14
- Settings: the window size is validated. Width must be 120-800 and height 36-200; out-of-range values are clamped and written back to the fields, non-numbers are rejected and the current size is kept. Previously an invalid value could save an empty size
- Settings: errors and confirmations are shown in the settings panel instead of chat (only save failures still go to chat)
- Settings: live preview while typing a valid size; Enter saves (same as Accept), Escape reverts to the last saved size
- Settings: size presets Small (160x40), Normal (190x56) and Large (260x80)
- Settings: "Center horizontally" and "Reset to defaults" (190x56, centered at the top) buttons, and the current window position is shown
- Settings: the unlock checkbox now says that the window locks again on reload
- A settings file with a missing size or position (saved by the old Accept bug) is repaired with defaults on load
