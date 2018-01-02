;trs80teeth.asm

LAST_CHAR EQU 4000h
LAST_CHAR_LO EQU 0h
LAST_CHAR_HI EQU 40h
VRAM_HI EQU 03Ch
VRAM_LO EQU 0h
*MOD
animate_teeth
	call cls
	
;5 times - shift top down, feed in a top line
;		 - shift bottom up, feed in a bottom line

	ld hl,VRAM+63 ; last row
	ld (topcopy),hl
	
    ld hl,VRAM+960 ; last row
	ld (bottomcopy),hl
	
	ld a,0
$lp?
	push af
	
	ld hl,(topcopy)
	call copy_top
	ld de,64	;add 64 to copy start
	add hl,de 
	ld (topcopy),hl
	
 
	ld hl,(bottomcopy)
	call copy_bottom
	ld de,64
	or	a 	; clear carry
	sbc hl,de ; subtract 64 from bottom copy
 	ld (bottomcopy),hl
	
	ld bc,8000
	call delay
	pop af
	inc a
	cp 6
	jp nz,$lp?

;lower top teeth two more times	
	ld a,0
$lp2?
	push af
	
	ld hl,(topcopy)
	call copy_top
	ld de,64	;add 64 to copy start
	add hl,de 
	ld (topcopy),hl
		
	ld bc,8000
	call delay
	pop af
	inc a
	cp 4
	jp nz,$lp2?

	ld bc,65535
	call delay
	
	call draw_eyes
	
	ld bc,65535
	call delay
	
	call cls
	ret
	
	
;hl is copy dest to start from 
;(starts as rightmost char of row 1)
;copying stops when start of VRAM is hit
;no registers affected	
*MOD
copy_top
	push af
	push de
	push hl
	ld de,top_teeth_end
$lp?	
	ld a,(de)
	ld (hl),a
	dec de
	dec hl
	ld a,h
	cp VRAM_HI
	jp nz,$lp?
	ld a,l
	cp VRAM_LO
	jp nz,$lp?
	pop hl
	pop de
	pop af

	ret
	

;hl is the destination
;copying stops when bottom right
;corner of screen is reached	
;no registers affected
*MOD
copy_bottom
	push af
	push de
	push hl
	ld de,bottom_teeth_data
$lp?	
	ld a,(de)
	ld (hl),a
	inc de
	inc hl
	ld a,h
	cp LAST_CHAR_HI
	jp nz,$lp?
	ld a,l
	cp LAST_CHAR_LO
	jp nz,$lp?
	pop hl
	pop de
	pop af
	ret

draw_eyes
	ld hl,VRAM+82
	call draw_eye
	ld hl,VRAM+102
	call draw_eye
	ret
	
;hl contains top left byte to draw the eye
draw_eye
 
	ld de,eye_data
	ld b,3

$ol?
	push bc
	
	ld b,5
$il?
	ld a,(de)
	ld (hl),a
	inc de
	inc hl
	djnz $il?
	
	;add 61 to hl
	push de
	ld de,59
	add hl,de
	pop de
 	
	pop bc ; restore outer lp counter
	djnz $ol?
 
	ret
	
	


	
topcopy DW  0h
bottomcopy dw 0h	