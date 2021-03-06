;lrs rand for z80

LEFT_BIT equ 16
RIGHT_BIT equ 4
RAND_MASK equ LEFT_BIT + RIGHT_BIT




;a times 10 
;a will overflow fast 
*MOD
a_times_10
	push bc
	ld c,a
	ld b,10
$lp?  
	add a,c
	dec b
	cp 0
	jp nz,$lp?	
	pop bc
	ret


;generates a random number and mods it by 'b'
;and returns it in 'a'
*MOD
rmod
	push bc
	call rand
	ld a,(urand)
	pop bc
	call mod ; now mod it by 'b' (leave result in 'a')
	
	ret	

;mods a by b		
*MOD	
mod 		
;			push hl
;			ld hl,moddbg
;			call printstrcr
;			pop hl
			cp a,b
			jp c,$x?
			sub a,b
 			jp mod
;			ld a,5 
$x?			ret

;div a by b		
*MOD	
div 		
			push de
			ld d,0 ; loop counter
$dvlp?		cp b
			jp c,$x?
			sub a,b
			inc d
			jp $dvlp?
$x?			ld a,d
			pop de
			ret


;returns # in a			
*MOD
rand
		ld a,(random)
		and a,RAND_MASK
		cp LEFT_BIT
		jp z,$po?
		cp RIGHT_BIT
		jp z,$po? 
		ld a,(random) 
;		srl a	;   just shift (pad with 0)	
		rra	;  srl is not 8080 compatible
		and 127d ; clear the leftmost
;		unset 7 ;  rotate right the clear leftmost bit
		jp $x?
$po?	ld a,(random)
;		srl a	;	pad with a 1
		rra	;  srl is not 8080 compatible
		add a,128 ; stick a 1 on the left 
$x?		ld (random),a
		dec a
		ld (urand),a
		ret

;a contains byte to print
*MOD
itoa8
 		push af	;save number
		push bc
		push de
		ld b,a	;save a
		ld a,0	;push a null onto the stack
		push af
		ld a,b ; restore a
$lp?	ld b,10 ; b is number to mod by
		call mod ; result in a
		ld b,a 	 ; save a
		add a,030h	 ; convert it to a char
 		push af	 ; push char to print onto the stack
		ld a,b	; restore a
		ld b,10 ; b is number to divide by
		call div ; divide a by 10
		cp 0
		jp nz,$lp? ; keep moding/dividing until 0
$pr?	pop af	   ;pop a character	
		cp 0	   ;null?
		jp z,$x?   ;yes - done
		ld e,a
		call print_char
		jp $pr? ; keep printing until 0 hit
$x?		pop de
		pop bc
		pop af	; restore #
		ret
		
random DB 255
urand DB 0  ; output