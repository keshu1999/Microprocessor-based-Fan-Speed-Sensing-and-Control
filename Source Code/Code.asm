.MODEL TINY
.DATA

		TABLE_KEYPAD      DW  0EEH, 0EDH, 0EBH, 0E7H, 0DEH, 0DDH, 0DBH, 0D7H, 0BEH, 0BDH, 0BBH, 0B7H, 7EH, 7DH, 7BH, 77H
							;0		1	2		3	4		5	6		7	8		9	A	  START STOP UP	  DOWN  AUTO
		TABLE_DISPLAY     DB  3FH, 06H, 5BH, 4FH, 66H, 6DH, 7DH, 27H, 7FH, 6FH, 77H
							   ;0   1     2    3    4    5    6    7    8    9    A
		SPEED       DW  00H
		STARTED     DW  00H
		AUTO_S      DW  03H
		SET_TIME    DW  00H
		FLAG_AUTO   DW  00H

		PORTA1   EQU     00H 
		PORTB1   EQU     02H
		PORTC1   EQU     04H
		CREG1    EQU     06H
		PORTA2   EQU     08H 
		PORTB2   EQU     0AH
		PORTC2   EQU     0CH
		CREG2    EQU     0EH

.CODE
.STARTUP
		;INITIALIZING THE PORTS OF 8255A
		MOV     AL, 88H
		OUT     CREG1, AL
		OUT 	CREG2, AL
	
A0: 	MOV     AL, 00H
		OUT     PORTC1, AL

A1: 	IN      AL, PORTC1
		AND     AL, 0F0H
		CMP     AL, 0F0H    ;CHECK FOR KEY RELEASE
		JNZ     A1
		
		CALL    DELAY20 	  
		
		MOV     AL, 00H
		OUT     PORTC1, AL
A2: 	IN      AL, PORTC1
		AND     AL, 0F0H
		CMP     AL, 0F0H
		JZ      A2
		
		CALL    DELAY20 	
    
		;VALIDITY OF KEY PRESS
		MOV     AL, 00H
		OUT     PORTC1, AL
		IN      AL, PORTC1
		AND     AL, 0F0H
		CMP     AL, 0F0H
		JZ      A2
		
		;KEY PRESS COLUMN 1
		MOV     AL, 0EH
		MOV     BL, AL
		OUT     PORTC1, AL
		IN      AL, PORTC1
		AND     AL, 0F0H
		CMP     AL, 0F0H
		JNZ     A3
		
		;PRESS COLUMN 2
		MOV     AL, 0DH
		MOV     BL, AL
		OUT     PORTC1, AL
		IN      AL, PORTC1
		AND     AL, 0F0H
		CMP     AL, 0F0H
		JNZ     A3
		
		;KEY PRESS COLUMN 3
		MOV     AL, 0BH
		MOV     BL, AL
		OUT     PORTC1, AL
		IN      AL, PORTC1
		AND     AL, 0F0H
		CMP     AL, 0F0H
		JNZ     A3
		
		;KEY PRESS COLUMN 4
		MOV     AL, 07H
		MOV     BL, AL
		OUT     PORTC1, AL
		IN      AL, PORTC1
		AND     AL, 0F0H
		CMP     AL, 0F0H
		JZ      A2
		
		;DECODE KEY
A3: 	OR      AL, BL
		MOV     CX, 0FH
		MOV     DI, 00H
		LEA     DI, TABLE_KEYPAD
		
A4: 	CMP     AL, [DI]
		JZ      A5
		INC     DI
		LOOP    A4
    
		;MOTOR STARTED CHECKS
A5: 	CMP     STARTED, 01H			;IF STARTED IS 1 THEN JUMP TO AUTO
										;AUTO GIVEN HIGHER PRIORITY THAN START
		JZ     AUTO
		CMP     AL, 0B7H 				;BUTTON ENCODING FOR START
		JZ      START
		JMP     A0
		
	
START:  CALL	 SFAN
        JMP 	A0
    
