;trs-80 screen data
VRAM EQU 3C00h
DRAWOFFSET EQU VRAM+354d; (VRAM + 5*64 + 33)
STRIPE_HGHT EQU 11
STRIPE_WDTH EQU 8
CURLOC EQU 4020h


;copies the gallows to the screen
*MOD
draw_background
	ld b,16  ;16 rows
	ld hl,platform
	ld de,VRAM+32
	
$lp?
	push bc
	
	ld bc,32 ; 32 cols to copy
	ldir 
	
	;add 32 to de (dest)
	push hl
	ex de,hl ;save de -> hl
	ld de,32d ;offset
	add hl,de
	ex de,hl ;new dest to de	
	pop hl
	 	
	pop bc
	djnz $lp?
	ret

draw_win
	call draw_background
	call erase_rope
	ld hl,win
	call copy_data
	ret
 
*MOD
draw_game
	call draw_background
	ld a,(badGuessIndex)
	cp 0
	jp z,$x?
$1?	cp 1
	jp nz,$2?
	ld hl,head
	call copy_data
	jp $x?
$2? cp 2
	jp nz,$3?
	ld hl,body
	call copy_data
	jp $x?
$3? cp 3
	jp nz,$4?
	ld hl,onearm
	call copy_data
	jp $x?	
$4? cp 4
	jp nz,$5?
	ld hl,twoarms
	call copy_data
	jp $x?		
$5? cp 5
	jp nz,$6?
	ld hl,oneleg
	call copy_data
	jp $x?		
$6? cp 6
	jp nz,$7?
	ld hl,twolegs
	call copy_data
	jp $x?			
$7? ;dead
	ld hl,dead
	call copy_data
$x?	ret

;copies an 8x11 strip onto the screen
;where the 'guy' is
;hl contains the addr of the data to copy
*MOD		
copy_data
	ld de,DRAWOFFSET
	ld b,STRIPE_HGHT
