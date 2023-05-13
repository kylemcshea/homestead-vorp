---@diagnostic disable: undefined-global
local isInCharacterSelector = false
local selectedChar = 1
local pedHandler
local mainCamera
local myChars = {}
local textureId = -1
local MaxCharacters
local PromptGroup = GetRandomIntInRange(0, 0xffffff)
local createPrompt
local deletePrompt
local swapPrompt
local selectPrompt
T = Translation.Langs[Lang]

-- GLOBALS
CachedSkin = {}
CachedComponents = {}



local function RegisterPrompts()
	local str = Config.keys.prompt_create.name
	createPrompt = PromptRegisterBegin()
	PromptSetControlAction(createPrompt, Config.keys.prompt_create.key)
	str = CreateVarString(10, 'LITERAL_STRING', str)
	PromptSetText(createPrompt, str)
	PromptSetEnabled(createPrompt, 1)
	PromptSetVisible(createPrompt, 1)
	PromptSetHoldMode(createPrompt, 3000)
	PromptSetGroup(createPrompt, PromptGroup)
	PromptRegisterEnd(createPrompt)

	local dstr = Config.keys.prompt_delete.name
	deletePrompt = PromptRegisterBegin()
	PromptSetControlAction(deletePrompt, Config.keys.prompt_delete.key)
	dstr = CreateVarString(10, 'LITERAL_STRING', dstr)
	PromptSetText(deletePrompt, dstr)
	PromptSetEnabled(deletePrompt, Config.AllowPlayerDeleteCharacter)
	PromptSetVisible(deletePrompt, 1)
	PromptSetHoldMode(deletePrompt, 5000)
	PromptSetGroup(deletePrompt, PromptGroup)
	PromptRegisterEnd(deletePrompt)

	local dstr = Config.keys.prompt_swap.name
	swapPrompt = PromptRegisterBegin()
	PromptSetControlAction(swapPrompt, Config.keys.prompt_swap.key)
	dstr = CreateVarString(10, 'LITERAL_STRING', dstr)
	PromptSetText(swapPrompt, dstr)
	PromptSetEnabled(swapPrompt, 1)
	PromptSetVisible(swapPrompt, 1)
	PromptSetStandardMode(swapPrompt, 1)
	PromptSetGroup(swapPrompt, PromptGroup)
	PromptRegisterEnd(swapPrompt)

	local dstr = Config.keys.prompt_select.name
	selectPrompt = PromptRegisterBegin()
	PromptSetControlAction(selectPrompt, Config.keys.prompt_select.key)
	dstr = CreateVarString(10, 'LITERAL_STRING', dstr)
	PromptSetText(selectPrompt, dstr)
	PromptSetEnabled(selectPrompt, 1)
	PromptSetVisible(selectPrompt, 1)
	PromptSetStandardMode(selectPrompt, 1)
	PromptSetGroup(selectPrompt, PromptGroup)
	PromptRegisterEnd(selectPrompt)
end


AddEventHandler('onClientResourceStart', function(resourceName)
	if (GetCurrentResourceName() ~= resourceName) then
		return
	end
	RegisterPrompts()
	if Config.DevMode then
		print("^3VORP Character Selector is in ^1DevMode^7 dont use in live servers")
		TriggerServerEvent("vorp_GoToSelectionMenu", GetPlayerServerId(PlayerId()))
	end
end)

AddEventHandler('onResourceStop', function(resourceName)
	if (GetCurrentResourceName() ~= resourceName) then
		return
	end
	if Config.DevMode then
		DeleteEntity(MalePed)
		DeleteEntity(FemalePed)
		DeletePed(pedHandler)
		DoScreenFadeIn(100)
		RemoveImaps()
		Citizen.InvokeNative(0x706D57B0F50DA710, "MC_MUSIC_STOP")
		MenuData.CloseAll()
		myChars[selectedChar] = {}
	end
end)

--#endregion
RegisterNetEvent("vorpcharacter:spawnUniqueCharacter", function(myChar)
	myChars = myChar
	CharSelect()
end)


