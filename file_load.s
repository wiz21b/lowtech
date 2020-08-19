
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

	RTS

	.endproc


	TOLERANCE = $180


	READ_SECTOR = 1
	MUSIC_LONG = 2
	MUSIC_REGULAR = 3
	MUSIC_SHORT = 4
	LOOP_STATES = 5
	STAND_BY_STATE = 6

read_sector_states:

.byte READ_SECTOR
.byte MUSIC_LONG
.byte MUSIC_REGULAR
.byte READ_SECTOR
.byte MUSIC_LONG
.byte MUSIC_REGULAR
.byte READ_SECTOR
.byte MUSIC_LONG
.byte MUSIC_REGULAR
.byte READ_SECTOR
.byte MUSIC_SHORT
.byte MUSIC_REGULAR
.byte READ_SECTOR
.byte MUSIC_LONG
.byte MUSIC_REGULAR
.byte READ_SECTOR
.byte MUSIC_LONG
.byte MUSIC_REGULAR
.byte READ_SECTOR
.byte MUSIC_LONG
.byte MUSIC_REGULAR
.byte READ_SECTOR
.byte MUSIC_SHORT
.byte MUSIC_REGULAR
.byte READ_SECTOR
.byte MUSIC_LONG
.byte MUSIC_REGULAR
.byte READ_SECTOR
.byte MUSIC_LONG
.byte MUSIC_REGULAR
.byte READ_SECTOR
.byte MUSIC_LONG
.byte MUSIC_REGULAR
.byte READ_SECTOR
.byte MUSIC_SHORT
.byte MUSIC_REGULAR
.byte READ_SECTOR
.byte MUSIC_LONG
.byte MUSIC_REGULAR
.byte READ_SECTOR
.byte MUSIC_LONG
.byte MUSIC_REGULAR
.byte READ_SECTOR
.byte MUSIC_LONG
.byte MUSIC_REGULAR
.byte READ_SECTOR
.byte MUSIC_LONG
.byte MUSIC_LONG
.byte MUSIC_LONG
.byte LOOP_STATES
STAND_BY_STATE_NDX = * - read_sector_states
	.byte STAND_BY_STATE


stepper:	.byte 0
sectors_to_read:	.byte 0
current_track:	.byte 0
sector_status:
	.repeat ::SECTORS_PER_TRACK
	.byte $0
	.endrepeat

sector_status_debug:
	.repeat ::SECTORS_PER_TRACK
	.byte $0
	.endrepeat

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

	LDA sectors_to_read
	BEQ music_long

	LDY stepper
read_sector_state:
	LDA read_sector_states,Y
	INY
	CMP #LOOP_STATES
	BNE dont_loop_states
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

music_regular:
	;set_timer_to_const DISK_READ_TIME
	set_timer_to_target full_sector_time

	JSR pt3_irq_handler
	JMP exit_interrupt

music_short:
	;set_timer_to_const DISK_READ_TIME - 2*TOLERANCE
	set_timer_to_target full_sector_time_minus_twice_tolerance
	JSR pt3_irq_handler
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
	;; The process is this :
	;; 1. We read whatever sector is below the R/W head.
	;; 2. Then we figure out if we've already read it or not.

	ldx #SLOT_SELECT
	JSR rdadr16

	;; Errors should not happen.If they do, that'll screw
	;; the reading "choregraphy" completely.

	BCC no_rdadr16_error

	;INC $500 + 39
no_rdadr16_error:
	ldx sect
	lda sector_status, X
	beq sector_already_read
	STA buf + 1
	lda #0
	sta buf

	ldx #SLOT_SELECT
	JSR read16
	BCC no_read16_error
	;INC $500 + 36

no_read16_error:

	;; This is tricky ! Doing a pause rught after a disk read
	;; ensures that the next PT3 beat will be played
	;; at the right time but also it makes sure we
	;; resync our timings on the disk speed. This way
	;; we prevent an accumulation of errors on the timer's
	;; interrupts.

	set_timer_to_const TOLERANCE

	;; Mark sector as read
	LDX sect
	LDA #0
	STA sector_status, X

	DEC sectors_to_read

	;; DEBUG -----------------------------------------------------

	LDY sect
	LDA #'R'+$80
	STA sector_status_debug,Y

exit_interrupt:
	pla
	tay			; restore Y
	pla
	tax			; restore X
	pla			; restore a
	plp

	RTI

