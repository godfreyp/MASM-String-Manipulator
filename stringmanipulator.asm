TITLE String Primitives and Macros    (Proj6_godfrepa.asm)

; Author: Patrick Godfrey
; Last Modified:	12/3/2021
; OSU email address: godfrepa@oregonstate.edu
; Course number/section:   CS271 Section 400
; Project Number: 6                 Due Date: 12/5/2021
; Description: This program is the portfolio project for the class.
; The program takes as input a given number of signed 32-bit integers.
; These integers are read as strings, processed, then stored as signed integers.
; When the integers are printed, they must be converted to a string before being
; displayed. This program displays the array of those numbers, their sum, and
; their truncated average.

INCLUDE Irvine32.inc

; ---------------------------------------------------------------------------------
; Name: mGetString
;
; Takes as input from the user a string that can fit in an SDWORD.
; Populates an array of ARRAY_SIZE length with the string converted to integers.
;
; Receives:
;	msg		=	Reference to message inputMsg
;	err		=	Reference to message errorMsg
;	arr		=	Reference to array inputArray
;	buff	=	Reference to buffer
;
; Returns: An array of (ARRAY_SIZE) signed integers from the user.
; ---------------------------------------------------------------------------------
mGetString		MACRO		msg, err, arr, buff
	LOCAL	_start
	LOCAL	getStrLoop
	LOCAL	_continue
	LOCAL	_positive
	LOCAL	_negative
	LOCAL	_invalidInput
	LOCAL	_checkIfNeg
	LOCAL	_finish

; Setup necessary pointers
	MOV		ebx, ARRAY_SIZE				; Length of inputArray
	SUB		ebx, ecx					; ebx = current empty index
	MOV		eax, 4
	MUL		ebx							; eax = current empty index corrected for DWORD format
	MOV		edi, arr
	ADD		edi, eax

; Get input from the user and validate it.
_start:
	; Displays prompt for user
	MOV		edx, msg
	CALL	WriteString

	; Gets input from user and check for valid length.
	MOV		edx, buff
	MOV		ecx, 13
	CALL	ReadString
	CMP		eax, 12						; String cannot fit in a signed 32-bit register
	JE		_invalidInput
	CMP		eax, 0						; String is empty
	JE		_invalidInput

	; Prepare for processing
	MOV		ecx, eax
	MOV		esi, buff
	MOV		eax, 0
	MOV		ebx, 2						; ebx = 0, Positive, ebx = 1, Negative, ebx = 2, Unknown
	MOV		edx, 0						; edx accumulates the value of the string

	LODSB	
	CMP		AL, 43
	JE		_positive
	CMP		AL, 45
	JE		_negative
	MOV		ebx, 0
	CMP		ecx, 11						; After processing +/- symbol, max # of digits is 10
	JGE		_invalidInput

; Validates and processes the string
getStrLoop:
	CMP		AL, 48
	JB		_invalidInput
	CMP		AL, 57
	JG		_invalidInput
	IMUL	edx, 10						; Shift sum to left one digit place, then add AL value to EDX
	SUB		AL, 48
	ADD		edx, eax

	_continue:
		LODSB
		LOOP	getStrLoop

	JMP		_checkIfNeg

; Validates if value is positive and valid
_positive:
	CMP		ebx, 2						; error if ebx is already set.
	JNE		_invalidInput
	CMP		ecx, 1						; + is the only value
	JE		_invalidInput
	MOV		ebx, 0
	JMP		_continue

; Validates if value is negative and valid
_negative:
	CMP		ebx, 2						; error if ebx is already set.
	JNE		_invalidInput
	CMP		ecx, 1						; - is the only value
	JE		_invalidInput
	MOV		ebx, 1
	JMP		_continue

; Throw error message
_invalidInput:
	CALL	CrLf
	MOV		edx, err
	CALL	WriteString
	CALL	CrLf
	JMP		_start