-- player is already in an instance
RegisterNetEvent("vorpcharacter:selectCharacter")
AddEventHandler("vorpcharacter:selectCharacter", function(myCharacters, mc)
	local param = Config.selectedCharacter
	local customWeather = Config.toggleWeatherSync
	local weather = Config.charselWeather
	local permSnow = Config.charselgroundSnow
	local hour = Config.timeHour
	local freeze = Config.timeFreeze
	if #myCharacters < 1 then
		return TriggerEvent("vorpcharacter:startCharacterCreator") -- if no chars then send back to creator
	end
	myChars = myCharacters
	MaxCharacters = mc
	DoScreenFadeOut(1000)
	Wait(1000)

	if customWeather then
		exports.weathersync:setMyWeather(weather, 10, permSnow) -- Disable weather and time sync and set a weather for this client.
		exports.weathersync:setMyTime(hour, 0, 0, 10, freeze)
	end

	isInCharacterSelector = true
	Controller()
	FreezeEntityPosition(PlayerPedId(), true)
	SetEntityVisible(PlayerPedId(), false)
	SetEntityInvincible(PlayerPedId(), true)
	SetEntityCoords(PlayerPedId(), param.coords, false, false, false, false)
	while not HasCollisionLoadedAroundEntity(PlayerPedId()) do
		Wait(1000)
	end
	mainCamera = CreateCamWithParams("DEFAULT_SCRIPTED_CAMERA", param.cameraParams.x, param.cameraParams.y,
		param.cameraParams.z, param.cameraParams.rotX, param.cameraParams.rotY, param.cameraParams.rotZ,
		param.cameraParams.fov, false, 0)
	SetCamActive(mainCamera, true)
	RenderScriptCams(true, true, 1000, true, true, 0)
	DoScreenFadeIn(1000)
	Wait(1000)
	StartSwapCharacters()
end)


-- send all components in a table and update core through server
RegisterNetEvent("vorpcharacter:updateCache")
AddEventHandler("vorpcharacter:updateCache", function(skin, comps)
	if skin then
		if type(skin) == "table" then
			CachedSkin = skin
		else
			CachedSkin = json.decode(skin)
		end
	end

	if comps then
		if type(comps) == "table" then
			CachedComponents = comps
		else
			CachedComponents = json.decode(comps)
		end
	end
	TriggerServerEvent("vorpcharacter:setPlayerCompChange", CachedSkin, CachedComponents)
end)

-- send components one by one
RegisterNetEvent("vorpcharacter:savenew")
AddEventHandler("vorpcharacter:savenew", function(comps, skin)
	if comps then
		local clothing
		if type(comps) == "table" then
			clothing = comps
		else
			clothing = json.decode(comps)
		end
		for k, v in pairs(clothing) do
			if CachedComponents[k] then
				CachedComponents[k] = v
			end
		end
	end
	if skin then
		local skinz
		if type(skin) == "table" then
			skinz = skin
		else
			skinz = json.decode(skin)
		end
		for k, v in pairs(skinz) do
			if CachedSkin[k] then
				CachedSkin[k] = v
			end
		end
	end
	TriggerServerEvent("vorpcharacter:setPlayerCompChange", CachedSkin, CachedComponents)
end)



