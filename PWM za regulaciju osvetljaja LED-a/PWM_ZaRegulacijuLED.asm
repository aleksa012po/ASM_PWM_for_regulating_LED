;
; PWM_ZaRegulacijuLED.asm
;
; Created: 9/28/2022 1:37:05 PM
; Author : Aleksandar Bogdanovic
;

// Arduino Asembler, PWM za regulaciju osvetljaja LED-a
// Regulacija LED-a putem PWM-a, ukljucujemo LED od 0% od 100%, pa nazad, FADE IN, fade OUT

.include "m328pdef.inc"
.org 0x0000
rjmp init

// Mapiranje
.def temp = r16
.def delay_0 = r17
.def delay_1 = r18
.def delay_2 = r19
.def counter = r20

.macro gore
	ldi	delay_0, 208					// Podesavanje delay-a sa vrednoscu od 10ms po ciklusu
	ldi	delay_1, 202
	;-----------------
	out	OCR0A, counter
	inc	counter
	;-----------------
	rcall delay
	;-----------------
	cpi	counter, 100					// Fade IN do 255
	brne count_up
.endmacro

.macro dole
	ldi	delay_0, 208					// Podesavanje delay-a sa vrednoscu od 10ms po ciklusu
	ldi	delay_1, 202
	;-----------------
	out	OCR0A, counter
	dec	counter
	;-----------------
	rcall delay
	;----------------- 
	cpi	counter, 0x00					// Fade OUT do 0
	brne count_down
 .endmacro

 //Inicijalizacija
 init:
	ldi	temp, 0xff		
	out	ddrd, temp						// 1 --> Output, 0 --> Input / PortD konfigurisan kao Output port  
	;----------------- 
	ldi	temp,	0b10000001				// ili 1<<WGM00 | 1<<COM0A1, PWM phase correct, TOP 0xFF 
	out	TCCR0A, temp					// Clear OC0A on compare match, set OC0A at BOTTOM, (non-inverting mode)
	;-----------------
	ldi	temp, 0b00000001				// temp = 0b00000010, 1<<CS01 = prescalar 8
	out	TCCR0B, temp					// Preskalar 1
	;-----------------
	clr counter
 
program:

count_up:
	gore
 
count_down:
	dole
	rjmp program
 
delay:
	dec delay_0
	brne delay      
	;-----------
	dec delay_1
	brne delay
	ret