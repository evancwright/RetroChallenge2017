CRTBYTE equ  0033H
INBUF equ 41e8h
CLS equ 01c9h
BUFSIZE EQU 48
KEYIN EQU 40H
SCR_WIDTH EQU 64
*MOD
readline
		push bc
		push de
		push hl
;		call clrbuf
		ld hl,INBUF
		ld b,BUFSIZE
		call KEYIN ; returns len in 'b'
		ld c,b
		ld b,0
		add hl,bc
		ld (hl),0  ; delete cr
		pop hl
		pop de
		pop bc
		call printcr
		ret


;hl = str
printstr
		push af
		push bc
		push de
		push hl
		push ix
		push iy
$lp?	ld a,(hl)
		cp 0
		jp z,$x?
		cp 32 ; space;
		jp nz,$c?
		;call word_len ;len->b
		ld b,10
		;is there room left on line
		ld a,(hcur)
		ld c,a
		ld a,SCR_WIDTH
		sub c ; a has remaining len
		cp b
		jp p,$sp?
		call printcr
		inc hl
		jp $lp?
$sp?	ld a,32 ; reload space
$c?		inc hl
		call CRTBYTE
		push hl
		ld hl,(hcur)
		inc hl
		ld (hcur),hl
		pop hl
		jp $lp?	
$x?		pop iy
		pop ix
		pop hl
		pop de
		pop bc
		pop af
		ret
		
*MOD
printstrcr
		push af
		push bc
		push de
		push hl
		push ix
		push iy
$lp?	ld a,(hl)
		cp 0
		jp z,$x?
		inc hl
		call CRTBYTE
		jp $lp?	
$x?		call printcr
		pop iy
		pop ix
		pop hl
		pop de
		pop bc
		pop af
		ret

newline
	call printcr
	ret
		
;prints a space (registers are preserved)
printcr
	push af
	push bc
	push de
	push iy
	ld a,0dh ; carriage return
	call CRTBYTE
	ld a,0
	ld (hcur),a
	pop iy
	pop de
	pop bc
	pop af
	ret

get_char
	ld a,r		;reload random seed
	ld (rand),a
	call readline
	ld a,(inbuf)
	ret	

;char in e
print_char	
	
	ld a,e
	call CRTBYTE
	ret

print_chara	
	push bc
	call CRTBYTE
	pop bc
	ret

;make hl point to the right most char
;in the buffer pointed to by hl
*MOD
pos_atoi
	ld a,(hl) ; already at end?
	cp 0
	jp z,$x?

	push de
	push hl	; hl->de
	pop de
	inc de
$lp?	
	ld a,(de)
	cp 0
	jp z,$x?
	inc de
	inc hl
	jp $lp?
	
	pop de
$x?	ret

hcur dw 0
	