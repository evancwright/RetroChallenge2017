;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;FloodIt.asm
;Evan C. Wright, 1/2018
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

CPM EQU 1
HEIGHT EQU 20
WIDTH EQU 20
NUM_SYMBOLS EQU 6



	ifdef CPM
	ORG 100H  ; CP/M
	else
	ORG 5200H ; TRS-80
	endif
	
START
	
*MOD
main
	call print_title
	
	ld hl,helpprmpt
	call printstrcr
	call get_char
	cp 'y'
	jp z,$h?
	cp 'Y'
	jp z,$h?
	jp $g?
$h?
	call print_help
$g?	
	call create_board
$lp?	
	call print_board
	call print_turns

$gc?
	call get_char
	ld (newSym),a
	cp 'a'
	jp z,$f?
	cp 'A'
	jp z,$f?
	cp 'b'
	jp z,$f?
	cp 'c'
	jp z,$f?
	cp 'd'
	jp z,$f?
	cp 'e'
	jp z,$f?
	cp 'f'
	jp z,$f?
	cp 'q'
	jp z,$x?
	jp $gc?
$f?
	call start_fill
	jp $lp?
$x?	
	ifdef CPM
	jp 0
	else
	ret
	endif


*MOD 
start_fill
	call clear_flags
	
	ld a,(board)
	ld (oldSym),a
	
	ld de,0 ; (x=0,y=0)
	call push_square
	call fill
	
	;turns++
	ld a,(turns)
	inc a
	ld (turns),a
	
	call print_turns
	ret	

*MOD
fill
$lp?

	call print_board

	;pop the 1st thing in the queue
	; ld de,(queue) ; z80 only
	ld hl,(queue)
	ex de,hl
;	call debug_pop
	
 	;shift everything down 2 bytes
	call shift_queue

	;fill it (de)
	call fill_square
	
	;ret	
	;enqueue its neighbors
	push de
	ld a,d
	dec a
	ld d,a
	call push_square  ;(x-1,y)
	pop de
	
	push de
	ld a,d
	inc a
	ld d,a
	call push_square ;(x+1,y)
	pop de

	push de
	ld a,e
	inc a
	ld e,a
	call push_square ; (x,y+1)
	pop de

	push de
	ld a,e
	dec a
	ld e,a
	call push_square ;(x,y-1)
	pop de
	
	;call get_char
	
	;is the queue empty?
	;do 16 bit compare using add 0 to set zero flg
	ld a,(queueIndex)
	cp 0
	jp nz,$lp?
	ld a,(queueIndex+1)
	cp 0
	jp nz,$lp?
	;queue is now empty
	ret

	
;fills the square with 'newSym' 
;d = x
;e = y
*MOD
fill_square
	push de
	call get_square_ptr
	ld a,(newSym)
	ld hl,(squarePtr)
	ld (hl),a

	;mark it as filled	
	ld hl,(flagPtr)
	;store a 1
	ld a,1		
	ld (hl),a
	
	pop de
	ret

;d contains x 
;e contains y
;return symbol in a
*MOD
get_square_color
	push de
	push hl
	call get_square_ptr	
	ld a,(squarePtr+1)	; load ptr
	ld d,a
	ld a,(squarePtr)
	ld e,a
	ex de,hl
	ld a,(hl) ;	dereference it
	pop hl
	pop de
	ret
	
	
;if rect is out of bounds, it is not pushed
;d contains x 
;e contains y
*MOD
push_square
	push bc
	push de
	push hl
	
;	call debug_push

	ld a,d	; x==-1?
	cp 255  
	jp z,$oob?
	cp WIDTH  ; x==right edge?
	jp z,$oob?
	ld a,e
	cp 255  ;y==-1?
	jp z,$oob?
	cp HEIGHT  ; bottom edge
	jp z,$oob?
	;does the color of the square match the old color?
	call get_square_color ; symbol in 'a'
	;does it match the old color?
	ld b,a ;new symbol in b