; Checks if ebx is 1 (negative), set value in edx to negative
_checkIfNeg:
	CMP		ebx, 1
	JNE		_finish
	NEG		edx

; Value is moved into the empty index
_finish:
	MOV		[edi], edx

ENDM


; ---------------------------------------------------------------------------------
; Name: mDisplayString
;
; Preconditions: EAX is set to some value to be printed. Otherwise, current value
; in EAX will be displayed.
;
; Receives:
;	buff	=	buffer
;	outStr	=	outString
;	blank	=	Reference to space
;
; Returns: An array of ARRAY_SIZE elements of signed integers from the user.
; ---------------------------------------------------------------------------------
mDisplayString		MACRO	buff, outStr, blank
	LOCAL	_setupDisplay
	LOCAL	_processDisplay
	LOCAL	_isNeg
	LOCAL	_adjustPointers
	LOCAL	revLoop
	LOCAL	cleanLoop

	MOV		edi, buff
	MOV		ebx, 0					; ebx = 0, Positive, ebx = 1, Negative
	CMP		eax, 0
	JGE		_setupDisplay
	INC		ebx
	NEG		eax

; Set registers to begin processing
_setupDisplay:
	PUSH	ebx
	MOV		ebx, 10					; Divide to isolate lowest number place in edx
	MOV		ecx, 0					; Digit place tracker

; Convert number to string (string is in reverse)
_processDisplay:
	CDQ
	IDIV	ebx
	PUSH	eax
	MOV		eax, edx
	ADD		al, 48
	STOSB
	POP		eax
	INC		ecx
	CMP		eax, 0
	JZ		_isNeg
	JMP		_processDisplay

; Add minus to string if negative
_isNeg:
	POP		ebx
	CMP		ebx, 0
	JE		_adjustPointers
	MOV		eax, 0
	MOV		al, 45
	INC		ecx
	STOSB

; Adjust pointers to reverse string
_adjustPointers:
	DEC		edi
	MOV		esi, edi
	MOV		edi, outStr

; Reverses the string in buffer
revLoop:
    STD
    LODSB
    CLD
    STOSB
	LOOP   revLoop

	; Print out the string
	MOV		edx, outStr
	CALL	WriteString
	MOV		edx, blank
	CALL	WriteString

	; Cleanup outString
	MOV		edi, outStr
	MOV		ecx, 12

; Returns outStr to empty state
cleanLoop:
	MOV		al, 0
	STOSB
	LOOP	cleanLoop

ENDM

ARRAY_SIZE	=	10

.data

intro		BYTE	"Program 6: String Primitives and Macros by Patrick Godfrey", 0
instruct1	BYTE	"Please provide 10 signed decimal integers.", 0
instruct2	BYTE	"Each number needs to be small enough to fit inside a 32 bit register.", 0
instruct3	BYTE	"This program will display a list of the integers, their sum, and their average value.", 0
inputMsg	BYTE	"Please enter a signed integer: ", 0
errorMsg	BYTE	"ERROR: Either the input is too big or invalid characters were used.", 0
responseMsg	BYTE	"You entered the following numbers: ", 0
sumMsg		BYTE	"The sum of these numbers is: ", 0
avgMsg		BYTE	"The truncated average is: ", 0
goodbyeMsg	BYTE	"Thank you for using this program :)", 0
buffer		BYTE	12	DUP(?)
outString	BYTE	12	DUP(?)
testspace	BYTE	" ", 0
space		BYTE	" ", 0
inputArray	SDWORD	ARRAY_SIZE DUP(?)
sumOfArr	SDWORD	?


.code
main PROC

; Introduces the program
PUSH	OFFSET			instruct3
PUSH	OFFSET			instruct2
PUSH	OFFSET			instruct1
PUSH	OFFSET			intro
CALL	Introduction

; Write ARRAY_SIZE number of integers into an array
MOV		ecx, ARRAY_SIZE
FillArray:
	PUSH	OFFSET			buffer
	PUSH	OFFSET			inputArray
	PUSH	OFFSET			errorMsg
	PUSH	OFFSET			inputMsg	
	CALL	ReadVal
	LOOP	FillArray

