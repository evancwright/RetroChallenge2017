;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Wumpus.asm
;8080 CP/M version of Hunt the Wumpus
;Evan c. Wright 2017
;Assemble with Z80asm -com wumpus.asm for a CP/M COM file
;Assemble with Z80asm -nh wumpus.asm for a CMD file
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	
;UNCOMMENT THE  EQU FOR THE TARGET PLATFORM
;AND COMMENT OUT THE OTHER ONE	
CPM EQU 1
;TRS80 EQU 1

CR EQU 0Dh
LF EQU 0Ah
WUMPUS_BIT EQU 1
NEXTTOWUMPUS_BIT EQU 2
BAT_BIT EQU 4
NEXTTOBATS_BIT EQU 8
PIT_BIT EQU 16
NEXTTOPIT_BIT EQU 32

	ifdef CPM
	ORG 100H  ; CP/M
	else
	ORG 5200H ; TRS-80
	endif
	
START

*MOD
main
	;save the stack ptr
	
;	ld (stacksave),sp
;	push hl

	ifdef CPM
	ld sp,stack	
	;ask user if playing in a terminal
	ld hl,ttyprmpt
	call printstrcr
	call get_char
	cp 'y'
	jp z,$y?
	ld a,0
	ld (cpmtty),a
	jp $z?
$y?
	ld hl,set40col ;doesn't seem to work
	call printstr
$z?	
	endif
	
	ifdef TRS80
	ld (stacksave),sp
	call intro_screen
	call animate_teeth
	endif
	
	ld hl,welcome
	call printstrcr
	ld hl,author
	call printstrcr
	call newline
	ld hl,helpprompt
	call printstrcr 
	call get_char	
	cp 'y'
	call z,print_help
	cp 'Y'
	call z,print_help
	call set_up_game

$ip?  	
	call look
	ld hl,entercmd
	call printstrcr
	ld hl,cmdprompt
	call printstrcr
	call get_char
	cp 'q'
	jp z,$x?
	cp 'Q'
	jp z,$x?
	cp 's'
	call z,handle_shoot
	cp 'S'
	call z,handle_shoot
	cp 'm'
	call z,handle_move
	cp 'M'
	call z,handle_move
	cp 'd'
	call z,dump_board
	cp 'D'
	call z,dump_board
	jp $ip?
$x?	
quit
	ld hl,bye
	call printstrcr
;quit	
	ifdef TRS80
	ld sp,(stacksave)
	call CLS
	endif
;	pop hl 

	ifdef CPM
	jp 0
	else
	ret
	endif
 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;This subroutine set the flag in a room then sets the flags in the adjacent rooms
;a contains room number to set flag for
;c contains the bit flag to OR onto the room
;1 = wumpus | 2 = next to wumpus | 4 = bat | 8 = next to bats | 16 = pit | 32 = next to pit
*MOD
set_room_flag:
    
    ;convert it to a ptr
    push af 
	
    push bc
    ld c, a
    call get_room_ptr ; takes # in c, puts addr in hl
    pop bc
	
    push hl; save room address
    
    ld d, 0
    ld e, 5; add 5 bytes to get the flags byte
    add hl, de
    
    ;set the requested bit
    ld a,(hl)
    or c
    ld (hl),a; store the bat bit
    
    ;shift the bit left and apply the flag to the adjacent rooms
    push af
	ld a,c
	;need to clear carry flag
	rlca
	; sla 1  ; no 8080 left shift? Are you kidding me?
	ld c,a
    pop af
	pop hl; restore room address for subroutine
    
	pop af ; restore room
	
    ld b,c ; save flag
	ld c,a
	call get_room_ptr
	ld c,b ; mask back in c
    inc hl
	inc hl
	ld a,(hl) ; get neighbor 1
	call set_flag_in_adjacent
	inc hl
	ld a,(hl)  ; get neighbor 1
	call set_flag_in_adjacent
	inc hl
	ld a,(hl)  ; get neighbor 1
	call set_flag_in_adjacent
    ret

