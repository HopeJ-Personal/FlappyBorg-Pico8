pico-8 cartridge // http://www.pico-8.com
version 43
__lua__
-- game loop --

function _init()

	plr_spawn_delay = 60     -- 60 frames minimum between pillars
	plr_spawn_timer = plr_spawn_delay -- start counting down from delay

	-- player / borg --
	p={} -- player table
	p.x=56 -- player x cord.
	p.y=56 -- player y cord.
	p.f=0 -- flip state (0 false / 1 true)
	p.g=1 -- gravity (0 false / 1 true)
	p.step=3
	p.spid_str = 1
	p.spid_up = 16
	p.spid_dwn = 17
	p.spid = p.spid_str
	p.score = 0
	-- game --
	g={} -- game table
	g.scn=0 -- current scene
	-- 1 menu
	-- 2 death
	g.scr=0 -- current score
	g.frz = false -- freeze state
	g.debug = false
	bg2_init()
	plr_new()
end

function _update()
	controls()
	phys()
	collission()
	bg2_shift()
	bg2_prune()
	sprite_control()
	if stimer > 0 then
		stimer -= 1
	end
	plr_shift()
	plr_prune()
	plr_collision()
end

function _draw()
	cls()
	map()
	spr(p.spid,p.x,p.y)
	if btn(🅾️) then
		pset(47,p.y,1)
	end
	plr_draw()
	bg2_draw()
	print(p.score,1,1,1)
	scenes()
end
-->8
-- scenes --
function scenes()
	if g.scn == 0 then
	end
	if g.scn == 1 then
		menu()
	end
	if g.scn == 2 then
		death()
	end
end

function menu()

end