; Display the contents of the array
PUSH	OFFSET			responseMsg
PUSH	OFFSET			space
PUSH	OFFSET			outString
PUSH	OFFSET			buffer
PUSH	OFFSET			inputArray
CALL	DisplayArray

; Display the sum of the numbers
PUSH	OFFSET			sumOfArr
PUSH	OFFSET			sumMsg
PUSH	OFFSET			space
PUSH	OFFSET			outString
PUSH	OFFSET			buffer
PUSH	OFFSET			inputArray
CALL	DisplaySum

; Display the truncated average of the numbers
PUSH	OFFSET			avgMsg
PUSH	OFFSET			space
PUSH	OFFSET			outString
PUSH	OFFSET			buffer
PUSH	OFFSET			sumOfArr
CALL	DisplayAverage

; Display a goodbye message
PUSH	OFFSET			goodbyeMsg
CALL	Goodbye
	Invoke ExitProcess,0	; exit to operating system
main ENDP

; ---------------------------------------------------------------------------------
; Name: Introduction
;
; Displays program introduction.
;
; Receives:
;	[ebp+36]	=	Reference to Intro
;	[ebp+40]	=	Reference to instruct1
;	[ebp+44]	=	Reference to instruct2
;	[ebp+48]	=	Reference to instruct3
; ---------------------------------------------------------------------------------
Introduction	PROC
	PUSHAD							; +32 to ebp
	MOV		ebp, esp
	MOV		edx, [ebp+36]			; Intro
	CALL	WriteString
	CALL	CrLf
	MOV		edx, [ebp+40]			; instruct1
	CALL	WriteString
	CALL	CrLf
	MOV		edx, [ebp+44]			; instruct2
	CALL	WriteString
	CALL	CrLf
	MOV		edx, [ebp+48]			; instruct3
	CALL	WriteString
	CALL	CrLf
	CALL	CrLf
	POPAD
	RET		16
Introduction	ENDP


; ---------------------------------------------------------------------------------
; Name: ReadVal
;
; Receive a value from the user
;
; Preconditions: ECX set to ARRAY_SIZE
;
; Postconditions: None
;
; Receives:
;	[ebp+36]	=	Reference to message
;	[ebp+40]	=	Reference to error message
;	[ebp+44]	=	Reference to inputArray
;	[ebp+48]	=	Reference to buffer
;
; Returns
; ---------------------------------------------------------------------------------
ReadVal			PROC
	PUSHAD
	MOV		ebp, esp
	mGetString [ebp+36], [ebp+40], [ebp+44], [ebp+48]
	POPAD
	RET		16
ReadVal			ENDP


; ---------------------------------------------------------------------------------
; Name: WriteVal
;
; Writes an integer as a string
;
; Preconditions: EAX is set to a value to be printed.
;
; Postconditions: None
;
; Receives:
;	[ebp+36]	=	Reference to buffer
;	[ebp+40]	=	Reference to outstring
;	[ebp+44]	=	Reference to space
;
; Returns: A given value in EAX is displayed as a string.
; ---------------------------------------------------------------------------------
WriteVal		PROC
	PUSHAD
	MOV		ebp, esp
	mDisplayString	[ebp+36], [ebp+40], [ebp+44]
	POPAD
	RET		12
WriteVal		ENDP


