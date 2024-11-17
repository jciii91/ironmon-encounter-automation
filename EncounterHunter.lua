local function EncounterHunter()
	-- Define descriptive attributes of the custom extension that are displayed on the Tracker settings
	local self = {}
	self.version = "1.0"
	self.name = "Encounter Hunter"
	self.author = "jciii91"
	self.description = "Triggers encounters until the desired Pokémon is found. Users can set what Pokémon and level they are hunting for. Extension ceases automatic search once it is complete."
	self.github = "jciii91/ironmon-encounter-automation"
	self.url = string.format("https://github.com/%s", self.github or "")

	-- EncounterHunterScreen locals --
	local EncounterHunterScreen = {}
	local previousScreen = nil
	local hunting = false
	local found = true
	local battle_menu_navigation = false
	local delay_counter = 0
	local move_right = true
	local target_name = ''
	local target_level = 0

	function self.openSetSearchParams()
		local form = Utils.createBizhawkForm("Set Search Params", 145, 100, 100, 50)
		
		forms.label(form, "Name:", 10, 0, 35, 20)
		local nameTextBox = forms.textbox(form, 'Name', 80, 20, nil, 55, 0)
		
		forms.label(form, "Level:", 10, 25, 35, 20)
		local levelTextBox = forms.textbox(form, 'Level', 50, 20, nil, 55, 25, false, true)
		
		forms.button(form, Resources.AllScreens.Save, function()
			self.saveSearchParms(forms.gettext(nameTextBox), forms.gettext(levelTextBox))
			Utils.closeBizhawkForm(form)
		end, 20, 60, 50, 20)
		
		forms.button(form, Resources.AllScreens.Cancel, function()
			Utils.closeBizhawkForm(form)
		end, 80, 60, 50, 20)
	end

	function self.saveSearchParms(name, level)
		target_name = name
		target_level = tonumber(level)
	end

	self.PixelImages = {
		CROSSHAIR = { -- 18x18 --
			{0,0,1,1,1,1,1,1,1,1,1,1,1,1,1,1,0,0},
			{0,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,0},
			{1,1,0,0,0,0,0,0,1,1,0,0,0,0,0,0,1,1},
			{1,1,0,0,0,0,0,0,1,1,0,0,0,0,0,0,1,1},
			{1,1,0,0,0,0,0,0,1,1,0,0,0,0,0,0,1,1},
			{1,1,0,0,0,0,0,0,1,1,0,0,0,0,0,0,1,1},
			{1,1,0,0,0,0,0,0,1,1,0,0,0,0,0,0,1,1},
			{1,1,0,0,0,0,0,0,1,1,0,0,0,0,0,0,1,1},
			{1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1},
			{1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1},
			{1,1,0,0,0,0,0,0,1,1,0,0,0,0,0,0,1,1},
			{1,1,0,0,0,0,0,0,1,1,0,0,0,0,0,0,1,1},
			{1,1,0,0,0,0,0,0,1,1,0,0,0,0,0,0,1,1},
			{1,1,0,0,0,0,0,0,1,1,0,0,0,0,0,0,1,1},
			{1,1,0,0,0,0,0,0,1,1,0,0,0,0,0,0,1,1},
			{1,1,0,0,0,0,0,0,1,1,0,0,0,0,0,0,1,1},
			{0,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,0},
			{0,0,1,1,1,1,1,1,1,1,1,1,1,1,1,1,0,0}
		}
	}

	self.Buttons = {
		LaunchEHScreen = {
			type = Constants.ButtonTypes.PIXELIMAGE,
			image = { -- 18x18 --
				{0,0,1,1,1,1,1,1,1,1,1,1,1,1,1,1,0,0},
				{0,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,0},
				{1,1,0,0,0,0,0,0,1,1,0,0,0,0,0,0,1,1},
				{1,1,0,0,0,0,0,0,1,1,0,0,0,0,0,0,1,1},
				{1,1,0,0,0,0,0,0,1,1,0,0,0,0,0,0,1,1},
				{1,1,0,0,0,0,0,0,1,1,0,0,0,0,0,0,1,1},
				{1,1,0,0,0,0,0,0,1,1,0,0,0,0,0,0,1,1},
				{1,1,0,0,0,0,0,0,1,1,0,0,0,0,0,0,1,1},
				{1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1},
				{1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1},
				{1,1,0,0,0,0,0,0,1,1,0,0,0,0,0,0,1,1},
				{1,1,0,0,0,0,0,0,1,1,0,0,0,0,0,0,1,1},
				{1,1,0,0,0,0,0,0,1,1,0,0,0,0,0,0,1,1},
				{1,1,0,0,0,0,0,0,1,1,0,0,0,0,0,0,1,1},
				{1,1,0,0,0,0,0,0,1,1,0,0,0,0,0,0,1,1},
				{1,1,0,0,0,0,0,0,1,1,0,0,0,0,0,0,1,1},
				{0,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,0},
				{0,0,1,1,1,1,1,1,1,1,1,1,1,1,1,1,0,0}
			},
			textColor = "Default text",
			box = { Constants.SCREEN.WIDTH + 10, 133, 18, 18, },
			boxColors = { "Upper box border", "Upper box background" },
			isVisible = function() return InfoScreen.viewScreen == InfoScreen.Screens.ROUTE_INFO end,
			onClick = function(this)
				previousScreen = InfoScreen
				Program.changeScreenView(EncounterHunterScreen)
			end,
		}
	}

	-- EncounterHunterScreen --
	local buttonOffsetX = Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN
	local buttonOffsetY = Constants.SCREEN.MARGIN + 3

	-- PixelImages --
	EncounterHunterScreen.PixelImages = {
		START = { -- 18x18 --
			{0,0,0,0,1,1,0,0,0,0,0,0,0,0,0,0,0,0},
			{0,0,0,0,1,1,1,0,0,0,0,0,0,0,0,0,0,0},
			{0,0,0,0,1,1,1,1,0,0,0,0,0,0,0,0,0,0},
			{0,0,0,0,1,1,1,1,1,0,0,0,0,0,0,0,0,0},
			{0,0,0,0,1,1,1,1,1,1,0,0,0,0,0,0,0,0},
			{0,0,0,0,1,1,1,1,1,1,1,0,0,0,0,0,0,0},
			{0,0,0,0,1,1,1,1,1,1,1,1,0,0,0,0,0,0},
			{0,0,0,0,1,1,1,1,1,1,1,1,1,0,0,0,0,0},
			{0,0,0,0,1,1,1,1,1,1,1,1,1,1,0,0,0,0},
			{0,0,0,0,1,1,1,1,1,1,1,1,1,1,0,0,0,0},
			{0,0,0,0,1,1,1,1,1,1,1,1,1,0,0,0,0,0},
			{0,0,0,0,1,1,1,1,1,1,1,1,0,0,0,0,0,0},
			{0,0,0,0,1,1,1,1,1,1,1,0,0,0,0,0,0,0},
			{0,0,0,0,1,1,1,1,1,1,0,0,0,0,0,0,0,0},
			{0,0,0,0,1,1,1,1,1,0,0,0,0,0,0,0,0,0},
			{0,0,0,0,1,1,1,1,0,0,0,0,0,0,0,0,0,0},
			{0,0,0,0,1,1,1,0,0,0,0,0,0,0,0,0,0,0},
			{0,0,0,0,1,1,0,0,0,0,0,0,0,0,0,0,0,0}
		},
		STOP = { -- 18x18 --
			{0,0,1,1,1,1,1,1,1,1,1,1,1,1,1,1,0,0},
			{0,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,0},
			{1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1},
			{1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1},
			{1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1},
			{1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1},
			{1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1},
			{1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1},
			{1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1},
			{1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1},
			{1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1},
			{1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1},
			{1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1},
			{1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1},
			{1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1},
			{1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1},
			{0,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,0},
			{0,0,1,1,1,1,1,1,1,1,1,1,1,1,1,1,0,0}
		}
	}

	local function leftAlignText(button, shadowcolor)
		local x, y = Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN + 3, button.box[2]
		local text = button:getCustomText() or button:getText() or ""
		Drawing.drawTransparentTextbox(x, y, text, Theme.COLORS[EncounterHunterScreen.Colors.text], Theme.COLORS[EncounterHunterScreen.Colors.fill], shadowcolor)
	end

	EncounterHunterScreen.Colors = {
		text = "Default text",
		highlight = "Intermediate text",
		border = "Upper box border",
		fill = "Upper box background",
	}

	-- add start/stop button (img changes depending on state), disable user joypad while searching
	-- Disabled if no name or level set
	EncounterHunterScreen.Buttons = {
		LaunchSetParamsDialog = {
			type = Constants.ButtonTypes.NO_BORDER,
			getCustomText = function() return 'Click here to set params.' end,
			textColor = EncounterHunterScreen.Colors.highlight,
			value = 'Launch Set Params Screen',
			defaultValue = 'Launch Set Params Screen',
			reset = function(this) this.value = this.defaultValue end,
			box = {	buttonOffsetX, buttonOffsetY, 100, 10 },
			draw = leftAlignText,
			onClick = function(this) self.openSetSearchParams(this) end,
		},
		StartStop = {
			type = Constants.ButtonTypes.PIXELIMAGE,
			image = EncounterHunterScreen.PixelImages.START,
			textColor = EncounterHunterScreen.Colors.text,
			box = { buttonOffsetX + 1, (buttonOffsetY * 2) + 5, 18, 18 },
			isVisible = function() return true end,
			onClick = function(self)
				hunting = not hunting
				if hunting then
					EncounterHunterScreen.Buttons.StartStop.image = EncounterHunterScreen.PixelImages.STOP
					EncounterHunterScreen.Buttons.StartStop.box = { buttonOffsetX + 4, (buttonOffsetY * 2) + 5, 18, 18 }
					found = false
					joypad.set({Right = true})

					Program.changeScreenView(previousScreen)
					previousScreen = nil
				else
					EncounterHunterScreen.Buttons.StartStop.image = EncounterHunterScreen.PixelImages.START
					EncounterHunterScreen.Buttons.StartStop.box = { buttonOffsetX + 1, (buttonOffsetY * 2) + 5, 18, 18 }
					found = true
				end
			end
		},
		Back = Drawing.createUIElementBackButton(function()
			Program.changeScreenView(previousScreen or SingleExtensionScreen)
			previousScreen = nil
		end, EncounterHunterScreen.Colors.text),
	}

	function EncounterHunterScreen.checkInput(xmouse, ymouse)
		Input.checkButtonsClicked(xmouse, ymouse, EncounterHunterScreen.Buttons or {})
	end

	-- Add lables to show current search params
	-- '*' to denote wildcard match, autoset wildcard if name/level is set but not the other
	-- Default both to 'Not set'
	function EncounterHunterScreen.drawScreen()
		local canvas = {
			x = Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN,
			y = Constants.SCREEN.MARGIN,
			w = Constants.SCREEN.RIGHT_GAP - (Constants.SCREEN.MARGIN * 2),
			h = Constants.SCREEN.HEIGHT - (Constants.SCREEN.MARGIN * 2),
			text = Theme.COLORS[EncounterHunterScreen.Colors.text],
			border = Theme.COLORS[EncounterHunterScreen.Colors.border],
			fill = Theme.COLORS[EncounterHunterScreen.Colors.fill],
			shadow = Utils.calcShadowColor(Theme.COLORS[EncounterHunterScreen.Colors.fill]),
		}
		Drawing.drawBackgroundAndMargins()
		gui.defaultTextBackground(canvas.fill)

		-- Draw the canvas box --
		gui.drawRectangle(canvas.x, canvas.y, canvas.w, canvas.h, canvas.border, canvas.fill)

		-- Title text --
		local centeredX = Utils.getCenteredTextX(self.name, canvas.w) - 2
		Drawing.drawTransparentTextbox(canvas.x + centeredX, canvas.y + 2, topText, canvas.text, canvas.fill, canvas.shadow)

		-- Draw buttons --
		for _, button in pairs(EncounterHunterScreen.Buttons or {}) do
			Drawing.drawButton(button, canvas.shadow)
		end
	end

	--------------------------------------
	-- INTENRAL TRACKER FUNCTIONS BELOW
	--------------------------------------

	-- Executed when the user clicks the "Check for Updates" button while viewing the extension details within the Tracker's UI
	-- Returns [true, downloadUrl] if an update is available (downloadUrl auto opens in browser for user); otherwise returns [false, downloadUrl]
	-- Remove this function if you choose not to implement a version update check for your extension
	function self.checkForUpdates()
		-- Update the pattern below to match your version. You can check what this looks like by visiting the latest release url on your repo
		local versionResponsePattern = '"tag_name":%s+"%w+(%d+%.%d+)"' -- matches "1.0" in "tag_name": "v1.0"
		local versionCheckUrl = string.format("https://api.github.com/repos/%s/releases/latest", self.github or "")
		local downloadUrl = string.format("%s/releases/latest", self.url or "")
		local compareFunc = function(a, b) return a ~= b and not Utils.isNewerVersion(a, b) end -- if current version is *older* than online version
		local isUpdateAvailable = Utils.checkForVersionUpdate(versionCheckUrl, self.version, versionResponsePattern, compareFunc)
		return isUpdateAvailable, downloadUrl
	end

	-- Executed only once: When the extension is enabled by the user, and/or when the Tracker first starts up, after it loads all other required files and code
	function self.startup()
		InfoScreen.Buttons.LaunchEHScreen = self.Buttons.LaunchEHScreen
	end

	-- Executed once every 30 frames, after most data from game memory is read in
	function self.afterProgramDataUpdate()
		if hunting and not found then
			if move_right then
				joypad.set({Right = true})
			else
				joypad.set({Left = true})
			end
			move_right = not move_right
		elseif battle_menu_navigation and delay_counter < 8 then
			joypad.set({B = true})
			delay_counter = delay_counter + 1
		elseif battle_menu_navigation and delay_counter < 16 then
			joypad.set({Down = true})
			delay_counter = delay_counter + 1
		elseif battle_menu_navigation and delay_counter < 24 then
			joypad.set({Right = true})
			delay_counter = delay_counter + 1
		elseif battle_menu_navigation and delay_counter < 28 then
			joypad.set({A = true})
			delay_counter = delay_counter + 1
		elseif battle_menu_navigation and delay_counter < 36 then
			joypad.set({A = true})
		end
	end

	-- Executed once every 30 frames or after any redraw event is scheduled (i.e. most button presses)
	function self.afterRedraw()
		if Program.currentScreen ~= InfoScreen or Battle.inBattle or InfoScreen.viewScreen ~= InfoScreen.Screens.ROUTE_INFO then
			return
		end

		Drawing.drawButton(InfoScreen.Buttons.LaunchEHScreen, Utils.calcShadowColor(Theme.COLORS["Upper box background"]))
	end

	-- Executed after a new battle begins (wild or trainer), and only once per battle
	function self.afterBattleBegins()
		hunting = false
		if Battle.isWildEncounter then
			local wild_name = Tracker.getPokemon(1, false).nickname
			local wild_level = Tracker.getPokemon(1, false).level

			-- add XOR capability, 
			if target_name == wild_name and target_level == wild_level then
				EncounterHunterScreen.Buttons.StartStop.image = EncounterHunterScreen.PixelImages.START
				EncounterHunterScreen.Buttons.StartStop.box = { buttonOffsetX + 1, (buttonOffsetY * 2) + 5, 18, 18 }
				found = true
			else
				battle_menu_navigation = true
			end
		end
	end

	-- Executed after a battle ends, and only once per battle
	function self.afterBattleEnds()
		battle_menu_navigation = false
		delay_counter = 0
		if not found then
			hunting = true
		end
	end

	return self
end
return EncounterHunter