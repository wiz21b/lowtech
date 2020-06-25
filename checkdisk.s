;;; This code is (c) 2019 Stéphane Champailler
;;; It is published under the terms of the
;;; GNU GPL License Version 3.

;;; Part of this code (see below) is copied from the PT3 player by Vince "Deater" Weaver and is licensed accordingly

	.import sect
	.import rdadr16, read16, buf
	.import seek, current_track

	.include "defs.s"

	TUNE_ADDRESS = $B800
	PT3_LOC = TUNE_ADDRESS

	SLOT_SELECT	= $60	; 0 (drive 1) 110 (slot 6) 0000
	;; MOCK_6522_ACR	= $C40B	; 6522 #1 auxilliary control register
	;; MOCK_6522_IER	= $C40E	; 6522 #1 interrupt enable register
	;; MOCK_6522_T1CL	= $C404	; 6522 #1 t1 low order latches
	;; MOCK_6522_T1CH	= $C405	; 6522 #1 t1 high order counter

	debug_ptr = $86
	debug_ptr2 = $88
dummy_ptr2	= $8A
dummy_ptr	= $8C
dummy_pointer	= $8E



	.macro read_timer target, const
	lda #>const
	sec
	sbc MOCK_6522_T1CL
	sta target
	lda #<const
	sbc MOCK_6522_T1CH
	sta target + 1
	.endmacro

	.macro read_timer_direct target
	lda MOCK_6522_T1CL
	sta target
	lda MOCK_6522_T1CH
	sta target + 1
	.endmacro


	.macro set_timer_const value
	lda	#>(value)	; 9C
	sta	MOCK_6522_T1CH	; write into high-order latch,
	lda	#<(value)
	sta	MOCK_6522_T1CL	; write into low-order latch
	.endmacro


	.macro print_timer source
	lda source + 1
	jsr byte_to_text
	INC debug_ptr
	INC debug_ptr

	lda source
	jsr byte_to_text
	INC debug_ptr
	INC debug_ptr
	.endmacro

	.macro set_irq_vector target
	lda	#<target
	sta	$fffe
	lda	#>target
	sta	$ffff
	lda	#<target
	sta	$03fe
	lda	#>target
	sta	$03ff
	.endmacro
;;; ==================================================================

	.segment "CODE"


	;JSR check_diskii
	JSR check_diskii_with_irq
freeze:
	JSR scroll_text
	JMP freeze

;;; ==================================================================

	.proc check_timer

	lda	#$FF
setup_irq_smc5:
	sta	MOCK_6522_T1CL	; write into low-order latch
	lda	#$FF	; 9C
setup_irq_smc6:
	sta	MOCK_6522_T1CH	; write into high-order latch,

loop0:
	LDY #18
loop:
	LDA  MOCK_6522_T1CH
	;; STA $400

	CMP #$FF
	BNE loop
wait2:
	LDA  MOCK_6522_T1CH
	CMP #$FF
	BEQ wait2

	DEY
	BNE loop

	LDA  MOCK_6522_T1CL
	STA $401
	JMP loop0

	RTS
	.endproc
;;; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


	.proc check_diskii

	;; Mame : +/ $30*256 ~ 12500 cyles per loop

	;; Make sure read data are put in a place where they don't
	;; disturb anything

	lda #$40
	STA buf + 1
	lda #0
	sta buf

	lda #$0		; One-shot mode, no PB7
	sta MOCK_6522_ACR

	lda #%01111111		; Clear all interrupt enable bits
	sta MOCK_6522_IER


	LDA #0
	STA current_track
        ldx #SLOT_SELECT
	JSR seek
        ldx #SLOT_SELECT
	JSR rdadr16		; stabilize
        ldx #SLOT_SELECT
	JSR rdadr16		; stabilize

track_loop:
	LDA #16
	STA sector_count

notyet:
	;; disk acces : ~ 1/80th second = 0.0125 (12500 cycles)
	;; timer 65536 cycles = 0.07 sec




        ldx #SLOT_SELECT
	JSR rdadr16


	;; Introduce a delay
