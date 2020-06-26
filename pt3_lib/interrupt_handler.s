	;================================
	;================================
	; mockingboard interrupt handler
	;================================
	;================================
	; On Apple II/6502 the interrupt handler jumps to address in 0xfffe
	; This is in the ROM, which saves the registers
	;   on older IIe it saved A to $45 (which could mess with DISK II)
	;   newer IIe doesn't do that.
	; It then calculates if it is a BRK or not (which trashes A)
	; Then it sets up the stack like an interrupt and calls 0x3fe

	; Note: the IIc is much more complicated
	;	its firmware tries to decode the proper source
	;	based on various things, including screen hole values
	;	we bypass that by switching out ROM and replacing the
	;	$fffe vector with this, but that does mean we have
	;	to be sure status flag and accumulator set properly

.export ace_jump, base_jump_pause

interrupt_handler:

	;; From doc : interrupt flag is set by 6502
	;; => no more IRQ here.

	php			; save status flags
	pha			; save A				; 3
				; A is saved in $45 by firmware

	LDA	$C404		; clear interrupts, slot 4 MockingBoard


	;LDA	$C504		; clear interrupts, slot 5 MockingBoard

	txa
	pha			; save X
	tya
	pha			; save Y

	jmp	exit_interrupt

	;; Guard is not necessary. My tests prove that
	;; there's no re-entry.

	inc ticks

	lda ticks
	cmp #11
freeze:
	beq freeze

	;; CLC
	;; LDA ticks
	;; ADC #1
	;; STA ticks
;; 	LDA ticks + 1
;; 	ADC #0
;; 	STA ticks + 1

;; 	LDA ace_jump
;; 	BEQ skip_ace_jump

;; 	STA $7D0+39
;; 	DEC ace_jump
;; 	BNE wait_ace_jump

;; 	LDA read_in_pogress
;; 	CMP #0
;; 	BEQ no_read

;; 	;;  Do the ace jump
;; 	JSR read_sector_in_track


;; 	LDX ace_jump_target
;; 	LDA #'<'+$80
;; 	STA $7D0+20,X

;; 	LDX sect
;; 	LDA #'X'+$80
;; 	STA $7D0+20,X

;; 	LDA #3
;; 	STA base_jump_pause

;; 	lda	#<CLOCK_SPEED	; 40
;; 	sta	MOCK_6522_T1CL	; write into low-order latch
;; 	lda	#>CLOCK_SPEED	; 9C
;; 	sta	MOCK_6522_T1CH	; write into high-order latch,

;; 	LDA ticks
;; 	AND #3
;; 	BEQ do_music
;; 	INC ticks
;; 	LDA ticks
;; 	AND #3
;; 	BEQ do_music
;; 	INC ticks
;; 	LDA ticks
;; 	AND #3
;; 	BEQ do_music


;; no_read:
;; skip_ace_jump:
;; wait_ace_jump:

;; 	LDA ticks
;; 	AND #3
;; 	BEQ do_music
;; 	JMP exit_interrupt
;; do_music:
	;; JMP exit_interrupt

;; 	lda ticks
;; 	cmp #10
;; 	bne no_sector_reset

;; 	ldx #SLOT_SELECT
;; 	jsr rdadr16
;; 	ldx #SLOT_SELECT
;; 	jsr read16
;; 	lda	#<CLOCK_SPEED	; 50
;; 	sta	MOCK_6522_T1CL	; write into low-order latch
;; 	lda	#>CLOCK_SPEED	; 9C
;; 	sta	MOCK_6522_T1CH	; write into high-order latch,

;; no_sector_reset:

	;; Set the next interrupt just before a sector address
	;; block.

 	;; lda	#<CLOCK_SPEED	; 50
 	;; sta	MOCK_6522_T1CL	; write into low-order latch
 	;; lda	#>CLOCK_SPEED	; 9C
 	;; sta	MOCK_6522_T1CH	; write into high-order latch,

 	lda #0
 	sta MOCK_6522_T1CL	; write into low-order latch
	lda #$62		; #$31 = 49 => *3/4 = 36
 	sta MOCK_6522_T1CH	; write into high-order latch,

	ldx #SLOT_SELECT
	jsr rdadr16

	ldx #SLOT_SELECT
	jsr read16

	LDX sect
	INC $7d0,X