function Controller()
	CreateThread(function()
		while true do
			if isInCharacterSelector then
				local firstname = myChars[selectedChar].firstname or ""
				local lastname = myChars[selectedChar].lastname or ""
				local fullname = (firstname .. " " .. lastname) or ""

				local label = CreateVarString(10, 'LITERAL_STRING',
					T.promptselect .. fullname .. T.promptselect2 .. myChars[selectedChar].money)
				PromptSetActiveGroupThisFrame(PromptGroup, label)

				-- this needs to be prompts
				if Citizen.InvokeNative(0xC92AC953F0A982AE, swapPrompt) then
					if selectedChar == #myChars then
						selectedChar = 1
					else
						selectedChar = selectedChar + 1
					end
					TaskGoToCoordAnyMeans(pedHandler, Config.selectedCharacter.initialPos.coords, 0.8, 0, false, 524419,
						-1)
					while not IsEntityAtCoord(pedHandler, Config.selectedCharacter.initialPos.coords, 1.5, 1.5, 1.2, 0, 1, 0) do
						Wait(0)
					end
					StartSwapCharacters()
				end

				if Citizen.InvokeNative(0xC92AC953F0A982AE, selectPrompt) then
					CharSelect()
					isInCharacterSelector = false
					exports.weathersync:toggleSync() -- enable weather sync
					break
				end

				if PromptHasHoldModeCompleted(createPrompt) then -- create
					if #myChars < MaxCharacters then
						DeletePed(pedHandler)
						isInCharacterSelector = false
						TriggerEvent("vorpcharacter:startCharacterCreator")
						PrepareMusicEvent("REHR_START")
						Wait(100)
						TriggerMusicEvent("REHR_START")
						Wait(500)
						break
					else
						VORPcore.NotifyObjective("you cant create more characers", 8000)
					end
				end

				if PromptHasHoldModeCompleted(deletePrompt) then -- delete
					isInCharacterSelector = false
					DeleteEntity(pedHandler)

					TriggerServerEvent("vorpcharacter:deleteCharacter", myChars[selectedChar].charIdentifier)
					table.remove(myChars, selectedChar)
					if selectedChar <= 1 then
						selectedChar = #myChars
					else
						selectedChar = selectedChar - 1
					end

					if #myChars == 0 or myChars == nil then
						TriggerEvent("vorpcharacter:startCharacterCreator")
						isInCharacterSelector = false
					else
						isInCharacterSelector = true
						StartSwapCharacters()
					end
				end
			end
			Wait(0)
		end
	end)
end

local function EnablePrompt(boolean)
	PromptSetEnabled(createPrompt, boolean)
	PromptSetEnabled(deletePrompt, Config.AllowPlayerDeleteCharacter)
	PromptSetEnabled(swapPrompt, boolean)
	PromptSetEnabled(logoutPrompt, boolean)
	PromptSetEnabled(selectPrompt, boolean)
	PromptSetVisible(createPrompt, boolean)
	PromptSetVisible(deletePrompt, boolean)
	PromptSetVisible(swapPrompt, boolean)
	PromptSetVisible(selectPrompt, boolean)
	PromptSetVisible(logoutPrompt, boolean)
end



function StartSwapCharacters()
	local spawn = Config.selectedCharacter.initialPos
	local gotoC = Config.selectedCharacter.gotoPos
	EnablePrompt(false)
	DeleteEntity(pedHandler)
	LoadPlayer(myChars[selectedChar].skin.sex)
	pedHandler = CreatePed(joaat(myChars[selectedChar].skin.sex), spawn.coords, spawn.heading, false, true, true, true)
	Wait(500)
	LoadCharacterSelect(pedHandler, myChars[selectedChar].skin, myChars[selectedChar].components)
	TaskGoToCoordAnyMeans(pedHandler, gotoC.coords, 0.8, 0, false, 524419, -1)
	while not IsEntityAtCoord(pedHandler, gotoC.coords, 0.5, 0.5, 0.2, 0, 1, 0) do
		Wait(0)
	end
	EnablePrompt(true)
end

function CharSelect()
	DoScreenFadeOut(1000)
	Wait(1000)
	local charIdentifier = myChars[selectedChar].charIdentifier
	local nModel = tostring(myChars[selectedChar].skin.sex)
	CachedSkin = myChars[selectedChar].skin
	CachedComponents = myChars[selectedChar].components
	TriggerServerEvent("vorp_CharSelectedCharacter", charIdentifier)
	DeleteEntity(pedHandler)
	SetModelAsNoLongerNeeded(nModel)
	RequestModel(nModel)
	while not HasModelLoaded(nModel) do
		Wait(0)
	end
	Wait(1000)
	SetPlayerModel(PlayerId(), joaat(nModel), false)
	Citizen.InvokeNative(0x77FF8D35EEC6BBC4, PlayerPedId(), 0, 0)
	Wait(1000)
	LoadPlayerComponents(PlayerPedId(), CachedSkin, CachedComponents)
	Wait(1000)
	LoadPlayerComponents(PlayerPedId(), CachedSkin, CachedComponents) -- idky why but only loads if ran twice
	NetworkClearClockTimeOverride()
	FreezeEntityPosition(PlayerPedId(), false)
	SetEntityVisible(PlayerPedId(), true)
	SetEntityInvincible(PlayerPedId(), false)
	SetCamActive(mainCamera, false)
	DestroyCam(mainCamera, true)
	RenderScriptCams(true, true, 1000, true, true, 0)
	local coords = myChars[selectedChar].coords
	local playerCoords = vector3(tonumber(coords.x), tonumber(coords.y), tonumber(coords.z))
	local isDead = myChars[selectedChar].isDead
	local heading = coords.heading
	TriggerEvent("vorp:initCharacter", playerCoords, heading, isDead)
	TriggerServerEvent('dream_lib:addPlayerToJobTable')
	DoScreenFadeIn(1000)
