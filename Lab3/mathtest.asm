; mathtest.asm:  Examples using math32.inc routines

$NOLIST
$MODN76E003
$LIST

;  N76E003 pinout:
;                               -------
;       PWM2/IC6/T0/AIN4/P0.5 -|1    20|- P0.4/AIN5/STADC/PWM3/IC3
;               TXD/AIN3/P0.6 -|2    19|- P0.3/PWM5/IC5/AIN6
;               RXD/AIN2/P0.7 -|3    18|- P0.2/ICPCK/OCDCK/RXD_1/[SCL]
;                    RST/P2.0 -|4    17|- P0.1/PWM4/IC4/MISO
;        INT0/OSCIN/AIN1/P3.0 -|5    16|- P0.0/PWM3/IC3/MOSI/T1
;              INT1/AIN0/P1.7 -|6    15|- P1.0/PWM2/IC2/SPCLK
;                         GND -|7    14|- P1.1/PWM1/IC1/AIN7/CLO
;[SDA]/TXD_1/ICPDA/OCDDA/P1.6 -|8    13|- P1.2/PWM0/IC0
;                         VDD -|9    12|- P1.3/SCL/[STADC]
;            PWM5/IC7/SS/P1.5 -|10   11|- P1.4/SDA/FB/PWM1
;                               -------
;

org 0000H
   ljmp MyProgram

; These register definitions needed by 'math32.inc'
DSEG at 30H
x:   ds 4
y:   ds 4
bcd: ds 5

BSEG
mf: dbit 1

$NOLIST
$include(math32.inc)
$LIST

; These 'equ' must match the hardware wiring
LCD_RS equ P1.3
;LCD_RW equ PX.X ; Not used in this code, connect the pin to GND
LCD_E  equ P1.4
LCD_D4 equ P0.0
LCD_D5 equ P0.1
LCD_D6 equ P0.2
LCD_D7 equ P0.3
$NOLIST
$include(LCD_4bit.inc)
$LIST

CSEG

Left_blank mac
	mov a, %0
	anl a, #0xf0
	swap a
	jz Left_blank_%M_a
	ljmp %1
Left_blank_%M_a:
	Display_char(#' ')
	mov a, %0
	anl a, #0x0f
	jz Left_blank_%M_b
	ljmp %1
Left_blank_%M_b:
	Display_char(#' ')
endmac

; Sends 10-digit BCD number in bcd to the LCD
Display_10_digit_BCD:
	Set_Cursor(2, 7)
	Display_BCD(bcd+4)
	Display_BCD(bcd+3)
	Display_BCD(bcd+2)
	Display_BCD(bcd+1)
	Display_BCD(bcd+0)
	; Replace all the zeros to the left with blanks
	Set_Cursor(2, 7)
	Left_blank(bcd+4, skip_blank)
	Left_blank(bcd+3, skip_blank)
	Left_blank(bcd+2, skip_blank)
	Left_blank(bcd+1, skip_blank)
	mov a, bcd+0
	anl a, #0f0h
	swap a
	jnz skip_blank
	Display_char(#' ')
skip_blank:
	ret

; We can display a number any way we want.  In this case with
; four decimal places.
Display_formated_BCD:
	Set_Cursor(2, 7)
	Display_char(#' ')
	Display_BCD(bcd+3)
	Display_BCD(bcd+2)
	Display_char(#'.')
	Display_BCD(bcd+1)
	Display_BCD(bcd+0)
	ret

wait_for_P1_5:
	jb P1.5, $ ; loop while the button is not pressed
	Wait_Milli_Seconds(#50) ; debounce time
	jb P1.5, wait_for_P1_5 ; it was a bounce, try again
	jnb P1.5, $ ; loop while the button is pressed
	ret

Test_msg:  db 'Test xx answer:', 0

MyProgram:
	mov sp, #07FH ; Initialize the stack pointer
	; Configure all the pins for biderectional I/O
	mov	P3M1,#0x00
	mov	P3M2,#0x00
	mov	P1M1,#0x00
	mov	P1M2,#0x00
	mov	P0M1,#0x00
	mov	P0M2,#0x00
    lcall LCD_4BIT
	Set_Cursor(1, 1)
    Send_Constant_String(#Test_msg)

Forever:
	; Test 1
	Set_Cursor(1, 6)
	Display_BCD(#0x01) ; LCD line 1 should say now 'Test 01 answer:'
	; Try multiplying 1234 x 4567 = 5635678
	mov x+0, #low(1234)
	mov x+1, #high(1234)
	mov x+2, #0
	mov x+3, #0
	mov y+0, #low(4567)
	mov y+1, #high(4567)
	mov y+2, #0
	mov y+3, #0
	; mul32 and hex2bcd are in math32.asm
	lcall mul32
	lcall hex2bcd
	; display the result
	lcall Display_10_digit_BCD
	; Now wait for key1 to be pressed and released so we can see the result.
	lcall wait_for_P1_5
	
	; Test 2
	Set_Cursor(1, 6);
	Display_BCD(#0x02)
	; There are macros defined in math32.asm that can be used to load constants
	; to variables x and y. The same code above may be written as:
	Load_x(1234)
	Load_y(4567)
	lcall mul32
	lcall hex2bcd
	lcall Display_10_digit_BCD
	lcall wait_for_P1_5
	
	; Test 3
	Set_Cursor(1, 6);
	Display_BCD(#0x03)
	; Try dividing 5635678 / 1234 = 4567
	Load_x(5635678)
	Load_y(1234)
	lcall div32 ; This subroutine is in math32.asm
	lcall hex2bcd
	lcall Display_10_digit_BCD
	lcall wait_for_P1_5

	; Test 4
	Set_Cursor(1, 6);
	Display_BCD(#0x04)
	; Try adding 1234 + 4567 = 5801
	Load_x(1234)
	Load_y(4567)
	lcall add32 ; This subroutine is in math32.asm
	lcall hex2bcd
	lcall Display_10_digit_BCD
	lcall wait_for_P1_5

	; Test 5
	Set_Cursor(1, 6);
	Display_BCD(#0x05)
	; Try subtracting 4567 - 1234 = 3333
	Load_x(4567)
	Load_y(1234)
	lcall sub32 ; This subroutine is in math32.asm
	lcall hex2bcd
	lcall Display_10_digit_BCD
	lcall wait_for_P1_5
	
	; Test 6
	Set_Cursor(1, 6);
	Display_BCD(#0x06)
	; Ok, that was easy.  Try computing the area of circle
	; with a radius of 23.2.  Remember we are working with
	; usigned 32-bit integers here, so there is the risk
	; of overflow, in particular when multiplying big numbers.
	; One trick you may use: approximate pi to 355/113.
	Load_x(232)
	Load_y(232)
	lcall mul32 ; Result is stored in x
	; Now multiply by pi
	Load_y(35500)
	lcall mul32
	Load_y(113)
	lcall div32
	lcall hex2bcd
	lcall Display_formated_BCD ; result should be 1690.9309
	lcall wait_for_P1_5
	
	ljmp Forever
	
END
