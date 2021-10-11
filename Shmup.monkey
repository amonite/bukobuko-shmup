'Strict 

Import mojo

Const STATE_MENU:Int = 1
Const STATE_PLAYING:Int = 2
Const STATE_PAUSED:Int = 3 

Global ScrW:Int, ScrH:Int  
Global Timer:Int 
Global Score:Int 

Class TGame Extends App
	Field player:TPlayer 
	Field font:TFont
	Field titleImage:Image 
	Global gameState:Int = STATE_MENU 
	
	Method SetState:Int(state:Int)
		gameState = state 
		Return gameState
	End Method 
	
	Method OnCreate:Int()
		ScrW = DeviceWidth()
		ScrH = DeviceHeight()
		Seed = Millisecs()
		font = New TFont
		titleImage = LoadImage("title_01.png",1)
		TFont.LoadBmp(LoadImage("font_02.png",43,1))
		TPlayer.LoadSprite(LoadImage("ship_06.png",1),LoadImage("halo_02.png",1))
		TBullet.halo = TPlayer.halo
		TBonus.halo = TPlayer.halo
		TBullet.LoadSprite(LoadImage("bullet_04.png",1))
		TAlien.LoadSprite(LoadImage("En_01.png",1),LoadImage("En_01_hit.png",1),LoadImage("blue_halo.png",1))
		TBurst.halo = TAlien.halo
		TAlienBullet.LoadSprite(LoadImage("AlienBomb_01.png",1))
		TBonus.LoadSprite(LoadImage("Bonus_01.png",1))
		player = New TPlayer(20,240)
	
		SetUpdateRate(60)
		Return 0
	End Method 
	
	Method OnUpdate:Int()
		Select gameState 
			Case STATE_MENU 
				If KeyHit(KEY_S)
					SetState(STATE_PLAYING)
				Endif 
			Case STATE_PLAYING
				player.Move()
				player.Shoot()
				TBullet.RefreshAll()
				TAlien.RefreshAll()
				TAlienBullet.RefreshAll() 
				TAlien.Spawn()
				TBonus.RefreshAll()
				TBurst.RefreshAll()
				If KeyHit(KEY_P)
					SetState(STATE_PAUSED)
				Endif 
			Case STATE_PAUSED
				If KeyHit (KEY_ESCAPE) Or KeyHit(KEY_P)
					SetState(STATE_PLAYING)
				Endif 
		End Select 
		Return 0
	End Method 
	
	Method OnRender:Int()
		Select gameState
			Case STATE_MENU
				Cls 0,0,200
				'Scale 2,2 
				DrawImage(titleImage, 130,50,0)
				TFont.Display("PRESS",250,200,14)
				TFont.Display("START",330,200,14)
				'Scale 1,1
			Case STATE_PLAYING
				Cls 0,0,0
				SetBlend(0)
					'SetColor(255,0,0)
						'Debug(player)
					'SetColor(255,255,255)
					player.Draw()
					TBullet.DrawAll()
					TAlien.DrawAll()
					TAlienBullet.DrawAll()
					TBonus.DrawAll()
					TBurst.DrawAll()
					Local s:String = Score
					TFont.Display(s,300,10,14)
					TFont.Display("POINTS:",200,10,14)
				'SetColor 255,255,255
			Case STATE_PAUSED
				Cls 0,0,0
				SetBlend(0)
				SetAlpha 0.5 
					player.Draw()
					TBullet.DrawAll()
					TAlien.DrawAll()
					TAlienBullet.DrawAll()
					TBonus.DrawAll()
					TBurst.DrawAll()
					Local s:String = Score
					TFont.Display(s,300,10,14)
					TFont.Display("POINTS:",200,10,14)
				SetAlpha 1 
				'SetColor 255,255,255
		End Select 
		
		Return 0
	End Method 
End 
Function Debug:Void(_player:TPlayer)
	Local player:TPlayer = _player
	SetColor 0,0,255
		DrawText "SpawnTimer : "+TAlien.spawnTimer, 10,10
		DrawText player.shot, 10, 30
	SetColor 255,255,255
End Function 
'Class TScore
'	Global list:List<TScore> = New List<TScore>
'	Global score:Int 
'	Field xpos:Int, ypos:Int 
	
'	Method New()
'		list.AddLast(Self)
'	End 
	
'	Method Draw:Void(_xpos:Int,_ypos:Int)
'		SetColor 255,0,0 
'			DrawText score,_xpos,_ypos
'		SetColor 255,255,255
'	End 
	
'	Method Refresh:Int(_inc:Int)
'		Return score+=_inc 
'	End Method 
'End 

