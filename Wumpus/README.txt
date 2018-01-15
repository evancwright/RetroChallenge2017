To build for TRS-80, open Wumpus.asm then comment out the line CPM EQU 1
Then save the file and run Z80asm -nh wumpus.asm
This will produce a CMD file you can run in an emulator or attach to a disk image using TRS-Tools

To build for CP/M, open Wumpus.asm then comment out the line TRS80 EQU 1
Save the file and run the command Z80asm -com wumpus.asm
You can then copy this into the A/0 folder under RunCPM or move it to the Altairduino using PCGET

