@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@//WELCOME TO HANGMAN, THE AUTHOR OF THE CODE IS PAVLO (pn00289) AND I HOPE THE CODE IS CLEAR AS TO WHAT IT DOES              @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@//THERE ARE SOME BUGS I WAS UNABLE TO TAKE CARE OF SUCH AS THE RESETLOOP OVERWRITTING THE WORD/UNDERSOCRES WITH INVALID INPUT@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@//THIS GAME WORKS AS LONG AS THE PLAYER DOES NOT TRY TO BREAK IT AND RESPECTS THE INSTRUCTIONS                               @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@//ENJOY!                                                                                                                     @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@

.extern printf
                                   @@@@@@REUSABLE FUNCTIONS/LABELS
reset:
	mov r2, #0		
	ldr r1, =word		@//Load into r1, word
	bl resetloop		@//Branch Link into resetloop to reset the word
	ldr r1, =underscores	@//Load underscores
	bl resetloop		@//Branch link to resetloop to reset the underscores
	b resetstate		@//Unconditional branch
resetloop:			@//Resets whatever is in r1
	ldrb r0, [r1]		@//Pointer pointing to 1st letter
	cmp r0, #0		@//Compares 1st letter to null
	bxeq lr			@//If it is equal then branch back 
	strb r2, [r1], #1	@//Store null into r1 follow by a post increment
	b resetloop		@//Unconditional branch loop
winningset:			@@@@//Setup Winning
	ldr r1, =word		@//Load word (r1)
	ldr r2, =underscores	@//Load underscored (r2)
winning:			@@@@//Checks if player won
	ldrb r3, [r1], #1	@//Pointer to word
	ldrb r4, [r2], #1	@//Pointer to underscores
	cmp r3, #0		@//Compare r3 with null
	beq winner		@//Branch if equals to winner
	cmp r3, r4		@//Compare r3 with r3
	bxne lr			@//If not equal branch back to where it was
	b winning		@//Unconditional branch loop
winner:				@//Winnning message and try again input
	ldr r0, =winningmessage @//Load winningmessage pt1
	bl printf
	ldr r0, =winningmessage2@//Load winningmessage pt2
	bl printf
	ldr r0, =word		@//Load word into r0
	bl printf
	ldr r0, =winningmessage3@//Load winningmessage pt3
	bl printf
	bl in			@//Ask for input
	bl inval		@//Validate input
	ldr r1, =input		@//Load input
	ldrb r2, [r1]		@//Load input into r2
	cmp r2, #'N'		@//Compare input to N
	beq exit		@//if equals branch to exit
	cmp r2, #'Y'		@//Compare input to Y
	b reset			@//Branch to reset anyways
numerror:
	push {lr} 		@//push link register
generatenum:
	bl rand 		@//rand number
	and r0, r0, #0xF	@///and operation to limit rand number between 0-15
	cmp r0, #10 		@///compare number (0-15) to 10
	bge generatenum 	@///if number is greater or equal to 10 generate another number
	pop {lr} 		@///pop link register
	push {r0} 		@///push random number
	bx lr 			@///go back to previous label
openfile:			@@@@@@@@/////Open the file and five it permissions
	ldr r0, =words 		@//load words.txt address into r0
	mov r1, #0
	mov r2, #644 		@//permissions 6(rw) 4(r) 4(r)
	mov r7, #5		@//Syscall to open
	svc 0			@//End syscall
	cmp r0, #-1		@//-1 equals to error
	beq error
readfile:			@@@@@@@@/////Read words inside file
	ldr r1, =buffer @load buffer into r1
	mov r2, #129		@//Load 129 null charachters into r2
	mov r7, #3		@//Syscall for read
	svc 0
closefile:			@@@@@@@@////Close file
	mov r7, #6		@//Syscall to close
	svc 0			@//End syscall
	bx lr			@//Branch back
error:				@@@@@@@@////File does not exist error
	ldr r0, =errormsg	@//Load errormsg
	bl printf		@//Print errormsg
	b exit
getword:			@@@@@@@@////Setting up registers with the textfile words and an empty word space
	pop {r0}		@//Restore r0 value
	ldr r1, =buffer		@//Loads buffer
	ldr r3, =word		@//Loads word
loopword:			@@@@@@@@////Gets to the word index and ''deletes'' the other words
	cmp r0, #0		@// cmp r0 to 0
	beq storeword		@// if equals branch to storeword
	ldrb r2, [r1]		@// load first charachter of buffer to r2
	cmp r2, #10		@// cmp r2 to new line
	subeq r0, #1		@// subtract if equals r0 by 1
	add r1, #1		@// add 1 to r1
	b loopword		@// loop branch
storeword:			@@@@@@@@////Stores the word
	ldrb r2, [r1]		@//load charachter which the r1 pointer is storing
	cmp r2, #10		@//compare that charachter to new line
	bxeq lr			@//if equals branch back to where it was
	strb r2, [r3]		@//else store r2 into r3 pointer(word)
	add r3, #1		@// increment r3(pointer)
	add r1, #1		@// increment r1(pointer)
	b storeword
underscore:			@@@@@@@////Dinamically changes the underscores
	ldrb r2, [r1]		@//Load first word letter into r2 (r1 is the pointer)
	cmp r2, #0		@//Compare r2 to null
	bxeq lr			@//if equals branch back
	strb R4, [R3]		@//else store r4, into underscores (r3)
	add R3, #1		@//increment pointer r3
	add r1, #1		@//increment pointer r1
	b underscore 
in:				@@@@@@@////Takes input
	push {lr}		@//Push link register
	MOV R0, #0		
	LDR R1, =input		@//Load input
	MOV R2, #19		@//Space 19
	MOV R7, #3		@//Syscall for read, to read input
	SVC 0			@//End syscall
	pop {lr}		@//Pop lr
	BX LR			@//Branch back to lr