;set a 'next to' flag in a room
;a contains room
;c contains bit mask
*MOD 
set_flag_in_adjacent
	push af
	push hl
	push bc
	
;	ld hl,setflg ;debug message
;	call printstrcr
	
	ld (curRoom),a
	call set_room_addr
	pop bc
	call get_flags_byte
	or c
	ld hl,(currroomaddr)
	inc hl
	inc hl
	inc hl
	inc hl
	inc hl
	ld (hl),a
 	pop hl
	pop af
	ret
	
*MOD	
;This subroutine set the flags adjacent in the room adjacent to one that has bats
;addr of room is in hl
;c = value to OR onto the flags
set_adjacent_room_flags:
    ;add 2 bytes to room addr to get to the adjacent rooms
    inc hl
    inc hl
    ;loop three times
    ld b, 3 ; loop counter
flag_loop:
    push hl; save addr of adjacent room byte
    push bc; save loop counter
    ld c,(hl);get the number of the room that is adjacent to hl
    
    ;convert it to a ptr
    call get_room_ptr ; addr in hl
    
    ld d,0;add five bytes to get the flags offset
    ld e,5
    add hl,de
    ld a,(hl) ; get the flags byte
    pop bc ; restore loop counter or bit to OR
    or c ; set bit
    ld (hl), a ;store it back
    pop hl ;restore addr of adjacent room byte
    
    inc hl ; increment src add
    ;djnz flag_loop
	dec b
	jp nz,flag_loop
    ret
	
*MOD
set_up_game:
    	
	ld a,(cpmtty)
	cp 1
	jp nz,$n?
	call term_cls
$n?		
	ld hl,setuptxt
	call printstrcr
    	
	call clear_all_flags

	
	ld hl,wumpuslurk
	call printstrcr
	

;    ld a,2;
    call random_20 ; put random in a
    ld c,WUMPUS_BIT; wumpus bit
    call set_room_flag  ; room in a, flag in c

	ld hl,pitsforming
	call printstrcr
	
;    call random_20 ; put random in a
    
;    ld a,15;  
	call random_20 ; put random in a
    ld c,PIT_BIT;pit bit
	call set_room_flag  ; room in c, flag in a

;    call random_20 ; put random in a
;    ld a, 16;  room#
    call random_20 ; put random in a 
    ld c, PIT_BIT;  pit bit
    call set_room_flag  ; room in c, flag in a

	ld hl,batsroosting
	call printstrcr
    
;
;	ld a,4; 
    call random_20 ; put random in a
     ld c,BAT_BIT; bat bit
	 call set_room_flag  ; room in c, flag in a

;    ld a,2; 
    call random_20 ; put random in a
    ld c,BAT_BIT; bat bit
	call set_room_flag  ; room in c, flag in a
  
      ;put player at start, but not in pit
;    ld a,1
$lp?
    call random_20 ; put random in a
    ld (curRoom),a
    call set_room_addr
	call  get_flags_byte ; a
	and PIT_BIT
	jp nz,$lp?

	ld hl,done
	call printstrcr
	call newline
    ret	
	
look
	call print_current_room;
    call print_tunnels; calls scroll
    call print_flags;
	ret
	

*MOD
promptcommand
	ld hl,cmdprompt
	call printstrcr
	ret
	
;compute the pointer for the room
;room number in register c
;address returned in hl
*MOD
get_room_ptr:
    push af
    push bc
    push de
    dec c
    ld d, 0
    ld e, c ;room number
    ld a, 6 ; size of room data
;    call DE_Times_A ; result in HL
	call DE_MUL_A
    ld de,room1
    add hl,de  ; add starting offset
    pop de
    pop bc
    pop af
    ret	

	
