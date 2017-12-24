del hello.com
z80asm -com wumpus8080.asm
move wumpus8080.com wumpus.com
echo "copying to CPM dir"
copy wumpus.com ..\Emulator\B\0

z80asm  -nh wumpus8080.asm
move wumpus8080.cmd wumpus.cmd