end

AddEventHandler("vorpcharacter:reloadafterdeath", function()
	--LoadPlayer(joaat("CS_dutch"))
	--Citizen.InvokeNative(0xED40380076A31506, PlayerId(), joaat("CS_dutch"), false)
	--UpdateVariation(PlayerPedId())
	Wait(1000)
	ExecuteCommand("rc")
end)


local function LoadFaceFeatures(ped, skin)
	for key, value in pairs(FaceFeatures) do
		Citizen.InvokeNative(0xCC8CA3E88256E58F, ped, true, true, true, false)
		Citizen.InvokeNative(0x5653AB26C82938CF, ped, value, skin[key])
	end
end

local function LoadComps(ped, components)
	local boots = -1
	for category, value in pairs(components) do
		if value ~= -1 and category ~= "Boots" then
			Citizen.InvokeNative(0x704C908E9C405136, ped)
			Citizen.InvokeNative(0xAAB86462966168CE, ped, 1)
			if Config.UseSPclothing then
				Citizen.InvokeNative(0xD3A7B003ED343FD9, ped, value, false, false, false)
			end
			Citizen.InvokeNative(0xD3A7B003ED343FD9, ped, value, true, true, false)
		elseif category == "Boots" then
			boots = value
		end
	end
	-- loa boots for last so they dont clip with pants
	if boots ~= -1 then
		if Config.UseSPclothing then
			Citizen.InvokeNative(0xD3A7B003ED343FD9, ped, boots, false, false, false)
		end
		Citizen.InvokeNative(0xD3A7B003ED343FD9, ped, boots, true, true, false)
	end
end