;this subrountine converts the room number
;to its address
;the address is returned in hl and stored 
;in the variable currroomaddr
*MOD
set_room_addr
    push af
    push bc
    push de
    push hl
    ld a,(curRoom) ; room number (1 based)
    dec a
    ld d, 0
    ld e, a
    ld a, 6; size of room in bytes (2 byte name, 3 rooms, 1 flags)
    call DE_Mul_A ; result in hl now add it to base
    ld bc, room1; load base addr
    add hl, bc ; add offset to base
    
    push hl ;switch hl, bc'
    push bc
    pop hl
    pop bc
    ld hl,currroomaddr
    ld (hl),c
    inc hl
    ld (hl),b
    pop hl
    pop de
    pop bc
    pop af
    ret
	
*MOD	
;this subroutine checks if the player can go in specified direction
;c - the room to move to
validate_move:
    ld hl, (currroomaddr)
    inc hl
    inc hl
    ld b, 3
validate_move_loop:    
    ld a, (hl)
    cp c
    jp z, valid_move
    inc hl
;    djnz validate_move_loop
	dec b
	jp nz,validate_move_loop
    ld a, 0
    ret
valid_move:
    ld a, 1
    ret

*MOD
handle_move
	ld hl,whichroom
	call printstrcr
	call readline
	
	ifdef CPM
    call cpm_atoi ; result in bc
	else
	ld hl,INBUF
	call pos_atoi
	call atoi
	endif
	
    call validate_move ; expects room in c
    cp 0
    jp z,invalid_room
    ld a, c
    ld (roomentry), a
	call move_player
	jp $x?
invalid_room
    ld hl,baddir
    call printstrcr
$x? ret	
	
	
*MOD
handle_shoot
	ld hl,whichroom
	call printstrcr
	call readline
	ifdef CPM
    call cpm_atoi ; result in bc
	else
	ld hl,INBUF
	call pos_atoi
	call atoi ;	
	endif
    call validate_move ; expects room in c
    cp 0
    jp z,bad_room
    ld a, c
    ld (roomentry),a
    call shoot_arrow
    jp $x?
bad_room
    ld hl,baddir
    call printstrcr
$x? ret	
	
	
*MOD	
;moves the player to the selected room
;the selection will be a valid choice by now
move_player: 
    ld a,(roomentry)
    ld (curRoom),a
    call set_room_addr
    call handle_hazards
    ret

;shoots the arrow, the target
;room is valid	
*MOD 
shoot_arrow

	ifdef CPM
	call animate_arrow
    ld hl,shootarrowtxt
    call printstrcr
	else
	call animate_arrow
	endif
	;delay here would be cool
	
    ;was the wumpus in that room
    ld a,(roomentry)
    ld c,a
    call get_room_ptr ; result in hl
    ld de,5 ; 5 byte offset to get flags
    add hl,de
    ld a,(hl) ; get flags bytes
    and WUMPUS_BIT
    jp nz,arrow_hit
arrow_miss:
	ifdef TRS80
	call animate_teeth
	endif
	
    ld hl,playereaten0
    call printstrcr
    ld hl,playereaten1
    call printstrcr
    ld hl,playereaten2
    call printstrcr  
	ld a,(wumpusscore)
	inc a
	ld (wumpusscore),a
	ld hl,youhavedied
	call printstrcr
	call play_again 
    jp $x?
arrow_hit:
    ld hl,thwacktxt
    call printstrcr
    ld hl,victorymessage1
    call printstrcr
	ld hl,victorymessage2
    call printstrcr
	ld a,(playerscore)
	inc a
	ld (playerscore),a
	call play_again 
$x?	
    ret
 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;    
;this subroutine checks for hazards in the room the player
;has just moved into
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
*MOD
handle_hazards:    
    call get_flags_byte; a
    ld (flagsSav),a ; save flags
        
    ;check for wumpus
    and WUMPUS_BIT
    jp z,check_for_pit
    
    ;wumpus death
    ld hl,roartxt
    call printstrcr
    ld hl,playereaten
	ld a,(wumpusscore)
	inc a
	ld (wumpusscore),a
    call printstrcr
	ld hl,youhavedied
	call printstrcr
	call play_again
    jp $x? 