Function Mid$( str$,pos:Int,size:Int=-1 )
		If pos>str.Length() Return ""
		pos-=1
		If( size<0 ) Return str[pos..]
		If pos<0 size=size+pos pos=0
		If pos+size>str.Length() size=str.Length()-pos
		Return str[pos..pos+size]
End Function

Class TFont
	Global img:Image 
	
	Function Display:Void(_disp$,_xpos%,_ypos%,_step%)
		For Local a:Int = 1 To _disp.Length()
			Local frame:Int= Mid(_disp,a,1)[0]-48
			DrawImage(img,_xpos+a*_step,_ypos,frame)
		Next 
	End Function 
	
	Function LoadBmp:Void(_img:Image)
		img = _img 
	End Function 
End Class 

Class TEntity 
	Field x:Float, y:Float
	Field sx:Float, sy:Float
	Field id:Int 
End 

Class TPlayer Extends TEntity
	Global image:Image
	Global halo:Image 
	Field timer:Int
	Field shot:Int = 1
	
	Method New(_x:Int,_y:Int)
		'playerImg = _playerImage 
		Self.sx = 2
		Self.sy = 2
		Self.x = _x
		Self.y = _y
		 
	End Method 
	
	Function LoadSprite:Void(_image:Image, _halo:Image)
		image = _image 
		halo = _halo
	End Function 
	
	Method Shoot:Void()
		'If KeyDown(KEY_SPACE)
		If shot = 1
			If Millisecs() >= timer+250
				New TBullet(x+20, y+6, 8)
				timer = Millisecs()
			Endif 
		Endif 
		If shot = 2
			If Millisecs() >= timer+250
				New TBullet(x+20, y-4, 8)
				New TBullet(x+20, y+14, 8)
				timer = Millisecs()
			Endif 
		Endif
		If shot = 3
			If Millisecs() >= timer+250
				New TBullet(x+20, y-8, 8)
				New TBullet(x+20, y+6, 8)
				New TBullet(x+20, y+20, 8)
				timer = Millisecs()
			Endif 
		Endif 
	End Method 
	
	Method Move:Void()
		If KeyDown(KEY_UP) y = y-sy
		If KeyDown(KEY_DOWN) y = y+sy
		If KeyDown(KEY_RIGHT) x = x+sx
		If KeyDown(KEY_LEFT) x = x-sx 
		For Local b:TBonus = Eachin TBonus.list
			If Dist2(x,y,b.x,b.y) <= 28 
				TBonus.list.Remove(b)
				shot +=1
			Endif
		Next  
	End Method 
	
	Method Draw:Void()
		SetAlpha 0.2
			DrawImage(halo,x-48,y-48,0,2,2,0)
		SetAlpha 1 
			DrawImage(image,x,y,0)

	End Method 
End 

Class TBonus Extends TEntity
	Global list:List<TBonus> = New List<TBonus>
	Global img:Image
	Global halo:Image 
	
	Method New(_x:Int,_y:Int,_id:Int)
		Self.x = _x
		Self.y = _y
		Self.id = _id
		Self.sx = 2
		list.AddLast(Self)
	End 
	
	Function LoadSprite:Void(_img:Image)
		img = _img
	End Function 
	
	Method Draw:Void()
		SetAlpha .5
			DrawImage halo,x-24,y-24,0
		SetAlpha 1
			DrawImage(img,x,y,0)
	End 
	
	Method Refresh:Void()
		x-=sx
	
	End Method 
	
	Function DrawAll:Void()
		For Local b:TBonus = Eachin list
			b.Draw()
		Next 
	End Function 
	
	Function RefreshAll:Void()
		For Local b:TBonus = Eachin list
			b.Refresh()
		Next 
	End Function 
End 