function LoadPlayerComponents(ped, skin, components)
	TriggerServerEvent("vorpcharacter:reloadedskinlistener")
	local normal
	local gender

	if skin.sex ~= "mp_male" then
		Citizen.InvokeNative(0x77FF8D35EEC6BBC4, ped, 7, true)
		normal = joaat("head_fr1_mp_002_nm")
		gender = "Female"
	else
		Citizen.InvokeNative(0x77FF8D35EEC6BBC4, ped, 4, true)
		normal = joaat("mp_head_mr1_000_nm")
		gender = "Male"
	end

	Citizen.InvokeNative(0x0BFA1BD465CDFEFD, ped) -- ResetPedComponents
	IsPedReadyToRender()
	Wait(100)
	RemoveMetaTags(PlayerPedId())
	local count = 0
	local uCount = 1
	for _, v in pairs(Config.DefaultChar[gender]) do
		count = count + 1
		for key, _ in pairs(v) do
			if key == "HeadTexture" then
				local headtext = joaat(Config.DefaultChar[gender][count].HeadTexture[1])
				if headtext == skin.albedo then
					uCount = count
					break
				end
			end
		end
	end

	if skin.HeadType == 0 then
		skin.HeadType = tonumber("0x" .. Config.DefaultChar[gender][uCount].Heads[1])
	end
	if skin.BodyType == 0 then
		skin.BodyType = tonumber("0x" .. Config.DefaultChar[gender][uCount].Body[1])
	end
	if skin.LegsType == 0 then
		skin.LegsType = tonumber("0x" .. Config.DefaultChar[gender][uCount].Legs[1])
	end

	--Preload
	Citizen.InvokeNative(0xC5E7204F322E49EB, skin.albedo, normal, 0x7FC5B1E1)
	Citizen.InvokeNative(0xCC8CA3E88256E58F, PlayerPedId(), true, true, true, false)
	Citizen.InvokeNative(0xD3A7B003ED343FD9, PlayerPedId(), skin.HeadType, false, true, true)
	Citizen.InvokeNative(0xD3A7B003ED343FD9, PlayerPedId(), skin.BodyType, false, true, true)
	Citizen.InvokeNative(0xD3A7B003ED343FD9, PlayerPedId(), skin.LegsType, false, true, true)
	Citizen.InvokeNative(0xD3A7B003ED343FD9, PlayerPedId(), skin.Eyes, false, true, true)
	Citizen.InvokeNative(0x1902C4CFCC5BE57C, PlayerPedId(), skin.Waist)
	Citizen.InvokeNative(0x1902C4CFCC5BE57C, PlayerPedId(), skin.Body)
	Citizen.InvokeNative(0xD3A7B003ED343FD9, PlayerPedId(), skin.Hair, false, true, true)
	Citizen.InvokeNative(0xD3A7B003ED343FD9, PlayerPedId(), skin.Beard, false, true, true)

	Wait(100)
	SetPedScale(PlayerPedId(), skin.Scale)
	LoadFaceFeatures(PlayerPedId(), skin)
	LoadComps(PlayerPedId(), components)
	UpdateVariation(ped)

	-- Setup our face textures
	faceOverlay("beardstabble", skin.beardstabble_visibility, 1, 1, 0, 0, 1.0, 0, 1,
		skin.beardstabble_color_primary, 0, 0, 1, skin.beardstabble_opacity)
	faceOverlay("scars", skin.scars_visibility, skin.scars_tx_id, 0, 0, 1, 1.0, 0, 0, 0, 0, 0, 1,
		skin.scars_opacity)
	faceOverlay("spots", skin.spots_visibility, skin.spots_tx_id, 0, 0, 1, 1.0, 0, 0, 0, 0, 0, 1,
		skin.spots_opacity)
	faceOverlay("disc", skin.disc_visibility, skin.disc_tx_id, 0, 0, 1, 1.0, 0, 0, 0, 0, 0, 1, skin
		.disc_opacity)
	faceOverlay("complex", skin.complex_visibility, skin.complex_tx_id, 0, 0, 1, 1.0, 0, 0, 0, 0, 0, 1,
		skin.complex_opacity)
	faceOverlay("acne", skin.acne_visibility, skin.acne_tx_id, 0, 0, 1, 1.0, 0, 0, 0, 0, 0, 1, skin
		.acne_opacity)
	faceOverlay("ageing", skin.ageing_visibility, skin.ageing_tx_id, 0, 0, 1, 1.0, 0, 0, 0, 0, 0, 1,
		skin.ageing_opacity)
	faceOverlay("freckles", skin.freckles_visibility, skin.freckles_tx_id, 0, 0, 1, 1.0, 0, 0, 0, 0, 0, 1,
		skin.freckles_opacity)
	faceOverlay("moles", skin.moles_visibility, skin.moles_tx_id, 0, 0, 1, 1.0, 0, 0, 0, 0, 0, 1,
		skin.moles_opacity)
	faceOverlay("shadows", skin.shadows_visibility, 1, 1, 0, 0, 1.0, 0, 1, skin.shadows_palette_color_primary,
		skin.shadows_palette_color_secondary, skin.shadows_palette_color_tertiary, skin.shadows_palette_id,
		skin.shadows_opacity)
	faceOverlay("eyebrows", skin.eyebrows_visibility, skin.eyebrows_tx_id, 1, 0, 0, 1.0, 0, 1,
		skin.eyebrows_color, 0, 0, 1, skin.eyebrows_opacity)
	faceOverlay("eyeliners", skin.eyeliner_visibility, 1, 1, 0, 0, 1.0, 0, 1, skin.eyeliner_color_primary, 0, 0,
		skin.eyeliner_tx_id, skin.eyeliner_opacity)
	faceOverlay("blush", skin.blush_visibility, skin.blush_tx_id, 1, 0, 0, 1.0, 0, 1,
		skin.blush_palette_color_primary, 0, 0, 1, skin.blush_opacity)
	faceOverlay("lipsticks", skin.lipsticks_visibility, 1, 1, 0, 0, 1.0, 0, 1, skin
		.lipsticks_palette_color_primary, skin.lipsticks_palette_color_secondary,
		skin.lipsticks_palette_color_tertiary, skin.lipsticks_palette_id, skin.lipsticks_opacity)
	faceOverlay("grime", skin.grime_visibility, skin.grime_tx_id, 0, 0, 1, 1.0, 0, 0, 0, 0, 0, 1,
		skin.grime_opacity)

	Wait(200)
	Citizen.InvokeNative(0xD710A5007C2AC539, ped, 0x3F1F01E5, 0)
	Citizen.InvokeNative(0xCC8CA3E88256E58F, PlayerPedId(), true, true, true, false)
