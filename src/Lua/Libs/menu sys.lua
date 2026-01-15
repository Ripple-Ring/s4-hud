
-- hooray!!
-- menu system for the title screen :OOO

local CH = customhud
local menu = {}

function menu.compareKeyToGC(key, gc)
	local keys = {input.gameControlToKeyNum(gc)}
	
	return (key == keys[1] or key == keys[2]) and true or false
end

local menuStuff = {
	list = {},
	curMenu = nil,
	curOption = 0,
	tics = 0
}

local funcType = {
	draw = true,
	input = true,
	changeOption = true
}

function menu.addMenu(name, funcs)
	if name == nil
	or type(funcs) ~= "table" then return end
	
	local s = menuStuff
	
	if s.list[name] then return end -- already exists :P
	
	s.list[name] = {}
	for key, func in pairs(funcs) do
		if funcType[key] then
			s.list[name][key] = func
		end
	end
end

function menu.setMenu(name)
	if name ~= nil
	and menuStuff.list[name] then
		menuStuff.curMenu = name
	else
		menuStuff.curMenu = nil
	end
	menuStuff.curOption = 0
	menuStuff.tics = 0
	
	return menuStuff.list[name]
end

function menu.modifyVar(varName, value)
	menuStuff[varName] = value
end

local upKeys = {GC_FORWARD, GC_LOOKUP}
local downKeys = {GC_BACKWARD, GC_LOOKDOWN}

addHook("KeyDown", function(key)
	if gamestate ~= GS_TITLESCREEN
	or menuStuff.curMenu == nil
	or menuactive then return end
	
	-- if you're pressing a console key, screenshot key or gif recording key then dont proceed, pls
	if menu.compareKeyToGC(key.num, GC_CONSOLE)
	or menu.compareKeyToGC(key.num, GC_SCREENSHOT)
	or menu.compareKeyToGC(key.num, GC_RECORDGIF) then return end
	
	-- menu input function shtick
	local curMenu = menuStuff.list[menuStuff.curMenu]
	local funcReturn
	if curMenu
	and curMenu.input then
		funcReturn = curMenu.input(menuStuff, key)
	end
	
	-- curMenu.input return val, so it overwrites the next stuff :P
	if funcReturn ~= nil then
		return funcReturn
	end
	
	local updown = 0 -- select up & down options
	for _, gc in ipairs(upKeys) do
		if menu.compareKeyToGC(key.num, gc) then
			updown = $+1
			break
		end
		
		
	end
	for _, gc in ipairs(downKeys) do
		if menu.compareKeyToGC(key.num, gc) then
			updown = $-1
			break
		end
	end
	local prevOption = menuStuff.curOption
	menuStuff.curOption = $+updown
	if menuStuff.curOption ~= prevOption
	and curMenu and curMenu.changeOption then
		local retval = curMenu.changeOption(menuStuff)
		if tonumber(retval) ~= nil then
			menuStuff.curOption = tonumber(retval)
		elseif retval == true then
			menuStuff.curOption = prevOption
		end
	end
	
	-- ignore the input
	return true
end)

local function hudMenu(v, p, type)
	local s = menuStuff -- s = stuff
	
	if not s.list[s.curMenu] then return end
	
	s.tics = $+1
	local curMenu = s.list[s.curMenu]
	if curMenu.draw then
		curMenu.draw(s, v, p, type)
	end
end

CH.SetupItem("s4-titlemenu", "S4HUD", function(v)
	hudMenu(v, consoleplayer, type)
end, "title")

CH.SetupItem("s4-gamemenu", "S4HUD", function(v, p)
	hudMenu(v, p, type)
end, "game")

addHook("MapChange", function()
	menu.setMenu("handler")
end)

addHook("GameQuit", function(exit)
	if not exit then
		menu.setMenu("handler")
	end
end)

return menu