AUTO:   CMP 	AL, 0B7H
        JZ  	A0
        CMP     FLAG_AUTO, 01H
        JZ      TIME_SET				;IF FLAG_AUTO IS ALREADY 1 THEN WE ASK FOR TIME FOR WHICH THE FAN SHOULD BE KEPT ON
        CMP     AL, 77H					;COMPARING IF AL IS AUTO
        JNZ     CHECKSPD				;IF AL IS NOT AUTO THEN WE CHECK THE SPEED
        MOV     FLAG_AUTO, 01H			;IF AL IS AUTO THEN WE SET FLAG_AUTO TO 1
        JMP     A0						;WE THEN JUMP TO A0 TO TAKE FURTHER INPUT

TIME_1: MOV     SET_TIME, 01H
		CALL    TIME
		JMP 	TIME_0

TIME_2: MOV     SET_TIME, 02H
		CALL    TIME
		JMP 	TIME_0
			
TIME_3: MOV     SET_TIME, 03H
		CALL    TIME
		JMP 	TIME_0
    
TIME_4: MOV     SET_TIME, 04H
		CALL    TIME
		JMP 	TIME_0
    
TIME_5: MOV     SET_TIME, 05H
		CALL    TIME
		JMP 	TIME_0
    
TIME_6: MOV     SET_TIME, 06H
		CALL    TIME
		JMP 	TIME_0
    
TIME_7: MOV     SET_TIME, 07H
		CALL    TIME
		JMP 	TIME_0
    
TIME_8: MOV     SET_TIME, 08H
		CALL    TIME
		JMP 	TIME_0
    
TIME_9: MOV     SET_TIME, 09H
		CALL    TIME
		JMP 	TIME_0
    
TIME_10:MOV     SET_TIME, 0AH
		CALL    TIME
		JMP 	TIME_0		
		
TIME_SET: CMP     AL, 0EEH ; CHECKS TIME
		JZ		TIME_0				
		
		CMP     AL, 0EDH
		JZ      TIME_1
		
		CMP     AL, 0EBH
		JZ      TIME_2
		
		CMP     AL, 0E7H
		JZ      TIME_3
		
		CMP     AL, 0DEH
		JZ      TIME_4
		
		CMP     AL, 0DDH
		JZ      TIME_5
		
		CMP     AL, 0DBH
		JZ      TIME_6
		
		CMP     AL, 0D7H
		JZ      TIME_7
		
		CMP     AL, 0BEH
		JZ      TIME_8
		
		CMP     AL, 0BDH
		JZ      TIME_9
		
		CMP     AL, 0BBH
		JZ      TIME_10
		JMP     A0
    
;SETTING THE SPEED.
SPEEDSET_0:	MOV		SPEED, 00H
			CALL 	STOP
			MOV		AL, 3FH
			NOT		AL
			OUT		PORTB1, AL
			JMP		A0
	
SPEEDSET_1: MOV     SPEED, 01H
			CALL    SPEEDSET
			MOV     AL, [BX + 01H]
			NOT		AL
			OUT     PORTB1, AL
			JMP     A0
    
SPEEDSET_2: MOV     SPEED, 02H
			CALL    SPEEDSET
			MOV     AL, [BX + 02H]
			NOT		AL
			OUT     PORTB1, AL
			JMP     A0
    
SPEEDSET_3: MOV     SPEED, 03H
			CALL    SPEEDSET
			MOV     AL, [BX + 03H]
			NOT		AL
			OUT     PORTB1, AL
			JMP     A0

SPEEDSET_4: MOV     SPEED, 04H
			CALL    SPEEDSET
			MOV     AL, [BX + 04H]
			NOT		AL
			OUT     PORTB1, AL
			JMP     A0
    
SPEEDSET_5: MOV     SPEED, 05H
			CALL    SPEEDSET
			MOV     AL, [BX + 05H]
			NOT		AL
			OUT     PORTB1, AL
			JMP     A0
  
  
;DECIDE SPEED TO SET AND SET IT
CHECKSPD:   LEA     BX, TABLE_DISPLAY
			CMP 	AL, 0EEH
			JZ      SPEEDSET_0
			
			CMP     AL, 0EDH
			JZ      SPEEDSET_1
			
			CMP     AL, 0EBH
			JZ      SPEEDSET_2
			
			CMP     AL, 0E7H
			JZ      SPEEDSET_3
			
			CMP     AL, 0DEH
			JZ      SPEEDSET_4
			
			CMP		AL, 0DDH
			JZ  	SPEEDSET_5
			JMP     INCREASE

  