timer_read:	.word 0
full_sector_time:	.word 0
twice_full_sector_time:	.word 0
full_sector_time_minus_twice_tolerance:	.word 0
data_time_plus_tolerance:	.word 0

	.endproc

;;; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	.proc handle_track_progress

	;; Make sure the file read progresses from track
	;; to track.

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
	BEQ first_iteration
	BCS all_tracks_read

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
	;; reading the tracks

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
	STA sector_status_debug, X
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

	;; Global calibration variables to avoid .scope hell

	CALIBRATION_RUNS = 128	;MUST BE 128 (hardcoded computations)

total_data_time:	.byte 0,0,0
total_sector_time:	.byte 0,0,0
sector_times:	.repeat CALIBRATION_RUNS
	.word 0
	.endrepeat

	.proc calibration


	JSR locate_drive_head	; Motor on !

	lda #$07
	sta buf + 1
	lda #$D0
	sta buf

	LDA #0
	STA sector_count

	STA total_sector_time
	STA total_sector_time+1
	STA total_sector_time+2

	STA total_data_time
	STA total_data_time+1
	STA total_data_time+2


	ldx #SLOT_SELECT
	JSR rdadr16

calibration_loop:
	set_timer_to_const TIMER_START

	ldx #SLOT_SELECT
	JSR read16
	read_timer2 data_times

	ldx #SLOT_SELECT
	JSR rdadr16
	read_timer2 sector_times

	LDA sector_count
	CLC
	ADC #2
	STA sector_count
	BCC calibration_loop

	LDA #0
sum_loop:
	PHA
	ASL
	TAX

	lda sector_times + 1,X
	sta sector_time+1
	lda sector_times,X
	sta sector_time

	lda data_times + 1,X
	sta data_time+1
	lda data_times,X
	sta data_time

	;; Fix the value read from the 6522 (MSB/LSB incoherence)

	fix_6522_read_value sector_time
	fix_6522_read_value data_time

	;; The 6522 counts down to zero, but we count the other way

	sub_16_to_const sector_time, TIMER_START
	sub_16_to_const data_time, TIMER_START

	;; Remove the time it took to measure the time :-)

	sub_const_to_16 sector_time, CYCLES_FOR_READING_TIMER
	sub_const_to_16 data_time, CYCLES_FOR_READING_TIMER

	CLC
	LDA data_time
	ADC total_data_time
	STA total_data_time
	LDA data_time + 1
	ADC total_data_time + 1
	STA total_data_time + 1
	LDA #0
	ADC total_data_time + 2
	STA total_data_time + 2

	CLC
	LDA sector_time
	ADC total_sector_time
	STA total_sector_time
	LDA sector_time + 1
	ADC total_sector_time + 1
	STA total_sector_time + 1
	LDA #0
	ADC total_sector_time + 2
	STA total_sector_time + 2

	PLA
	CMP #CALIBRATION_RUNS - 1
	BEQ done_loop
	CLC
	ADC #1
	JMP sum_loop
done_loop:

	;; ROL because we have 128 measurements.
	;; so 128 measurements x 2 = 256 and then
	;; I leaf the LSByte out => 128 x 2 / 256 = 1 :-)

	CLC
	ROL total_data_time
	ROL total_data_time + 1
	ROL total_data_time + 2

	CLC
	ROL total_sector_time
	ROL total_sector_time + 1
	ROL total_sector_time + 2


	;; Now the calibration is complete, we compute various
	;; timings for the IRQ handler.

	LDA total_sector_time + 1
	STA disk_irq_handler2::full_sector_time
	LDA total_sector_time + 2
	STA disk_irq_handler2::full_sector_time + 1


	CLC
	LDA total_data_time + 1
	ADC #<TOLERANCE
	STA disk_irq_handler2::data_time_plus_tolerance
	LDA total_data_time + 2
	ADC #>TOLERANCE
	STA disk_irq_handler2::data_time_plus_tolerance + 1

	CLC
	LDA disk_irq_handler2::full_sector_time
	ROL
	STA disk_irq_handler2::twice_full_sector_time
	LDA disk_irq_handler2::full_sector_time + 1
	ROL
	STA disk_irq_handler2::twice_full_sector_time + 1


	SEC
	LDA disk_irq_handler2::full_sector_time
	SBC #<(2*TOLERANCE)
	STA disk_irq_handler2::full_sector_time_minus_twice_tolerance
	LDA disk_irq_handler2::full_sector_time + 1
	SBC #>(2*TOLERANCE)
	STA disk_irq_handler2::full_sector_time_minus_twice_tolerance + 1

	RTS

