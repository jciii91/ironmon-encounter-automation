# ironmon-encounter-automation

### 1.1 Release Notes
- Search field for name is case-insensitive
- No longer requires both fields to be set. Users can search against name or level or both.
- Saved search parameters will show in the tracker.
- Extended the delay before the first input during battle. Long ability animations like Drought would mess the timing up.
- Introduced logic to mitigate the player character "drifting" while the extension is running.
    - The left/right movement would cause the player to move off their initial mark.
    - Switching between left/right and up/down keeps the player in place but if the player is facing up they will take one initial step up.

### Installation
Place Lua file in your tracker's 'extension' folder. No other files required.

### Summary and Instructions
Automate encounter searching for IronMon players. Enter the name and level of the desired encounter and press the start button. The extension will trigger encounters until one matching the search criteria has begun.

When active, a (poorly drawn) crosshair will appear in the bottom left corner of the ROUTE_INFO pane of the InfoScreen. (Pane that shows what Pokémon have been seen in the current area). Clicking this crosshair will bring you to the extension screen. Click the prompt text, enter the name of the Pokémon and/or the level you want to find. 

Save the info, situate your character where it can trigger encounters, and hit the Play button. The game will progress until you find your Pokémon. If you wish to stop the search, reopen the extension screen using the same steps and hit the Stop button. (The Play buttons transforms into the Stop button.)
