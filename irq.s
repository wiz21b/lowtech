interrupt_handler:
interrupt_handler_music:

	php
	pha
	txa
	pha			; save X
	tya
	pha			; save Y

	;LDA	$C404

	INC time_skip_count
	LDA time_skip_count
	CMP #2
	BNE no_skip
	LDA #0
	STA time_skip_count

	FULL_SECTOR_SKIP = 2*$3179 ; 2* 1/80th of sec => 1/40th
	set_timer_const FULL_SECTOR_SKIP
	JMP pt3_interrupt_hook

no_skip:

	;; The code in this macro must ABSOLUTELY
	;; load one sector and one sector only.
	;; (so it must be rdadr16 immeditately followed by read16)
	;; It must be that way, because we expect it
	;; to run for the time of a sector read.

	sector_read_code

	STATUS_LINE = $7d0 ;$650
	LDA sector_shift
	BNE no_clear
	LDX #15
	LDA #'''+$80
clear_line:
	STA STATUS_LINE,X
	DEX
	BPL clear_line
no_clear:
	LDX sector_shift
	LDA hexa_apple,X
	CLC
	ADC #$80
	LDX sect
	STA STATUS_LINE,X


	INC sector_shift
	LDX sector_shift

	CPX #4
	BEQ shift_a_sector
	CPX #8
	BEQ shift_a_sector
	CPX #12
	BEQ shift_a_sector

	CPX #17
	BEQ back_to_zero

	;; This time is computed to be the closest possible
	;; to a sector address block on the disk, so that
	;; rdadr16 waits the less possible.

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
	LDA	$C404

	pla
	tay			; restore Y
	pla
	tax			; restore X
	pla			; restore a
interrupt_smc:
				;lda $45
	;; FIXME I'm sre the start_player code messes around here
	;; So sometimes it's LDA $45, sometimes it's NOP/NOP
	;; Maybe the difference resides in the fact that I activate
	;; the language card or not.

	nop
	nop
	;; LDA $45
	plp
	RTI

sector_shift:
	.byte 0
time_skip_count:
	.byte 0

time_expand:	.byte 0

;;; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	.proc start_interrupts

wait_sector_zero:
        ldx #SLOT_SELECT
	JSR rdadr16		; stabilize
	LDA sect
	BNE wait_sector_zero

	SEI

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