function death()
	local str = "bird crash"
	local x = 64 - (#str *2)
	print(str, x, 61)
end
-->8
-- player --
function controls()
	if g.frz==false then
		if btn(⬆️) and p.y > 0 then
			p.y-=p.step
		end
		if btn(⬇️) and p.y < 128 then
			p.y+=p.step
		end
		if btn(➡️) and p.x < 120 then
			p.x+=p.step
		end
		if btn(⬅️) and p.x > 0 then
			p.x-=p.step
		end
	end
	if btn(❎) then
		g.debug = true
	else
		g.debug = false
	end
end

-- player: interactions --
function phys()
	if g.frz==false then
		if p.g==1 then
				p.y += 1
		end
	end
end

function collission()
	//bottom of screen is 122
	--if p.y >= 122 then
	if p.y >= 90 then
		g.frz = true
		g.scn = 2
	end
end

function sprite_control()
	if g.frz==false then
		if btn(⬆️) and (btn(⬇️)==false) then
			p.spid = p.spid_up
		elseif btn(⬇️) and (btn(⬆️)==false) then
			p.spid = p.spid_dwn
		else
			p.spid = p.spid_str
		end
	end
end
-->8
-- background --

-- init variables for obj management and spawning
bg_obj_list = {}
bg_screen_twidth = 16 -- tile width
bg_screen_pwidth = bg_screen_twidth*8
bg_obj_width = 8 -- sprite pixel width
bg_obj_mt_height = 3 -- mt = max tile
bg_obj_spawntimer = 0
bg_sx = 128 -- start x
bg_sy = 120 -- start y

-- initialize scene objects
--  (first buildings and roads
--  the player sees)
bg2_obj_list = {}
function bg2_init()
	bg_cx = bg_sx
	bg_cy = bg_sy
	for i = 0,(bg_screen_pwidth/bg_obj_width) do
		-- building
		temp_var=flr(rnd(3))
		temp_height=flr(rnd(bg_obj_mt_height))
		item = {t="b",x=bg_cx,y=bg_cy,varient=temp_var,height=temp_height,speed=0.5,dir=0}
		add(bg2_obj_list,item)
		
		-- road
		item = {t="r",x=bg_cx,y=bg_cy,speed=1,dir=0}
		add(bg2_obj_list,item)
		
		-- move to next pos for obj init
		bg_cx -= bg_obj_width
	end
end

-- shift obj
halftimer = 0
function bg2_shift()
 -- now with variable speed
 -- control to allow things
 -- like the road and
 -- buildings moving at dif
 -- speeds to give a
 -- parralax effect
	if halftimer == 0 then
		halftimer = 1
	elseif halftimer == 1 then
		halftimer = 0
	end
	if g.frz==false then
		for item in all(bg2_obj_list) do
			--item.x-=1
			if item.dir == 0 then
				if itemspeed == 0.5 then
					if halftimer == 1 then
						item.x-=item.speed
					end
				else
					item.x-=item.speed
				end
			end
			if item.dir == 1 then
				if item.speed == 0.5 then
					if halftimer == 1 then
						item.x-=item.speed
					end
				else
					item.x+=item.speed
				end
			end
		end
	end
end

-- spawn new obj to replace oob obj(s)
function bg2_new(t)
	-- speed = px moved
	-- dir = direction
	--  0 = left (-)
	--  1 = right (+)
	if t == "b" then
		-- building
		temp_var=flr(rnd(3))
		temp_height=flr(rnd(bg_obj_mt_height))
		item = {t="b",x=bg_sx,y=bg_sy,varient=temp_var,height=temp_height,speed=0.5,dir=0}
		add(bg2_obj_list,item)
	elseif t == "r" then
		-- road
		item = {t="r",x=bg_sx,y=bg_sy,speed=1,dir=0}
		add(bg2_obj_list,item)
	end
end

function bg2_prune()
	-- del obj out of bounds and
	-- spawn new obj to
	-- preserve 1 continious
	-- scene illusion
	for item in all(bg2_obj_list) do
		if item.x < -7 then
			del(bg2_obj_list,item)
			bg2_new(item.t)
		end
	end
end

-- turn the obj list into visual sprites
--  (or table intepreter and spr spawner)
function bg2_draw()
	for item in all(bg2_obj_list) do
		-- roads
		
		if item.t == "r" then
			-- spawn road sprite
			spr(22,item.x,item.y)
		
		-- buildings
		elseif item.t == "b" then
			-- step 1:
			--  set sprites per varient
			
			-- varient 0 - grey building 
			if item.varient == 0 then
				sprid_btm_noroof = 51
				sprid_btm_wroof = 67
				sprid_mio = 35
				sprid_top = 19
			
			-- varient 1 - green building
			elseif item.varient == 1 then
				sprid_btm_noroof = 52
				sprid_btm_wroof = 68
				sprid_mio = 36
				sprid_top = 20
				
			-- varient 2 -- tan building
			elseif item.varient == 2 then
				sprid_btm_noroof = 53
				sprid_btm_wroof = 69
				sprid_mio = 37
				sprid_top = 21
			end
			
			-- step 2:
			--  gen building
			if item.height == 0 then
				spr(sprid_btm_wroof,item.x,item.y-8)
			end
			if item.height > 0 then
				spr(sprid_btm_noroof,item.x,item.y-8)
				if item.height < 2 then
					spr(sprid_top,item.x,item.y-16)
				elseif item.height == 2 then
					spr(sprid_mio,item.x,item.y-16)
					spr(sprid_top,item.x,item.y-24)
				end
			end
		end
	end
end
-->8
-- pillars --
-- initialize (idk if ill use this tbh as it dont need to have any in first frames)
function plr_init()
	plr_new()
end

function plr_shift()
	if g.frz==false then
		for obj in all(plr.obj_list) do
			obj.x -= 1
			for item in all(obj) do
				item.x-=1
			end
		end
	end
end

plr = {}
plr.obj_list = {}
plr.sx = 128
plr.sy = 120
plr.height = 8

function plr_new()
	-- set temp variables
	cx = plr.sx
	cy = plr.sy
	
	-- dynamic variables
	gap = flr(rnd(2)) + 1
	height = flr(rnd(10 - gap)) + 5
	topgap = height+gap
	
	obj = {}
	obj.x = cx
	obj.gap_top = plr.sy - ((height + gap + 2) * plr.height) + 16
	obj.gap_bot = plr.sy - ((height + 1) * plr.height) + 17
	obj.w = 8

	
	--10-15 top
	--9 top cap
	--7,8 mid empty
	--6 bottomcap
	--0-5 bottom
	
	for i = 1, 16 do
		-- fix #2
		-- so turns out yes fix #1 did
		-- fix one issue however another
		-- more "invisible" bug was happening
		-- the best way i can explain it is that
		-- lua doesnt treat functions the same
		-- as loops in the way it makes local vars,
		-- infact any vars are apparently
		-- **always** global unless specified
		-- so theoretically doing item == nil or
		-- setting each item before adding to be
		-- local item instead of just item
		-- would fix it. i was unaware of this
		-- until i was made aware of the discrepency
		-- of var handling from my usual languages
		-- and presumably most languages to lua
		item = nil
		
		if i < height then
			if i == 0 then
				item={x=cx,y=cy,spid=12}
			else
				item={x=cx,y=cy,spid=12}
			end
		elseif i == height then
			item={x=cx,y=cy,spid=14}
		elseif i == height+gap+2 then
			item={x=cx,y=cy,spid=13}
		elseif i > height+gap+2 then
			item={x=cx,y=cy,spid=12}
		end
		
		-- fix #1
		-- who would have thought adding if item would fix phantom speed increase of spid 13
		-- essentialy in the gap it fits none so it adds top cap again and again meaning dupe ref
		-- 3 to be specific meaning top cap moves 3x per frame.
		if item then add(obj, item) end
		cy -= plr.height
	end
	
	add(plr.obj_list, obj)
	-- item
	--  x
	--  y
	--  speed
	--  gap_size? (unsure how ill code gen rn)
	--  gap_height? (unsure how ill code gen rn)
end

-- frame-based timer for spawning
--plr_spawn_timer = 30 -- frames until next pillar

stimer = 0
plrx = 0

function plr_prune()
 -- remove pillars off-screen
 if g.frz==false then
 	for obj in all(plr.obj_list) do
 	 if obj[1].x < -8 then
 	 	del(plr.obj_list,obj)
 		elseif obj[1].x == 50 then
 			p.score+=1
 		end
 	end
	end

	-- spawn new pillars at regular intervals
 plr_spawn_timer -= 1
 if plr_spawn_timer <= 0 then
	 plr_new()
  plr_spawn_timer = flr(rnd(30)) + 30 -- random delay 30-59 frames
 end
end

function plr_draw()
	for obj in all(plr.obj_list) do
		for item in all(obj) do
			spr(item.spid,item.x,item.y)
		end
	end
	if g.debug == true then
		-- debug collision overlay
		for obj in all(plr.obj_list) do
			-- top solid
			draw_hitbox(
				obj.x,
				0,
				obj.w,
				obj.gap_top,
				8
			)
			
			-- gap (safe zone)
			draw_hitbox(
				obj.x,
				obj.gap_top,
				obj.w,
				obj.gap_bot - obj.gap_top,
				11 -- green
			)
			
			-- bottom solid
			draw_hitbox(
				obj.x,
				obj.gap_bot,
				obj.w,
				128 - obj.gap_bot,
				8 -- red
			)
		end
		
		-- player hitbox
		draw_hitbox(p.x,p.y,8,8,1) -- blue (switched 12 to 1)
	end
end

function plr_collision()
	for obj in all(plr.obj_list) do
		if p.x+8 > obj.x and p.x < obj.x+obj.w then
			if p.y < obj.gap_top or p.y+8 > obj.gap_bot then
				g.frz = true
				g.scn = 2
				return
			end
		end
	end
end

function draw_hitbox(x,y,w,h,col)
	rect(x,y,x+w-1,y+h-1,col)
end
__gfx__
00000000000000000000000099999999aaaaaaaabbbbbbbb33333333cccccccc1111111122222222eeeeeeee8888888803bbbb3003bbbb305555555500000000
0000000000aa77000000000099999999aaaaaaaabbbbbbbb33333333cccccccc1111111122222222eeeeeeee8888888803bbbb3003bbbb305333333500000000
007007000aaa75700000000099999999aaaaaaaabbbbbbbb33333333cccccccc1111111122222222eeeeeeee8888888803bbbb3003bbbb305333333500000000
00077000aaaaa7aa0000000099999999aaaaaaaabbbbbbbb33333333cccccccc1111111122222222eeeeeeee8888888803bbbb3003bbbb305555555500000000
00077000aaaaa8800000000099999999aaaaaaaabbbbbbbb33333333cccccccc1111111122222222eeeeeeee8888888803bbbb305555555503bbbb3000000000
007007000aaa88000000000099999999aaaaaaaabbbbbbbb33333333cccccccc1111111122222222eeeeeeee8888888803bbbb305333333503bbbb3000000000
00000000000000000000000099999999aaaaaaaabbbbbbbb33333333cccccccc1111111122222222eeeeeeee8888888803bbbb305333333503bbbb3000000000
00000000000000000000000099999999aaaaaaaabbbbbbbb33333333cccccccc1111111122222222eeeeeeee8888888803bbbb305555555503bbbb3000000000
000000000000000000000000000000000000000000000000dddddddd000000000000000000000000000000000000000000000000000000000000000000000000
000a770000aa700000000000ddddddddbbbbbbbb5555555555555555000000000000000000000000000000000000000000000000000000000000000000000000
00a757a00aa7570000000000d111111db333333b5ffffff566666666000000000000000000000000000000000000000000000000000000000000000000000000
0aaa7aaaaaa77aa000000000d1d11d1db3b33b3b5f5ff5f5a66aa66a000000000000000000000000000000000000000000000000000000000000000000000000
aaaaaaa00aaaaaaa00000000d111111db333333b5ffffff5a66aa66a000000000000000000000000000000000000000000000000000000000000000000000000
0aaa880000aaa88000000000d1d11d1db3b33b3b5f5ff5f566666666000000000000000000000000000000000000000000000000000000000000000000000000
00aaa000000aa80000000000d111111db333333b5ffffff555555555000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000d1d11d1db3b33b3b5f5ff5f5dddddddd000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000d111111db333333b5ffffff500000000000000000000000000000000000000000000000000000000000000000000000000000000
00aa00000000000000000000d1d11d1db3b33b3b5f5ff5f500000000000000000000000000000000000000000000000000000000000000000000000000000000
0aaa77000000000000000000d111111db333333b5ffffff500000000000000000000000000000000000000000000000000000000000000000000000000000000
aaaaa5700000000000000000d1d11d1db3b33b3b5f5ff5f500000000000000000000000000000000000000000000000000000000000000000000000000000000
aaaaaaa00000000000000000d111111db333333b5ffffff500000000000000000000000000000000000000000000000000000000000000000000000000000000
0aaa88000000000000000000d1d11d1db3b33b3b5f5ff5f500000000000000000000000000000000000000000000000000000000000000000000000000000000
000a80000000000000000000d111111db333333b5ffffff500000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000d1d11d1db3b33b3b5f5ff5f500000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000d111111db333333b5ffffff500000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000d1d11d1db3b33b3b5f5ff5f500000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000d111111db333333b5ffffff500000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000d188881db399993b5f9999f500000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000d888888db999999b5999999500000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000d111111db333333b5ffffff500000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000d11dd11db33bb33b5ff55ff500000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000d11dd11db33bb33b5ff55ff500000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000ddddddddbbbbbbbb5555555500000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000d111111db333333b5ffffff500000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000d188881db399993b5f9999f500000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000d888888db999999b5999999500000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000d111111db333333b5ffffff500000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000d11dd11db33bb33b5ff55ff500000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000d11dd11db33bb33b5ff55ff500000000000000000000000000000000000000000000000000000000000000000000000000000000
__label__
ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc3bbbb3ccccccccccccccccccccccccc
c6c6ccccccccc666c66cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc3bbbb3ccccccccccccccccccccccccc
c6c6cc6cccccc6cccc6cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc3bbbb3ccccccccccccccccccccccccc
c666ccccccccc666cc6cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc3bbbb3ccccccccccccccccccccccccc
ccc6cc6cccccccc6cc6cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc3bbbb3ccccccccccccccccccccccccc
c666ccccccccc666c666ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc3bbbb3ccccccccccccccccccccccccc
ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc3bbbb3ccccccccccccccccccccccccc
c666ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc3bbbb3ccccccccccccccccccccccccc
c6c6ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc3bbbb3ccccccccccccccccccccccccc
c66cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc3bbbb3ccccccccccccccccccccccccc
c6c6ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc3bbbb3ccccccccccccccccccccccccc
c666ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc3bbbb3ccccccccccccccccccccccccc
ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc3bbbb3ccccccccccccccccccccccccc
c66cc666c666ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc3bbbb3ccccccccccccccccccccccccc
cc6cc6c6ccc6ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc3bbbb3ccccccccccccccccccccccccc
cc6cc6c6c666ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc3bbbb3ccccccccccccccccccccccccc
cc6cc6c6c6ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc3bbbb3ccccccccccccccccccccccccc
c666c666c666ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc3bbbb3ccccccccccccccccccccccccc
ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc3bbbb3ccccccccccccccccccccccccc
c66cc666c666ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc3bbbb3ccccccccccccccccccccccccc
cc6cccc6c6c6cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc55555555cccccccccccccccccccccccc
cc6cc666c6c6cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc53333335cccccccccccccccccccccccc
cc6cc6ccc6c6cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc53333335cccccccccccccccccccccccc
c666c666c666cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc55555555cccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c666ccccc666cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c6c6ccccc6cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c6c6ccccc666cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c6c6ccccccc6cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c666cc6cc666cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc55555555cccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc53333335cccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc53333335cccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc55555555cccccccccccccccccccccccc
ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccaa77ccccccccccccccccccccccccccccccccccc3bbbb3ccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccaaa757cccccccccccccccccccccccccccccccccc3bbbb3ccccccccccccccccccccccccc
ccccccccccccccccccccccccccccccccccccccccccccccccccccccccaaaaa7aaccccccccccccccccccccccccccccccccc3bbbb3ccccccccccccccccccccccccc
ccccccccccccccccccccccccccccccccccccccccccccccccccccccccaaaaa88cccccccccccccccccccccccccccccccccc3bbbb3ccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccaaa88ccccccccccccccccccccccccccccccccccc3bbbb3ccccccccccccccccccccccccc
ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc3bbbb3ccccccccccccccccccccccccc
ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc3bbbb3ccccccccccccccccccccccccc
ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc3bbbb3ccccccccccccccccccccccccc
ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc3bbbb3ccccccccccccccccccccccccc
ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc3bbbb3ccccccccccccccccccccccccc
ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc3bbbb3ccccccccccccccccccccccccc
ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc3bbbb3ccccccccccccccccccccccccc
ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc3bbbb3ccccccccccccccccccccccccc
ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc3bbbb3ccccccccccccccccccccccccc
ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc3bbbb3ccccccccccccccccccccccccc
ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc3bbbb3ccccccccccccccccccccccccc
ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc3bbbb3ccccccccccccccccccccccccc
ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc3bbbb3ccccccccccccccccccccccccc
ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc3bbbb3ccccccccccccccccccccccccc
ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc3bbbb3ccccccccccccccccccccccccc
ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc3bbbb3ccccccccccccccccccccccccc
ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc3bbbb3ccccccccccccccccccccccccc
ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc3bbbb3ccccccccccccccccccccccccc
ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc3bbbb3ccccccccccccccccccccccccc
ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc3bbbb3ccccccccccccccccccccccccc
ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc3bbbb3ccccccccccccccccccccccccc
ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc3bbbb3ccccccccccccccccccccccccc
ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc3bbbb3ccccccccccccccccccccccccc
ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc3bbbb3ccccccccccccccccccccccccc
ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc3bbbb3ccccccccccccccccccccccccc
ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc3bbbb3ccccccccccccccccccccccccc
ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc3bbbb3ccccccccccccccccccccccccc
ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc3bbbb3ccccccccccccccccccccccccc
ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc3bbbb3ccccccccccccccccccccccccc
ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc3bbbb3ccccccccccccccccccccccccc
ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc3bbbb3ccccccccccccccccccccccccc
ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc3bbbb3ccccccccccccccccccccccccc
ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc3bbbb3ccccccccccccccccccccccccc
ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc3bbbb3ccccccccccccccccccccccccc
ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc3bbbb3ccccccccccccccccccccccccc
ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc3bbbb3ccccccccccccccccccccccccc
ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc3bbbb3ccccccccccccccccccccccccc
ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc3bbbb3ccccccccccccccccccccccccc
ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc3bbbb3ccccccccccccccccccccccccc
ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc3bbbb3ccccccccccccccccccccccccc
ccccccccccccccccccccccccccccccccccccccccccccccddddddddddddddddccccccccccccccccddddddddccccccccccc3bbbb55555555cccccccccccccccccc
ccccccccccccccccccccccccccccccccccccccccccccccd111111dd111111dccccccccccccccccd111111dccccccccccc3bbbb5ffffff5cccccccccccccccccc
ccccccccccccccccccccccccccccccccccccccccccccccd1d11d1dd1d11d1dccccccccccccccccd1d11d1dccccccccccc3bbbb5f5ff5f5cccccccccccccccccc
ccccccccccccccccccccccccccccccccccccccccccccccd111111dd111111dccccccccccccccccd111111dccccccccccc3bbbb5ffffff5cccccccccccccccccc
ccccccccccccccccccccccccccccccccccccccccccccccd1d11d1dd1d11d1dccccccccccccccccd1d11d1dccccccccccc3bbbb5f5ff5f5cccccccccccccccccc
ccccccccccccccccccccccccccccccccccccccccccccccd111111dd111111dccccccccccccccccd111111dccccccccccc3bbbb5ffffff5cccccccccccccccccc
ccccccccccccccccccccccccccccccccccccccccccccccd1d11d1dd1d11d1dccccccccccccccccd1d11d1dccccccccccc3bbbb5f5ff5f5cccccccccccccccccc
ccccccccccccccccccccccccccccccccccccccccccccccd111111dd111111dccccccccccccccccd111111dccccccccccc3bbbb5ffffff5cccccccccccccccccc
bbbbbbddddddddccccccccccccccccccccccccddddddddd1d11d1dd1d11d1d55555555bbbbbbbbd1d11d1ddddddddddddddddd5f5ff5f5cccccccbbbbbbbbddd
33333bd111111dccccccccccccccccccccccccd111111dd111111dd111111d5ffffff5b333333bd111111dd111111dd111111d5ffffff5cccccccb333333bd11
b33b3bd1d11d1dccccccccccccccccccccccccd1d11d1dd1d11d1dd1d11d1d5f5ff5f5b3b33b3bd1d11d1dd1d11d1dd1d11d1d5f5ff5f5cccccccb3b33b3bd1d
33333bd111111dccccccccccccccccccccccccd111111dd111111dd111111d5ffffff5b333333bd111111dd111111dd111111d5ffffff5cccccccb333333bd11
b33b3bd1d11d1dccccccccccccccccccccccccd1d11d1dd1d11d1dd1d11d1d5f5ff5f5b3b33b3bd1d11d1dd1d11d1dd1d11d1d5f5ff5f5cccccccb3b33b3bd1d
33333bd111111dccccccccccccccccccccccccd111111dd111111dd111111d5ffffff5b333333bd111111dd111111dd111111d5ffffff5cccccccb333333bd11
b33b3bd1d11d1dccccccccccccccccccccccccd1d11d1dd1d11d1dd1d11d1d5f5ff5f5b3b33b3bd1d11d1dd1d11d1dd1d11d1d5f5ff5f5cccccccb3b33b3bd1d
33333bd111111dccccccccccccccccccccccccd111111dd111111dd111111d5ffffff5b333333bd111111dd111111dd111111d5ffffff5cccccccb333333bd11
b33b3bd1d11d1dddddddddbbbbbbbbddddddddd1d11d1dd1d11d1dd1d11d1d5f5ff5f5b3b33b3bd1d11d1dd1d11d1dd1d11d1d5f5ff5fbbbbbbbbb3b33b3bd1d
33333bd111111dd111111db333333bd111111dd111111dd111111dd111111d5ffffff5b333333bd111111dd111111dd111111d5ffffffb333333bb333333bd11
99993bd188881dd188881db399993bd188881dd188881dd188881dd188881d5f9999f5b399993bd188881dd188881dd188881d5f9999fb399993bb399993bd18
99999bd888888dd888888db999999bd888888dd888888dd888888dd888888d59999995b999999bd888888dd888888dd888888d5999999b999999bb999999bd88
33333bd111111dd111111db333333bd111111dd111111dd111111dd111111d5ffffff5b333333bd111111dd111111dd111111d5ffffffb333333bb333333bd11
3bb33bd11dd11dd11dd11db33bb33bd11dd11dd11dd11dd11dd11dd11dd11d5ff55ff5b33bb33bd11dd11dd11dd11dd11dd11d5ff55ffb33bb33bb33bb33bd11
3bb33bd11dd11dd11dd11db33bb33bd11dd11dd11dd11dd11dd11dd11dd11d5ff55ff5b33bb33bd11dd11dd11dd11dd11dd11d5ff55ffb33bb33bb33bb33bd11
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
55555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
66666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666
a66aa66aa66aa66aa66aa66aa66aa66aa66aa66aa66aa66aa66aa66aa66aa66aa66aa66aa66aa66aa66aa66aa66aa66aa66aa66aa66aa66aa66aa66aa66aa66a
a66aa66aa66aa66aa66aa66aa66aa66aa66aa66aa66aa66aa66aa66aa66aa66aa66aa66aa66aa66aa66aa66aa66aa66aa66aa66aa66aa66aa66aa66aa66aa66a
66666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666
55555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd

__map__
0707070707070707070707070707070700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0707070707070707070707070707070700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0707070707070707070707070707070700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0707070707070707070707070707070700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0707070707070707070707070707070700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0707070707070707070707070707070700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0707070707070707070707070707070700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0707070707070707070707070707070700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0707070707070707070707070707070700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0707070707070707070707070707070700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0707070707070707070707070707070700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0707070707070707070707070707070700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0707070707070707070707070707070700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0707070707070707070707070707070700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0707070707070707070707070707070700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0707070707070707070707070707070700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