inval:				@@@@@@@////Input validation
	ldr r1, =input		@//Load input
	ldrb r2, [r1]		@//Load into r2 charachter which r1 is pointing to
	ldrb r3, [r1, #1]!	@//Load into r3 second charachter
	cmp r3, #10		@//Compare r3 to new line
	bne invalid		@//If not newline invalid input
	cmp r2, #48		@//else compare r2 to '0'
	beq exit		@//if equals exit
	cmp r2, #65		@//Compare r2 to 'A'
	blt invalid		@//If less then invalid input
	cmp r2, #90		@//Compare r2 to 'Z'
	bxle lr			@//If less or equal branch back
	cmp r2, #97		@//Compare r2 to 'a'
	blt invalid		@//If less then invalid
	cmp r2, #123		@//Compare r2 to '{'
	bge invalid		@//If greater or equal invalid
	cmp r2, #97		@//Compare r2 to 'a'
	subge r2, #32		@//If greater or equal subtract r2 by 32, making letter capital (For reference use ascii table)
	subge r1, #1		@//If greater or equal Subtract r1(pointer) by 1
	strgeb r2, [r1]		@//Store converter letter into r1
	bxge lr			@//Branch back
invalid:			@@@@@//Print invalid
	LDR R0, =invalinp
	bl printf
	b errors
switchsetup: 			@@@@@///verifies correspondence of letters/input
	ldr r0, =word		@//loads word
	ldr r1, =underscores	@//loads underscores
	ldr r2, =input		@//loads input
	ldrb r2, [r2]		@//loads input into r2
	mov r4, #0		@//Move null into r4
switch:				@@@@//
	ldrb r3, [r0] 		@//first character of word
	cmp r3, #0		@//Compares r3 to null
	bxeq lr			@//if equal branch back
	cmp r3, r2		@//Compares r3 to r2
	streqb r2, [r1, r4]!	@//Store if equals r2 into r1(pointer) + r4(pre increment)
	moveq r4, #0		@//Moves if equals 0 into r4
	add r4, #1		@//Increment r4
	add r0, #1		@//Increment r0
	b switch		@//Branch Loop
setunder:			@//Setup equaling underscores and storing old underscores to check if person got a letter right
	ldr r0, =underscores	@//Load underscores
	ldr r1, =oldunder	@//Load oldundercores
setunder2:
	ldrb r2, [r0]		@//Load underscores pointer into r2
	add r0, #1		@//Increment r0
	cmp r2, #0		@//Compare r2 with null
	bxeq lr			@//If equals branch back
	strb r2, [r1]		@//Store r2 in r1
	add r1, #1		@//Increment r1
	b setunder2		@//Branch loop
equalunder:
	ldr r0, =underscores
	ldr r1, =oldunder
equalunder2:
	ldrb r2, [r0], #1	@//Load pointer underscores(post increment)
	ldrb r3, [r1], #1	@//Load pointer oldunderscores(post increment)
	cmp r2, #0		@//Compare r2, to null
	addeq r6, #1		@//Add if equals r6 by #1 which means person got a letter wrong
	beq errors		@//Branch to errors
	cmp r2, r3		@//Compare r2 to r3
	bxne lr			@//If not equal branch back
	b equalunder2		@//Else loop branch
checkiferrorset:		@@@@@//Setup for checking if used
	ldr r1, =input		@//Load input
	ldr r2, =misses		@//Load misses
	ldrb r3, [r2]		@//Load first charachter/pointer into r3
	ldrb r4, [r1]		@//''
	b checkifused
checkifused:			@@@@@//Checks wether the letter was already used
	cmp r3, #10		@//Compare r3 with new line
	beq checkiferror	@//If equals branch
	cmp r4, r3		@//Comapare r4 with r3
	beq alreadyused		@//If equals branch alreadyused
	ldrb r3, [r2], #1	@//Else load r3 into r2 and post increment r2
	b checkifused		@//Loop
checkiferror:			@@@@@//Setup to check if it is an error
	ldr r1, =input		@//Load input
	ldr r2, =misses		@//Load misses
	ldrb r4, [r1]		@//Load pointer of input into r4
checkiferrorloop:		@@@@@//Check if the letter inputed was an error
	ldrb r3, [r2]		@//Load r2 pointer into r3
	cmp r3, #10		@//Compare r3 with new line
	addne r2, #1		@//Add if not equals r2 by 1
	bne checkiferrorloop	@//Branch if not equals to checkiferrorloop
	strb r4, [r2], #1	@//Else store r4 into r2 and increment r2
	mov r4, #10		@//Move new line into r4
	strb r4, [r2]		@//Store r4 into r2 pointer
	bx lr			@//Branch back
alreadyused:			@@@@@//Prints out already used letter message
	ldr r0, =alreadyusedletter @//Load alreadyused
	bl printf
	sub r6, #1		@//Mantain mistakes by subtracting r6 by 1
	b errorsf		@//Branch errors f (Avoid infinite loop)
errors:
	bl checkiferrorset
errorsf:			@@@@@//Determins hangman phase (Compares r6 which is mistakes and branches to the correct phase)
	cmp r6, #0
	beq first
	cmp r6, #1
	beq fsterror
	cmp r6, #2
	beq snderror
	cmp r6, #3
	beq trderror		@@@@@@@@@COMPARISONS OF R6(MISTAKES)
	cmp r6, #4
	beq ftherror
	cmp r6, #5
	beq fitherror
	cmp r6, #6
	beq stherror
tryagain:			@@@@//Asks player if he wants to try again
	ldr r0, =tryagaintext
	bl printf
	ldr r0, =word
	bl printf
	ldr r0, =tryagaintext2
	bl printf
	bl in			@//Branch to in (Ask for input)
	bl inval		@//Check if input is valid
	ldr r0, =input		@//Load input
	ldrb r0, [r0]		@//Load input pointer
	cmp r0, #89		@//Compare pointer to Y
	beq reset		@//If equals reset
	cmp r0, #78		@//Comapre pointer to N
	beq exit		@//If equals exit
	b tryagain		@//Loop
fsterror:
        LDR R0, =tline
        BL printf
        LDR R0, =underscores 	@//Displays hidden charachters
        BL printf
        LDR R0, =Aline
        BL printf
        LDR R0, =Firsterror
        BL printf
        LDR R0, =misses 	@//Displays misses
        BL printf
	LDR R0, =Cline
	BL printf
        LDR R0, =Dline			@@@DISPLAYS HANGMAN CORRESPONDING TO 1ST ERROR
        BL printf
        LDR R0, =Eline
        BL printf
        LDR R0, =Fline
        BL printf
        LDR R0, =Gline
        BL printf
        LDR R0, =Hline
        BL printf
        LDR R0, =firstIn
        BL printf
        BL in			@//Asks for input
	BL inval		@//Checks input
	BL setunder		@//Sets underscores
	BL switchsetup		@//Changes underscores
	BL equalunder		@//Equals underscores to old underscores
	BL winningset		@//Checks if player wins
	b fsterror
snderror:
        LDR R0, =tline
        BL printf
        LDR R0, =underscores 	@//Displays hidden charachters
        BL printf
        LDR R0, =Aline
        BL printf
        LDR R0, =Firsterror
        BL printf
        LDR R0, =misses 	@//Displays misses
        BL printf
        LDR R0, =Seconderror
        BL printf
        LDR R0, =Seconderrort
        BL printf
        LDR R0, =Eline			@@@@PRINTS HANGMAN CORRESPONDING TO 2ND ERROR
        BL printf
        LDR R0, =Fline
        BL printf
        LDR R0, =Gline
        BL printf
        LDR R0, =Hline
        BL printf
        LDR R0, =firstIn
        BL printf
        BL in			@//SPECIFIED ABOVE
        BL inval
        BL setunder
        BL switchsetup
        BL equalunder
	BL winningset
	b snderror
trderror:
        LDR R0, =tline
        BL printf
        LDR R0, =underscores 	@//Displays hidden charachters
        BL printf
        LDR R0, =Aline
        BL printf
        LDR R0, =Firsterror
        BL printf
        LDR R0, =misses 	@//Displays misses
        BL printf
        LDR R0, =Thirderror
        BL printf
        LDR R0, =Seconderrort
        BL printf
        LDR R0, =Eline			@@@PRINTS HANGMAN CORRESPONDING TO 3RD ERROR
        BL printf
        LDR R0, =Fline
        BL printf
        LDR R0, =Gline
        BL printf
        LDR R0, =Hline
        BL printf
        LDR R0, =firstIn
        BL printf
        BL in			@//SPECIFIED ABOVE
        BL inval
        BL setunder
        BL switchsetup
        BL equalunder
	BL winningset
	b trderror
ftherror:
        LDR R0, =tline
        BL printf
        LDR R0, =underscores 	@//Displays hidden charachters
        BL printf
        LDR R0, =Aline
        BL printf
        LDR R0, =Firsterror
        BL printf
        LDR R0, =misses 	@//Displays misses
        BL printf
        LDR R0, =Fourtherror
        BL printf
        LDR R0, =Seconderrort
        BL printf
        LDR R0, =Eline			@@@4TH ERROR
        BL printf
        LDR R0, =Fline
        BL printf
        LDR R0, =Gline
        BL printf
        LDR R0, =Hline
        BL printf
        LDR R0, =firstIn
        BL printf
        BL in
        BL inval
        BL setunder
        BL switchsetup
        BL equalunder
	BL winningset
	b ftherror
fitherror:
        LDR R0, =tline
        BL printf
        LDR R0, =underscores 	@//Displays hidden charachters
        BL printf
        LDR R0, =Aline
        BL printf
        LDR R0, =Firsterror
        BL printf
        LDR R0, =misses 	@//Displays misses
        BL printf
        LDR R0, =Fourtherror
        BL printf
        LDR R0, =Torso
        BL printf
        LDR R0, =Fiftherror		@@@5TH ERROR
        BL printf
        LDR R0, =Fline
        BL printf
        LDR R0, =Gline
        BL printf
        LDR R0, =Hline
        BL printf
        LDR R0, =firstIn
        BL printf
        BL in
        BL inval
        BL setunder
        BL switchsetup
        BL equalunder
	BL winningset
	b fitherror
stherror:
        LDR R0, =tline
        BL printf
        LDR R0, =underscores 	@//Displays hidden charachters
        BL printf
        LDR R0, =Aline
        BL printf
        LDR R0, =Firsterror
        BL printf
        LDR R0, =misses 	@//Displays misses
        BL printf
        LDR R0, =Fourtherror
        BL printf
        LDR R0, =Torso			@@@6TH ERROR
        BL printf
        LDR R0, =Sixtherror
        BL printf
        LDR R0, =Fline
        BL printf
        LDR R0, =Gline
        BL printf
        LDR R0, =Hline
        BL printf
        b tryagain


				@@@@@@@@@@@@@@@MAIN FUNCTION
.global main

main:
	ldr R0, =welcome 		@//Moving welcome address into r1
	BL printf
	ldr R0, =inputinstruc 		@//input reciever
	BL printf
	ldr r0, =misses			@//Load into r0 misses
	mov r2, #10			@//Load new line into r2
	strb r2, [r0]			@//Store byte r2 into r0
	BL openfile			@//OpenFile
resetstate:
	MOV R6, #0 			@//Reset lives
	mov r0, #0			@//Move 0 into r0
        bl time				@//Call upon time function
        bl srand			@//Generate random seed
	BL numerror			@//Generate random number
	BL getword			@//Uses number to choose word
	LDR R1, =word			@//Assign word memory into r1
	LDR R3, =underscores		@//Assign underscores space into r3
	MOV R4, #'_'			@//Assign underscore into r4
	BL underscore			@//Save as many underscores as the length of the word
first:					@////First stage of the game
	LDR R0, =tline			@///Load into r0 tline memory address
	BL printf			@///Print function
	LDR R0, =underscores 		@///Displays hidden charachters
	BL printf			@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
	LDR R0, =Aline			@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
	BL printf			@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
	LDR R0, =Bline			@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
	BL printf			@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
	LDR R0, =firstnewline		@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
	BL printf			@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
	LDR R0, =Dline			@@@@@//Printing hangman
	BL printf			@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
	LDR R0, =Eline			@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
	BL printf			@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
	LDR R0, =Fline			@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
	BL printf			@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
	LDR R0, =Gline			@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
	BL printf			@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
	LDR R0, =Hline			@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
	BL printf			@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
	LDR R0, =firstIn		@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
	BL printf			@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
	BL in				@//Calling upon the in label
	BL inval			@//Calling upon the inval label which validates the input
	BL setunder			@//Calling upon setunder
	BL switchsetup			@//Calling upon switchsetup
	BL equalunder			@//Calling upon equalunder
	BL winningset			@//Calling upon winningset
	b first				@//Unconditional Branch
exit:					@///Exit system call
	mov R0, #0
	mov R7, #1
	svc #0
					
					@@@@@@@@@DATA SECTION
.data
.balign 4
welcome: .asciz "////Welcome to Hangman, game created by Pavlo, if you wish to stop playing type 0./////\n"
newline: .asciz "\n"
instructions: .asciz "//////Enter next charachter (A-Z), or 0 (zero) to exit:"
inputinstruc: .asciz "\n"
chosenword: .asciz "______"
tline: .asciz "   |----|   Word: "
Aline: .asciz "\n   |    |\n"
Bline: .asciz "        |   Misses: "
Cline: .asciz "        |\n"
firstnewline: .asciz "\n        |\n"
Dline: .asciz "        |\n"
Eline: .asciz "        |\n"
Fline: .asciz "        |\n"						@@@ASCII ART@@@
Gline: .asciz "        |\n"
Hline: .asciz "--------\n"
Firsterror: .asciz "   O    |   Misses:  "
Seconderror: .asciz "   |    |\n"
Seconderrort: .asciz "   |    |\n"
Thirderror: .asciz "  \\|    |\n"
Fourtherror: .asciz "  \\|/   |\n"
Fiftherror: .asciz "  /     |\n"
Sixtherror: .asciz "  / \\   |\n"
Torso: .asciz "   |    |\n" 
firstIn: .asciz "/////Guess a letter or enter 0 to exit: \n"
wrongTry:  .asciz "Wrong! Guess another letter or type 0 to leave: \n"
correctTry: .asciz "Correct! Guess another letter or type 0 to leave: "
words: .asciz "words.txt"
errormsg: .asciz "////File does not exist.////\n"
invalinp: .asciz "\n\n////////INVALID CHARACHTER!///////\n\n"
tryagaintext: .asciz "/////////YOU LOST! DO YOU WANT TO PLAY AGAIN?(Y) for yes (N) for no////////\n ////THE WORD WAS: "
tryagaintext2: .asciz "/////\n"
alreadyusedletter: .asciz "\n/////You already used this letter!////\n \n"
winningmessage: .asciz "/////YOU WON! Congratulations!///\n"
winningmessage2: .asciz "/////If you wish to play again enter (Y) else type (N)/////// \n //////The word was: "
winningmessage3: .asciz "/////\n"

				@@@@@@@@@BSS SECTION
.bss
buffer: .space 130
word: .space 20
underscores: .space 20
input: .space 20
oldunder: .space 20
misses: .space 26