;	push bc 
;	push de
;	ld e,a
;	ld hl,symbolis
;	call printstr
;	ld e,a
;	call print_char
;	call newline
;	pop de
;	pop bc

	ld a,(oldSym)	
	cp b
	jp nz,$nm? ; no don't enqueue it
	
	;has it already been filled?
	ld hl,(flagPtr)
	ld a,(hl)
	cp 1
	jp z,$alf?
	
	;mark it as examined
	ld a,1
	ld (hl),a
	
	;put de in the end of the queue
;	ld hl,pushed
;	call printstrcr

	push de ; save data
	ld hl,(queueIndex)
	ld de,queue
	add hl,de ; add base offset
	pop de ;restore data

	
	ld (hl),e
	inc hl
	ld (hl),d
	
	;add 2 bytes to the queue ptr
	ld hl,(queueIndex)
 	inc hl
	inc hl
	ld (queueIndex),hl
	jp $x?
$nm?
;	ld hl,nomatch
;	call printstrcr
	jp $x?		
$oob?
;	ld hl,oob
;	call printstrcr
	jp $x?;	
$alf?
;	ld hl,alf
;	call printstrcr
	jp $x?;		
$x?	pop hl
	pop de
	pop bc
	ret
	
*MOD 
shift_queue
	push bc
	push de
	push hl
	
	;get times to loop
	ld hl,(queueIndex)
	push hl   ;hl->bc
	pop bc
	
	ld de,queue
	ld hl,queue+2
	;ldir  ; not supported by 8080
$lp?
	ld a,(hl)
	ld (de),a
	inc hl
	inc de
	dec bc
	ld a,b
	cp 0
	jp nz,$lp?
	ld a,c
	cp 0
	jp nz,$lp?
	
	;decrement queue ptr (twice)
	; ld de,(queueEnd)
	ld hl,(queueIndex)
	dec hl
	dec hl
	ld (queueIndex),hl
	
	pop hl
	pop de
	pop bc
	ret

;d = x
;e = y
;set squarePtr
;sets flagPtr
*MOD
get_square_ptr	
	push bc
	push de
	push hl
	
	
	ld b,e  ; loop counter (y)
	ld a,d ; accumulator (starts with x in it)
	ld e,a ;(d->e)
	ld d,0 ; zero out d
	ld a,b ;do we have to loop
	cp 0
	jp z,$o?
$lp?
	ld hl,WIDTH
	add hl,de
	ex de,hl ; total back in de
	dec b
	jp nz,$lp?
$o?	
  	
 	ld hl,board
	add hl,de ; add the initial offset
	ld (squarePtr),hl
	
	;the flagptr will be 1 board width forward
	ld de,WIDTH*HEIGHT
	add hl,de
	ld (flagPtr),hl
	
	pop hl
	pop de
	pop bc
	ret
	
;generates a random board
*MOD
create_board
	;turns=0
	ld a,0
	ld (turns),a

	ld de,board
	ld bc,WIDTH*HEIGHT

$lp?		
	push bc

	ld b,6
	call rmod ; result in a
	 
	push de ; save addr
	ld hl,symbols
	
	ld d,0
	ld e,a
	add hl,de
	 
	ld a,(hl)
	pop de ; restore addr
	ld (de),a	
	
	inc de
	
	pop bc
	dec bc
	ld a,b
	cp 0
	jp nz,$lp?
	ld a,c
	cp 0
	jp nz,$lp?
	
	ret

	
*MOD
clear_flags
	ld bc,WIDTH*HEIGHT
	ld de,filledFlgs
	
$lp?
	ld a,0 
	ld (de),a
	inc de
	dec bc
	
	ld a,b
	cp 0
	jp nz,$lp?
	ld a,c
	cp 0
	jp nz,$lp?

	ret

*MOD
print_help
	ld hl,helpxt1
	call printstrcr
	ld hl,helpxt2
	call printstrcr
	ld hl,helpxt3
	call printstrcr
	ld hl,helpxt4
	call printstrcr
	ld hl,helpxt5
	call printstrcr
	call get_char
	ret

*MOD
print_turns
	ld a,(turns)
	call itoa8
	ld hl,outof
	call printstrcr
	ret
	
