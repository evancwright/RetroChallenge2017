;cpm.asm
BDOS EQU 5
RCONF EQU 1
A_READ EQU 3
C_STAT EQU 11
C_RAWIO EQU 6
WCONF EQU 2  ; "write to console function"
C_READSTR EQU 0Ah

;hl points to the start of the cpm buffer
;2nd is length of buffer
;*MOD
;atoi
;	ld a,0
;	ld (atoirslt),a
;	inc hl
;	ld a,(hl)
;	ld b,a
;	inc hl
;$lp?
;	
;	djnz $lp;
;	ret
	
;atoirslt

;assumes string is loaded into hl
*MOD
printstr
$lp? ld a,(hl)
	cp 0
	jp z,$x?
	ld e,a
	ld c,WCONF
	push hl
	call BDOS
	pop hl
	inc hl
	jp $lp?
$x?	ret

; hl contains string
printstrcr
	push af
	push bc
	push de
	call printstr
	call newline
	pop de
	pop bc
	pop af
	ret

newline
	ld e,CR
	ld c,WCONF
	call BDOS
	ld e,LF
	ld c,WCONF
	call BDOS
	ret

*MOD
get_char
	;loop until char is ready
$lp? 
	 ld a,(random)
	 inc a
	 ld (random),a
	 
	 ld c,C_RAWIO
	 ld e,0FFh;
	 call BDOS
	 cp 0
	 jp z,$lp?	 
	 ret
	
*MOD	
readline
	ld de,inbuf
	ld c,C_READSTR
	call BDOS
	call newline
	call newline
	ret


;char in e	
*MOD
print_char
	push af
	push bc
	push de
	push hl
	ld c,WCONF
	call BDOS	
	pop hl
	pop de
	pop bc
	pop af
	ret
	
*MOD
animate_pit_fall
	ld b,255
$lp? push bc
	ld e,'A'
	ld c,WCONF
	call BDOS
	pop bc
	push bc
	ld bc,000ffh
$il? dec bc 
	ld a,b
	cp 0
	jp nz,$il?
	ld a,c
	cp 0
	jp nz,$il?
	pop bc
;	djnz $lp?
	dec b
	jp nz,$lp?
	call newline
	ret	