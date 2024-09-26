'Free and Open Source Project
'DOSBOX, FREEDOS GRAPHICS ENVIRONMENT
'
'BY LUKAS
'UNDER A TERMS A MIT LICENSE
'
'
'
' FreeBASIC #lang command is for compatibility with QuickBASIC,
' there is nothing wrong to use fblite mode.
'
#lang "fblite"

#ifdef __FB_WIN32__
#define SLASH "\"
#define CONFIG_DIR environ("APPDATA") & SLASH & __appname & SLASH
#define CONFIG_NAME "interfw.ini"
#define HOME_DIR environ("APPDATA") & SLASH
#endif

#ifdef __FB_DOS__
#define SLASH "\"
#define CONFIG_DIR exepath() & SLASH
#define CONFIG_NAME "interf.ini"
#define HOME_DIR exepath() & SLASH
#endif

#ifdef __FB_LINUX__
#define SLASH "/"
#define CONFIG_DIR environ("HOME") & SLASH & ".config" & SLASH & __appname & SLASH
#define CONFIG_NAME "interf.ini"
#define HOME_DIR environ("HOME") & SLASH
#endif

declare sub printf overload (x, y, s as string, c as ubyte)
declare sub printf overload (x, y, s as string, c as ubyte, buffer as any ptr)

declare sub drawin overload (x, y, x1, y1, cap as string)
declare sub drawin overload (x, y, x1, y1, cap as string, buffer as any ptr)
declare sub redraw ()
declare sub res (x, y)
declare sub resize(x, y, buffer as any ptr)

declare sub mktop (id)
declare sub closewin (id)
declare sub makewin (x, y, x1, y1, cap as string, pid)

declare sub clock (id)
declare sub smalldir (id)
declare sub text (id)
declare sub loadbmp (id)
declare sub runcom (id)

declare sub terminal (id)

declare function readIniValue (iniFile as string, searchSection as string, searchKey as string) as string

declare function getfiles (path as string, f() as string)
declare function mousebox (x, y, x1, y1)

dim shared mx, my, mb

type wintype
	x as integer
	y as integer
	x1 as integer
	y1 as integer
	cap as string
	pid as integer
	
	diri as integer
	
	iptr as any ptr
end type
dim shared win(100) as wintype
dim shared as integer wins = 0


dim shared sdir(100) as string
dim shared sdirs(100) as integer
dim shared sdirf(500) as string
redim shared dirselect(0) as string
redim shared dircopy(0) as string


type listtype
	s as zstring ptr
	p as any ptr
	n as any ptr
end type
dim shared as listtype ptr list, prev, tfirst(100), tc(100)
dim shared as integer tl(100), tcx(100), tcy(100), tsx(100), tsy(100)
dim shared as string tf(100)


type loadbmptype
	iptr as any ptr
	x as integer
	y as integer
end type
dim shared lbmp(100) as loadbmptype
dim shared bmpf(100) as string

dim shared runcomx(100) as string

dim ss as string

dim shared menu1(9) as string
menu1(0)="menu"
menu1(1)=""
menu1(2)="file man"
menu1(3)="command line"
menu1(4)="clock"
menu1(5)="run"
menu1(6)=""
menu1(7)="-----------"
menu1(8)="options >"
menu1(9)="exit"

dim shared menu2(6) as string
menu2(0)=" 320x240"
menu2(1)=" 640x480"
menu2(2)=" 800x600"
menu2(3)=" 1024x768"
menu2(4)="*640x400" 'this is widescreen resolution
menu2(5)=" "
menu2(6)="bg center"

dim shared bgstretch=0
dim shared bgoff=0

dim xxx as integer
xxx = val(readIniValue(CONFIG_NAME, "screen", "resx"))
dim yyy as integer
yyy = val(readIniValue(CONFIG_NAME, "screen", "resy"))

screenres  xxx, yyy, 8
dim shared as integer screenw,screenh
screeninfo screenw,screenh

dim shared as any ptr temp1,temp2,temp3,temp4
temp1 = imagecreate(screenw,screenh)

dim shared font(1040) as ubyte
bload "font.dat", varptr(font(11))

dim sss as string
sss = readIniValue(CONFIG_NAME, "screen", "bg")

dim shared s as string*2
dim shared as ushort ffbx, by
dim shared bg as any ptr
bg = imagecreate(screenw,screenh,0)
if not bgoff then
	open sss for binary as #1
		get #1,,s
		if s="BM" then
			get #1,19,fbx
			get #1,23,by
			temp3=imagecreate(fbx,by)
			bload sss,temp3
			if bgstretch then
				resize screenw,screenh,temp3
				imagedestroy bg
				bg = temp3
			else
				put bg,((screenw-fbx)\2,(screenh-by)\2),temp3
				imagedestroy temp3
			end if
		end if
	close
end if

palette  0, &h000000
palette 15, &hffffff

'SETMOUSE 0,0,0 'hide cursor
'Dim As Any Ptr cur=ImageCreate(10,10,0)
'  load custom mouse pointer
dim CursorImage(64 * 64) as ubyte
dim Cursor1 as any pointer
bload "hand1.bmp", varptr(CursorImage(0))
Cursor1 = imagecreate(64, 64)
get CursorImage, (0,0)-(63,63), Cursor1



'makewin 400,200,150,175,"clock",1
'makewin 100,100,150,175,"clock1",1

'makewin 0,0,150,200,"dir",2
'win(wins-1).diri=wins-1
'sdir(win(wins-1).diri)="C:\"
'sdirs(win(wins-1).diri)=0

'makewin 0,0,150,200,"dir",2
'win(wins-1).diri=wins-1
'sdir(win(wins-1).diri)="C:\font\"
'sdirs(win(wins-1).diri)=0


makewin screenw-170,screenh-195,150,175,"clock",1
					
mktop wins-1
screenlock	
put(0,0),bg,pset
redraw
screenunlock
clock 0		

'makewin 50,50,200,200,"text",3
'win(wins-1).diri=wins-1
'tf(win(wins-1).diri)="readme.txt"
'open tf(win(wins-1).diri) for input as #1
'tl(win(wins-1).diri)=0
'prev = 0
'do
'	line input #1, ss
'	tl(win(wins-1).diri)+=1
'	
'	list = allocate(len(listtype))
'	if prev<>0 then prev->n = list else tfirst(win(wins-1).diri) = list
'	list->s = allocate(len(ss)+1)
'	*list->s = ss
'	list->n = 0
'	list->p = prev
'	prev = list
'loop until eof(1)
'close
'tcx(win(wins-1).diri)=0
'tcy(win(wins-1).diri)=0
'tsx(win(wins-1).diri)=0
'tsy(win(wins-1).diri)=0
'tc(win(wins-1).diri)=tfirst(win(wins-1).diri)