*MOD	
print_title
	
	ld hl,cpmhome
	call printstr
	ld hl,cpmcls
	call printstr

	ld hl,title1
	ld b,6
	ld de,70
$lp?
	call printstrcr
	add hl,de
	dec b
	jp nz,$lp?
	
	call newline
	ld hl,title7
	call printstrcr
	
	ret

;set (wonFlg)
*MOD
player_wins
	
	ld a,1
	ld (wonFlg),a
	
	ld bc,WIDTH*HEIGHT
	ld hl,board
	ld a,(hl)
	ld d,a
$lp?
	ld a,(hl)
	cp d  
	jp nz,$n?
	
	inc hl
	dec bc
	ld a,b
	cp 0
	jp nz,$lp?
	ld a,c
	cp 0
	jp nz,$lp?
	jp $x?
$n? ;not won
	ld a,0
	ld (wonFlg),a
$x?	ret
	
*MOD
debug_push
	push de
	push hl
	ld hl,pushing
	call printstr
	ld a,d
	call itoa8
	push de
	ld e,','
	call print_char
	pop de
	ld a,e
	call itoa8	
	call newline
	pop hl
	pop de
	ret
*MOD
debug_pop
	push de
	push hl
	ld hl,popping
	call printstr
	ld a,d
	call itoa8
	push de
	ld e,','
	call print_char
	pop de
	ld a,e
	call itoa8	
	call newline
	pop hl
	pop de
	ret	
*MOD
print_board
	push bc
	push hl
	
	ld hl,cpmhome
	call printstr
	
	ld hl,cpmcls
	call printstr

	
	ld hl,board
	ld b,HEIGHT
$ol?
	push bc

	ld b,WIDTH
$il?	
	push bc
	ld a,(hl)
	ld e,a
	call print_char
	inc hl
	pop bc
	dec b
	jp nz,$il?
	
	call newline
	
	pop bc
	dec b
	jp nz,$ol?
	
	call newline
	pop hl
	pop bc
	ret

	ifdef CPM
*INCLUDE cpm.asm
	else
*INCLUDE trs80.asm
	endif

	
*INCLUDE math.asm	
	
squarePtr DW 0	
flagPtr DW 0
oldSym DB 0
newSym DB 0
turns DB 0
board
	DS WIDTH*HEIGHT
filledFlgs
	DS WIDTH*HEIGHT
boardEnd
queue
	DS WIDTH*HEIGHT*2
queueIndex DW 0
wonFlg DB 0
symbols
	DB 'abcdef',0	
outof DB '/30',0h
oob 
	DB 'out of bounds.',0h	
alf 
	DB 'already filled.',0h
nomatch 
	DB 'does not match.',0h	
pushed DB 'pushed ',0h
pushing DB 'pushing ',0h
popping DB 'popping ',0h
symbolis DB 'symbol is ',0h	

title1 DB ' ______   __     ______   ______   _____      _______   _______   __ ',0h
title2 DB '|  ____| |  |   |  __  | |  __  | |  ___ \   |__   __| |__   __| |  |',0h
title3 DB '| |___   |  |   | |  | | | |  | | | |   | |     | |       | |    |  |',0h
title4 DB '|  ___|  |  |   | |  | | | |  | | | |   | |     | |       | |    |__|',0h
title5 DB '| |      |  |_  | |__| | | |__| | | |___| |   __| |__     | |     __ ',0h
title6 DB '|_|      |____| |______| |______| |_____ /   |_______|    |_|    [__]',0h
 db 0
title7 DB 'CP/M version by Evan Wright,2018',0h
helpprmpt
	DB 'Would you like instructions? (y/n)',0h
	db 0

helpxt1 DB 'The goal of the game is to make the board all the same symbol.',0h	
helpxt2 DB 'This is done by bucket-filing the top,left symbol.',0h
helpxt3 DB 'To start a fill, press the key for the symbol to fill with (a-f).',0h
helpxt4 DB 'The game ends when the board is all one symbol or you turns are used up.',0h
helpxt5 DB 'Press any key to continue...',0,0h
	END START