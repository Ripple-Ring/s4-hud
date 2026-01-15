
-- the title card
-- for episode 1
-- -pac

-- TODO:
-- 	- subtitle thing

local CH = customhud
local resConv = FU/2 -- base screenshot uses 640x400, so use this to convert it to 320x200 :P

local BGTime = TICRATE/2

CH.SetupFont("S4TC", -4, 16)
CH.SetupFont("S4ACT", 0, 16)
CH.SetupFont("S4SUB", 0, 8)

local fontScale = FixedMul(resConv, 13*FU/20) -- 0.65 in decimal

CH.SetupItem("stagetitle", "S4HUD", function(v, p, tics, endtic)
	if tics > endtic then return end
	
	local patch = v.cachePatch("EP1TTL_BG")
	local scale = resConv/2
	
	local vwidth = v.width() * FU / v.dupx()
	local vheight = v.height() * FU / v.dupy()
	
	local fillWidth = vwidth / FU + 1
	
	local fadeStr = 10 -- Str stands for Strength
	local pTics = tics -- p stands for proper, because it accounts for the going back stuff :P
	
	local fadeEndTics = TICRATE / 4
	local fadePos = 32 - FixedRound(32*FU / fadeEndTics * min(tics, fadeEndTics)) / FU -- math for where the black fade is at
	
	local runAwayTic = TICRATE
	if tics >= endtic-runAwayTic then -- if you're supposed to be going away then
		pTics = endtic - $ -- make pTics be equals a countdown from runAwayTic to 0
		fadeStr = 10*FU / max(min(runAwayTic - pTics, fadeEndTics), 1) / FU - 1 -- wdym i copied this?? never would i do that
		
		fadeEndTics = TICRATE-5 -- im so smart :) (this code is a mess with the going out thing now D:)
	end
	
	v.fadeScreen(0, fadeStr)
	
	if fadeEndTics ~= 0 then
		v.fadeScreen(0xFA00, fadePos)
	end
	
	local uTics = max(pTics - fadeEndTics, 0)
	
	-- THE RED FILL (spongebob creepypasta)
	local showAnimTics = min(uTics, 5)
	local fillX = fillWidth - (fillWidth / 5) * showAnimTics
	v.drawFill(fillX, 200-(200/3), fillWidth, 200/3, 35|V_SNAPTOLEFT|V_SNAPTOBOTTOM|V_PERPLAYER)
	
	if tics >= endtic-runAwayTic then -- if you're supposed to go away, then make the uTics just go down normally pls pls pls
		uTics = pTics -- im gonna go crazy! :D
	end
	
	-- add the 5 tics used for the anim above + 5 tics of delay, for the text anim, not the bg one below it :P
	uTics = max($-(5 + 5), 0)
	
	local zoneTics = min(uTics, 5)
	local mh = mapheaderinfo[gamemap]
	
	-- ZONE
	if mh and not (mh.levelflags & LF_NOZONE)
	and uTics > 0 then -- so it doesn't show up on non-green resolutions :P
		local zoneX = 488*resConv / 5 * zoneTics
		local zoneY = 151*resConv
		
		-- shadow thingie
		CH.CustomFontString(v, zoneX + 6*fontScale, zoneY + 5*fontScale, "ZONE", "S4TC", V_SNAPTORIGHT|V_50TRANS|V_PERPLAYER, "right", fontScale, 0, "AllBlack")
		
		CH.CustomFontString(v, zoneX, zoneY, "ZONE", "S4TC", V_SNAPTORIGHT|V_PERPLAYER, "right", fontScale)
	end
	
	-- THE SPIKY THING IDK THE NAME OF
	local thingX = (-patch.width * scale) + (patch.width * scale / 5) * showAnimTics
	local thingY = tics % BGTime <= (BGTime/2)-1 and -patch.height * (scale/2) or 0
	while thingY < vheight do
		v.drawScaled(thingX, thingY + patch.height * (scale/5), scale, patch, V_SNAPTOLEFT|V_SNAPTOTOP|V_40TRANS, v.getColormap(TC_DEFAULT, 0, "AllBlack")) -- shadow thing idk
		
		v.drawScaled(thingX, thingY, scale, patch, V_SNAPTOLEFT|V_SNAPTOTOP|V_PERPLAYER)
		thingY = $ + patch.height * scale
	end
	
	-- LEVEL NAME
	local str = mh and mh.lvlttl or "null"
	if str
	and uTics > 0 then
		str = str:upper()
		local fontX = 585*resConv / 5 * zoneTics
		local fontY = 95*resConv
		
		-- ow ie
		CH.CustomFontString(v, fontX + 6*fontScale, fontY + 5*fontScale, str, "S4TC", V_SNAPTORIGHT|V_50TRANS|V_PERPLAYER, "right", fontScale, 0, "AllBlack")
		
		CH.CustomFontString(v, fontX, fontY, str, "S4TC", V_SNAPTORIGHT|V_PERPLAYER, "right", fontScale)
	end
	
	-- ACT NUMBER
	if mh then
		if mh.bonustype == 1 or mh.bonustype == 2 then
			local actX = (348*resConv * 2) - 348*resConv / 5 * zoneTics
			local actTextY = 196*resConv
			local actTextScale = FixedMul(resConv, 55*FU/100)

			v.drawScaled(actX + 6*actTextScale, actTextY + 5*actTextScale, actTextScale, v.cachePatch("EP1TTL_BOSS"), V_SNAPTORIGHT|V_50TRANS|V_PERPLAYER, v.getColormap(TC_DEFAULT, 0, "AllBlack"))

			v.drawScaled(actX, actTextY, actTextScale, v.cachePatch("EP1TTL_BOSS"), V_SNAPTORIGHT|V_PERPLAYER)
		elseif mh.actnum ~= 0 then
			local actX = (400*resConv * 2) - 400*resConv / 5 * zoneTics
			local actScale = FixedMul(resConv, FU+FU/2)
			
			local actTextY = 194*resConv
			local actTextScale = FixedMul(resConv, 3*FU/5) -- 0.6 in decimal
			
			-- ACT shadow the hedgehog
			v.drawScaled(actX + 6*actTextScale, actTextY + 5*actTextScale, actTextScale, v.cachePatch("EP1TTL_ACT"), V_SNAPTORIGHT|V_50TRANS|V_PERPLAYER, v.getColormap(TC_DEFAULT, 0, "AllBlack"))
			
			v.drawScaled(actX, actTextY, actTextScale, v.cachePatch("EP1TTL_ACT"), V_SNAPTORIGHT|V_PERPLAYER)
			
			-- actX = 400, + 90 = 490, which is where we want it to be :P
			actX = $ + 90*resConv
			local actY = 160*resConv
			
			-- shadow thingie
			CH.CustomNum(v, actX + 2*actScale, actY + 2*actScale, mh.actnum, "S4ACT", 0, V_SNAPTORIGHT|V_50TRANS|V_PERPLAYER, nil, actScale, 0, "AllBlack")
			
			CH.CustomNum(v, actX, actY, mh.actnum, "S4ACT", 0, V_SNAPTORIGHT|V_PERPLAYER, nil, actScale)
		end
	end
	
	uTics = max($-(5 + 5), 0) -- literally the same as the other one :P
	
	-- SUBTITLE (The Adventure Begins.)
	if mh and mh.subttl and #mh.subttl > 0
	and uTics > 0 then
		local subtitleTable = {
			x = 194*resConv,
			y = 300*resConv,
			scale = (resConv / 2) * 3,
			trans = 10 -- stands for transparency, i think thats a bit obvious, but gotta make sure!!
		}
		
		subtitleTable.x = $ + (CH.CustomFontStringWidth(v, mh.subttl, "S4SUB", subtitleTable.scale) / 4) -- i didnt wanna have to do this but idk how else i'd do thiS GRAHH
		subtitleTable.y = $ - (29*subtitleTable.scale / 2) -- so it'd be the right position and i don't have to do math every time i change something about scale or position :P
		
		local subTics = min(uTics, 5) -- stands for SUBtitle :P
		
		-- in this case scale will always be triple :P
		-- FixedMul(subTics*FU, 6*FU / 10) should be translated to
		-- subTics * 0.6
		-- which should make it so when subTics is equals to 5
		-- it'd become 3 instead, so it'd make the text be normal scaled :P
		subtitleTable.scale = FixedDiv($, FixedMul(subTics*FU, 6*FU / 10))
		subtitleTable.trans = 10 - (subTics * 2)
		
		if subtitleTable.trans < 10 then
			local verticalCenter = 29*subtitleTable.scale / 2
			
			-- ow ie 2
			for i = 1, 4 do
				local num = i%2 == 0 and -1 or 1
				local x = i <= 2 and num or 0
				local y = i > 2 and num or 0
				
				CH.CustomFontString(v, subtitleTable.x + x*subtitleTable.scale, subtitleTable.y+verticalCenter + y*subtitleTable.scale, mh.subttl, "S4SUB", V_SNAPTOBOTTOM|V_SNAPTOLEFT|V_MODULATE|V_PERPLAYER, "center", subtitleTable.scale, 0, "Invert")
			end
			
			CH.CustomFontString(v, subtitleTable.x, subtitleTable.y+verticalCenter, mh.subttl, "S4SUB", V_SNAPTOBOTTOM|V_SNAPTOLEFT|V_ADD|(subtitleTable.trans << V_ALPHASHIFT)|V_PERPLAYER, "center", subtitleTable.scale)
		end
	end
	
	-- STR = 65%?
	-- ACT = 60%
end, "titlecard")