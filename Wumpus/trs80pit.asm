;trs80pitfall
VRAM equ 03C00h

FALL_START EQU VRAM+30

*MOD
animate_pit_fall
	call CLS
	ld hl,VRAM
	;first draw the pit walls
	ld b,16
$ol	
	push bc
	ld b,26
$l1?
	;call CRTBYTE
	ld a,255 ; solid space
	;call print_chara
	ld (hl),a
	inc hl
	djnz $l1?

	;print 8 spaces
	ld b,12
$zl?
	ld a,' '; gap
;	call print_chara
	ld (hl),a
	inc hl

	djnz $zl?

	;print 28 solid blocks
	ld b,26

$l3?
;	call CRTBYTE
	ld a,0ffh; solid space	
;	call print_chara
	ld (hl),a
	inc hl
	djnz $l3?
	
	pop bc	
	djnz $ol
	;jp $x? 
	;now draw the character falling
	ld hl,FALL_START
	ld de,guyaddr
	ld hl,FALL_START
	call draw4chars	
	
	ld b,15
$fl
	push bc
	;erase the previous guy
	ld de,spaces
	call draw4chars	

	;move the character down a line (add 64 to hl)
	ld de,64
	add hl,de
	
	;draw the newguy
	;add offset to each address
	ld de,guy
	call draw4chars
	
	push bc
	ld bc,8000
	call delay
	pop bc
	
	pop bc
 	djnz $fl
$x? ;call get_char
	call CLS
	ret

;copies 4 chars 
;de is src of chars
;hl is dest
*MOD
draw4chars
	push bc
	push de
	push hl
	ld b,4
$lp?
	ld a,(de)
	ld (hl),a
	inc hl
	inc de
	djnz $lp?
	pop hl
	pop de
	pop bc
	ret

;bc contains delay length	
*MOD
delay

$lp?
	dec bc
	ld a,b
	cp 0
	jp nz,$lp?
	ld a,c
	cp 0
	jp nz,$lp?
$x?	ret
	
guyaddr DW 0
eraseaddr DW 0
 
guy DB '>-+o'
spaces DB '    '	
