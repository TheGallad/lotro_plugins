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