Class TAlien Extends TEntity
	Global list:List<TAlien> = New List<TAlien>
	Global img:Image
	Global halo:Image 
	Global vx:Float 
	Global img_hit:Image
	Field ang:Int
	Field bulletTimer:Int
	Field timer:Int 
	Field life:Int 
	Field hit:Int   
	Field hitTimer:Int 
	Global spawnTimer:Int 
	Global point:Int 
	
	Method New(_x:Float, _y:Float, _sx:Float, _sy:Float, _id:Int)
		Self.x = _x
		Self.y = _y
		Self.sx = _sx
		Self.sy = _sy
		Self.id = _id
		ang = Rnd(359)
		life = 2
		'Local a:Int = Rnd(200) 
		'If a = 100 hasBonus = True 
		list.AddLast(Self)
	End Method  
	
	Function LoadSprite:Void(_img:Image, _img_hit:Image, _halo:Image)
		img = _img
		img_hit = _img_hit 
		halo = _halo
	End Function 

	
	Method Draw:Void()
		SetAlpha 0.2
			DrawImage(halo, x-36, y-36, 0)
		SetAlpha 1
			DrawImage(img, x, y, 0) 
		If hit = True 
			DrawImage(img_hit,x,y,0)
		Endif 
	End Method 
	
	Function DrawAll:Void()
		For Local a:TAlien = Eachin list
				a.Draw()
		Next 
	End Function
	
	Method Refresh:Void()
		 
		If id = 0
			x-=sx
			ang+=7
			If ang >= 360 ang = 0
			sy=Cos(ang)
			y+=sy
			If x < -32 list.Remove(Self)
		Endif 
		If id = 1
			x-=sx
			sx+=.01
			ang+=7
			If ang >= 360 ang = 0
			sy=Cos(ang)
			y+=sy
			
			If x < ScrW/2 
				New TAlienBullet(x,y,3,0)
				New TAlienBullet(x,y,3,1)
				New TAlienBullet(x,y,3,2)		
				sx = 2
				sx*=-1
			Endif 
			If x < -32 list.Remove(Self)
		Endif
		If id = 2
			y+=sy
			ang+=7
			If ang >= 360 ang = 0
			sx = Sin(ang)
			x+=sx
			If y = 100 New TAlienBullet(x,y,3,0)
			If y = 200 New TAlienBullet(x,y,3,0)
			If y > ScrH+32 list.Remove(Self)
		Endif  
		If id = 3
			y-=sy
			ang+=7
			If ang >= 360 ang = 0
			sx = Sin(ang)
			x+=sx
			If y = ScrW-132 New TAlienBullet(x,y,3,0)
			If y = ScrW-232 New TAlienBullet(x,y,3,0)
			If y <= -32 list.Remove(Self) 
		Endif 
	End Method 
	
	Function RefreshAll:Void()
		For Local a:TAlien = Eachin list 
				a.Refresh()
				a.ShotBullet()
		Next 
	End Function  
	
	Method ShotBullet:Void()
		
		'		New TAlienBullet(x,y,3,0)
		'		New TAlienBullet(x,y,3,1)
		'		New TAlienBullet(x,y,3,2)
		
	End Method 
	
	Function Spawn:Void()
		Local steps%
		spawnTimer+=1
		If spawnTimer = 100 
			For Local n% = 0 Until 6
				steps+=32
				New TAlien(ScrW+steps,50,1,0,0)
			Next 
		Endif 
		If spawnTimer = 500
			For Local n% = 0 Until 6
				steps+=32
				New TAlien(ScrW+steps,ScrH-82,1,0,0)
			Next
		Endif 
		If spawnTimer = 900
			New TAlien(ScrW+64,ScrH/2-32,1,0,1)
		Endif 
		If spawnTimer = 1200
			New TAlien(ScrW+64,50,1,0,1)
			New TAlien(ScrW+64,ScrH-82,1,0,1)
		Endif 
		If spawnTimer = 1500
			For Local n% = 0 Until 6
				steps+=32
				New TAlien(ScrW+steps,100,1.5,0,0)
			Next 
			For Local n% = 0 Until 6
				steps+=32
				New TAlien(ScrW+steps,ScrH/2-12,1.5,0,0)
			Next 
			For Local n% = 0 Until 6
				steps+=32
				New TAlien(ScrW+steps,ScrH-132,1.5,0,0)
			Next 
		Endif 
		If spawnTimer = 1900
			For Local n% = 0 Until 6
				steps+=32
				New TAlien(ScrW/2,0-steps,1.5,1.5,2)
			Next 
			For Local n% = 0 Until 6
				steps+=32
				New TAlien(ScrW/2+32,ScrH+steps,1.5,1.5,3)
			Next 
		Endif 
	End Function 
End 

Class TAlienBullet Extends TEntity
	Global list:List<TAlienBullet> = New List<TAlienBullet>
	Global img:Image 

	
	Method New(_x:Float, _y:Float, _sx:Float, _id:Int)
		Self.x = _x
		Self.y = _y
		Self.sx = _sx
		Self.id = _id 
		list.AddLast(Self)
	End Method  
	
	Function LoadSprite:Void(_img:Image)
		img = _img 
	End Function
	
	
	Method Draw:Void()
			DrawImage(img,x,y,0)
	End Method
	
	Method Refresh:Void()
		If id = 0 
			x-=sx
		Elseif id = 1
			x-=sx
			y-=1
		Elseif id = 2
			x-=sx
			y+=1
		Endif 
		If x <= 0 	list.Remove(Self)
		If y <= 0 	list.Remove(Self)
		If y >= ScrH list.Remove(Self)
	End Method 
	
	Function DrawAll:Void()
		For Local b:TAlienBullet = Eachin list 
			b.Draw()
		Next 
	End Function 
	
	Function RefreshAll:Void()
		For Local b:TAlienBullet = Eachin list 
			b.Refresh()
		Next 
	End Function 
