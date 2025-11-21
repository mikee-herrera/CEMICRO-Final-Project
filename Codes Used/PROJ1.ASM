REGBAS  EQU     $1000       ; Register Base Address for I/O
PORTA   EQU     $00         
PORTB   EQU     $04         
PORTC   EQU     $03         
DDRC    EQU     $07         

BAUD    EQU     $2B         ; SCI Baud Register
SCCR2   EQU     $2D         ; SCI Control Register 2 (Tx/Rx Enable)
SCSR    EQU     $2E         ; SCI Status Register (TDRE flag)
SCDR    EQU     $2F         ; SCI Data Register (Data In/Out)

HPRIO   EQU     $3C         ; Offset for HPRIO (Mode Select)

STACK   EQU     $00FF       ; Top of Internal RAM

PROGRAM EQU     $0000       ; Code must start at $0000 for bootloader

        ORG     PROGRAM     ; Start program execution

START:
        LDS     #STACK      ; 1. Initialize Stack Pointer

        LDX     #REGBAS     ; 2. Load X with $1000 (I/O Register Base)

        LDAA    #$C0        
        STAA    HPRIO,X     ; Write to $103C ($103C)

        LDAA    #$00        
        STAA    DDRC,X  

        ; Set bits 5 (CE) and 6 (OE) HIGH (Inactive state)
        LDAA    PORTA,X     ; Read current PORTA
        ORAA    #%01100000  ; Set CE (bit 5) and OE (bit 6) HIGH
        STAA    PORTA,X     ; Write to $1000

        LDAA    #$30        
        STAA    BAUD,X      
        LDAA    #$0C        
        STAA    SCCR2,X     

        JSR     LONG_DELAY ;delay that allows PC to switch to 9600 baud
        
        ; counters
        CLRA                
        CLRB                
        LDY     #25         

READ_LOOP:
        
        
        PSHA                ; Save Address (A) to Stack
        PULB                ; Pop A's value into B
        STAB    PORTB,X     ; Output Low Address to $1004 (PORTB)
        
        LDAA    PORTA,X     ; Read current PORTA
        ANDA    #%11100000  ; Clear bits A0-A4
        STAA    PORTA,X     ; Write back (A8-A12 are now 0)

        ANDA    #%10011111  ; Clear Bits 5 & 6 (now CE & OE are active low)
        STAA    PORTA,X     

        NOP                 ; Small Delay for CE/OE settling
        JSR     SHORT_DELAY ; T_ACC Access Time Delay 
        
        PSHA                ; Save (Address-controlling) PORTA value to Stack
        LDAA    PORTC,X     ; A now holds the DATA from EPROM ($1003)
        
        JSR     SEND_SERIAL ; Transmit Data in Accumulator A

        PULA                ; Restore PORTA value (A) from Stack
        
        ORAA    #%01100000  ; Set Bits 5 & 6 HIGH (CE & OE inactive)
        STAA    PORTA,X

        INCA                ; Increment Address (A = A + 1)
        DEY                 ; Decrement Byte Counter (Y = Y - 1)
        BNE     READ_LOOP   ; Loop if Y != 0

        SWI                 ; Stop execution

SEND_SERIAL:
        BRCLR   SCSR,X #$80 SEND_SERIAL ; Wait until TDRE (Transmit Data Register Empty) is 1
        STAA    SCDR,X                  ; Send Data in A to $102F
        RTS

SHORT_DELAY:
        NOP
        NOP
        RTS
        
LONG_DELAY:
        PSHY                
        PSHX                
        
        LDY     #$0010      ; Outer Loop Counter (16 decimal)

DELAY_OUTER:
        LDX     #$FFFF      ; Inner Loop Counter (65535 decimal)

DELAY_INNER:
        DEX
        BNE     DELAY_INNER ; Loop until X is 0
        DEY
        BNE     DELAY_OUTER ; Loop until Y is 0
        
        PULX                ; Restore X (Base Address $1000)
        PULY                ; Restore Y
        RTS
        
        END