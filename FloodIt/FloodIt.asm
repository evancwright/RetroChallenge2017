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
	call create_board
$lp?	
	call print_board
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
	ret	

*MOD
fill
$lp?

	;pop the 1st thing in the queue
	; ld de,(queue) ; z80 only
	ld hl,(queue)
	ex de,hl
	call debug_pop
	
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
	
	call debug_push

	ld a,d
	cp 255  ; -1
	jp z,$oob?
	cp WIDTH  ; right edge
	jp z,$oob?
	ld a,e
	cp 255  ; -1
	jp z,$oob?
	cp HEIGHT  ; bottom edge
	jp z,$oob?
	;does the color of the square match the old color?
	call get_square_color ; symbol in 'a'
	;does it match the old color?
	ld b,a
	ld a,(oldSym)
	cp b
	jp nz,$nm? ; no don't enqueue it
	
	;has it already been filled?
	ld hl,(flagPtr)
	ld a,(hl)
	cp 1
	jp z,$alf?
	
	;put de in the end of the queue
	push de ; save data
	ld hl,(queueIndex)
	ld de,queue
	add hl,de ; add base offset
	pop de ;restore data

	ld hl,pushed
	call printstrcr
	
	ld (hl),d
	inc hl
	ld (hl),e
	
	;add 2 bytes to the queue ptr
	ld hl,(queueIndex)
 	inc hl
	inc hl
	ld (queueIndex),hl
	jp $x?
$nm?
	ld hl,nomatch
	call printstrcr
	jp $x?		
$oob?
	ld hl,oob
	call printstrcr
	jp $x?;	
$alf?
	ld hl,alf
	call printstrcr
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
	;call flip_h
	 
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
turn DB 0
board
	DS WIDTH*HEIGHT
filledFlgs
	DS WIDTH*HEIGHT
boardEnd
queue
	DS WIDTH*HEIGHT*2
queueIndex DW 0

symbols
	DB 'abcdef',0	
oob 
	DB 'out of bounds.',0h	
alf 
	DB 'already filled.',0h
nomatch 
	DB 'does not match.',0h	
pushed DB "pushed ",0h
pushing DB "pushing ",0h
popping DB "popping ",0h
	
	END START