End 

Class TBurst Extends TEntity 
	Global list:List<TBurst> = New List<TBurst>
	Field r:Int,g:Int,b:Int 
	Field alpha:Float = 1  
	Global halo:Image 
	
	Method New(_x:Int,_y:Int,_sx:Int,_sy:Int,_r:Int,_g:Int,_b:Int)
		Self.x = _x
		Self.y = _y
		Self.sx = _sx
		Self.sy = _sy
		r = _r
		g = _g
		b = _b
		list.AddLast(Self)
	End Method 
	
	Method Refresh:Void()
		x+=sx
		y+=sy 
		alpha-=.02
		If alpha <= 0 list.Remove(Self) 
	End Method 
	
	Method Draw:Void()
		SetAlpha .2
			DrawImage halo, x-44,y-44
		SetAlpha alpha
		SetColor r,g,b
			DrawRect x,y,8,8
		SetColor 255,255,255
		SetAlpha 1 
	End Method 
	
	Function RefreshAll:Void()
		For Local b:TBurst = Eachin list
			b.Refresh()
		Next 
	End Function 
	
	Function DrawAll:Void()
		For Local b:TBurst = Eachin list
			b.Draw()
		Next 
	End Function 
End 

Class TBullet Extends TEntity
	Global list:List<TBullet> = New List<TBullet>
	Global img:Image 
	Global halo:Image 
	
	Method New(_x:Int, _y:Int, _sx:Int)
		Self.x = _x
		Self.y = _y
		Self.sx = _sx
		list.AddLast(Self)
	End Method 
	
	Function LoadSprite:Void(_img:Image)
		img=_img
	End Function  
	
	Method Draw:Void()
		SetAlpha 0.2
			DrawImage(halo,x-24,y-24,0)
		SetAlpha 1
			DrawImage(img, x, y, 0)
	End Method 
	
	Method Refresh:Void()
		x = x+sx
		If x >= ScrW+32 list.Remove(Self)
		
	End Method 
	
	Function DrawAll:Void()
		For Local b:TBullet = Eachin list 
				b.Draw()
				'For Local a:TAlien = Eachin TAlien.list
						'DrawText dist(en.x, en.y, b.x, b.y),10,10
				'Next 
		Next 
	End Function 

	Function RefreshAll:Void()
		For Local b:TBullet = Eachin list
				b.Refresh()
				For Local a:TAlien = Eachin TAlien.list
					If Dist(a.x, a.y, b.x, b.y) <= 23 
						'DrawText dist(en.x, en.y, b.x, b.y),10,10
						a.hit = True 
						a.life-=1
						
						If a.life <= 0 
							New TBurst(a.x,a.y,-3, 0,0,0,255)
							New TBurst(a.x,a.y, 3, 0,0,0,255)
							New TBurst(a.x,a.y, 0,-3,0,0,255)
							New TBurst(a.x,a.y, 0, 3,0,0,255)
							
							New TBurst(a.x,a.y,-3,-2, 0, 0,255)
							New TBurst(a.x,a.y,-3, 2, 0, 0,255)
							New TBurst(a.x,a.y, 3,-2, 0, 0,255)
							New TBurst(a.x,a.y, 3, 2, 0, 0,255)
							Score+=100
							If Score = 600
								New TBonus(a.x,a.y,0)
							Endif 
							If Score = 1200
								New TBonus(a.x,a.y,0)
							Endif 
							TAlien.list.Remove(a)
							
						Endif 
						list.Remove(b)
 
					Endif 
					If a.hit = True 
						a.hitTimer+=1
						If a.hitTimer>=100
							a.hit = False 
						Endif 
					Endif 
				Next 
		Next 
	End Function 
End 

Function Dist:Int(x1:Int,y1:Int,x2:Int,y2:Int)
	Return Sqrt(Pow((x1-x2),2) + Pow((y1-y2),2))
End Function

Function Dist2:Int(x1:Int,y1:Int,x2:Int,y2:Int)
	Return Sqrt(Pow((x1-x2),2) + Pow((y1-y2),2))
End Function

Function Main:Int()
	New TGame
	Return 0
End Function 