$lp?
	push bc
	
	ld bc,STRIPE_WDTH
	ldir
	
	;move down to next row
	push hl 
	ex de,hl ; save dest to  hl
	ld de,56d ; de contains offset
	add hl,de ; add offset to dest`
	ex de,hl ; dest back to de
	pop hl
	
	pop bc
	djnz $lp?

	ret
	
*MOD
erase_rope
	ld de,VRAM+166
	ld a,20h ; space
	ld (de),a
	ld b,2
$lp?
	ex de,hl	; save de -> hl
	ld de,64
	add hl,de
	ex de,hl
	ld (de),a	; overwrite rope with a space
	djnz $lp?
	ret
	
;right half of screen
platform
	DB 20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h
	DB 20h,20h,20h,20h,20h,255,255,255,255,255,255,255,255,255,255,255,255,255,255,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h
	DB 20h,20h,20h,20h,20h,20h,255,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,255,255,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h
	DB 20h,20h,20h,20h,20h,20h,255,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,255,255,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h
	DB 20h,20h,20h,20h,20h,20h,255,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,255,255,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h
	DB 20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,255,255,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h
	DB 20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,255,255,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h
	DB 20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,255,255,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h
	DB 20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,255,255,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h
	DB 20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,255,255,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h
	DB 20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,255,255,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h
	DB 20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,255,255,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h
	DB 20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,255,255,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h
	DB 20h,20h,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h
	DB 20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,255,255,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h
	DB 255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h
		
head
	DB 20h,20h,20h,255,255,255,20h,20h
	DB 20h,20h,20h,20h,20h,20h,20h,20h
	DB 20h,20h,20h,20h,20h,20h,20h,20h
	DB 20h,20h,20h,20h,20h,20h,20h,20h
	DB 20h,20h,20h,20h,20h,20h,20h,20h
	DB 20h,20h,20h,20h,20h,20h,20h,20h
	DB 20h,20h,20h,20h,20h,20h,20h,20h
	DB 20h,20h,20h,20h,20h,20h,20h,20h
	DB 20h,255,255,255,255,255,255,255
	DB 20h,20h,20h,20h,20h,20h,20h,20h
	DB 255,255,255,255,255,255,255,255
body
	DB 20h,20h,20h,255,255,255,20h,20h
	DB 20h,20h,20h,20h,20h,20h,20h,20h
	DB 20h,20h,20h,255,255,255,20h,20h
	DB 20h,20h,20h,255,255,255,20h,20h
	DB 20h,20h,20h,255,255,255,20h,20h
	DB 20h,20h,20h,20h,20h,20h,20h,20h
	DB 20h,20h,20h,20h,20h,20h,20h,20h
	DB 20h,20h,20h,20h,20h,20h,20h,20h
	DB 20h,255,255,255,255,255,255,255
	DB 20h,20h,20h,20h,20h,20h,20h,20h
	DB 255,255,255,255,255,255,255,255
onearm
	DB 20h,20h,20h,255,255,255,20h,20h
	DB 20h,20h,20h,20h,20h,20h,20h,20h
	DB 20h,20h,255,255,255,255,20h,20h
	DB 20h,255,20h,255,255,255,20h,20h
	DB 20h,255,20h,255,255,255,20h,20h
	DB 20h,20h,20h,20h,20h,20h,20h,20h
	DB 20h,20h,20h,20h,20h,20h,20h,20h
	DB 20h,20h,20h,20h,20h,20h,20h,20h
	DB 20h,255,255,255,255,255,255,255
	DB 20h,20h,20h,20h,20h,20h,20h,20h
	DB 255,255,255,255,255,255,255,255
twoarms
	DB 20h,20h,20h,255,255,255,20h,20h
	DB 20h,20h,20h,20h,20h,20h,20h,20h
	DB 20h,20h,255,255,255,255,255,20h
	DB 20h,255,20h,255,255,255,20h,255
	DB 20h,255,20h,255,255,255,20h,255
	DB 20h,20h,20h,20h,20h,20h,20h,20h
	DB 20h,20h,20h,20h,20h,20h,20h,20h
	DB 20h,20h,20h,20h,20h,20h,20h,20h
	DB 20h,255,255,255,255,255,255,255
	DB 20h,20h,20h,20h,20h,20h,20h,20h
	DB 255,255,255,255,255,255,255,255
oneleg
	DB 20h,20h,20h,255,255,255,20h,20h
	DB 20h,20h,20h,20h,20h,20h,20h,20h
	DB 20h,20h,255,255,255,255,255,20h
	DB 20h,255,20h,255,255,255,20h,255
	DB 20h,255,20h,255,255,255,20h,255
	DB 20h,20h,20h,255,20h,20h,20h,20h
	DB 20h,20h,20h,255,20h,20h,20h,20h
	DB 20h,20h,20h,255,20h,20h,20h,20h
	DB 20h,255,255,255,255,255,255,255
	DB 20h,20h,20h,20h,20h,20h,20h,20h
	DB 255,255,255,255,255,255,255,255
twolegs
	DB 20h,20h,20h,255,255,255,20h,20h
	DB 20h,20h,20h,20h,20h,20h,20h,20h
	DB 20h,20h,255,255,255,255,255,20h
	DB 20h,255,20h,255,255,255,20h,255
	DB 20h,255,20h,255,255,255,20h,255
	DB 20h,20h,20h,255,20h,255,20h,20h
	DB 20h,20h,20h,255,20h,255,20h,20h
	DB 20h,20h,20h,255,20h,255,20h,20h
	DB 20h,255,255,255,255,255,255,255
	DB 20h,20h,20h,20h,20h,20h,20h,20h
	DB 255,255,255,255,255,255,255,255
dead
	DB 20h,20h,20h,20h,255,20h,20h,20h
	DB 20h,20h,20h,20h,255,20h,20h,20h
	DB 20h,20h,20h,255,255,255,20h,20h
	DB 20h,20h,20h,20h,20h,20h,20h,20h
	DB 20h,20h,255,255,255,255,255,20h
	DB 20h,255,20h,255,255,255,20h,255
	DB 20h,255,20h,255,255,255,20h,255
	DB 20h,20h,20h,255,20h,255,20h,20h
	DB 20h,20h,20h,255,20h,255,20h,20h
	DB 20h,20h,20h,255,20h,255,20h,20h
	DB 255,255,255,255,255,255,255,255
win
	DB 20h,0ffh,20h,0ffh,0ffh,0ffh,20h,0ffh
	DB 20h,0ffh,20h,20h,20h,20h,20h,0ffh
	DB 20h,20h,0ffh,0ffh,0ffh,0ffh,0ffh,20h
	DB 20h,20h,20h,0ffh,0ffh,0ffh,20h,20h
	DB 20h,20h,20h,0ffh,0ffh,0ffh,20h,20h
	DB 20h,20h,20h,0ffh,20h,0ffh,20h,20h
	DB 20h,20h,20h,0ffh,20h,0ffh,20h,20h
	DB 20h,20h,20h,0ffh,20h,0ffh,20h,20h
	DB 20h,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh
	DB 20h,20h,20h,20h,20h,20h,20h,20h
	DB 0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh


