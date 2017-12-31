;hangman.asm
;Evan Wright 2017/2018

CR EQU 0Dh
LF EQU 0Ah
NUM_WORDS EQU 109
CPM EQU 1
NUM_GUESSES EQU 5

	ifdef CPM
	ORG 100H  ; CP/M
	else	 
	ORG 5200H ; TRS-80
	endif

START

*MOD
main
	ld hl,welcomeTxt1
	call printstrcr
	ld hl,welcomeTxt2
	call printstrcr
	ld hl,welcomeTxt3
	call printstrcr
	
	call reset
	
	;ask for a letter
$il?
	call draw_game
	ld hl,workingWord
	call printstrcr
	ld hl,guessedTxt
	call printstr
	ld hl,guessedChars
	call printstrcr

	ld hl,promptText
	call printstrcr
	
	call get_char
	ld (curChar),a
	ld e,a
	call print_char
	call newline
	
	;has it been guess already?
	call already_guessed
	ld a,(guessedFlag)
	cp 1
	jp z,$il?
	
	;is it in the word?
	call find_matches
	ld a,(foundFlag)
	cp 1
	jp z,$fm? ;yes

	call store_guess
	
	ld a,(curChar)
	ld e,a
	call print_char
	ld hl,notInWordTxt
	call printstrcr
	
	
	;are we out of guesses?
	ld a,(badGuessIndex)
	cp NUM_GUESSES
    
	jp nz, $c?
     
	;draw last image
	call draw_game
	 
	ld hl,loseTxt
	call printstrcr 

	call reveal_word
	
	ld hl,playAgainTxt
	call printstrcr
	call get_char
	cp 'y'
	jp nz,$quit?	
	call reset
	jp $il? 
	 
$fm?
	call find_matches
	
	;has the whole word been guessed?
	call player_won
	ld a,(winFlag)
	cp 1
	jp z,won
	
	
	jp $c?
won
	call reveal_word

	call draw_win
	ld hl,winTxt
	call printstrcr
	ld hl,playAgainTxt
	call printstrcr
	call get_char
	cp 'y'
	jp nz,$quit?	
	call reset
	jp $il?
	
$c?	jp $il?
$quit?	
	ifdef CPM
	jp 0
	else
	ret
	endif

	
reset
	ld a,0
	ld (winFlag),a
	call pick_word
	call clear_guesses
	call clearbuf
	; call printbuffer
	ret

;reveals the word	
reveal_word
	ld hl,revealTxt
	call printstr 

	ld hl,(curWordPtr)
	call printstrcr 	
	ret
;nulls out the 5 guessed letters
*MOD
clear_guesses
	ld a,0
	ld (badGuessIndex),a ; set index to 0
	ld a,0
	ld b,NUM_GUESSES
	ld hl,guessedChars
$lp?
	ld (hl),a
	inc hl
	dec b
	jp nz,$lp?
	ret

;reveals letters and sets foundFlag to 1
;if there was a match
*MOD
find_matches
	ld a,0				;clear found flag
	ld (foundFlag),a
	ld hl,workingWord
	ld de,(curWordPtr)
	ld a,(curChar)
	ld b,a
$lp?
	ld a,(de)	; get char from word
	cp 0
	jp z,$x?    ;hit the end, done
	cp b		; is it the one being guessed
	jp nz, $c?
	ld (hl),a   ; copy the letter into buffer
	ld a,1
	push hl
	ld (foundFlag),a
	ld hl,foundTxt
	pop hl
$c?
	inc de
	inc hl
	jp $lp?
$x?	ret
	
*MOD
check_for_win
	ld hl,workingWord
$lp?
	
$x?	ret
	
*MOD	
pick_word
	call rand ; result in a
	ld b,NUM_WORDS
	call mod

	ld hl,pickingTxt
	call printstrcr
	
	;skip that many nulls
	ld hl,wordlist
	ld b,a
	cp 0
	jp z,$dn?
$lp?	
	ld a,(hl)
	inc hl ; skip past the null to the word
	cp 0
	jp nz,$lp?
    ;found a null
	dec b
	jp nz,$lp?
$dn?	
	ld (curWordPtr),hl
;	call printstrcr	
	ld hl,doneTxt
	call printstrcr	
	ret

;clear the working buffer
;by copying in the correct number of _ chards
*MOD
clearbuf
	ld hl,(curWordPtr)
	ld de,workingWord
$lp?
	ld a,(hl)
	cp 0
	jp z,$x?	
	ld a,'_'	;copy a _ into the working buffer
	ld (de),a
	inc de
	inc hl
	jp $lp?
$x?	ld (de),a ;copy the 0 into the end of the working buf
	ret

;char to test in a
;sets the already guessed byte	
*MOD
already_guessed
	ld a,(curChar) ; char -> b
	ld b,a
	ld a,0				;clear the flag
	ld (guessedFlag),a
	ld hl,guessedChars