'open "PRINCE.BMP" for binary as #1
'
'	get #1,,s
'	if s="BM" then
'
'		get #1,19,fbx
'		get #1,23,by
'		
'		makewin 50,50,fbx+2,by+27,"INTRO",4
'		win(wins-1).diri=wins-1
'		bmpf(wins-1)="prince.bmp"
'	end if
'close

dim key as string
dim ti as double
'makewin 50,50,150,200,"dir",2
'win(wins-1).diri=wins-1
'sdir(win(wins-1).diri)=".\img\"
'sdirs(win(wins-1).diri)=0

screenlock
put(0,0),bg,pset
for i=wins-1 to 0 step -1
	select case win(i).pid
	case 1
		clock i
	case 2 
		smalldir i
	case 3
		text i
	case 4
		loadbmp i
	case 5 
		runcom i
	case 6
		terminal i
	case else
		drawin 0,0,win(i).x1,win(i).y1,win(i).cap,win(i).iptr
		put (win(i).x,win(i).y),win(i).iptr,pset
	end select
next
screenunlock

const xres = 640*1
const yres = 400*1

'SETMOUSE 0,0,0 'hide cursor

do
start:
	getmouse mx,my,,mb

	'custom mouse cursor
	'SETMOUSE mx,my,0 'hide cursor
	'Put (mx,my),cur
    	'Pcopy
	'  display custom mouse cursor
    'put (mx, my), Cursor1, trans
	' screencopy
	
	'window management
	for i=0 to wins-1
		if mousebox(win(i).x,win(i).y,win(i).x1+win(i).x,win(i).y1+win(i).y) then
			if mousebox(win(i).x,win(i).y,win(i).x1+win(i).x,win(i).y+25) then

				if mb=1 then
					mktop i

					screenlock
					put(0,0),bg,pset
					redraw
					get(0,0)-(screenw-1,screenh-1),temp1
					put(win(0).x,win(0).y),win(0).iptr,pset
					screenunlock

					oldx= mx-win(0).x
					oldy= my-win(0).y
					do
						oldmx= mx
						oldmy= my
						getmouse mx,my,,mb
							
						newx= mx-oldx
						newy= my-oldy
						if mx<>oldmx and my<>oldmy then							
							screenlock	
							put(0,0),temp1,pset
							'put(newx,newy),temp2,pset
							'line(0,0)-(639,479),0,bf
							'redraw
							'drawin newx,newy,win(0).x1,win(0).y1,win(0).cap
							put(newx,newy),win(0).iptr,pset

							screenunlock
						end if
					loop until mb=0
					win(0).x= newx
					win(0).y= newy
						
					screenlock
					put(0,0),bg,pset
					redraw
					put(win(0).x,win(0).y),win(0).iptr,pset
					screenunlock
					exit for
					goto start
				elseif mb=2 then
					do
						getmouse mx,my,,mb
					loop while mb=2
				
					closewin i
					screenlock
					put(0,0),bg,pset
					redraw
					put(win(0).x,win(0).y),win(0).iptr,pset
					screenunlock
					exit for
					goto start
				end if
			else
				if mb<>0 then
					mktop i
					screenlock
					put(0,0),bg,pset
					redraw
					get(0,0)-(screenw-1,screenh-1),temp1
					put(win(0).x,win(0).y),win(0).iptr,pset
					screenunlock
					goto start
				end if
				exit for
			end if
			
		end if
	next
	
	'menu
	if mb=2 then
		do
			getmouse mx,my,,mb
		loop while mb=2
		l=len(menu1(0))
		for i=0 to ubound(menu1)
			if l<len(menu1(i)) then l=len(menu1(i))
		next
		
		x=l*8+10
		y=(ubound(menu1)+1)*15+10
		temp2=imagecreate(x+1,y+1)
		
		if screenw-mx<=x then ox=screenw-x-1 else ox=mx
		if screenh-my<=y then oy=screenh-y-1 else oy=my
		
		get (ox,oy)-step(x,y),temp2
		do
			getmouse mx,my,,mb
			screenlock
			line (ox+1,oy+1)-step(x-2,y-2),0,bf
			line (ox,oy)-step(x,y),15,b
			for i=0 to ubound(menu1)
				if (my-oy-5)\15 = i then
					line(ox+1,oy+3+((my-oy-5)\15)*15)-step(x-2,15),15,bf
					printf ox+5,oy+i*15+5,menu1(i),0
				else
					printf ox+5,oy+i*15+5,menu1(i),15
				end if
			next
			screenunlock
			
			'sub menu
			if (my-oy-5)\15 = ubound(menu1)-1 then
				l2=len(menu2(0))
				for i=0 to ubound(menu2)
					if l2<len(menu2(i)) then l2=len(menu2(i))
				next
				
				x2=l2*8+10
				y2=(ubound(menu2)+1)*15+10
				temp3=imagecreate(x2+1,y2+1)
				
				ox2=ox+x+1
				oy2=oy+((my-oy-5)\15)*15
				if screenw-ox-x<x2+2 then ox2=ox-x2-1
				if screenh-oy-y<y2 then oy2=screenh-y2-1
				
				get(ox2,oy2)-step(x2,y2),temp3
				do 
					getmouse mx,my,,mb
					
					screenlock
					line (ox2+1,oy2+1)-step(x2-2,y2-2),0,bf
					line (ox2,oy2)-step(x2,y2),15,b
					for i=0 to ubound(menu2)
						if (my-oy2-5)\15 = i then
							line(ox2+1,oy2+3+((my-oy2-5)\15)*15)-step(x2-2,15),15,bf
							printf ox2+5,oy2+i*15+5,menu2(i),0
						else
							printf ox2+5,oy2+i*15+5,menu2(i),15
						end if
					next
					screenunlock
					if mb<>0 then
						if mousebox(ox2,oy2,ox2+x2,oy2+y2) then
							select case (my-oy2-5)\15
							case 0
								menu2(0)="*320x240"
								menu2(1)=" 640x480"
								menu2(2)=" 800x600"
								menu2(3)=" 1024x768"
								menu2(4)=" 640x400"
								'res 320, 240
								'goto start
							case 1
								menu2(0)=" 320x240"
								menu2(1)="*640x480"
								menu2(2)=" 800x600"
								menu2(3)=" 1024x768"
								menu2(4)=" 640x400"
								
								put (ox2,oy2),temp3,pset
								imagedestroy temp3
								res 640, 480
								goto start
							case 2
								menu2(0)=" 320x240"
								menu2(1)=" 640x480"
								menu2(2)="*800x600"
								menu2(3)=" 1024x768"
								menu2(4)=" 640x400"
								put (ox2,oy2),temp3,pset
								imagedestroy temp3
								res 800, 600
								goto start
							case 3
								menu2(0)=" 320x240"
								menu2(1)=" 640x480"
								menu2(2)=" 800x600"
								menu2(3)="*1024x768"
								menu2(4)=" 640x400"
								put (ox2,oy2),temp3,pset
								imagedestroy temp3
								res 1024, 768
								goto start
							case 4
								menu2(0)=" 320x240"
								menu2(1)=" 640x480"
								menu2(2)=" 800x600"
								menu2(3)=" 1024x768"
								menu2(4)="*640x400"
								put (ox2,oy2),temp3,pset
								imagedestroy temp3
								res 640, 400
								goto start
							case 6
								if mb=1 then
									bgstretch=not bgstretch
									bgoff=0
									if bgstretch then menu2(6)="bg stretch" else menu2(6)="bg center"
									put (ox2,oy2),temp3,pset
									imagedestroy temp3
									res screenw, screenh
									goto start
								else
									do
										getmouse mx,my,,mb
									loop until mb=0
									menu2(5)="bg off"
									bgoff=-1
									put (ox2,oy2),temp3,pset
									imagedestroy temp3
									res screenw, screenh
									goto start
								end if
							
							case 7
								goto start
							
							end select
						end if
					end if
				loop while ((my-oy-5)\15 = ubound(menu1)-1 and mousebox(ox,oy,ox+x,oy+y)) or mousebox(ox2,oy2,ox2+x2,oy2+y2)
				put (ox2,oy2),temp3,pset
				imagedestroy temp3
			end if
			
			'
			'menu selection
			if mb=1 and mousebox(ox,oy,ox+x,oy+y) then 
				put (ox,oy),temp2,pset
				
				select case (my-oy-5)\15
				case 0
					'MAIN			
					goto start
				case 2
					'Directory Listing
					makewin mx,my,150,200,"dir",2
					win(wins-1).diri=wins-1
					sdir(win(wins-1).diri)="c:\"
					sdirs(win(wins-1).diri)=0
					
					mktop wins-1
					screenlock	
					put(0,0),bg,pset
					redraw
					screenunlock
					smalldir 0
					goto start
				case 3
					'Open Command Line
					makewin mx,my,300,200,"Open Command Line",6
					win(wins-1).diri=wins-1
					runcomx(win(wins-1).diri)=HOME_DIR
					
					mktop wins-1
					screenlock	
					put(0,0),bg,pset
					redraw
					screenunlock
					runcom 0				
					goto start
				case 4
					makewin mx,my,150,175,"clock",1
					
					mktop wins-1
					screenlock	
					put(0,0),bg,pset
					redraw
					screenunlock
					clock 0				
					goto start
				case 5
					makewin mx,my,200,50,"run command",5
					win(wins-1).diri=wins-1
					runcomx(win(wins-1).diri)=""
					
					mktop wins-1
					screenlock	
					put(0,0),bg,pset
					redraw
					screenunlock
					runcom 0				
					goto start
				case ubound(menu1)
					end
				case else
				end select
			end if
		loop until mb<>0'while mousebox(ox,oy,ox+x,oy+y)
		
		put (ox,oy),temp2,pset
		imagedestroy temp2
	end if
		
	'live redrawing & application main loops
	select case win(0).pid
	case 1
		clock 0
	case 2
		if mousebox(win(0).x,win(0).y+25,win(0).x+win(0).x1,win(0).y+win(0).y1) then
			j=getfiles(sdir(win(0).diri),sdirf())
			do while mousebox(win(0).x,win(0).y+25,win(0).x+win(0).x1,win(0).y+win(0).y1)
			
				if multikey(&h1d) then
					if ubound(dirselect)>0 then
						if multikey(&h2d) then 'x
							locate 1,1
							?"SELECTED"
							redim dircopy(ubound(dirselect))
							for i=1 to ubound(dirselect)
								dircopy(i)=dirselect(i)
								'?dircopy(i)
							next
						end if
						if multikey(&h2f) then 'v
							locate 1,1
							?"COPIED"
							for i=1 to ubound(dircopy)
								if right(dircopy(i),1)<>"\" then 
									open pipe "copy "+dircopy(i)+" "+sdir(win(0).diri) for input as #1
									close
								end if
							next
							redim dircopy(0)
							smalldir 0
						end if
						if multikey(&h32) then 'm
							locate 1,1
							?"MOVED"
							for i=1 to ubound(dircopy)
								if right(dircopy(i),1)<>"\" then 
									open pipe "move "+dircopy(i)+" "+sdir(win(0).diri) for input as #1
									close
								end if
							next
							redim dircopy(0)
							smalldir 0
						end if
						
					end if
					if multikey(&h31) then 'n
						locate 1,1
						?"NEW FILE:";
						line input ss
						open sdir(win(0).diri)+ss for output as #1
						close
						smalldir 0
					end if
				end if
				if multikey(&h53) then
					if ubound(dirselect)>0 then
						locate 1,1
						?"DELETED"
						for i=1 to ubound(dirselect)
							kill dirselect(i)
						next
						redim dirselect(0)
						smalldir 0
					end if
				end if
				
				getmouse mx,my,,mb
							
				if mousebox(win(0).x+win(0).x1-25,win(0).y+win(0).y1-25,win(0).x+win(0).x1,win(0).y+win(0).y1) then
				
					if mb=1 then 'resize
						screenlock
						put(0,0),bg,pset
						redraw
						get(0,0)-(screenw-1,screenh-1),temp1
						put(win(0).x,win(0).y),win(0).iptr,pset
						screenunlock
						
						oldx=win(0).x1-mx
						oldy=win(0).y1-my
						do
							getmouse mx,my,,mb
							imagedestroy win(0).iptr
							if mx+oldx>=150 then win(0).x1=mx+oldx
							if my+oldy>=100 then win(0).y1=my+oldy
							
							win(0).iptr=imagecreate(win(0).x1+1,win(0).y1+1)	
							
							screenlock		
							put(0,0),temp1,pset
							
							drawin 0,0,win(0).x1,win(0).y1,sdir(win(0).diri),win(0).iptr
							line win(0).iptr,(win(0).x1,25)-step(-25,25),15,b
							line win(0).iptr,-(win(0).x1,win(0).y1-50),15,b
							line win(0).iptr,-step(-25,25),15,b
							line win(0).iptr,-step(25,25),15,b
							xx = (win(0).x1-25)\125
							sdirs(win(0).diri)=(sdirs(win(0).diri)\xx)*xx
							'xx replace
							for i=0 to (win(0).y1-30)\15-1
								for k=0 to xx-1
									if i*xx+k+sdirs(win(0).diri)>=j then exit for
									printf 5+k*125, 30+i*15, sdirf(i*xx+k+sdirs(win(0).diri)), 15, win(0).iptr
								next
							next
							put(win(0).x,win(0).y),win(0).iptr,pset
							screenunlock
						loop while mb=1
												
					end if
				
				elseif mousebox(win(0).x+win(0).x1-25,win(0).y+win(0).y1-50,win(0).x+win(0).x1,win(0).y+win(0).y1-25) then 'scroll down
					if mb=1 then			
						ti=timer
												
						if ((win(0).x1-25)\125)*((win(0).y1-30)\15)+sdirs(win(0).diri)<j then sdirs(win(0).diri)+=(win(0).x1-25)\125
						
						line win(0).iptr,(1,26)-(win(0).x1-26,win(0).y1-1),0,bf
						for i=0 to (win(0).y1-30)\15-1
							for k=0 to (win(0).x1-25)\125-1
								if i*((win(0).x1-25)\125)+k+sdirs(win(0).diri)>=j then exit for
								printf 5+k*125, 30+i*15, sdirf(i*((win(0).x1-25)\125)+k+sdirs(win(0).diri)), 15, win(0).iptr
							next
						next
						put(win(0).x,win(0).y),win(0).iptr,pset
						
						do
						loop until timer-ti>0.04
					end if			
				elseif mousebox(win(0).x+win(0).x1-25,win(0).y+25,win(0).x+win(0).x1,win(0).y+50) then
					if mb=1 then
						ti = timer
						
						if sdirs(win(0).diri)>=(win(0).x1-25)\125 then sdirs(win(0).diri)-=(win(0).x1-25)\125
						
						line win(0).iptr,(1,26)-(win(0).x1-26,win(0).y1-1),0,bf
						for i=0 to (win(0).y1-30)\15-1
							for k=0 to (win(0).x1-25)\125-1
								if i*((win(0).x1-25)\125)+k+sdirs(win(0).diri)>=j then exit for
								printf 5+k*125, 30+i*15, sdirf(i*((win(0).x1-25)\125)+k+sdirs(win(0).diri)), 15, win(0).iptr
							next
						next
						put(win(0).x,win(0).y),win(0).iptr,pset
						
						do
						loop until timer-ti>0.04
					end if
				'elseif mousebox(win(0).x,win(0).y+25,win(0).x+win(0).x1-25,win(0).y+win(0).y1) then
				'you have wandered off into a very evil area
				elseif mousebox(win(0).x,win(0).y+25,win(0).x+125*((win(0).x1-25)\125),win(0).y+30+15*((win(0).y1-30)\15)-5) then
					
					if mb=1 then
						do
							getmouse mx,my,,mb
						loop until mb=0
						
						f=((mx-win(0).x-5)\125)+((my-win(0).y-25)\15)*((win(0).x1-25)\125)+sdirs(win(0).diri)
						
						if f < j then
							if sdirf(f)="..\" then
								if right(sdir(win(0).diri),2)<>":\" then
									for i=len(sdir(win(0).diri)) to 2 step -1
										if mid(sdir(win(0).diri),i-1,1)="\" then exit for
									next
									if multikey(&h1d) then
										makewin mx,my,150,200,"dir",2
										win(wins-1).diri=wins-1
										sdir(win(wins-1).diri)=left(sdir(win(0).diri),i-1)
										sdirs(win(wins-1).diri)=0
										
										mktop wins-1
										screenlock
										put(0,0),bg,pset
										redraw
										smalldir 0
										screenunlock
									else
										sdir(win(0).diri)=left(sdir(win(0).diri),i-1)
										sdirs(win(0).diri)=0
										smalldir 0
									end if
									exit select
								end if
							elseif right(sdirf(f),1)="\" then
								if multikey(&h1d) then
									makewin mx,my,150,200,"dir",2
									win(wins-1).diri=wins-1
									sdir(win(wins-1).diri)=sdir(win(0).diri) + sdirf(f)
									sdirs(win(wins-1).diri)=0
									
									mktop wins-1
									screenlock
									put(0,0),bg,pset
									redraw
									smalldir 0
									screenunlock
								else
									sdir(win(0).diri) += sdirf(f)
									sdirs(win(0).diri)=0
									smalldir 0
								end if
								exit select
							elseif ucase(right(sdirf(f),4))=".BAS" or ucase(right(sdirf(f),4))=".TXT" then							

								makewin mx,my,200,200,"",3
								win(wins-1).diri=wins-1
								tf(win(wins-1).diri)=sdir(win(0).diri)+sdirf(f)
								open tf(win(wins-1).diri) for input as #1
								tl(win(wins-1).diri)=0
								prev = 0
								do
									line input #1, ss
									tl(win(wins-1).diri)+=1
									
									list = allocate(len(listtype))
									if prev<>0 then prev->n = list else tfirst(win(wins-1).diri) = list
									list->s = allocate(len(ss)+1)
									*list->s = ss
									list->n = 0
									list->p = prev
									prev = list
								loop until eof(1)
								close
								tcx(win(wins-1).diri)=0
								tcy(win(wins-1).diri)=0
								tsx(win(wins-1).diri)=0
								tsy(win(wins-1).diri)=0
								tc(win(wins-1).diri)=tfirst(win(wins-1).diri)
								
								mktop wins-1
								screenlock
								put(0,0),bg,pset
								redraw
								text 0
								screenunlock
							elseif ucase(right(sdirf(f),4))=".BMP" then
								open sdir(win(0).diri)+sdirf(f) for binary as #1
									get #1,,s
									if s="BM" then

										get #1,19,fbx
										get #1,23,by
										
										makewin mx,my,fbx+2,by+27,"bmpload",4
										win(wins-1).diri=wins-1
										bmpf(wins-1)=sdir(win(0).diri)+sdirf(f)
									end if
								close
								mktop wins-1
								screenlock
								put(0,0),bg,pset
								redraw
								loadbmp 0
								screenunlock
								
							end if
						end if

					'rewrite later
					elseif mb=2 then
						qx1=(mx-win(0).x-5)\125
						qy1=(my-win(0).y-25)\15
						
						px1=((mx-win(0).x)\125)*125+win(0).x
						py1=((my-win(0).y-25)\15)*15+win(0).y+25
								
						do
							getmouse mx,my,,mb
							
							if mousebox(win(0).x,win(0).y+25,win(0).x+125*((win(0).x1-25)\125),win(0).y+30+15*((win(0).y1-30)\15)-5) then
								
								qx2=(mx-win(0).x-5)\125
								qy2=(my-win(0).y-25)\15
								
								px2=((mx-win(0).x)\125)*125+win(0).x
								py2=((my-win(0).y-25)\15)*15+win(0).y+25
								
								screenlock
								put(win(0).x,win(0).y),win(0).iptr,pset
								
								if px2>=px1 and py2>=py1 then
									line (px1,py1)-(px2+125,py2+15),15,b
								elseif px2>=px1 and py2<=py1 then
									line (px1,py1+15)-(px2+125,py2),15,b
								elseif px2<=px1 and py2>=py1 then
									line (px1+125,py1)-(px2,py2+15),15,b
								elseif px2<=px1 and py2<=py1 then
									line (px1+125,py1+15)-(px2,py2),15,b
								end if
								
								screenunlock
							end if
							
						loop while mb=2
						if qx1>qx2 then swap qx1,qx2
						if qy1>qy2 then swap qy1,qy2
						
						
						redim dirselect(0)
						for k=qy1 to qy2
							for i=qx1 to qx2
								f=i+k*((win(0).x1-25)\125)+sdirs(win(0).diri)
								if f<j then
									if sdirf(f)<>"..\" then
										l=ubound(dirselect)+1
										redim preserve dirselect(l)
										dirselect(l) = sdir(win(0).diri)+sdirf(f)
									end if
								end if
							next
						next
						
					end if
					
				end if
			loop
		end if
	case 3
		d=win(0).diri
		do while mousebox(win(0).x,win(0).y+25,win(0).x+win(0).x1,win(0).y+win(0).y1)
			getmouse mx,my,,mb
			
			if multikey(&h1f) and multikey(&h1d) then
				open tf(d) for output as #1
				list = tfirst(d)
				do 
					? #1, *list->s
					list = list->n
				loop until list = 0
				close
				locate 1,1
				? "SAVED"
			end if
			
			key=inkey
			if key<>"" then
				
				select case key
				case chr(255)+"P" 'down
					if tcy(d)+tsy(d) = tl(d)-1 then exit select
					tcx(d)=0
					if tcy(d)=(win(0).y1-55)\15-1 then 
						tsy(d)+=1
						text 0
					else
						line win(0).iptr,(5,30+tcy(d)*15)-step(win(0).x1-35,11),0,bf
						draw string win(0).iptr,(5,30+tcy(d)*15),left(*tc(d)->s,(win(0).x1-30)\8),15
						tcy(d)+=1
						line win(0).iptr,(5,30+tcy(d)*15)-step(5,11),15,b
						put (win(0).x,win(0).y),win(0).iptr,pset
					end if
					tc(d)=tc(d)->n
				case chr(255)+"H" 'up
					if tcy(d)+tsy(d) = 0 then exit select
					tcx(d)=0
					if tcy(d)=0 then
						tsy(d)-=1
						text 0
					else
						line win(0).iptr,(5,30+tcy(d)*15)-step(win(0).x1-35,11),0,bf
						draw string win(0).iptr,(5,30+tcy(d)*15),left(*tc(d)->s,(win(0).x1-30)\8),15
						tcy(d)-=1
						line win(0).iptr,(5,30+tcy(d)*15)-step(5,11),15,b
						put (win(0).x,win(0).y),win(0).iptr,pset
					end if
					tc(d)=tc(d)->p	
				case chr(255)+"M" 'right
					if tcx(d)=len(*tc(d)->s) then
						if tcy(d)+tsy(d) = tl(d)-1 then exit select
						if tcy(d)=(win(0).y1-55)\15-1 then
							tsy(d)+=1
							text 0
						else
							line win(0).iptr,(5,30+tcy(d)*15)-step(win(0).x1-35,11),0,bf
							draw string win(0).iptr,(5,30+tcy(d)*15),left(*tc(d)->s,(win(0).x1-30)\8),15
							tcy(d)+=1
							line win(0).iptr,(5,30+tcy(d)*15)-step(5,11),15,b
							put (win(0).x,win(0).y),win(0).iptr,pset
						end if
						tcx(d)=0
						tc(d)=tc(d)->n
						'text 0
					else
						tcx(d)+=1
						line win(0).iptr,(5,30+tcy(d)*15)-step(win(0).x1-35,11),0,bf
						draw string win(0).iptr,(5,30+tcy(d)*15),left(*tc(d)->s,(win(0).x1-30)\8),15
						line win(0).iptr,(5+tcx(d)*8,30+tcy(d)*15)-step(5,11),15,b
						put (win(0).x,win(0).y),win(0).iptr,pset
					end if
				case chr(255)+"K" 'left
					if tcx(d)=0 then
						if tcy(d)+tsy(d) = 0 then exit select
						if tcy(d)=0 then
							tsy(d)-=1
							text 0
						else
							line win(0).iptr,(5,30+tcy(d)*15)-step(win(0).x1-35,11),0,bf
							draw string win(0).iptr,(5,30+tcy(d)*15),left(*tc(d)->s,(win(0).x1-30)\8),15
							tcy(d)-=1
							tc(d)=tc(d)->p
							tcx(d)=len(*tc(d)->s)
							line win(0).iptr,(5+tcx(d)*8,30+tcy(d)*15)-step(5,11),15,b
							put (win(0).x,win(0).y),win(0).iptr,pset
						end if
						'text 0
					else
						tcx(d)-=1
						line win(0).iptr,(5,30+tcy(d)*15)-step(win(0).x1-35,11),0,bf
						draw string win(0).iptr,(5,30+tcy(d)*15),left(*tc(d)->s,(win(0).x1-30)\8),15
						line win(0).iptr,(5+tcx(d)*8,30+tcy(d)*15)-step(5,11),15,b
						put (win(0).x,win(0).y),win(0).iptr,pset
					end if
				case chr(13) 'enter	
					tl(d)+=1
					sl=len(*tc(d)->s)
					list = allocate(len(listtype))
					list->s = allocate(sl-tcx(d)+1)
					*list->s = right(*tc(d)->s,sl-tcx(d))
					*tc(d)->s = left(*tc(d)->s,tcx(d))
					tc(d)->s = reallocate(tc(d)->s,tcx(d)+1)
					list->p = tc(d)
					list->n = tc(d)->n
					if tcy(d)+tsy(d) = 0 then
						tc(d)->p = 0
						tc(d)->n = list
						tfirst(d) = tc(d)
					else
						prev = tc(d)->n
						tc(d)->n = list
						if prev<>0 then prev->p = list
					end if
					tc(d) = tc(d)->n
					if tcy(d)=(win(0).y1-55)\15-1 then tsy(d)+=1 else tcy(d)+=1
					tcx(d)=0
					text 0
				case chr(8) 'backspace
					if tcx(d)=0 then
						if tcy(d)+tsy(d) = 0 then exit select
						tl(d)-=1
						list=tc(d)
						tc(d)=tc(d)->p
						sl=len(*tc(d)->s)
						tc(d)->n=list->n
						tc(d)->s=reallocate(tc(d)->s,sl+len(*list->s)+1)
						*tc(d)->s += *list->s
						deallocate list->s
						prev=list->n
						prev->p=tc(d)
						deallocate list
						tcx(d)=sl
						if tcy(d)=0 then tsy(d)-=1 else tcy(d)-=1
						text 0
					else
						sl=len(*tc(d)->s)
						*tc(d)->s=left(*tc(d)->s,tcx(d)-1)+right(*tc(d)->s,sl-tcx(d))
						tc(d)->s = reallocate(tc(d)->s,sl)
						tcx(d)-=1
						line win(0).iptr,(5,30+tcy(d)*15)-step(win(0).x1-35,11),0,bf
						draw string win(0).iptr,(5,30+tcy(d)*15),left(*tc(d)->s,(win(0).x1-30)\8),15
						line win(0).iptr,(5+tcx(d)*8,30+tcy(d)*15)-step(5,11),15,b
						put (win(0).x,win(0).y),win(0).iptr,pset
					end if
				case chr(32) to chr(128)
					sl=len(*tc(d)->s)
					tc(d)->s = reallocate(tc(d)->s,sl+2)
					*tc(d)->s=left(*tc(d)->s,tcx(d))+key+mid(*tc(d)->s,tcx(d)+1,sl-tcx(d))
					tcx(d)+=1
					line win(0).iptr,(5,30+tcy(d)*15)-step(win(0).x1-35,11),0,bf
					draw string win(0).iptr,(5,30+tcy(d)*15),left(*tc(d)->s,(win(0).x1-30)\8),15
					line win(0).iptr,(5+tcx(d)*8,30+tcy(d)*15)-step(5,11),15,b
					put (win(0).x,win(0).y),win(0).iptr,pset
				end select
			end if
			
			
			if mousebox(win(0).x+win(0).x1-25,win(0).y+win(0).y1-25,win(0).x+win(0).x1,win(0).y+win(0).y1) then
				if mb=1 then
					
					screenlock
					put(0,0),bg,pset
					redraw
					get(0,0)-(screenw-1,screenh-1),temp1
					put(win(0).x,win(0).y),win(0).iptr,pset
					screenunlock
	
					oldx=win(0).x1-mx
					oldy=win(0).y1-my				
					do
						getmouse mx,my,,mb
						
						if mx+oldx>100 then win(0).x1=mx+oldx
						if my+oldy>100 then win(0).y1=my+oldy
						imagedestroy win(0).iptr
						win(0).iptr=imagecreate(win(0).x1+1,win(0).y1+1)
						screenlock		
						put(0,0),temp1,pset
						text 0
						'drawin win(0).x,win(0).y,win(0).x1,win(0).y1,"Test"
						screenunlock
							
					loop while mb=1
					
					if tcx(d)>=(win(0).x1-30)\8 or tcy(d)>=(win(0).y1-55)\15 then
						tsy(d)=0
						tsx(d)=0
						tc(d)=tfirst(d)
						tcx(d)=0
						tcy(d)=0
						text 0
					end if
					
				end if
			elseif mousebox(win(0).x+win(0).x1-25,win(0).y+25,win(0).x+win(0).x1,win(0).y+50) then 'scroll up
				if mb=1 then
					if tsy(d)>0 then
						ti=timer
						
						tsy(d)-=1
						tc(d)=tc(d)->p
						text 0
					
						do
						loop until timer-ti>0.04
					end if
				end if
							
			elseif mousebox(win(0).x+win(0).x1-25,win(0).y+win(0).y1-50,win(0).x+win(0).x1,win(0).y+win(0).y1-25) then 'scroll down
				if mb=1 then
					if (win(0).y1-55)\15+tsy(d)<tl(d) then
						ti=timer
						
						tsy(d)+=1
						tc(d)=tc(d)->n
						text 0
						
						do
						loop until timer-ti>0.04
					end if
				end if
				
			elseif mousebox(win(0).x,win(0).y+win(0).y1-25,win(0).x+25,win(0).y+win(0).y1) then 'scroll left
					
			elseif mousebox(win(0).x+win(0).x1-50,win(0).y+win(0).y1-25,win(0).x+win(0).x1-25,win(0).y+win(0).y1) then 'scroll right
				
			end if
		loop
		
	case 4
		do while mousebox(win(0).x,win(0).y+26,win(0).x+win(0).x1,win(0).y+win(0).y1)
			getmouse mx,my,,mb
			if mb=1 then
				screenlock
				put(0,0),bg,pset
				redraw
				get(0,0)-(screenw-1,screenh-1),temp1
				put(win(0).x,win(0).y),win(0).iptr,pset
				screenunlock
	
				oldx=win(0).x1-mx
				oldy=win(0).y1-my				
				do
					getmouse mx,my,,mb
					
					if mx+oldx>100 then win(0).x1=mx+oldx
					if my+oldy>100 then win(0).y1=my+oldy
					
					imagedestroy win(0).iptr
					win(0).iptr=imagecreate(win(0).x1+1,win(0).y1+1)
					
					screenlock		
					put(0,0),temp1,pset
					resize win(0).x1-2,win(0).y1-27,lbmp(win(0).diri).iptr
					drawin 0,0,win(0).x1,win(0).y1,bmpf(win(0).diri)+" "+str(win(0).x1-2)+"x"+str(win(0).y1-27),win(0).iptr
					put win(0).iptr,(1,26),lbmp(win(0).diri).iptr,pset
					put (win(0).x,win(0).y),win(0).iptr,pset
					screenunlock
				loop while mb=1
			elseif mb=2 then
				open bmpf(win(0).diri) for binary as #1
					get #1,,s
					if s="BM" then
						get #1,19,fbx
						get #1,23,by
						
						win(0).x1=fbx+2
						win(0).y1=by+27
						
						imagedestroy win(0).iptr
						win(0).iptr=imagecreate(win(0).x1+1,win(0).y1+1)
						
						screenlock
						put(0,0),bg,pset
						redraw
						loadbmp 0
						screenunlock
						
					end if
				close
				
			end if
		
		loop
	case 5
			
		do while mousebox(win(0).x,win(0).y+25,win(0).x+win(0).x1,win(0).y+win(0).y1)
			getmouse mx,my,,mb
			
			
			key=inkey
			if key<>"" then
				select case key
				case chr(13)
					dim as string exe,args
					runcomx(win(0).diri)=runcomx(win(0).diri)+chr(32)
					exe= mid(runcomx(win(0).diri),1,instr(runcomx(win(0).diri),chr(32)))
					args=right(runcomx(win(0).diri),len(runcomx(win(0).diri))-instr(runcomx(win(0).diri),chr(32)))
					x=exec(exe,args)
					res screenw,screenh
				case chr(8)
					if len(runcomx(win(0).diri))>=1 then
						runcomx(win(0).diri)=left(runcomx(win(0).diri),len(runcomx(win(0).diri))-1)
						runcom 0
					end if
				case chr(32) to chr(128)
					runcomx(win(0).diri)=runcomx(win(0).diri)+key
					runcom 0
				end select
			end if
		loop
	case 6
		'TERMINAL APP
		do while mousebox(win(0).x,win(0).y+25,win(0).x+win(0).x1,win(0).y+win(0).y1)
			getmouse mx,my,,mb
			
		loop
		
	case else
	end select
