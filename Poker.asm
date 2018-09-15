INCLUDE Irvine32.inc
;include the irvine library

;macro to output onto console
mWrite MACRO text 
     LOCAL String
     .data
          string BYTE text, 0
     .code
          push edx
          mov edx, OFFSET String
          Call WriteString
          pop edx
ENDM

;card structure to hold the card together
CARD STRUCT
	SUITE DWORD ? ;diamonds, clubs, hearts, spade
	FACE DWORD ? ;2-10, J Q K A
	theVALUE DWORD ? ;1-11
CARD ENDS

PLAYER STRUCT
	TheirCards CARD 10 DUP(<?,?,?>) ;maximum of 10 cards allocated
	; 2 cards of  default constructors

PLAYER ENDS

.data
	RandomCard Card <?,?,?> ;stores random card
	cardSuits DWORD 3 ; 0-3 number of card suites
	cardNumber DWORD 12 ;number of different face values
	Players PLAYER <> ;number of players ONLY 1

	LastIndexPlayer1 DWORD 0 ;keeps track of last index of the cards that player holds
	numberofCardsPlayer1 DWORD 0 ;keeps track of number of cards the player has
	theSum DWORD 0 ;calculates the sum of the cards that the player currently has

.code


;;creates a Random Card and stores it into the RandomCard variable
createCard proc

	;output will be in RandomCard

	;push registers to stack to save their values
	push eax
	push ebx
L1:

	mov eax, cardNumber  ;random range on eax
	Call RandomRange ;giving a random FACE of eax
	add eax, 2 ;add one to take into account for 2-14
	mov ebx,eax ; ebx = 0
	mov eax, cardSuits ; range eax to 0-3
	call RandomRange ; eax = radom suite
	add eax,1 ;eax = eax + 1

	mov RandomCard.SUITE, eax ; suite = eax
	mov RandomCard.FACE, ebx ; face value = ebx
	call CreateValue ;creates the value of the used suite and face

	call checkExistence ;checks if the random card exists

	cmp eax, 0 ;does exist
	JE L1 ;generate random age
		
;data is stored in RandomCard
;restore registers
pop ebx 
pop eax
ret
createCard endp

;creates the value
CreateValue proc
;uses eax

	push eax ;store eax
	mov eax, RandomCard.Face ;eax = face value
	cmp eax,10 ;compare eax with 10
	JG JQKA ;if greater than it's J Q K or A
	mov RandomCard.TheValue, eax ;give it regular face value
	JMP skip ;end function
	JQKA:
		cmp eax, 14 ;compares eax with 13
		JE anAce ; if 14 then the card is an A
		mov eax, 10 ;eax = 10
		mov RandomCard.TheValue, eax ;value = 10
		JMP skip ;exit function
	anAce:
		mov eax, 11 ;eax = 11
		mov RandomCard.TheValue, eax ;value = 11

	skip: 

	pop eax ;restore register

ret
CreateValue endp

checkExistence proc

	;save registers
	push esi
	push eax
	push ebx
	push ecx
	push edx

	mov esi, offset Players ;esi = Players address
	mov ecx, LastIndexPlayer1 ;ecx = the last player index
	mov edx, 0 ;edx = 0
	mov ebx, 0 ;ebx = 0

	cmp ecx, 0 ;compare ecx with 0
	JMP Empty ;if it's 0 then the player's hand is empty

	L1:
		mov eax, (Card PTR[esi]).SUITE ;eax = cards suite
		cmp Players[ebx].TheirCards[edx].SUITE, eax ;compare this particular player and the card suite
		JNE skip ;already different
		mov eax, (Card PTR[esi]).FACE ;eax = cards face
		cmp Players[ebx].TheirCards[edx].FACE, eax ;compare this particular player and the card face
		JNE skip ; if not equal then they are different
		mov eax, (Card PTR[esi]).theValue ;eax = cards theValue
		cmp Players[ebx].TheirCards[edx].theValue, eax ;compare this particular player and the card theValue
		JNE skip ;already not equal

		mov eax, 0 ;eax =0
		JMP outofLoop ;get out of the loop

		add edx, TYPE CARD ;add edx by the type card to increment to next card
		
		mov eax, (Card PTR[esi]).SUITE ;eax = cards suite
		cmp Players[ebx].TheirCards[edx].SUITE, eax ;compare this particular player and the card suite
		JNE skip ;already different
		mov eax, (Card PTR[esi]).FACE ;eax = cards face
		cmp Players[ebx].TheirCards[edx].FACE, eax ;compare this particular player and the card face
		JNE skip ; if not equal then they are different
		mov eax, (Card PTR[esi]).theValue ;eax = cards theValue
		cmp Players[ebx].TheirCards[edx].theValue, eax ;compare this particular player and the card theValue
		JNE skip ;already not equal
		
		mov eax, 0 ;eax =0
		JMP outofLoop ;get out of the loop

		skip:
	
		add ebx, TYPE Player ;go to next player
		mov edx, 0 ;reset edx

	Loop L1

	Empty:
		mov eax,1 ;eax = 1

	outofLoop:


	;restore register
	pop edx
	pop ecx
	pop ebx
	pop eax
	pop esi

ret
checkExistence endp

DrawCard proc
	
	
	call CreateCard ;creates a card and puts it in RandomCard variable
	add numberOfCardsPlayer1, 1 ;increment the players number of cards

	mov edx, 0 ;reset edx
	mov ecx, LastIndexPlayer1 ;ecx = last card 
	cmp ecx, 10 ; compare if ecx is greater than or equal to 10
	JGE full ; if so it is full and exist
	inc ecx ;incremenet ecx
	L2:
		cmp ecx, 1 ;compare ecx with 1
		JE skip ;if so exit loop
		add edx, TYPE CARD ;add ecx to TYPE card
	loop L2
	skip:

	mov ecx, 0 ; ecx =0
	mov eax, RandomCard.SUITE ;this would be the first card
	mov Players[ebx].TheirCards[edx].SUITE, eax ;last index of players card is equal to random card suite
	mov eax, RandomCard.FACE ;eax = random card's face value
	mov Players[ebx].TheirCards[edx].FACE, eax ; ;last index of players card is equal to random card face value
	mov eax, RandomCard.theValue ;eax = random card's the value
	mov Players[ebx].TheirCards[edx].theValue, eax  ;last index of players card is equal to random card the value

	mov ecx, LastIndexPlayer1 ;ecx = last index
	inc ecx	;increment ecx
	mov LastIndexPlayer1, ecx ; change last card

	JMP gotoexit ;go to exit

	full:
		mWrite "FULL"
		sub numberOfCardsPlayer1, 1 ;subtract number of cards
		call Crlf
		call Crlf

	gotoexit:

ret
DrawCard endp

PrintCard proc
;Printcards calls -> print card and changes address

push eax
; card should be in ESI
; mov esi, the card
mov eax, (CARD PTR[esi]).SUITE
 cmp eax, 1 ;compare eax = 1
 JE diamond ; is so it's diamond
 cmp eax, 2 ;compare eax = 2
 JE club ; is so it's club
 cmp eax, 3 ;compare eax = 3
 JE heart ; is so it's heart
 cmp eax, 4 ;compare eax = 4
 JE spade ; is so it's spade
 
;print diamond
diamond:
	mWrite "Diamond" 
	JMP skip1
	
;print club
club:
	mWrite "Clubs"
	JMP skip1
	
;print heart
heart:
	mWrite "Heart"
	JMP skip1
	
;print spade
spade:
	mWrite "Spade"
	JMP skip1
skip1:

;compares the values of the FACE
;if its 10 or less -> just print the value
;if it's more than print J Q K or A
mWrite " "
mov eax, (CARD PTR[esi]).FACE
cmp eax, 10
JLE standard
cmp eax, 11
JE Jack
cmp eax, 12
JE Queen
cmp eax, 13
JE King
cmp eax, 14
JE Ace
Jack:
mWrite "J"
JMP skip2
Queen:
mWrite "Q"
JMP skip2
King:
mWrite "K"
JMP skip2
Ace:
mWrite "A"
JMP skip2
standard:
call WriteInt
skip2:

pop eax
ret
PrintCard endp

