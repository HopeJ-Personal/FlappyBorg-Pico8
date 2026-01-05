pico-8 cartridge // http://www.pico-8.com
version 42
__lua__
-- game loop --

function _init()
	-- player / borg --
	p={} -- player table
	p.x=0 -- player x cord.
	p.y=0 -- player y cord.
	p.f=0 -- flip state (0 false / 1 true)
	p.g=0 -- gravity (0 false / 1 true)
	
	-- game --
	g={} -- game table
	g.scn=0 -- current scene
	g.scr=0 -- current score
	
	-- statistics --
	s={} -- statistics table
	s.a={} -- stats. all
	s.l={} -- stats. latest
	s.t={} -- stats. top
	s.a.scr={} -- all scores
	s.l.scr={} -- latest scores
	
	-- timer --
	timer={}
	timer.a=0
	timer.b=1
end

function _update()
	hopes_um()
	gravity()
	for ct in all(timer) do
		--timer.ct+=1
		--timer.c=ct
	end
	
	for key, value in pairs( timer ) do
		timer.c=key
		timer.d=value
	end
end

function _draw()
	cls()
	map()
	spr(1,p.x,p.y)
	print(timer.a)
	print(timer.b)
	print(timer.c)
	print(timer.d)
end
-->8
-- scenes --
function menu()

end
-->8
-- borg --
function hopes_um()
	-- hopes_um = hopes universal movement
	if btn(0) then -- ⬅️ left
	 p.x-=1
	end
 if btn(1) then -- ➡️ right
	 p.x+=1
	end
 if btn(2) then -- ⬇️ down
	 p.y-=4
	end
 if btn(3) then -- ⬆️ up
	 p.y+=1
	end
	if btn(4) then -- 🅾️ z or n
	 --p.y+=1
	end
	if btn(5) then -- ❎ x or m
	 --p.x+=1
	end
end

function gravity()
	p.y+=1
end

function jump()
	jtimer=0
end
-->8
-- tab ideas:
-- scenes --
-- borg --
-- tower --
-- collisions --
__gfx__
00000000000000000000000099999999aaaaaaaabbbbbbbb33333333cccccccc1111111122222222eeeeeeee8888888800000000000000000000000000000000
0000000000aa77000000000099999999aaaaaaaabbbbbbbb33333333cccccccc1111111122222222eeeeeeee8888888800000000000000000000000000000000
007007000aaa70700000000099999999aaaaaaaabbbbbbbb33333333cccccccc1111111122222222eeeeeeee8888888800000000000000000000000000000000
00077000aaaaa7aa0000000099999999aaaaaaaabbbbbbbb33333333cccccccc1111111122222222eeeeeeee8888888800000000000000000000000000000000
00077000aaaaa8800000000099999999aaaaaaaabbbbbbbb33333333cccccccc1111111122222222eeeeeeee8888888800000000000000000000000000000000
007007000aaa88000000000099999999aaaaaaaabbbbbbbb33333333cccccccc1111111122222222eeeeeeee8888888800000000000000000000000000000000
00000000000000000000000099999999aaaaaaaabbbbbbbb33333333cccccccc1111111122222222eeeeeeee8888888800000000000000000000000000000000
00000000000000000000000099999999aaaaaaaabbbbbbbb33333333cccccccc1111111122222222eeeeeeee8888888800000000000000000000000000000000