;; 	set_timer_const $3179 * 2 / 3
;; wait_shot:
;; 	LDX MOCK_6522_T1CL
;; 	LDA MOCK_6522_T1CH
;; 	BNE wait_shot
;; 	read_timer_direct timer3


	set_timer_const $FFFF
	ldx #SLOT_SELECT
	jsr rdadr16
	bcs notyet
	read_timer timer,$FFFF

	set_timer_const $FFFF
	ldx #SLOT_SELECT
	jsr read16
	read_timer timer2,$FFFF

	;; sector so TXT line
	LDA sect
	CMP #16
	BMI sect_ok
	jmp end_loop

sect_ok:
	;; A = sector number
	CLC
	ADC #2
	ASL
	TAX
	LDA txt_ofs,X
	STA debug_ptr
	LDA txt_ofs+1,X
	STA debug_ptr+1

	LDA #0
	LDY current_track
mult:
	DEY
	BMI end_mult
	ADC #20
	BNE mult
end_mult:

	CLC
	ADC debug_ptr
	STA debug_ptr
	LDA #0
	ADC debug_ptr+1
	STA debug_ptr+1

	LDX sect
	LDA hexa_apple,X
	CLC
	ADC #$00
	LDY #0
	sta (debug_ptr),Y
	INC debug_ptr
	INC debug_ptr

	print_timer timer3
	INC debug_ptr
	print_timer timer
	INC debug_ptr
	print_timer timer2
	;INC debug_ptr



end_loop:
	DEC sector_count
	BEQ next_track

	JMP notyet

next_track:
	LDA current_track
	CMP #1
	BNE next_track2
	RTS

next_track2:

	CLC
	ADC #1
	STA current_track

	ASL
        ldx #SLOT_SELECT
	JSR seek

;; 	LDA #16
;; no_ready:
;; 	PHA
;; wait_error:
;;         ldx #SLOT_SELECT
;; 	JSR rdadr16		; stabilize
;; 	bcs wait_error
;; 	PLA
;; 	SEC
;; 	SBC #1
;; 	BNE no_ready

        ldx #SLOT_SELECT
 	JSR rdadr16		; stabilize
	;; ldx #SLOT_SELECT
	;; jsr read16

	JMP track_loop

	rts

sector_count:	.byte 0
timer:	.word 0
timer2:	.word 0
timer3:	.word 0

	.endproc


;;; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	.proc scroll_text

	LDA #0
line_loop:
	STA line_count

	TAY

	ASL
	TAX
	LDA txt_ofs+1,X
	STA debug_ptr + 1
	LDA txt_ofs,X
	STA debug_ptr

	INY
	TYA
	ASL
	TAX
	LDA txt_ofs+1,X
	STA debug_ptr2 + 1
	LDA txt_ofs,X
	STA debug_ptr2

	LDY #39
move_line:
	LDA (debug_ptr2),Y
	STA (debug_ptr),Y
	DEY
	BPL move_line

	LDA line_count
	CLC
	ADC #1
	CMP #22
	BNE line_loop


	LDA #23
	ASL
	TAX
	LDA txt_ofs+1,X
	STA debug_ptr + 1
	LDA txt_ofs,X
	STA debug_ptr

	LDY #39
	LDA #' '+$80
clear_line:
	STA (debug_ptr),Y
	DEY
	BNE clear_line

	rts
line_count:	.byte 0

	.endproc

;;; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	.proc byte_to_text

	;; A = byte
	;; debug_ptr = pointer to where to write
	PHA
	CLC
	AND #%11110000
	ROR
	ROR
	ROR
	ROR
	TAX
	LDA hexa_apple,X
	CLC
	ADC #$80
	ldy #0
	sta (debug_ptr),Y

	PLA
	AND #15			; 4 lo bits of timer
	TAX
	LDA hexa_apple,X
	CLC
	ADC #$80
	INY
	sta (debug_ptr),Y

	rts
	.endproc

;;; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	.proc interrupt_handler_dummy

	PHP
	INC $7D0
	PLP

	RTI

	.endproc

hexa_apple:
	.byte $30,$31,$32,$33,$34,$35,$36,$37,$38,$39
	.byte $1,$2,$3,$4,$5,$6
txt_ofs:
	.word $400,$480,$500,$580,$600,$680,$700,$780
	.word $428,$4A8,$528,$5A8,$628,$6A8,$728,$7A8
	.word $450,$4D0,$550,$5D0,$650,$6D0,$750,$7D0