PrintAll proc
	
	push esi ;push esi
	push eax ; push eax
	mov esi, offset Players ;esi = Players adress
	mov eax, TYPE Card ;eax = bits of card
	
	mov ecx, numberofCardsPlayer1 ;ecx = number of cards player holds
	dec ecx ;dec ecx
	call PrintCard ;print the card
	call crlf
	L3:
		add esi, eax ;move to next card
		call PrintCard ;print that card
		call crlf ;space

	loop L3

	;restore registers
	pop eax 
	pop esi
ret
PrintAll endp

CalcSum proc

	;push registers
	push esi
	push eax
	push ecx
	push ebx
	

	mov esi, offset Players ;address to players cards
	mov eax, TYPE Card ;to increment in the loop
	mov ecx, numberofCardsPlayer1 ;number of cards the player currently has
	mov ebx, 0 ; sum value of all the cards
	;there will always be more than 1 card
	L3:
	
		add ebx, (Card PTR[esi]).theValue ;add the value to the sum in the current card
		add esi, eax ; go to next card

	loop L3



	;next is to check for aces if the value is over 21 and change value from 11 to 1
	mov esi, offset Players 
	MOV ecx, numberofCardsPlayer1

	L4:
		cmp ebx, 21 ;if sum is less than 21 then get out
		JLE skip2 ;getting out
		cmp (Card PTR[esi]).theValue, 11 ;if card is an ace
		JNE skip ;if not an ace then skip
		sub ebx, 10 ;subtract sum by 10

		skip:
		add esi, eax ;go to next card
		

	loop L4 ;loop

	skip2: 

	;prints sum
	mov eax, ebx
	mWrite "sum: "
	call writeint
	call crlf
	call crlf

	mov theSum, ebx ;store sum into variable for outside use
	;restore registers
	pop ebx
	pop ecx
	pop eax
	pop esi
ret
CalcSum endp

CheckBust proc
; uses edx to check whether or not
mov eax, 10 ;eax = 10
mov edx, 0 ;edx = 0
cmp theSum , 21 ;checks if the sum is greater than 21
JG bust ;if so then busted! yo
JMP skip ;skip
bust: 
mov eax, 1 ;returns 1 outside of function for outside use
mWrite "BUST" ;write to console to indicate
skip:	

ret
CheckBust endp

DealCards proc

;;all this does is set the player by drawing 2 cards
	mov ecx, 1  ;resets appropriate value
	mov ebx, 0 ;index of the Players
	mov edx, LastIndexPlayer1 ;resets appropriate value
	call DrawCard
	call DrawCard
	ret
DealCards endp

resetGame proc

	mov LastIndexPlayer1, 0 ;resets index of last card
	mov numberofCardsPlayer1, 0 ;resets hand of player

ret
resetGame endp

gamingSequence proc
push eax
;assuming cards are dealt
;prompt game
mWrite "==============================BlackJack======================================"
call crlf
call crlf
start:
call resetGame ;reset player hands
mov eax, 3 ;give arbitrary value
call DealCards ;give player cards

gameLoop:

;print out the hand that the player currently has
mWrite "Hand: "
call crlf
call crlf
call PrintAll
call CalcSum ;calculates the sum
call CheckBust ;checks if the sum is a bust
call crlf
call crlf
cmp eax, 1 ;checks if bust
JE theEnd ;if it's bust go to play again option
call crlf
call crlf

;request for input from the user
request:
mWrite "Hit(1), Fold(2), Quit(3) " ;the 3 choices
call crlf
call crlf

mWrite ": "
call ReadDec

cmp eax, 1 ;for hittings
JE draw
CMP eax, 2 ;for folding
JE fold
CMP eax, 3 ;for quitting
je quit
JMP invalid ;for invalid options
draw: 
call DrawCard ;when hit is called, draws card
jmp gameLoop
fold: ;when fold is called, go to end game option
jmp theEnd

invalid: ;when none is called, request again for an option
mWrite "Invalid input"
call crlf
call crlf
jmp request

;end game option
theEnd:
	mWrite "Again(1) or no(2): "
	call ReadInt ;get input
	cmp eax, 1 ;if eax =1 -> start again
	JE start
quit:
;exit out of game loop
ret
gamingSequence endp

main proc
	call Randomize ;seed for randomization
	call gamingSequence ;start game loop

invoke ExitProcess, 0 
main endp
End main
;interaction
;comments