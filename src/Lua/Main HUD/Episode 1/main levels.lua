
-- hudding the 4th sonic
-- hooray!!
-- -pac

local CH = customhud

--- returns if the main hud should be displayed or not.
---@return boolean
local function useHUD()
	if gamemap >= sstage_start
	and gamemap <= sstage_end then
		return false
	end

	if gamemap >= smpstage_start
	and gamemap <= smpstage_end then
		return false
	end

	if mapheaderinfo[gamemap]
	and (mapheaderinfo[gamemap].typeoflevel & TOL_NIGHTS) then
		return false
	end

	return true
end

---@param stplyr player_t
local function getLives(stplyr)
	if stplyr == nil then return end

	local candrawlives = false;
	local livescount = -1

	local cv_cooplives = CV_FindVar("cooplives")

	// Co-op and Competition, normal life counter
	if (G_GametypeUsesLives()) then
		// Handle cooplives here
		if ((netgame or multiplayer) and G_GametypeUsesCoopLives() and cv_cooplives.value == 3) then
			livescount = 0;
			for p in players.iterate() do
				if p.spectator
				or p.lives < 1 then
					continue;
				end

				if (p.lives == INFLIVES) then
					livescount = INFLIVES;
					break;
				elseif (livescount < 99) then
					livescount = $+(p.lives);
				end
			end
		else
			livescount = (((netgame or multiplayer) and G_GametypeUsesCoopLives() and cv_cooplives.value == 0) and INFLIVES or stplyr.lives);
		end
		
		candrawlives = true
	// Infinity symbol (Race)
	elseif (G_PlatformGametype() and not (gametyperules & GTR_LIVES)) then
		livescount = INFLIVES;
		candrawlives = true;
	end

	return livescount, candrawlives
end

local resConv = FU/2 -- base screenshot uses 640x400, so use this to convert it to 320x200 :P

-- font name, kerning, space, mono
/* CH.SetupFont("S4RNG", 4, 4, 29) -- RNG = Rings
CH.SetupFont("S4SCR", 2, 4, 13) -- SCR = Score
CH.SetupFont("S4LVS", 2, 4, 27) -- LVS = Lives */
CH.SetupFont("S4RNG", 4) -- RNG = Rings
CH.SetupFont("S4SCR", 2) -- SCR = Score
CH.SetupFont("S4LVS", 2) -- LVS = Lives
CH.SetupFont("S4TIM", 2) -- TIM = Time

-- RING COUNTER
local noRingTime = TICRATE/2
CH.SetupItem("rings", "S4HUD", function(v, p)
	if not useHUD() then return end

	local flags = V_SNAPTOTOP|V_SNAPTOLEFT|V_PERPLAYER|V_HUDTRANS
	v.drawScaled(57*resConv, 40*resConv, resConv/2, v.cachePatch("S4E1RING"), flags)
	
	if p.rings ~= 0 then
		CH.CustomNum(v, 66*resConv, 56*resConv, p.rings, "S4RNG", 3, flags, nil, resConv/2)
	elseif leveltime%noRingTime <= noRingTime/2-1 then
		CH.CustomFontString(v, 66*resConv, 56*resConv, "!!!", "S4RNG", flags, nil, resConv/2)
	end
end)

-- LIVES COUNTER
local lifeIcon = {
	x = 62*resConv,
	--y = 328*resConv,
	y = 358*resConv,
	scale = FU
}
CH.SetupItem("lives", "S4HUD", function(v, p)
	if not useHUD() then return end

	local flags = V_SNAPTOBOTTOM|V_SNAPTOLEFT|V_PERPLAYER|V_HUDTRANS
	
	local skin = skins[p.skin]
	local charGFX
	local charScale = FU
	if skin.sprites[SPR2_LIFE].numframes then
		charGFX = v.getSprite2Patch(p.skin, SPR2_LIFE, (p.powers[pw_super] and true or false))
		charScale = (skin.flags & SF_HIRES) and skin.highresscale or $
	else
		charGFX = v.cachePatch("DEF1UPPIC")
	end
	charScale = FixedMul($, lifeIcon.scale)
	
	local xPos = lifeIcon.x + charGFX.leftoffset * charScale
	local yPos = lifeIcon.y + charGFX.topoffset * charScale - charGFX.height * charScale
	for i = 1, 4 do
		local num = i%2 == 0 and -1 or 1
		local x = i <= 2 and num or 0
		local y = i > 2 and num or 0
		
		v.drawScaled(xPos + x * lifeIcon.scale, yPos + y * lifeIcon.scale, charScale, charGFX, flags, v.getColormap(TC_ALLWHITE) )
	end
	v.drawScaled(xPos, yPos, charScale, charGFX, flags, v.getColormap((p.mo and p.mo.valid and p.mo.colorized) and TC_RAINBOW or p.skin, (p.mo and p.mo.valid) and p.mo.color or p.skincolor) )
	
	v.drawString(99*resConv, 328*resConv, skin.hudname, flags, "small-fixed")
	v.drawScaled(99*resConv, 343*resConv, resConv/2, v.cachePatch("S4E1LIFEX"), flags)
	local numScale = resConv/2 + resConv/6
	--CH.CustomNum(v, 113*resConv, 353*resConv - 28 * numScale, p.lives, "S4LVS", 3, flags, nil, numScale)

	local lives = getLives(p)
	CH.CustomNum(v, 113*resConv, 339*resConv, lives, "S4LVS", 3, flags, nil, numScale)
end)

-- SCORE
CH.SetupItem("score", "S4HUD", function(v, p)
	if not useHUD() then return end

	local flags = V_SNAPTOTOP|V_SNAPTOLEFT|V_PERPLAYER|V_HUDTRANS
	
	v.drawScaled(111*resConv, 49*resConv, resConv/2, v.cachePatch("S4E1SCOREBG"), flags)
	CH.CustomNum(v, 136*resConv, 52*resConv, p.score, "S4SCR", 9, flags, nil, resConv/2)
end)

-- TIME
CH.SetupItem("time", "S4HUD", function(v, p)
	if not useHUD() then return end
	
	local flags = V_SNAPTOTOP|V_SNAPTOLEFT|V_PERPLAYER|V_HUDTRANS
	
	v.drawScaled(120*resConv, 63*resConv, resConv/2, v.cachePatch("S4E1TIMEBG"), flags)
	local mins = G_TicsToMinutes(p.realtime, true)
	local secs = string.format("%02d", G_TicsToSeconds(p.realtime))
	local centi = string.format("%02d", G_TicsToCentiseconds(p.realtime))
	local str = mins+"'"+secs+'"'+centi
	CH.CustomFontString(v, 150*resConv, 73*resConv, str, "S4TIM", flags, nil, resConv/2)
end)