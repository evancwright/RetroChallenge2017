;cpm.asm
BDOS EQU 5
RCONF EQU 1
A_READ EQU 3
C_STAT EQU 11
C_RAWIO EQU 6
WCONF EQU 2  ; "write to console function"
C_READSTR EQU 0Ah
CR EQU 0Dh
LF EQU 0Ah
ESC EQU 1Bh

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
	push bc
	push de
	
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
$x?	pop de
	pop bc
	ret

*MOD
wait_keyup
	;loop until char is NOT ready
$lp? 
	 ld c,C_RAWIO
	 ld e,0FFh;
	 call BDOS
	 cp 0
	 jp nz,$lp?	 
	 ret

; hl contains string
printstrcr
	push af
	push bc
	push de
	push hl
	call printstr
	call newline
	pop hl
	pop de
	pop bc
	pop af
	ret

newline
	push bc
	push de
	push hl
	
	ld e,CR
	ld c,WCONF
	call BDOS
	ld e,LF
	ld c,WCONF
	call BDOS
	
	pop hl
	pop de
	pop bc
	ret

*MOD
get_char
	;loop until char is ready
$lp? 
	 ld a,(randlo)
	 inc a
	 ld (randlo),a
	 
	 ld c,C_RAWIO
	 ld e,0FFh;
	 call BDOS
	 cp 0
	 jp z,$lp?	 
	 push af
	 call wait_keyup
	 pop af
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

showcrsr DB ESC,'[?25h',0
hidecrsr DB ESC,'[?25l',0
cpmcls 	DB ESC,'[2J',0
cpmhome DB ESC,'[;H',0
set40col DB ESC, '[=0',0
ansisave DB ESC,'[s',0
ansirestor DB ESC,'[u',0
ansidel DB 127 ; 
bell DB 7,7,7,0
inputbuffer
inbuf 	DB 40  ; len
bytesrd DB 0		
chars	DS 40  ; space