INCREASE:   LEA     BX, TABLE_DISPLAY				;BX CONTAINS STARTING ADDRESS OF TABLE_DISPLAY
			CMP     AL, 7DH						;COMPARE AL WITH UP
			JNZ     DECREASE					;IF UP IS NOT CALLED THEN JUMP TO DECREASE
			CALL    INCR
			CALL    SPEEDSET
			JMP     A0
    
DECREASE:   CMP     AL, 7BH						;COMPARE AL WITH DOWN
			JNZ     STOP_FAN					;IF DOWN IS ALSO NOT CALLED THEN IT MEANS STOP SO JUMP TO STOP_FAN
			CALL    DECR
			CALL    SPEEDSET
			JMP     A0
    
    
STOP_FAN:   CMP      AL, 7EH					;COMPARE WITH STOP
			JNZ     A0

TIME_0:	CALL 	STOP
		MOV		AL, 3FH
		NOT		AL
		OUT		PORTB1, AL
		JMP     A0
    
.EXIT


;DELAY OF 20MS
DELAY20 PROC NEAR
    MOV     CX, 2220
X9: LOOP    X9
    RET
DELAY20 ENDP


;STARTS THE FAN AND SET IT'S SPEED TO 1
SFAN PROC NEAR
	LEA     BX, TABLE_DISPLAY
	MOV     AL, [BX + 01H]
	NOT		AL
	OUT     PORTB1, AL
    MOV     SPEED, 01H
    MOV     AL, 22H				;;;;;;;
    OUT     PORTA1, AL
    MOV     STARTED, 01H
    RET
SFAN ENDP


;STOPS THE FAN
STOP PROC NEAR						;SET ALL VALUES TO INITIAL IE 0
    MOV     SPEED, 00H
    MOV     AL, 00H
    OUT     PORTA1, AL
    MOV     STARTED, 00H
    MOV     FLAG_AUTO, 00H
    RET
STOP ENDP


;SETS THE REQUIRED SPEED
SPEEDSET PROC NEAR
    MOV     CX, SPEED				
    MOV     AL, 00H
X:  ADD     AL, 22H					;;;;;;;;
    LOOP    X
    OUT     PORTA1, AL
    RET
SPEEDSET ENDP


TIME PROC NEAR
		LEA     BX, TABLE_DISPLAY
		MOV		DI, SPEED
		MOV     AL, [BX + DI]
		NOT		AL
		OUT     PORTB1, AL	
		MOV     CX, SPEED			
		MOV     AL, 00H				
X8: 	ADD     AL, 22H				;;;;;;;
		LOOP    X8
		OUT     PORTA1, AL  
		MOV     DI, SET_TIME
LOOP3:  MOV		AL, [BX + DI]
		NOT 	AL
		OUT 	PORTB2, AL
		MOV     DX, 50
LOOP2:  MOV     CX, 2220    
LOOP1:  NOP
		
		DEC     CX
		JNZ     LOOP1
		DEC     DX
		JNZ     LOOP2
		DEC     DI
		JNZ     LOOP3
		MOV		AL, [BX + DI]		;DIPLAYING 0
		NOT 	AL
		OUT 	PORTB2, AL
    RET
TIME ENDP


INCR PROC NEAR
    CMP     SPEED, 05H
    JGE     X6					;IF SPEED IS ALREADY 5 AND WE ASK FOR INCREMENT THEN IT EXITS THE PROC
    INC     SPEED				
    MOV     CX, SPEED
    ADD     BX, CX				
    MOV     AL, [BX]
    NOT		AL
    OUT     PORTB1, AL
X6: RET
INCR ENDP


DECR PROC NEAR
    CMP     SPEED, 01H
    JBE     X7
    DEC     SPEED
    MOV     CX, SPEED
    ADD     BX, CX
    MOV     AL, [BX]
    NOT		AL
    OUT     PORTB1, AL
X7: RET
DECR ENDP
END