loop
do
loop while inkey<>""
end

sub printf(x, y, s as string, c as ubyte)
	dim sptr as ubyte ptr = sadd(s)
	dim vptr as ubyte ptr = screenptr
	'dim w as integer
	'screeninfo w

	o=y*screenw+x
	l=((len(s)) shl 3)-1
	j=0
	for y1=0 to 10
		i=0
		for x1=0 to l
			if font(11*(*(sptr+(x1 shr 3))-32)+y1) and (1 shl (7-(x1 and 7))) then *(vptr+o+j+i)=c
			i+=1
		next
		j+=screenw
	next
end sub

sub printf(x, y, s as string, c as ubyte, buffer as any ptr)
	dim sptr as ubyte ptr = sadd(s)
	dim vptr as ubyte ptr = buffer
	dim as any ptr pixdata
	Dim As Long w, h, bypp, pitch
	Dim As Long result
	if imageinfo(buffer,w,h,bypp,pitch,pixdata) then exit sub

	o=y*w+x
	l=((len(s)) shl 3)-1
	j=0
	for y1=0 to 10
		i=0
		for x1=0 to l
			if font(11*(*(sptr+(x1 shr 3))-32)+y1) and (1 shl (7-(x1 and 7))) then *(vptr+o+j+i)=c
			i+=1
		next
		j+=w
	next