data_time:	.word 0
sector_time:	.word 0

sector_count:	.byte 0
data_times:	.repeat ::CALIBRATION_RUNS
	.word 0
	.endrepeat

	.endproc



apple_model:	.byte 0
has_language_card:	.byte 0

	.proc detect_apple

	;; The following code is a slightly adapted
	;; version of what was gently provided by
	;; French Touch

        LDA $FBB3

        CMP #$06                ; IIe/IIc/IIGS = 06
        BEQ apple2_e_c_gs

	CMP #$38
	BEQ apple2

	CMP #$EA
	BEQ apple2plus

unrecognized_apple:
	LDA #'?'
quick_return:
	STA apple_model

	;; Detecting and setting up Language Card

	;; Crucial for interrupts to work !!!

	;; From the Apple 2c Reference Manual Volume 1 :

	;; " Vector location is $FFFE-$FFFF
	;;   of ROM or whichever bank of RAM is switched in.
	;;   If ROM is switched in, this vector is the address
	;;   of the Monitor's interrupt handler. If the monitor
	;;   gets the interrupt, then it dispatches to $3F0-$3F1
	;;   in case of a BRK, or $3FE-3FF else. "

	;; Same information in the Apple 2e Reference Manual.

	;; On table 14, page 132 of the Apple II Reference (Woz),
	;; the same IRQ vectors are given, and later in the book,
	;; the $FFFE vector is given too. But no explanation about
	;; the IRQ handling in the Monitor.

	;; Since I use the bank switched memory (64kb), then
	;; the $FFFE-$FFFF vector is defined by me and won't go
	;; to the monitor ('cos the RAM has been switched !!!guess!!!).
	;; So I don't have to touch $3fe/$3ff (on the 2+, 2e and 2c).

	LDA LC_RAM_SELECT
	LDA LC_RAM_SELECT

	LDA #$55
	STA $E000
	LDA $E000
	CMP #$55
	BNE no_language_card
	LDA #1
	STA has_language_card
no_language_card:

	RTS

apple2_e_c_gs:

	;; IIc ?

	LDA $FBC0               ; détection IIc
        BEQ apple2_c            ; 0 = IIc => bad guy2

	;; IIgs ou IIe ?
        SEC
        JSR $FE1F               ; TEST GS
        BCS apple2_e

apple2_gs:
	LDA #'G'
	BNE quick_return

apple2_e:
	LDA #'E'
	BNE quick_return	; Always taken

apple2_c:
	LDA #'C'
	BNE quick_return	; Always taken

apple2:
	LDA #' '
	BNE quick_return	; Always taken

apple2plus:
	LDA #'+'
	BNE quick_return	; Always taken

	.endproc

;;; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	.proc detect_mocking_board

	;; The following code is a slightly adapted
	;; version of what was gently provided by
	;; French Touch

	LDA apple_model
	CMP #'C'
	BNE not_a_2c

	;; Tip from Fenarinarsa from French Touch,
	;; activate the MB so that it is not shadowed
	;; by the mouse. In this case, I assume the
	;; mockingboard is either in slot 4 or 5.
	;; Dunno if it's always like that in the IIc...

	LDA #$FF
	STA $C404
	STA $C405
not_a_2c:

	LDA #00
	STA MB_Base
bdet:	LDA #$07		; on commence en $C7 jusqu'en $C1
	ORA #$C0		; -> $Cx
	STA MB_Base+1

	LDY #04		; $CX04
	LDA (MB_Base),Y	; timer 6522 (Low Order Counter) - attention compte à rebour !
	STA Temp		; 3 cycles
	LDA (MB_Base),Y	; + 5 cycles = 8 cycles entre les deux accès au timer
	SEC		;
	SBC Temp		;
	CMP #$F8		; -8 (compte à rebour) ?
	BEQ mb_found
	DEC bdet+1	; on décrémente le "slot" pour tester le suivant
	BNE bdet		; on boucle de 7 à 1
	JMP mb_not_found	; on est arrivé au SLOT0 donc pas de MB!
mb_found:
	RTS
mb_not_found:
	LDA #$FF
	STA MB_Base
	STA MB_Base+1
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


	.proc start_player
	lda	#0
	sta	DONE_PLAYING
	lda	#1
	sta LOOP


	jsr	mockingboard_init

	jsr	pt3_init_song
	jsr	reset_ay_both
	jsr	clear_ay_both

	rts
	.endproc
