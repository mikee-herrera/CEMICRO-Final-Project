PROGRAM	EQU 	$0000 	; Code must start at $0000 for bootloader's forced jump
PORTB 	EQU 	$1004 	
DDRB 	EQU 	$1005 	

	ORG 	PROGRAM
	
	; Set Port B as an output port
	LDAB 	#$FF 	; Load accumulator B with all ones ($FF)
	STAB 	DDRB 	; Store FF into DDRB at $1005 (Ensures output mode is active)
	
	; Initialize the counter/output value to 0
	CLRB 		; Clear B accumulator (B = 0)
	STAB 	PORTB 	; Output 0 to Port B at $1004 (all LEDs OFF initially)


	
FOREVER LDX 	#$FFFF 	; DELAY: Load a large value for a slower count cycle
AGAIN 	DEX		; Decrement X
	BNE 	AGAIN	; Loop until X = 0
	
        NOP             ; Use NOPs to consume a few extra cycles for delay
        NOP
        NOP
        NOP
        
	; Check if the count has exceeded 25 (decimal)
	CMPB 	#23	
	BLE 	INCREMENT 

	; If B > 25, reset the counter
RESET_COUNTER CLRB 		 
	BRA 	OUTPUT	; Skip increment, go straight to output

INCREMENT INCB 		; Increment the B accumulator (B = B + 1)

OUTPUT 	NOP
        NOP
        NOP
        NOP
        NOP
        NOP
        NOP
        NOP
        STAB 	PORTB 	

	BRA 	FOREVER	
	
	END			