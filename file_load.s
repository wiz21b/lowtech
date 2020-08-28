	TOLERANCE = $100	; $100 OK on AWin, bugs on Mame

	;; Demo :
	;; $80, $110, $180 ok mame
	;; $80 almost OK on AWin

	;; Checkdisk:
	;; $80 ends up freezing on Mame


	Temp = $FF

	;; All these values are globals because else we
	;; end up in a .scoe mangement nightmare (ca65 is
	;; quite defective here :-( )
first_page:	.byte $20
first_sector:	.byte 0
first_track:	.byte 0
last_sector:	.byte 0
last_track:	.byte 0
track_last_sector:	.byte 0
track_first_sector:	.byte 0
first_track_iteration:	.byte 0


	.proc init_file_load

	;; Prepare the data structures to load a file.
	;; A = file index in TOC (cf. disk_toc)

	mul_a_by_5

	TAX

	LDA disk_toc,X
	STA first_track
	STA current_track

	LDA disk_toc+1,X
	STA first_sector
	LDA disk_toc+2,X
	STA last_track
	LDA disk_toc+3,X
	STA last_sector

	;; Pages will be incremented, starting from first_page.
	;; So if a file is 17 sectors long, then it will be
	;; loaded from first_page to first_page + (17-1), inclusive.

	LDA disk_toc+4,X
	STA first_page

	LDA #1
	STA first_track_iteration

	;; Make sure the IRQ doesn't start reading any leftovers.

	LDA #0
	STA sectors_to_read
	STA stepper

	RTS

	.endproc

;;; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	.proc load_file
	;; A = file index

	JSR init_file_load
still_stuff_to_read:
	JSR handle_track_progress
	BCS still_stuff_to_read

	RTS
	.endproc

;;; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	.proc load_file_no_irq
	;; A = file index

	JSR init_file_load

	;; Init the first track load
	JSR handle_track_progress

still_stuff_to_read:
sector_already_read:
	JSR read_any_sector_in_track
	BCC sector_already_read

	JSR handle_track_progress
	BCS still_stuff_to_read

	RTS
	.endproc

;;; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	READ_SECTOR = 1
	MUSIC_REGULAR = 2
	MUSIC_LONG = 3
	MUSIC_SHORT = 4
	LOOP_STATES = 5
	STAND_BY_STATE = 6

read_sector_states:

.byte READ_SECTOR
.byte MUSIC_LONG
.byte MUSIC_SHORT
.byte READ_SECTOR
.byte MUSIC_LONG
.byte MUSIC_SHORT
.byte READ_SECTOR
.byte MUSIC_LONG
.byte MUSIC_SHORT
.byte READ_SECTOR
.byte MUSIC_REGULAR
.byte MUSIC_SHORT
.byte READ_SECTOR
.byte MUSIC_LONG
.byte MUSIC_SHORT
.byte READ_SECTOR
.byte MUSIC_LONG
.byte MUSIC_SHORT
.byte READ_SECTOR
.byte MUSIC_LONG
.byte MUSIC_SHORT
.byte READ_SECTOR
.byte MUSIC_REGULAR
.byte MUSIC_SHORT
.byte READ_SECTOR
.byte MUSIC_LONG
.byte MUSIC_SHORT
.byte READ_SECTOR
.byte MUSIC_LONG
.byte MUSIC_SHORT
.byte READ_SECTOR
.byte MUSIC_LONG
.byte MUSIC_SHORT
.byte READ_SECTOR
.byte MUSIC_REGULAR
.byte MUSIC_SHORT
.byte READ_SECTOR
.byte MUSIC_LONG
.byte MUSIC_SHORT
.byte READ_SECTOR
.byte MUSIC_LONG
.byte MUSIC_SHORT
.byte READ_SECTOR
.byte MUSIC_LONG
.byte MUSIC_SHORT
.byte READ_SECTOR
.byte MUSIC_LONG
.byte MUSIC_LONG
.byte MUSIC_LONG


STAND_BY_STATE_NDX = * - read_sector_states
	.byte STAND_BY_STATE


stepper:	.byte 0
sectors_to_read:	.byte 0
current_track:	.byte 0
sector_status:
	.repeat ::SECTORS_PER_TRACK
	.byte $0
	.endrepeat

	.ifdef DEBUG
sector_status_debug:
	.repeat ::SECTORS_PER_TRACK
	.byte $0
	.endrepeat
disk_times_lo:
	.repeat 64
	.byte $0
	.endrepeat
disk_times_hi:
	.repeat 64
	.byte $0
	.endrepeat
disk_times_sect:
	.repeat 64
	.byte $0
	.endrepeat
dummy:	.word 0

	.endif

	;; -----------------------------------------------------------
	;; INTERRUPT HANDLER
	;; -----------------------------------------------------------

	.proc disk_irq_handler2

	php
	pha
	txa
	pha			; save X
	tya
	pha			; save Y

	LDY #$04	; Allow the next IRQ from the 6522
	LDA (MB_Base),Y

	;; --- DEBUG
	;; set_timer_to_target twice_full_sector_time
	;; JMP exit_interrupt
	;; --- DEBUG

	LDA sectors_to_read
	BEQ music_long

	LDY stepper
read_sector_state:
	LDA read_sector_states,Y
	INY
	CMP #LOOP_STATES
	BNE dont_loop_states
loop_states:
	LDY #0
	BEQ read_sector_state	; Always taken
dont_loop_states:
	STY stepper

	CMP #MUSIC_LONG
	BEQ music_long
	CMP #MUSIC_REGULAR
	BEQ music_regular
	CMP #MUSIC_SHORT
	BEQ music_short
	CMP #READ_SECTOR
	BEQ read_sector

	;; STAND_BY_STATE
	;; DEBUG
	;JMP loop_states

music_regular:
	;set_timer_to_const DISK_READ_TIME
	set_timer_to_target full_sector_time

	JSR pt3_irq_handler
	JMP exit_interrupt

music_short:
	;set_timer_to_const DISK_READ_TIME - 2*TOLERANCE
	set_timer_to_target full_sector_time_minus_twice_tolerance
	JSR pt3_irq_handler

	;JSR measure_pt3_speed

	JMP exit_interrupt

music_long:
	;set_timer_to_const 2*DISK_READ_TIME
	set_timer_to_target twice_full_sector_time
	JSR pt3_irq_handler
	JMP exit_interrupt

sector_already_read:

	set_timer_to_target data_time_plus_tolerance
	JMP exit_interrupt

read_sector:

	JSR read_any_sector_in_track
	BCC sector_already_read

	;; This is tricky ! Doing a pause right after a disk read
	;; ensures that the next PT3 beat will be played
	;; at the right time but also it makes sure we
	;; resync our timings on the disk speed. This way
	;; we prevent an accumulation of errors on the timer's
	;; interrupts.

	set_timer_to_const TOLERANCE

exit_interrupt:

	pla
	tay			; restore Y
	pla
	tax			; restore X
	pla			; restore a
	;lda	$45		; restore A
	plp

	RTI

	.ifdef DEBUG

	;; My measurements give up to $C00 cycles per IRQ for PT3 play.
	;; Well below what I need.

measure_pt3_speed:
	LDY #4			; 2 cycles
	LDA (MB_Base),Y 	; 5 cycles; read MOCK_6522_T1CL
	TAX
	INY			; (*) 2 cycles
	LDA (MB_Base),Y		; (*) 5 cycles; read MOCK_6522_T1CH

	STX dummy
	STA dummy+1

	;; dummy := fst - dummy
	sub16inv dummy, full_sector_time_minus_twice_tolerance
	;; dummy := $FFFF - dummy = $FFFF - (fst - dummy)
	sub_16_to_const dummy, $FFFF

	LDY stepper
	LDA dummy + 1
	STA disk_times_hi,Y
	LDA dummy
	STA disk_times_lo,Y

	RTS

	.endif


timer_read:	.word 0
full_sector_time:	.word 0
twice_full_sector_time:	.word 0
full_sector_time_minus_twice_tolerance:	.word 0
data_time_plus_tolerance:	.word 0

	.endproc

;;; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	.proc read_any_sector_in_track
	;; The process is this :
	;; 1. We read whatever sector address is below the R/W head.
	;; 2. Then we figure out if we've already read it or not.
	;; 3. If not already read, we actually loads its data

	.ifdef DEBUG
	set_timer_to_const $FFFF
	.endif

	LDA #0			; We do it here to minimize the time
	STA buf			; between rdadr16 and read16

	ldx #SLOT_SELECT
	JSR rdadr16

	;; Errors should not happen.If they do, that'll screw
	;; the reading "choregraphy" completely.

	;BCC no_rdadr16_error
	;INC $500 + 39
;no_rdadr16_error:


	ldx sect
	lda sector_status, X

	;; DEBUG !
	;; lda #$E0
	;; JMP sector_already_read

	beq sector_already_read


	STA buf + 1
	ldx #SLOT_SELECT
	JSR read16
	;BCC no_read16_error
	;INC $500 + 36
;no_read16_error:



	;; Mark sector as read
	LDX sect
	LDA #0
	STA sector_status, X

	.ifdef DEBUG

	LDY #4			; 2 cycles
	LDA (MB_Base),Y 	; 5 cycles; read MOCK_6522_T1CL
	TAX
	INY			; (*) 2 cycles
	LDA (MB_Base),Y		; (*) 5 cycles; read MOCK_6522_T1CH

	LDY stepper
	STA disk_times_hi,Y
	TXA
	STA disk_times_lo,Y
	LDA sect
	STA disk_times_sect, Y

	SEC
	LDA #$11
	SBC sectors_to_read
	LDY sect
	STA sector_status_debug,Y

	.endif

	DEC sectors_to_read

	SEC			; Carry set = sector read
	RTS

sector_already_read:


	.ifdef DEBUG

	LDY #4			; 2 cycles
	LDA (MB_Base),Y 	; 5 cycles; read MOCK_6522_T1CL
	TAX
	INY			; (*) 2 cycles
	LDA (MB_Base),Y		; (*) 5 cycles; read MOCK_6522_T1CH

	LDY stepper
	STA disk_times_hi,Y
	TXA
	STA disk_times_lo,Y
	LDA sect
	STA disk_times_sect, Y

	.endif


	CLC
	RTS

	.endproc


;;; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	.proc handle_track_progress

	;; Make sure the file read progresses from track
	;; to track.

	;; The scheme of operations is this :
	;; - the IRQ handler the reading of the interesting
	;;   sectors in a single track.
	;; - this proc willl push the read head of the Disk II
	;;   when all the sectors of a track are read by
	;;   the IRQ handler.
	;; This is done this way because pushing the read head
	;; one track forward takes a lot of time. If the IRQ
	;; was doing it, then it would incurs a big pause.

	;; One must call this proc every now and then to help
	;; the IRQ to progress.

	;; Are we still reading some sectors in the current track ?

	LDA sectors_to_read
	BNE still_stuff_to_read

current_track_finished:

	;; Are they still tracks to read ?

	LDA current_track
	CMP last_track		; current_track - last_track
	BEQ read_more_tracks	; current_track == last_track
	BCS all_tracks_read	; This is it : current_track > last_track

read_more_tracks:
	;; The following ugly code is there to ensure that
	;; we increase the current track at the right time.
	;; That means we want the current track to reflect
	;; the actual current track...

	LDX current_track
	LDA first_track_iteration
	BNE first_iteration
	INX
	CPX last_track
	BEQ first_iteration	; track to read == last_track
	BCS all_tracks_read	; track to read > last_track

first_iteration:
	LDA #0
	STA first_track_iteration
	STX current_track


	LDX #SLOT_SELECT
	LDA current_track
	ASL			; half tracks
	JSR seek

	LDA current_track
	JSR prepare_track_read


still_stuff_to_read:
	;; At this point we either are more tracks left to
	;; read or we still have sectors to read in the current
	;; track (the last track).

	SEC
	RTS

all_tracks_read:
	;; If current_track > last_track, it means we're done
	;; reading the tracks (ie. done reading the file)

	CLC
	RTS

	.endproc

;;; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	.proc prepare_track_read

	;; A = track we want to prepare to.

	;; At this point, we expect :
	;; first_track <= A <= last_track

	;; In particular, you must never call this routine
	;; if A > last_track (this conditions
	;; shows that we are done reading the tracks)


	CMP first_track
	BEQ on_first_track

not_on_first_track:
	CMP last_track
	BEQ on_last_track

not_on_last_track:
	;; neither on first track nor on last track
	;; (so on a track between)

	LDA #0
	STA track_first_sector
	LDA #SECTORS_PER_TRACK - 1
	STA track_last_sector
	JMP done_config

on_last_track:
	;; on last track and not on first track
	LDA #0
	STA track_first_sector
	LDA last_sector
	STA track_last_sector
	JMP done_config

on_first_track:

	CMP last_track
	BEQ first_and_last_track_equal

	;;  on first track and not on last track

	LDA first_sector
	STA track_first_sector
	LDA #SECTORS_PER_TRACK - 1
	STA track_last_sector
	JMP done_config


first_and_last_track_equal:
	;;  on first track and on last track
	LDA first_sector
	STA track_first_sector
	LDA last_sector
	STA track_last_sector

done_config:

	;; Clear previous data (much easier this way
	;; than to compute what is zero and what is not)

	LDX #16
	LDA #0
clear_status:
	DEX
	STA sector_status,X
	;; DEBUG --------------------------------------------------
	.ifdef DEBUG
	STA sector_status_debug, X
	.endif
	;; --------------------------------------------------------
	BNE clear_status

	;; Configure one track read
loop_start:
	LDX track_first_sector
	LDA first_page
set_page_loop:
	STA sector_status,X
	INX
	CLC
	ADC #1
;smc0:
	CPX track_last_sector	; did we just fill the last sector ?
	BMI set_page_loop
	BEQ set_page_loop	; nope

	;;  Be ready for next track

	STA first_page

	;; Restart the disk read/music play choregraphy
	LDA #0
	STA stepper

	;; Compute how many sectors we'll need to read in this track

	LDA track_last_sector
	SEC
	SBC track_first_sector
	CLC
	ADC #1
	STA sectors_to_read

	;; Right now, sectors_to_read guards the secto reading.
	;; Therefore I set it last.

	RTS

	.endproc

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