$lp? ld a,(hl)
	cp 0	;hit end of list - not used yet
	jp z,$x?
	inc hl
	cp b	;equal to curChar?
	jp nz,$lp? ; no, keep looping
	;if here, they match
	ld a,1
	ld (guessedFlag),a	
	ld hl,alreadyUsedTxt
	call printstr
	ld a,(curChar)
	ld e,a
	call print_char
	call newline
$x?	ret

;put the letter in the list of used ones
*MOD
store_guess	
	ld a,(badGuessIndex)
	;compute the offset
	ld de,guessedChars
	ld h,0
	ld l,a
	add hl,de
	;store the char in the array
	ld a,(curChar)
	ld (hl),a
	;increment the index
	ld a,(badGuessIndex)
	inc a
	ld (badGuessIndex),a
	ret


;if can't find a '_' in the buffer, winFlag set to 1
*MOD
player_won
	ld hl,workingWord
$lp?	
	ld a,(hl)
	inc hl
	cp 0		; hit the end - player won
	jp z,$w?
	cp '_'		
	jp z,$x?	; lose
	jp $lp?
$w?	ld a,1
	ld (winFlag),a
$x?	ret

;draws no bad guesses
draw_zero
	ld hl,top
	call printstrcr
	ld hl,post
	call printstrcr
	call printstrcr
	call printstrcr
	call printstrcr
	ld hl,bottom
	call printstrcr
	ret

;draws no bad guesses
draw_one
	ld hl,top
	call printstrcr
	ld hl,head
	call printstrcr
	ld hl,post
	call printstrcr
	call printstrcr
	call printstrcr
	ld hl,bottom
	call printstrcr
	ret

;draws no bad guesses
draw_two
	ld hl,top
	call printstrcr
	ld hl,head
	call printstrcr
	ld hl,onearms
	call printstrcr
	ld hl,post
	call printstrcr
		call printstrcr
	ld hl,bottom
	call printstrcr
	ret

draw_three
	ld hl,top
	call printstrcr
	ld hl,head
	call printstrcr
	ld hl,botharms
	call printstrcr
	ld hl,post
	call printstrcr
	call printstrcr
	ld hl,bottom
	call printstrcr
	ret
;draws no bad guesses
draw_four
	ld hl,top
	call printstrcr
	ld hl,head
	call printstrcr
	ld hl,botharms
	call printstrcr
	ld hl,oneleg
	call printstrcr
	ld hl,post
	call printstrcr
	ld hl,bottom
	call printstrcr
	ret

;draws no bad guesses
draw_five
	ld hl,top
	call printstrcr
	ld hl,rope
	call printstrcr
	ld hl,head
	call printstrcr
	ld hl,botharms
	call printstrcr
	ld hl,bothlegs
	call printstrcr
	ld hl,bottom
	call printstrcr
	ret	

draw_win
	ld hl,top
	call printstrcr
	ld hl,post
	call printstrcr
	ld hl,headwin
	call printstrcr
	ld hl,body
	call printstrcr
	ld hl,bothlegs
	call printstrcr
	ld hl,bottom
	call printstrcr
	ret	
	
draw_game
	ld a,(badGuessIndex)
	cp 0
	jp z,draw_zero
	cp 1
	jp z,draw_one
	cp 2
	jp z,draw_two
	cp 3
	jp z,draw_three
	cp 4
	jp z,draw_four
	cp 5
	jp z,draw_five
	ret
	
*INCLUDE math.asm

	ifdef CPM	
*INCLUDE cpm.asm
	else
*INCLUDE trs80.asm
	endif
	
inputbuffer
inbuf 	DB 40  ; len
bytesrd DB 0		
chars	DS 40  ; space

curChar DB 0
curWordPtr DW 0
workingWord DS 15;
guessedChars DS 15 ; array of guessedChars
badGuessIndex DB 0 ;
welcomeTxt1 DB 'Hangman!',0h
welcomeTxt2 DB 'CP/M version by Evan C. Wright',0h
welcomeTxt3 DB 'Procrastination exercise for Retro Challenge, 2018',0h
alreadyUsedTxt DB 'You have already guessed ',0h
notInWordTxt DB ' is not in the word.',0h 
winTxt DB 'Congratulations!',0h 
promptText DB 'Enter a letter...',0h 
playAgainTxt DB 'Play again? (y/n)',0h 
pickingTxt DB 'Picking a word...',0h 
revealTxt DB 'The word was ',0h 
guessedTxt DB 'Bad guesses:',0h 
foundTxt DB 'Letter found',0h
doneTxt DB 'Done',0h 
loseTxt DB '***GULP***',0h 
guessedFlag DB 0 ; word already guessed
foundFlag DB 0
winFlag DB 0
top DB  ' --- ',0h
rope DB  '  | |',0h
head DB  '  O |',0h
headwin DB  ' \O/|  WOHOO!',0h
post DB     '    |',0h
onearms DB  ' -+ |',0h
botharms DB ' -+-|',0h
body DB     '  | |',0h
oneleg DB   ' /  |',0h
bothlegs DB ' / \|',0h
bottom DB  '===== ',0h
wordlist
*include words.asm
	END START