;cpm.asm

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

printstrcr
	call printstr
	call newline
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
	ld c,WCONF
	call BDOS	
	ret