end sub

function getfiles(path as string, f() as string)
	dim s as string = dir(path+"*.*", &h10)
	if s<>"." then 
		f(0)=s+"\"
		i=1
	else
		i=0
	end if
	
	for i=i to ubound(f)
		s=dir()
		if s="" then exit for
		f(i)=s+"\"
	next
	
	s = dir(path+"*.*", &h21)
	for i=i to ubound(f)
		if s="" then exit for
		f(i)=s
		s=dir()
	next
	
	getfiles = i
end function

function mousebox(x, y, x1, y1) 
	if mx>=x then if mx<=x1 then if my>=y then if my<=y1 then mousebox=-1
end function

sub makewin(x, y, x1, y1, cap as string, pid)
	win(wins).x=x
	win(wins).y=y
	win(wins).x1=x1
	win(wins).y1=y1
	win(wins).cap=cap
	win(wins).pid=pid
	win(wins).iptr=imagecreate(x1+1, y1+1)
	
	wins=wins+1
end sub

sub mktop(id)
	dim temp as wintype = win(id)
	for i=id-1 to 0 step -1
		win(i+1)=win(i)
	next
	win(0)=temp
end sub

sub closewin(id)
	if win(id).pid=3 then
		list = tfirst(win(id).diri)
		do 
			prev=list->n
			deallocate list->s
			deallocate list
			list=prev
		loop until prev=0
	end if
	
	imagedestroy win(id).iptr
	for i=id to wins
		win(i)=win(i+1)
	next
	
	wins=wins-1