; ---------------------------------------------------------------------------------
; Name: DisplayArray
;
; Display the contents of an array in string form.
;
; Preconditions: None
;
; Postconditions: None
;
; Receives:
;	[ebp+36]	=	Reference to array
;	[ebp+40]	=	Reference to buffer
;	[ebp+44]	=	Reference to outstring
;	[ebp+48]	=	Reference to space
;	[ebp+52]	=	Reference to responseMsg
;
; Returns: Displays the array the array of elements.
; ---------------------------------------------------------------------------------
DisplayArray	PROC
	PUSHAD
	MOV		ebp, esp
	CALL	CrLf
	MOV		edx, [ebp+52]
	CALL	WriteString
	CALL	CrLf

	MOV		esi, [ebp+36]
	MOV		ecx, ARRAY_SIZE

	_displayArrLoop:
		LODSD
		PUSH	[ebp+48]
		PUSH	[ebp+44]
		PUSH	[ebp+40]
		CALL	WriteVal
		MOV		eax, 0
		LOOP	_displayArrLoop
	
	CALL	CrLf
	CALL	CrLf
	POPAD
	RET		20
DisplayArray	ENDP


; ---------------------------------------------------------------------------------
; Name: DisplaySum
;
; Display the sum of an array of ARRAY_SIZE elements
;
; Preconditions: The given array is ARRAY_SIZE in length.
;
; Postconditions: None
;
; Receives:
;	[ebp+36]	=	Reference to inputArray
;	[ebp+40]	=	Reference to buffer
;	[ebp+44]	=	Reference to outstring
;	[ebp+48]	=	Reference to space
;	[ebp+52]	=	Reference to sumMsg
;	[ebp+56]	=	sumOfArr
;
; Returns: The sum of the array is displayed and stored in sumOfArr
; ---------------------------------------------------------------------------------
DisplaySum		PROC
	PUSHAD
	MOV		ebp, esp
	MOV		esi, [ebp+36]
	
	; Display sumMsg
	MOV		edx, [ebp+52]
	CALL	WriteString
	
	; Calculate the sum of the array
	MOV		eax, 0
	MOV		ebx, 0
	MOV		ecx, ARRAY_SIZE
	sumLoop:
		LODSD
		ADD		ebx, eax
		LOOP	sumLoop
	MOV		eax, ebx

	; Store the sum of the array
	PUSH	edi
	MOV		edi, [ebp+56]
	STOSD
	POP		edi
	
	; Display the sum
	PUSH	[ebp+48]
	PUSH	[ebp+44]
	PUSH	[ebp+40]
	CALL	WriteVal
	CALL	CrLf
	CALL	CrLf
	
	POPAD
	RET		24
DisplaySum		ENDP

; ---------------------------------------------------------------------------------
; Name: DisplayAverage
;
; Display the truncated average of an array of ARRAY_SIZE elements
;
; Preconditions: sumOfArr has been written with the sum of all elements
;	of the array.
;
; Postconditions: None
;
; Receives:
;	[ebp+36]	=	Reference to sumOfArr
;	[ebp+40]	=	Reference to buffer
;	[ebp+44]	=	Reference to outstring
;	[ebp+48]	=	Reference to space
;	[ebp+52]	=	Reference to avgMsg
;
; Returns: The truncated average of the array being processed
; ---------------------------------------------------------------------------------
DisplayAverage	PROC
	PUSHAD
	MOV		ebp, esp

	; Display avgMsg
	MOV		edx, [ebp+52]
	CALL	WriteString

	; Find the truncated average
	PUSH	esi
	MOV		esi, [ebp+36]
	LODSD
	POP		esi
	MOV		ebx, ARRAY_SIZE
	CDQ
	IDIV	ebx

	; Display the average
	PUSH	[ebp+48]
	PUSH	[ebp+44]
	PUSH	[ebp+40]
	CALL	WriteVal
	CALL	CrLf
	CALL	CrLf

	POPAD
	RET		20
DisplayAverage	ENDP


; ---------------------------------------------------------------------------------
; Name: Goodbye
;
; Displays a goodbye message to the user.
;
; Receives:
;	[ebp+36]	=	Reference to goodbyeMsg
;
; Returns: A goodbye message.
; ---------------------------------------------------------------------------------
Goodbye			PROC
	PUSHAD
	MOV		ebp, esp
	MOV		edx, [ebp+36]
	CALL	WriteString
	CALL	CrLf
	POPAD
	RET		4
Goodbye			ENDP
END main
