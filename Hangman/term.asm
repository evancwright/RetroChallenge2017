;term.asm
ESC EQU 1Bh


term_cls
	ld hl,ttyhome
	call printstr	
	ld hl,ttycls
	call printstr
	ret

ttyprmpt DB  'Are you playing in a terminal? (y/n)',0
cpmtty	DB 1 ; whether player is in a terminal or not

showcrsr DB ESC,'[?25h',0
hidecrsr DB ESC,'[?25l',0
ttycls 	DB ESC,'[2J',0
ttyhome DB ESC,'[;H',0