end sub

sub drawin(x, y, x1, y1, cap as string)
	line(x,y)-step(x1,y1),0,bf
	line(x,y)-step(x1,y1),15,b
	line(x,y)-step(x1,25),15,b
	
	if (len(cap)*8)>(x1-10) then printf x+5,y+8,left(cap, (x1-10) shr 3),15 else printf x+5,y+8,cap,15
end sub

sub drawin (x, y, x1, y1, cap as string, buffer as any ptr)
	line buffer,(x,y)-step(x1,y1),0,bf
	line buffer,(x,y)-step(x1,y1),15,b
	line buffer,(x,y)-step(x1,25),15,b
	
	if (len(cap)*8)>(x1-10) then printf x+5,x+8,left(cap, (x1-10) shr 3),15,buffer else printf x+5,y+8,cap,15,buffer
end sub

sub redraw()
	for i=wins-1 to 1 step -1
		'drawin win(i).x,win(i).y,win(i).x1,win(i).y1,win(i).cap
		put(win(i).x,win(i).y),win(i).iptr,pset
	next
end sub

sub clock(id)
	drawin 0,0,win(id).x1,win(id).y1,time,win(id).iptr
	
	dim pi as single =3.1415926*2
	circle win(id).iptr,(75,100),70,15
	
	dim i as single
	j=0
	for i=0 to pi step pi/60
		if j mod 5 = 0 then r=58 else r=62
		j=j+1
		line win(id).iptr,(65*cos(i)+75,65*sin(i)+100)-(r*cos(i)+75,r*sin(i)+100),15
	next
	
	sec=val(right(time,2))
	min=val(mid(time,4,2))
	hou=val(left(time,2))
	line win(id).iptr,(75,100)-(70*cos(sec*pi/60-pi/4)+75,70*sin(sec*pi/60-pi/4)+100),15,,&h5555
	line win(id).iptr,(75,100)-(64*cos(min*pi/60-pi/4)+75,64*sin(min*pi/60-pi/4)+100),15
	hou=5*hou+(5*min)/60
	line win(id).iptr,(75,100)-(20*cos(hou*pi/60-pi/4)+75,20*sin(hou*pi/60-pi/4)+100),15
	put(win(id).x,win(id).y),win(id).iptr,pset