;;; ==================================================================

	.include "pt3_lib/zp.inc"
	; some firmware locations
	.include "pt3_lib/hardware.inc"
	.include "pt3_lib/pt3_lib_core.s"
	.include "pt3_lib/pt3_lib_init.s"
	.include "pt3_lib/pt3_lib_mockingboard_setup.s"
	;.include "pt3_lib/interrupt_handler.s"
	; if you're self patching, detect has to be after
	; interrupt_handler.s
	.include "pt3_lib/pt3_lib_mockingboard_detect.s"

;;; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

interrupt_handler:
interrupt_handler_music:

	php
	pha
	txa
	pha			; save X
	tya
	pha			; save Y

	LDA	$C404

;; 	INC time_skip_count
;; 	LDA time_skip_count
;; 	CMP #2
;; 	BNE no_skip
;; 	LDA #0
;; 	STA time_skip_count

;; 	FULL_SECTOR_SKIP = 2*$3179
;; 	set_timer_const FULL_SECTOR_SKIP
;; 	JMP pt3_interrupt_hook

;; no_skip:

        ldx #SLOT_SELECT
	JSR rdadr16

	lda #$40
	sta buf + 1
	lda #0
	sta buf
	ldx #SLOT_SELECT
	jsr read16
	;jmp exit_interrupt

	LDX sect
	LDA sector_shift
	BNE no_clear
	LDX #15
	LDA #'.'+$80
clear_line:
	STA $750,X
	DEX
	BPL clear_line
no_clear:
	INC sector_shift

	LDX sector_shift
	LDA hexa_apple,X
	CLC
	ADC #$80
	LDX sect
	STA $750,X


	LDX sector_shift
	CPX #8
	BEQ shift_a_sector
	CPX #17
	BEQ back_to_zero

	REGULAR_SKIP = ($3179 * 3) / 4
	SHIFTER_SKIP = $3179 + REGULAR_SKIP

regular_sector_progress:
	set_timer_const REGULAR_SKIP
	jmp go_on
back_to_zero:
	LDA #0
	STA sector_shift
shift_a_sector:
	set_timer_const SHIFTER_SKIP
	jmp go_on
go_on:
	;set_timer_const $3179 + $3179
	;jmp exit_interrupt

pt3_interrupt_hook:
	.include "pt3_lib/pt3_lib_irq_handler.s"
	jmp exit_interrupt

quiet_exit:
	stx	DONE_PLAYING
	jsr	clear_ay_both

	ldx	#$ff		; also mute the channel
	stx	AY_REGISTERS+7	; just in case

exit_interrupt:

	pla
	tay			; restore Y
	pla
	tax			; restore X
	pla			; restore a
interrupt_smc:
	lda $45
	plp
	RTI

sector_shift:
	.byte 0
time_skip_count:
	.byte 0

;;; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	.proc check_diskii_with_irq

	JSR start_player

wait_sector_zero:
        ldx #SLOT_SELECT
	JSR rdadr16		; stabilize
	LDA sect
	BNE wait_sector_zero

	SEI
	set_irq_vector interrupt_handler_music

	;; MOCK_6522_ACR = C40B
	;; bits 7 and 6 controls the timer1 operating mode
	;; $40 = Generate continuous interrupts, PB7 is disabled.
	lda	#%01000000
	sta	MOCK_6522_ACR	; ACR register

	lda	#%01111111	; clear all interrupt "enables"
	sta	MOCK_6522_IER	; IER register (interrupt enable)

	lda	#%11000000	; set timer1 IRQ enable
	sta	MOCK_6522_IER	; IER register (interrupt enable)



	lda	#$7F		; clear all interrupt flags
	set_timer_const $FFFE
	CLI

	RTS
	.endproc



start_player:
	lda	#0
	sta	DONE_PLAYING
	lda	#1
	sta LOOP

	;; jsr	mockingboard_detect
	;; bcc	mocking_not_found

	;; jsr	mockingboard_patch
mocking_not_found:
	jsr	mockingboard_init

	jsr	pt3_init_song
	jsr	reset_ay_both
	jsr	clear_ay_both

	rts