check_for_pit:    
    ;check for pit
	ld a,(flagsSav)
    and PIT_BIT
    jp z,check_for_bats
    
    call animate_pit_fall
	;+1 to wumpus
	ld a,(wumpusscore)
	inc a
	ld (wumpusscore),a

	call play_again 
	jp $x?
check_for_bats:
    ;check for bats
    ld a,(flagsSav) ; reset flags
    and BAT_BIT
    jp z,player_safe
    
    ;player needs to be moved
    call fly_player_to_new_room 
    call handle_hazards;  ;after move, room needs to be checked for pits/wumpus
player_safe: 
$x? ret

	
*MOD
fly_player_to_new_room
	push af
	push bc
	push de
	push hl
	ld hl,batmove
	call printstrcr
	call random_20
;	ld a,20
	ld (curRoom),a	
	call set_room_addr
;	call print_room_label
	pop hl
	pop de
	pop bc
	pop af
	ret
	

; returns 1-20 (inclusive) in 'a'
*MOD
random_20
;	ld a,5
;	ret
	push bc
	ld b,19d  ; 0-19
	call rmod
;	ld a,015h ;21
	inc a ;1-20
	cp 0
	jp z,badrand
	cp 21d
	jp c,$x?
	ld hl,badrand
	call printstrcr
$x?	;push af
	;call itoa8
    ;pop af
	pop bc
	ret

*MOD 
DE_MUL_A
	push af
	push bc
	push de
	 ld b,a  ; loop counter
	 ld h,0 ; accumulator
	 ld l,0
$lp? ld a,b
	 cp 0
	 jp z,$x?
	 add hl,de
;	 djnz $lp?
	dec b
	jp nz,$lp?
$x? pop de
	pop bc
	pop af
	ret
	
	
get_flags_byte:
	push de
	push hl
    ld hl,(currroomaddr) ; load addr of byte with tunnel
    ld de,5 ; 5 byte offset
    add hl,de
    ld a,(hl) ; get flags bytes
	pop hl
	pop de
    ret
	
	
*MOD 
print_flags:
;	ld a,(curRoom)
;	call set_room_addr
    call get_flags_byte
	ld (flagsSav),a   ;save it
    and NEXTTOPIT_BIT
	cp NEXTTOPIT_BIT
	jp nz,nopit;
    ld hl,pitwarning
    call printstrcr
nopit:
	ld a,(flagsSav)
    and NEXTTOBATS_BIT
	cp NEXTTOBATS_BIT
	jp nz,nobats;
    ld hl,batswarning
    call printstrcr
nobats:
	ld a,(flagsSav)
    and NEXTTOWUMPUS_BIT; bit 2 = next to wumpus
    cp NEXTTOWUMPUS_BIT
	jp nz,nowumpus;
    ld hl,wumpuswarning
    call printstrcr
nowumpus:
    ret


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;take char in c
;puts code into c
;c = $FF if char is invalid
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
char_to_num:
    push af
    push de
    push hl
         
    ld e,30h   ; subtract off $1C to convert it to a number
    ld a,c     ; load char into accumulator
    sub e   ;subract '0' from char
    jp m, badchar  ; char was less than "0"
    
    ; char is still loaded into d
    ; load char code for "9"
    ; subtract that from the char
    ld d,a;
    ld a,39h ; char code for 9
    sub d;
    jp m,badchar; char was greater than "9"
    
    ;char (in d) is valid and is 0-9
    ld c,d	;
    jp goodchar
badchar:
    ld c,0ffh
