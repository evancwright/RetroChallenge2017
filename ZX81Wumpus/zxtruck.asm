;
; To assembly this, either use the zxasm.bat file:
;
; zxasm hello
;
; or... assemble with the following options:
;
; tasm -80 -b -s hello.asm hello.p
;
;==============================================
;    ZX81 assembler 'Truck ' 
;==============================================
;
;defs
#include "zx81defs.asm"
;EQUs for ROM routines
#include "zx81rom.asm"
;ZX81 char codes/how to survive without ASCII
#include "charcodes.asm"
;system variables
#include "zx81sys.asm"

;the standard REM statement that will contain our 'hex' code
#include "line1.asm"

;------------------------------------------------------------
; code starts here and gets added to the end of the REM 
;------------------------------------------------------------
 
   
    ;draw the truck
    call drawtruck;
        
    ;draw the top black line
    ld hl, (D_FILE) ; addr to print to
    ld bc, 133; load offset
    add hl, bc; add it to hl
    ld d, h ; copy hl into de
    ld e, l ;copy addr back to de
    ld hl, cityline1
    call printline;

    inc de; skip newline
    ld hl, cityline2
    call printline;


    inc de; skip newline
    ld hl, cityline1
    call printline;
    
    inc de; skip newline
    ld hl, cityline2
    call printline;

    inc de; skip newline
    ld hl, cityline3
    call printline;

    ;draw the top black line
    inc de;
    ld hl, blackline
    call printline;
    
    ;draw the bottom black line
    ld hl, (D_FILE) ; addr to print to
    ld bc, 496; load offset
    add hl, bc; add it to hl
    ld d, h ; copy hl into de
    ld e, l ;copy addr back to de
    ld hl, blackline
    call printline;
    
    inc de; skip newline
    ld hl, inversespaces
    call printline;

    inc de; skip newline
    ld hl, inversespaces
    call printline;
    
    inc de; skip newline
    ld hl, titletext1;
    call printline;
    
    inc de; skip newline
    ld hl, titletext2;
    call printline;
    ;draw the instructions

mainloop:

   ;increment and flip the tire flag
    push hl
    push de
    push af
    ld e, $36; 'O' character for tires
    ld hl, (tireflag)
    inc hl
    ld a, l
    cp $02;
    jp nz, noreset;
    ld hl, $00; //reset back to 0
    ld e, $1c; '0' character for tires    
noreset:
    ;store flag back
    ld (tireflag), hl
    
    call drawtires;
    pop de
    pop hl
    pop af

    ;check to see if 'q' was pressed, if so return
    ;check the keyboard routine
    ;this routine calls the kscan subroutine
    ;kscan wipes out HL - so that needs to be saved

    push de ;save de
    ld de, kbstatus
    call checkquit
     pop de ;restore de
    
    ;now we can check kbstatus
    
    ld a, (kbstatus+1)
    ld b, $fb  ;0xFB  if section 2 (QWERT) pressed 
    cp b ; compare A to 0xFB  4099
    jp nz, skip
    ld a, (kbstatus)    
    ld b, $fd  ;0xFD if section 1 (1QA) pressed
    cp b ; compare A to 0xFD
    jp nz, skip
    ret ;Q was pressed, return 

skip:

    call decdrawpos;    
    
    jp mainloop ; end of main loop