end

function faceOverlay(name, visibility, tx_id, tx_normal, tx_material, tx_color_type, tx_opacity, tx_unk, palette_id,
					 palette_color_primary, palette_color_secondary, palette_color_tertiary, var, opacity)
	-- Setup our defaults
	visibility = visibility or 0
	tx_id = tx_id or 0
	palette_color_primary = palette_color_primary or 0
	palette_color_secondary = palette_color_secondary or 0
	palette_color_tertiary = palette_color_tertiary or 0
	var = var or 0
	opacity = opacity or 1.0


	for k, v in pairs(Config.overlay_all_layers) do
		if v.name == name then
			v.visibility = visibility
			if visibility ~= 0 then
				v.tx_normal = tx_normal
				v.tx_material = tx_material
				v.tx_color_type = tx_color_type
				v.tx_opacity = tx_opacity
				v.tx_unk = tx_unk
				if tx_color_type == 0 then
					v.palette = Config.color_palettes[name][palette_id]
					v.palette_color_primary = palette_color_primary
					v.palette_color_secondary = palette_color_secondary
					v.palette_color_tertiary = palette_color_tertiary
				end
				if name == "shadows" or name == "eyeliners" or name == "lipsticks" then
					v.var = var
					v.tx_id = Config.overlays_info[name][1].id
				else
					v.var = 0
					if tx_id == 0 then
						v.tx_id = Config.overlays_info[name][1].id
					else
						v.tx_id = Config.overlays_info[name][tx_id].id
					end
				end
				v.opacity = opacity
				if opacity == 0 then
					-- if its visible but opacity is 0 then set visible to 0
					v.visibility = 0
					v.opacity = 0
				end
			end
		end
	end
	Citizen.CreateThread(StartOverlay)
end

function StartOverlay()
	local ped = PlayerPedId()
	local current_texture_settings = Config.texture_types.Male

	--[[ if isInCharacterSelector then
		ped = pedHandler
	end ]]
	if myChars[selectedChar].skin.sex ~= "mp_male" then
		current_texture_settings = Config.texture_types.Female
	end

	if textureId ~= -1 then
		Citizen.InvokeNative(0xB63B9178D0F58D82, textureId) -- reset texture
		Citizen.InvokeNative(0x6BEFAA907B076859, textureId) -- remove texture
	end
	textureId = Citizen.InvokeNative(0xC5E7204F322E49EB, myChars[selectedChar].skin.albedo,
		current_texture_settings.normal, current_texture_settings.material)
	for k, v in pairs(Config.overlay_all_layers) do
		if v.visibility ~= 0 then
			local overlay_id = Citizen.InvokeNative(0x86BB5FF45F193A02, textureId, v.tx_id, v.tx_normal,
				v.tx_material, v.tx_color_type, v.tx_opacity, v.tx_unk)
			if v.tx_color_type == 0 then
				Citizen.InvokeNative(0x1ED8588524AC9BE1, textureId, overlay_id, v.palette); -- apply palette
				Citizen.InvokeNative(0x2DF59FFE6FFD6044, textureId, overlay_id, v.palette_color_primary,
					v.palette_color_secondary, v.palette_color_tertiary)        -- apply palette colours
			end
			Citizen.InvokeNative(0x3329AAE2882FC8E4, textureId, overlay_id, v.var); -- apply overlay variant
			Citizen.InvokeNative(0x6C76BC24F8BB709A, textureId, overlay_id, v.opacity); -- apply overlay opacity
		end
	end
	while not Citizen.InvokeNative(0x31DC8D3F216D8509, textureId) do -- wait till texture fully loaded
		Citizen.Wait(0)
	end

	Citizen.InvokeNative(0x0B46E25761519058, ped, joaat("heads"), textureId) -- apply texture to current component in category "heads"
	Citizen.InvokeNative(0x92DAABA2C1C10B0E, textureId)                   -- update texture
	Citizen.InvokeNative(0xCC8CA3E88256E58F, ped, true, true, true, false) -- refresh ped components