end sub

sub smalldir(id)
	drawin 0,0,win(id).x1,win(id).y1,sdir(win(id).diri),win(id).iptr
	
	line win(0).iptr,(win(0).x1,25)-step(-25,25),15,b
	line win(0).iptr,-(win(0).x1,win(0).y1-50),15,b
	line win(0).iptr,-step(-25,25),15,b
	line win(0).iptr,-step(25,25),15,b
	
	j=getfiles(sdir(win(id).diri),sdirf())

	for i=0 to (win(0).y1-30)\15-1
		for k=0 to (win(0).x1-25)\125-1
			if i*((win(0).x1-25)\125)+k+sdirs(win(0).diri)>=j then exit for
			printf 5+k*125, 30+i*15, sdirf(i*((win(0).x1-25)\125)+k+sdirs(win(0).diri)), 15, win(0).iptr
		next
	next
	
	put(win(id).x,win(id).y),win(id).iptr,pset
end sub

sub text(id)
	drawin 0,0,win(id).x1,win(id).y1,tf(win(id).diri)+" ("+str(tl(win(id).diri))+" lines)",win(id).iptr
	
	line win(id).iptr,(win(id).x1-25,25)-step(25,25),15,b
	line win(id).iptr,-step(-25,win(id).y1-100),15,b
	line win(id).iptr,-step(25,25),15,b
	line win(id).iptr,-step(-25,25),15,b
	line win(id).iptr,-step(-25,-25),15,b
	line win(id).iptr,-(25,win(id).y1-25),15,b
	line win(id).iptr,-step(-25,25),15,b

	list = tfirst(win(id).diri)
	for i=1 to tsy(win(id).diri)
		if list=0 then exit for
		list=list->n
	next
	for i=0 to (win(id).y1-55)\15-1
		if list=0 then exit for
		draw string win(id).iptr, (5, 30+i*15), left(*list->s,(win(id).x1-30)\8), 15
		'printf 5, 30+i*15,left(*list->s,(win(id).x1-30)\8),15,win(id).iptr
		list=list->n
	next
	
	line win(id).iptr,(5+tcx(win(id).diri)*8,30+tcy(win(id).diri)*15)-step(5,11),15,b

	put(win(id).x,win(id).y),win(id).iptr,pset