;----------------------------
;THIS ROUTINE CALL KSCAN AT 02BB, THEN STORES
;THE STATUS CODE IN THE ADDRESS STORED IN DE
checkquit: ; 40A0
    push hl    ;save HL to stack
    push bc    ;save BC
    push de
    call KSCAN    ;call ROM subroutine at address 02BB, result put in HL
    pop de
    ld b, h  ;move hl to bc (because we're about to need HL)
    ld c, l
    ld h, d  ;copy kb status flag address into HL (so we can store it)
    ld l, e
    ld (hl), b ;store B in (HL)
    inc l
    ld (hl), c ;store C in (HL)+1
    pop bc
    pop hl
    ret
    
;draw truck to screen - assumes dfile is full
drawtruck:
    push hl
    push bc
    ld hl,(D_FILE) ;+ (33 * 10) + 10  ; ten rows down, 10 spaces over
    ld bc, 340;33 * 10 + 10;
    add hl, bc
    ld (hl), $81;
    inc hl
    ld (hl), $85;
    inc hl
    ld (hl), $80;
    inc hl
    ld (hl), $80;
    pop bc
    pop hl
    ret

; char to draw in de    
drawtires:
    ; draw the tires
    push hl
    push bc
    ld hl, (D_FILE)
    ld bc, 340 + 33;33 * 10 + 10;
    add hl, bc
    ld (hl), e; draw a tire
    inc hl  ; skip a space
    inc hl  ; skip a space
    ld (hl), e; draw a tire
    inc hl  ; skip a space
    ld (hl), e; draw a tire
 ;   ld (hl), $80;
    
    pop bc
    pop hl
    ret
;accepts the address of the text to print in hl, and the D_FILE location to print in DE
;printing stops when the char 0xFF is hit
printline:
    push bc
    push af
prloop:    
    ld a, (hl)  ; //get a char
    cp $ff      ; hit the end?
    jp z, done
    ld (de), a; copy char in 'a' to D_FILE
    inc hl ; increment addr to copy to
    inc de ; get addr of next character
    jp prloop
done:
    pop af
    pop bc
    ret

;this subroutine will draw a line of the background
;hl will be the offset from the start of the screen file to draw to
;bc will contain the address of the line to copy
;there will be a variable (drawpos) which is the start position to draw from (starting at 0)
;1. the routine will copy characters  drawpos  to 32 - drawpos to the start of the screen
;2. the routine will copy characters 0 from drawpos to startline + drawpos
;ldir will be used for the block copying
;drawpos will be getting decremented
drawline:

    ;step 1
    push bc; save line to copy
    
    ;bc (counter)
    ;de (dest)
    ;hl (src)
    ld de, (D_FILE); ; src
    add hl, de
    ld d, h  ; copy hl to de (because ldir needs it that way)
    ld e, l
    
    ;setup src address
    ld h, b; copy addr of line to draw
    ld l, c
    ld bc, (drawpos)
    add hl, bc
    
    ; bc needs to be 32-drawpos
    push hl
    
    ld hl, (drawpos)
    ld a, 32
    sub l
    ld b, 0
    ld c, a    
    pop hl
    
    ;if a==0 skip to step2
    cp 0
    jp z, step2;
    
    ldir ; copy until bc=0

    ;step 2
    ;2. the routine will copy characters 0 from drawpos to startline + drawpos
    ;bc (counter)
    ;de (dest) ;2. the routine will copy characters 0 from drawpos to startline + drawpos
    ;hl (src) - this should still be set up     
step2:
    
    ;stack contain line to draw
     
    ;bc should be drawpos    
     ld bc, (drawpos)
 
    
    pop hl ; setup src address
    
    ;if drawpos is 0, don't do the second part of the loop
    ld a, c;
    cp 0
    jp z, enddrawline;
    
    ;setup src address
    ;ld hl, cityline1
    
    ldir ; copy until bc=0    
enddrawline:    
    ret    

;this subroutine decrements the drawing position
;if it become negative it is set to 32
decdrawpos:
    
    ld a, (delaycounter)
    dec a;
    ld (delaycounter), a ; store it back
    cp 0
    ret nz ; not time to draw yet

    ld a, $80 ; loop counter was 0 reset it
    ld (delaycounter), a; store it

    ld de, (drawpos)
    dec de     
    ld a, e
    cp $FF  ;did the flag flip and go to -1
    jp nz, noflip
    ld d,0  ; reset drawpos back to 32
    ld e,32    
noflip:
    ld (drawpos), de; store it back

    ;redraw the city
    ld hl, 133
    ld bc, cityline1
    call drawline
    
    ld hl, 166
    ld bc, cityline2
    call drawline
    
    ld hl, 199
    ld bc, cityline1
    call drawline
    
    ld hl, 232
    ld bc, cityline2
    call drawline

    ret

;;;;;;;;;;;;;;;;;;;;;;;;;;VARIABlES;;;;;;;;;;;;;;;;;;;;;;;;;    
kbstatus:
    DEFW $ff $ff;storage for the 2 keyboard code bytes
drawpos:
    DEFW $00 $01
delaycounter:
    DEFB $80; 128d
tireflag:    
    DEFW $00 $00
    
titletext1:
    DEFB $B5,$B7,$B4,$AC,$B7,$A6,$B2,$B2,$AA,$A9,$80,$AE,$B3,$80,$A6,$B8
    DEFB $B8,$AA,$B2,$A7,$B1,$AA,$B7,$80,$80,$80,$80,$80,$80,$80,$80,$80, $FF
titletext2:
    DEFB $A7,$BE,$80,$AA,$BB,$A6,$B3,$80,$A8,$9B,$80,$BC,$B7,$AE,$AC,$AD,
    DEFB $B9,$9A,$80,$9E,$9C,$9D,$A1,$80,$80,$80,$B6,$94,$B6,$BA,$AE,$B9, $FF
blackline:
    DEFB $03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03, $03
    DEFB $03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03, $03, $FF
inversespaces:
    DEFB $80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80, $80
    DEFB $80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80, $80, $FF

cityline1: ;no windows
    DEFB $00,$00,$88,$88,$88,$88,$88,$00,$00,$00,$88,$88,$88,$88,$88,$88
    DEFB $88,$00,$88,$88,$88,$88,$00,$00,$00,$00,$88,$88,$88,$88,$88,$88, $FF

cityline2: ; windows
    DEFB $00,$00,$88,$03,$88,$03,$88,$00,$00,$00,$88,$95,$88,$95,$88,$95
    DEFB $88,$00,$88,$88,$88,$88,$00,$00,$00,$00,$88,$80,$88,$88,$80,$88, $FF

cityline3:
    DEFB $88,$88,$88,$88,$88,$88,$88,$88,$88,$88,$88,$88,$88,$88,$88,$88
    DEFB $88,$88,$88,$88,$88,$88,$88,$88,$88,$88,$88,$88,$88,$88,$88,$88, $FF
    
; ===========================================================
; code ends
; ===========================================================
;end the REM line and put in the RAND USR line to call our 'hex code'
#include "line2.asm"

;display file defintion
#include "screen.asm"               

;close out the basic program
#include "endbasic.asm"