end

RegisterCommand("rc", function() -- reload skin
	local hogtied = Citizen.InvokeNative(0x3AA24CCC0D451379, PlayerPedId())
	local cuffed = Citizen.InvokeNative(0x74E559B3BC910685, PlayerPedId())
	if not hogtied and not cuffed and not IsEntityDead(PlayerPedId()) then
		LoadPlayerComponents(PlayerPedId(), CachedSkin, CachedComponents)
	end
end)


function LoadCharacterSelect(ped, skin, components)
	local normal
	local gender

	if skin.sex ~= "mp_male" then
		normal = joaat("head_fr1_mp_002_nm")
		gender = "Female"
	else
		normal = joaat("mp_head_mr1_000_nm")
		gender = "Male"
	end

	RemoveMetaTags(pedHandler)
	IsPedReadyToRender()
	Citizen.InvokeNative(0x0BFA1BD465CDFEFD, ped)

	local count = 0
	local uCount = 1
	for k, v in pairs(Config.DefaultChar[gender]) do
		count = count + 1
		for key, _ in pairs(v) do
			if key == "HeadTexture" then
				local headtext = joaat(Config.DefaultChar[gender][count].HeadTexture[1])
				if headtext == skin.albedo then
					uCount = count
					break
				end
			end
		end
	end

	if skin.HeadType == 0 then
		skin.HeadType = tonumber("0x" .. Config.DefaultChar[gender][uCount].Heads[1])
	end
	if skin.BodyType == 0 then
		skin.BodyType = tonumber("0x" .. Config.DefaultChar[gender][uCount].Body[1])
	end
	if skin.LegsType == 0 then
		skin.LegsType = tonumber("0x" .. Config.DefaultChar[gender][uCount].Legs[1])
	end

	--Preload
	Citizen.InvokeNative(0xC5E7204F322E49EB, skin.albedo, normal, 0x7FC5B1E1)
	Citizen.InvokeNative(0xCC8CA3E88256E58F, pedHandler, true, true, true, false)
	Citizen.InvokeNative(0xD3A7B003ED343FD9, pedHandler, skin.HeadType, true, true, true)
	Citizen.InvokeNative(0xD3A7B003ED343FD9, pedHandler, skin.BodyType, true, true, true)
	Citizen.InvokeNative(0xD3A7B003ED343FD9, pedHandler, skin.LegsType, true, true, true)
	Citizen.InvokeNative(0xD3A7B003ED343FD9, pedHandler, skin.Eyes, true, true, false)
	Citizen.InvokeNative(0xD3A7B003ED343FD9, pedHandler, skin.Hair, true, true, false)
	Citizen.InvokeNative(0xD3A7B003ED343FD9, pedHandler, skin.Beard, true, true, false)
	Citizen.InvokeNative(0x1902C4CFCC5BE57C, pedHandler, skin.Waist)
	Citizen.InvokeNative(0x1902C4CFCC5BE57C, pedHandler, skin.Body)
	SetPedScale(pedHandler, skin.Scale)
	LoadFaceFeatures(pedHandler, skin)
	LoadComps(pedHandler, components)
	UpdateVariation(pedHandler)
	Citizen.InvokeNative(0xC6258F41D86676E0, pedHandler, 1, 100)
	Citizen.InvokeNative(0xC6258F41D86676E0, pedHandler, 0, 100)
end