end sub

sub loadbmp(id)
	w=win(id).x1-2
	h=win(id).y1-27

	lbmp(win(id).diri).iptr=imagecreate(w,h)
	bload bmpf(win(id).diri),lbmp(win(id).diri).iptr
	palette  0, &h000000
	palette 15, &hffffff
	
	drawin 0,0,win(id).x1,win(id).y1,bmpf(win(id).diri)+" "+str(w)+"x"+str(h),win(id).iptr
	put win(id).iptr,(1,26),lbmp(win(id).diri).iptr,pset
	put(win(id).x,win(id).y),win(id).iptr,pset

end sub

sub res (x, y)
	screenres x, y, 8
	screeninfo screenw,screenh
	imagedestroy temp1
	temp1 = imagecreate(screenw,screenh)
	imagedestroy bg
	bg = imagecreate(screenw,screenh,0)

	if not bgoff then
		open "bg.bmp" for binary as #1
			get #1,,s
			if s="BM" then
				get #1,19,fbx
				get #1,23,by
				temp4=imagecreate(fbx,by)
				bload "bg.bmp",temp4
				if bgstretch then
					resize screenw,screenh,temp4
					imagedestroy bg
					bg = temp4
				else
					put bg,((screenw-fbx)\2,(screenh-by)\2),temp4
					imagedestroy temp4
				end if
			end if
		close
	end if

	palette  0, &h000000
	palette 15, &hffffff
	put(0,0),bg
	redraw
	put(win(0).x,win(0).y),win(0).iptr,pset