goodchar:
    pop hl
    pop de
    pop af
    ret

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Sets all room flags back to 0 (so the flags don't accumulate)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
clear_all_flags
    
    ld a,0h	
    ld hl,room1
    ld bc,5h
    add hl,bc
  
    ld de,6
    ld b,20 ; # of rooms
clear_flags_loop
    ;add 6 to get the addr of the next byte
    ld (hl),a ; zero out the byte
    add hl,de ; jump ahead six bytes to the next flags byte
 ;   djnz clear_flags_loop
    dec b
	jp nz,clear_flags_loop
    ret	

*MOD
print_help
	ld hl,help
	call printstrcr
	
	ifdef TRS80
	ld hl,hitenter
	call printstrcr
	call get_char
	endif
	
	ifdef CPM
	ld a,(cpmtty)
	cp 1
	jp nz,$w?
	ld hl,hitenter
	call printstrcr
	call get_char
	call term_cls
$w?
	endif

	ret


;converts text in a buffer to an integer
;this function t akes the address of the rightmost
;hl address of rightmost byte
;c number of bytes in the buffer
;result is returned in bc
atoi:
    ;bc will be the sum
    ;de will be the place value (power of 10)
    ;hl will contain the src address
    ;a will be loop counter
    ld a, c    
    ld bc,0
    ld de,1
atoiloop:
    push af ; save loop counter
    push hl ; save src addr (free up hl)
    push bc ; save sum (free up bc)
    
    ld c,(hl)
    call char_to_num;
    ld a, c
    cp 0ffh
    jp z, invalid
    
    ;multiply de * the place value (de)
    push de
    call Mul8 ; HL=DE*A
    pop de
    
    ;move temp to bc
    ld b, h
    ld c, l
    
    ;add to the sum
    pop hl ; restore sum to hl
    add hl, bc
    ld b, h ; copy sum back into bc
    ld c, l
    
    ;multiply the place value x 10
    ld a, 10
    call Mul8 ; HL=DE*A
    ld d, h
    ld e, l
    
    pop hl ; restore addr
    dec hl
    
    pop af ; restore loop counter
    dec a
    jp nz, atoiloop;

    ;finished loop - number was valid
    ret
invalid:
    pop bc
    pop hl
    pop af
    ret 
	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;  this routine performs the operation HL=DE*A
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
*MOD
Mul8    
  push af
  push bc
  push de
  ld hl,0                       
  ld b,a                        
Mul8Loop:
  add hl,de	
  dec b
  jp nz,Mul8Loop
  pop de
  pop bc
  pop af
  ret
	

	
*MOD	
print_current_room
	ld hl,curRoomStr
	call printstr
	call print_room_label
	call newline	
	ret
	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;prints out the scores then prompts the
;player to play again
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
*MOD 
play_again
	ld hl,playerwinstxt
	call printstr
	ld a,(playerscore)
	call itoa8
	ld hl,wumpuswinstxt
	call printstr
	ld a,(wumpusscore)
	call itoa8
	call newline	
	ld hl,playagain
	call printstrcr
	call get_char
	cp 'y'
	jp z,$y?
	jp quit
$y?	call set_up_game
	ret
	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;    
print_tunnels:
    ld hl,passages
    call printstr
    
    ;11,15,22
	ld a,(curRoom)
	push af
    ld hl,(currroomaddr) ; load addr of byte with tunnel
	push hl
	
    inc hl	; skip to 1st neighbor
    inc hl
	ld a,(hl)
	ld (curRoom),a
	call set_room_addr
    call print_room_label

;	push hl
    ld e,','
;	ld c,WCONF
;	call BDOS
;	pop hl
;	ld e,a
	call print_char
	
	inc hl
	ld a,(hl)
	ld (curRoom),a
	call set_room_addr
    call print_room_label

;	push hl
    ld e,','
;	ld c,WCONF
;	call BDOS
;	pop hl
	call print_char
	
	inc hl
	ld a,(hl)
	ld (curRoom),a
	call set_room_addr
    call print_room_label
    
	call newline
	
	;restore original room ptr
	pop hl
	ld (currroomaddr),hl
	
	pop af
	ld (curRoom),a
	
    ret

;assumes currroomaddr is set
print_room_label
	push hl
	
	;print 1st char
	ld hl,(currroomaddr)
	ld a,(hl)
	push hl
	ld e,a
	call print_char
	pop hl

	;print 2nd char
	push hl
	inc hl
	ld a,(hl)
	ld e,a
	call print_char
	pop hl
	
	pop hl
	ret

*MOD
dump_board
	 ld a,(curRoom)
	 push af 
	 ld a,1
$lp? push af
	 ld (curRoom),a
	 call set_room_addr
	 call print_room_label
	 call get_flags_byte
	 ld (flagsSav),a
	 and PIT_BIT
	 jp z,$t?	 
	 ld hl,pitdbg
	 call printstr
	 call newline
$t?	 ld a,(flagsSav)
	 and NEXTTOPIT_BIT
	 jp z,$n?
	 ld hl,draftdbg
	 call printstr
	 call newline
$n?	 ld a,(flagsSav)
	 and BAT_BIT
	 jp z,$o?
	 ld hl,batsdbg
	 call printstr
	 call newline
$o?	 ld a,(flagsSav)
	 and NEXTTOBATS_BIT
	 jp z,$l?
	 ld hl,squeakdbg
	 call printstr
	 call newline
$l?	ld a,(flagsSav)
	 and WUMPUS_BIT
	 jp z,$p?
	 ld hl,wumpdbg
	 call printstr
$p? ld a,(flagsSav)
	 and NEXTTOWUMPUS_BIT
	 jp z,$m?
	 ld hl,smelldbg
	 call printstr
$m?	 call newline
	 pop af
	 inc a
	 cp 21
	 jp nz,$lp?
	 pop af
	 ld (curRoom),a
	 call set_room_addr
	 ret

	ifdef TRS80
*MOD 
intro_screen
	call CLS 
	
	ld de,VRAM
	ld hl,title_data
	ld bc,1024
	ldir
	
	call get_char
	call CLS
	ret
	endif

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

*INCLUDE math.asm

	ifdef CPM
*INCLUDE cpm.asm
	else
*INCLUDE trs80.asm	
*INCLUDE trs80pit.asm
*INCLUDE trs80arrow.asm
*INCLUDE trs80teeth.asm
	endif

	
;data
seed DB 0
curRoom DB 1
currroomaddr DW room1
roomentry DB 0
playerscore DB 0
wumpusscore DB 0

;2byte label, 
;three bytes for the number of the connecting rooms, 
;one byte for flags bits from left to right
; |0|0|next to pit|has pit|next to bats|has bats|next to wumpus|has wumpus|

room1:
    DB 20h,31h,02,05,08,0
room2:
    DB 20h,32h,01,03h,0Ah,0
room3:
    DB 20h,33h,02,04,0Ch,0
room4:
    DB 20h,34h,03,05,0Eh,0
room5:
    DB 20h,35h,01h,04h,06h,0 
room6:
    DB 20h,36h,05h,07h,0Fh,0
room7:
    DB 20h,37h,6h,08h,11h,0 
room8:
    DB 20h,38h,01,07,09,0
room9:
    DB 20h,39h,08h,0Ah,12h,0 
room10:
    DB 31h,30h,02h,09h,0Bh,0 
room11:
    DB 31h,31h,0Ah,0Ch,13h,0 
room12:
    DB 31h,32h,03h,0Bh,0Dh,0 
room13:
    DB 31h,33h,0Ch,0Eh,14h,00
room14:
    DB 31h,34h,04h,0Dh,0Fh,0
room15:
    DB 31h,35h,06h,0Eh,10h,0
room16:
    DB 31h,36h,0Fh,11h,14h,0h
room17:
    DB 31h,37h,07h,10h,12h,0
room18:
    DB 31h,38h,09h,11h,13h,0 
room19:
    DB 31h,39h,0Bh,12h,14h,0 
room20:
    DB 32h,30h,0Dh,10h,13h,0 


;strings	
welcome DB "Welcome to Hunt the Wumpus",0
	DB 0
	ifdef CPM
author DB "CP/M Version by Evan Wright, 2017-18",0
	else
author DB "TRS-80" Version by Evan Wright, 2017-18",0
	endif
	
flagsSav DB 0	
stacksave DW 0
curRoomStr DB "You are in room ",0
passages DB "Passages lead to rooms ",0
period DB ".",0
and DB " and ",0
setuptxt DB "Setting up the caves...",0h
wumpuslurk DB "The Wumpus has found a cave to lurk in... ",0h
pitsforming DB "The Earth's crust is cracking, forming bottomless pits...",0h
batsroosting DB "Giant vampire bats have infiltrated the caves...",0h
done DB "Done.",0
baddir DB "You can't move/shoot that way.",0h
batswarning DB "*RUSTLE* *RUSTLE* You hear vampire bats nearby.",0	
batmove DB "*FLAP* *FLAP* *FLAP* Giant vampire bats have flown you to a different cave.",0	
pitwarning DB "You feel a draft.",0	
hitenter DB "Press ENTER to continue.",0;
wumpuswarning DB "I SMELL A WUMPUS!",0	
whichroom DB "Which room?",0	
youcantgothatway DB "That's not a valid room.",0	
helpprompt DB "Would you like instructions? (y/n)",0
playagain DB "Play again?",0
entercmd DB "Enter a command:",0
cmdprompt DB "Move(m), shoot(s), or quit(q)?",0
bye DB "Bye.",0
pitdeath DB "Ooops...you have fallen into a bottomless pit.",0
youhavedied DB "***YOU HAVE DIED***",0
shootarrowtxt DB "SWOOSH...",0
thwacktxt DB "THWACK!",0
roartxt DB "ROAR!",0
playereaten DB "Oh no! You have wandered into the lair of the Wumpus",0h
playereaten0 DB "Clunk.",0
playereaten1 DB "Your single arrow lands harmlessly in an empty cave...",0
playereaten2 DB "As you stop to ponder the fatal implications, the Wumpus sneaks up behind you and devours you!",0
victorymessage1 DB "A deafening roar fills the caverns as the wumpus falls dead.",0
victorymessage2 DB "Congratulations...You have killed the wumpus!!!",0
help
help1 DB "In this maze of cave lives a fearsome creature known as the Wumpus which you must kill with your single arrow."
help2 DB "  Should you venture into the cave containing the Wumpus, it will surely devour you."
help3 DB "  Other hazards exist besides the wumpus. There are two bottomless pits."
help4 DB "  If you are adjacent to a pit, you will feel a draft."
help5 DB "  Giant vampire bats are known to inhabit the caves as well."
help6 DB "  If you disturb them by entering their lair, they will fly you elsewhere."
help7 DB "  Hope though, that they don't drop you in a pit or on the wumpus!"
help8 DB "  When you have located the wumpus, fire an arrow into its lair to slay it.",0h
wumpuswinstxt DB " Wumpus: ",0h
playerwinstxt DB "Player: ",0h
badrand DB "BAD RANDOM NUMBER!",0h
;setflg DB "SETTING FLAG.",0h
pitdbg DB "PIT",0
draftdbg DB "DRAFT",0
batsdbg DB "BATS",0
squeakdbg DB "NEXTTOBATS",0
wumpdbg DB "WUMPUS",0
smelldbg DB "SMELL",0
moddbg DB "MOD...",0
	DB 0
	
 	
	ifdef TRS80
*INCLUDE trs80title.asm
*INCLUDE teeth_data.asm
	endif
	DEFS 64 ; stack area
stack DB 0 ; top
	

	END START