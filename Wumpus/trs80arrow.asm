;trs80arrow.asm

ARROW_START equ VRAM+512
*MOD
animate_arrow
;draw the sideways tunnel
	ld hl,VRAM
	ld a,0ffh
	
	;6x64 blocks	
	ld bc,384
	ld hl,VRAM

$lp?
	ld a,0ffh
	ld (hl),a
	inc hl
	dec bc
	ld a,b
	cp 0
	jp nz,$lp?
	ld a,c
	cp 0
	jp nz,$lp?
	
	;4x64 spaces
	ld bc,256
$lp2?
	ld a,' '
	ld (hl),a
	inc hl
	dec bc
	ld a,b
	cp 0
	jp nz,$lp2?
	ld a,c
	cp 0
	jp nz,$lp2?
 
	;6x64 blocks	
	ld bc,384
$lp3?
	ld a,0ffh
	ld (hl),a
	inc hl
	dec bc
	ld a,b
	cp 0
	jp nz,$lp3?
	ld a,c
	cp 0
	jp nz,$lp3?

;now animate the arrow
	ld hl,ARROW_START
	ld de,arrow
	ld b,60
$al?	
	call draw4chars
	inc hl
	push bc
	ld bc,1000
	call delay
	pop bc
	djnz $al?
	call cls
	ret
	
arrow DB ' =->'	