end sub

sub resize (x, y, buffer as any ptr)
	dim as integer w,h,k,l
	dim as single p,q
	dim as ubyte ptr addr1,addr2
	
	temp2=imagecreate(x,y)
	if imageinfo(temp2,,,,,addr2) then exit sub
	if imageinfo(buffer,w,h,,,addr1) then exit sub
	
	p=w/x
	q=h/y
	k=0
	for j=0 to y-1
		k=w*cint(j*q)
		for i=0 to x-1
			*(addr2+l+i)=*(addr1+k+cint(i*p))
		next
		l=l+x
	next
	
	imagedestroy buffer
	buffer=temp2
end sub

sub runcom (id)
	drawin 0,0,win(id).x1,win(id).y1,win(id).cap,win(id).iptr
	
	if len(runcomx(win(id).diri))>23 then
		printf 5,35,right(runcomx(win(id).diri),23),15,win(id).iptr
		line win(id).iptr,(5+23*8,30)-step(5,15),15,b

	else
		printf 5,35,runcomx(win(id).diri),15,win(id).iptr
		line win(id).iptr,(5+len(runcomx(win(id).diri))*8,30)-step(5,15),15,b

	end if
	put (win(id).x,win(id).y),win(id).iptr,pset
end sub

sub terminal (id)
	drawin 0,0,win(id).x1,win(id).y1,win(id).cap,win(id).iptr
	
	if len(runcomx(win(id).diri))>23 then
		printf 5,35,right(runcomx(win(id).diri),23),15,win(id).iptr
		line win(id).iptr,(5+23*8,30)-step(5,15),15,b

	else
		printf 5,35,runcomx(win(id).diri),15,win(id).iptr
		line win(id).iptr,(5+len(runcomx(win(id).diri))*8,30)-step(5,15),15,b

	end if
	put (win(id).x,win(id).y),win(id).iptr,pset
end sub

'' QB-ish graphics test
sub createsprite( sprite() as byte, byval w as integer, byval h as integer, byval bpp as integer = 1 )
	redim sprite(0 to w*h*bpp-1 + 2*len(short)) as byte

	cls

	for y as integer = 0 to h-1
		for x as integer = 0 to w-1
			pset (x, y), (x xor y) * 4
		next
	next

	line (0,0)-(w-1, h-1), 0, B

	get (0, 0)-(w-1,h-1), sprite(0)

	cls
end sub

function readIniValue (iniFile as string, searchSection as string, searchKey as string) as string
    dim fileNum as integer = freefile, iniLine as string, newSection as string
    dim strSep as integer, strLeft as string, strRight as string
    open iniFile for input as #fileNum
    
    do
        line input #fileNum, iniLine
        if left(iniLine,1) = "[" and right(iniLine,1) = "]" then
            newSection = mid(iniLine, 2, len(iniLine)-2)
        elseif instr(iniLine, "=") > 0 then
            strSep = instr(iniLine, "=")
            strLeft = trim(left(iniLine,strSep-1))
            strRight = trim(right(iniLine, len(iniLine)-strSep))
            if (newSection = searchSection) and (strLeft = searchKey) then
                return strRight
            end if
        end if
    loop until eof(fileNum)
    close #filenum
end function