skip_sectors2:

;	JMP skip_music2
	.include "pt3_lib_irq_handler.s"
skip_music2:


;; 	lda ticks
;; 	and #63
;; 	bne no_debug_display

;; 	lda #>CLOCK_SPEED
;; 	sec
;; 	sbc MOCK_6522_T1CH

;; 	;; LDA MOCK_6522_T1CH

;; 	tay
;; 	CLC
;; 	ROR
;; 	CLC
;; 	ROR
;; 	CLC
;; 	ROR
;; 	CLC
;; 	ROR
;; 	TAX
;; 	LDA hexa,X
;; 	CLC
;; 	ADC #$80
;; 	sta $400

;; 	tya
;; 	AND #15			; 4 lo bits of timer
;; 	TAX
;; 	LDA hexa,X
;; 	CLC
;; 	ADC #$80
;; 	sta $401
;; no_debug_display:

;; record:
;; 	LDX ticks_entries
;; 	CPX #255
;; 	BEQ done_recording

;; 	LDA skip_sectors
;; 	STA $F000,X
;; 	;LDA ticks + 1
;; 	LDA sect
;; 	STA $F100,X
;; 	LDA track
;; 	STA $F200,X
;; 	LDA useless_sector
;; 	STA $F300,X

;; 	INC ticks_entries
;; done_recording:
;; 	JMP exit_interrupt

skip_music:
	JMP exit_interrupt	; CALINRATIUON !!!

;; 	LDA skip_sectors
;; 	BEQ no_read
;; 	JSR read_sector_in_track
;; 	JMP record
;;no_read:
lazy:

	jmp	exit_interrupt

	;inc	$0404		; debug (flashes char onscreen)
	;; jsr read_any_sector

	;=================================
	; Finally done with this interrupt
	;=================================

quiet_exit:
	stx	DONE_PLAYING
	jsr	clear_ay_both

	ldx	#$ff		; also mute the channel
	stx	AY_REGISTERS+7	; just in case


exit_interrupt:

	;; LDA #0
	;; STA guard

	pla
	tay			; restore Y
	pla
	tax			; restore X
	pla			; restore a				; 4

	; on II+/IIe (but not IIc) we need to do this?

interrupt_smc:

	;; This seems to be important

	nop
	nop

	;; lda	$45		; restore A

	plp

	rti			; return from interrupt			; 6

	.export ticks
ticks:	.word 1
ticks_entries:	.byte 0

	.export ace_jump_target
ace_jump:	.byte 0
ace_jump_target:	.byte 0

calibration_run:	.byte 0
calibration_step:	.byte 0
tick_before_measure:	.byte $ff

calibration_records:
	.repeat 50
	.byte 0
	.endrepeat

base_jump_pause:	.byte 0

;; calibration:
;; 	lda tick_before_measure
;; 	beq measure

;; 	cmp #$FF
;; 	beq not_measuring

;; 	dec tick_before_measure
;; 	rts

;; not_measuring:
;; 	lda calibration_step
;; 	cmp #15
;; 	beq calibration_done

;; wait_sector_zero:
;; 	jsr rdadr16
;; 	lda sect
;; 	cmp #0
;; 	bne wait_sector_zero

;; 	lda calibration_step
;; 	sta tick_before_measure

;; 	inc calibration_step

;; calibration_done:
;; 	rts
;; measure:
;; 	jsr rdadr16
;; 	lda sect
;; 	ldx calibration_step
;; 	sta wait_table,X
;; 	lda #$FF
;; 	sta tick_before_measure
;; 	rts

;guard:	.byte 0

								;============
								; typical
								; ???? cycles
