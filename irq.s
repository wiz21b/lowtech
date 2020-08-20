	STATUS_LINE = $7d0 ;$650

	.macro draw_debug_info

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

	.endmacro

;;; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

interrupt_handler:
interrupt_handler_music:

	php
	pha
	txa
	pha			; save X
	tya
	pha			; save Y

	inc $402

	;; FIXME this must be SMC'ed to handle MockingBoard
	;; on another port.
	LDA	$C404		; Allow the next IRQ from the 6522

	;; When in "simulation mode", it means that the timer
	;; has been set to wait for the time it takes to read
	;; a sector. So we spend time just like if a sector
	;; was read. We do that to maintain sector synchronisation
	;; with the disk while making sure the 6502 can do useful
	;; things during that time. The simulation mode is used
	;; when the read_sector macro does nothing useful.

	LDA #0
	CMP read_sector_simulation
	BEQ regular_operation

	LDX read_sector_simulation ; FIXME Remove this, it's for diagnostics only
	CPX #$FF
	BNE not_check_disk
	JMP pt3_interrupt_hook
not_check_disk:

	STA read_sector_simulation
	JMP sector_was_read

regular_operation:
	;; We'll read 40/2=20 sectors per seconds while maintainng
	;; a 40Hz interrupt frequency (for PT3 play). time_skip_count
	;; counts one sector out of two.

	INC time_skip_count
	LDA time_skip_count
	CMP #2			; FIXME use SBC to hae A=0 afterwards
	BNE no_skip
	LDA #0
	STA time_skip_count

	;; A full sector skip is actually made of two things
	;; - the time it takes to read the data of the sector
	;; - the (maximum) time it takes to reach the address
	;;   nibbles preceding those sector data (we count that
	;;   time as a mximum because we make the hypothesis
	;;   that when we start to want to read a sector, the
	;;   read head is somewhere in the sector proceding that
	;;   sector; so we must wait to reach the address nibbles)

	;; Rememeber, 16 sectors per track, 5 round pers econd
	;; => 80 sectors per second.

	FULL_SECTOR_SKIP = 2*$3179 ; 2* 1/80th of sec => 1/40th of sec.

	;; We set our timer interrupt at the same frequency
	;; of a full "sector" that is, one sector out of two.
	;; That frequency is chosen for two reasons. First
	;; reason is that if we wanted to read all sectors,
	;; we would never leave the interrupt (we'd spend all
	;; our time reading). The second reason is that the frequency
	;; of one every two sectors is 2*1/80th = 40Hz. That frequency
	;; is close to the 50Hz frequency of a PT3 player.

	set_timer_const FULL_SECTOR_SKIP
	JMP pt3_interrupt_hook

no_skip:

	sector_read_code

sector_was_read:

	;draw_debug_info

	;; Given the fact that we have a 40Hz IRQ frequency,
	;; x2 because we skip one every other IRQ , we end
	;; up reading a sector out of four. But, as a track is
	;; 16 sectors, doing so leads to reading always the
	;; same 4 sectors : 0,4,8,12,0,4,8,12,... To avoid that
	;; we shift one sector each time the disk has completed a
	;; revolution (4 interrupts, counted in sector_shift)
	;; to have a pattern such as : 0,4,8,12,1,5,9,13,2,6,10,14...
	;; This way
	;; we make sure we read each sector once and we also make sure
	;; we read it at the most appropriate time (that is, we don't
	;; have to wait for it).

	INC sector_shift	; FIXME this can pobably be optimized a bit
	LDX sector_shift

	CPX #4
	BEQ shift_a_sector
	CPX #8
	BEQ shift_a_sector
	CPX #12
	BEQ shift_a_sector

	CPX #17			; FIXME Why not 16 ???
	BEQ back_to_zero

	;; This time is computed to be the closest possible
	;; to a sector address block on the disk, so that
	;; rdadr16 waits the less possible.

	REGULAR_SKIP = ($3179 * 5) / 6
	SHIFTER_SKIP = $3179 + REGULAR_SKIP

regular_sector_progress:
	set_timer_const REGULAR_SKIP
	jmp go_on		; FIXME Use shorter jumps
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
	.ifndef MUSIC
	JMP skip_music
	.include "pt3_lib/pt3_lib_irq_handler.s"
skip_music:
	.else
	JSR pt3_irq_handler
	;.include "pt3_lib/pt3_lib_irq_handler.s"
	.endif

	jmp exit_interrupt

;; quiet_exit:
;; 	stx	DONE_PLAYING
;; 	jsr	clear_ay_both

;; 	ldx	#$ff		; also mute the channel
;; 	stx	AY_REGISTERS+7	; just in case

exit_interrupt:

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



	.ifdef MUSIC
;pt3_irq_handler:
	.include "pt3_lib/pt3_lib_irq_handler.s"
	RTS
quiet_exit:
	stx	DONE_PLAYING
	jsr	clear_ay_both

	ldx	#$ff		; also mute the channel
	stx	AY_REGISTERS+7	; just in case
	RTS
	.endif


sector_shift:
	.byte 0
time_skip_count:
	.byte 0
read_sector_simulation:	.byte 0
time_expand:	.byte 0

;;; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	.proc start_interrupts

wait_sector_zero:
	;; Wait for sector zero before starting interrupts.
	;; This is not 100% necessary, but it helps to have
	;; more predictable execution and that's useful
	;; when debugging. We assume no interrupts occur
	;; while doing this (else the timing will be wrong)
	;; FIXME Use this to measure the time it takes to read
	;; a sector.


        ldx #SLOT_SELECT
	JSR rdadr16
	LDA sect		; Wait for sector 0
	BNE wait_sector_zero


	SEI
	;; MOCK_6522_ACR = C40B
	;; bits 7 and 6 controls the timer1 operating mode
	lda	#%01000000 	; Generate continuous interrupts, PB7 is disabled.
	ldy #$0B		; MOCK_6522_ACR
	STA (MB_Base),Y
	;sta	MOCK_6522_ACR	; ACR register

	ldy #$0E		; IER Register
	lda	#%01111111	; clear all interrupt "enables"
	;sta	MOCK_6522_IER	; IER register (interrupt enable)
	STA (MB_Base),Y

	lda	#%11000000	; set timer1 IRQ enable
	;sta	MOCK_6522_IER	; IER register (interrupt enable)
	STA (MB_Base),Y


	;lda	#$7F		; clear all interrupt flags
	set_timer_to_const $FFFE
	CLI

	RTS

	.endproc
