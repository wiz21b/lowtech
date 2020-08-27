
	;; Global calibration variables to avoid .scope hell

	CALIBRATION_RUNS = 128	;MUST BE 128 (hardcoded computations)

total_data_time:	.byte 0,0,0
total_sector_time:	.byte 0,0,0
sector_times:	.repeat CALIBRATION_RUNS
	.word 0
	.endrepeat

	.proc calibration


	JSR locate_drive_head	; Motor on !

	;; We'll read garbage data, so make sure we don't put them
	;; in a unsafe place.

	lda #$B0
	sta buf + 1
	lda #$00
	sta buf

	LDA #0
	STA sector_count


	STA total_sector_time
	STA total_sector_time+1
	STA total_sector_time+2

	STA total_data_time
	STA total_data_time+1
	STA total_data_time+2


	store_16 total_sector_time, $7FFF
	store_16 total_data_time, $7FFF

	;; The first step is to gather timing
	;; We'll read 128 sectors (in the same track)
	;; The hypothesis is that the way we read sectors
	;; is fast enough so that we can read address field and
	;; data fields without ever missing any of those.

	ldx #SLOT_SELECT
	JSR rdadr16

calibration_loop:
	set_timer_to_const TIMER_START

	ldx #SLOT_SELECT
	JSR read16
	read_timer2 data_times	; sector_count will be used as an index

	ldx #SLOT_SELECT
	JSR rdadr16
	read_timer2 sector_times

	LDA sector_count
	CLC
	ADC #2
	STA sector_count
	BCC calibration_loop

	;; Now that the timings are gathered, we compute their average.

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

	sub_const_to_16 sector_time, 2*CYCLES_FOR_READING_TIMER
	sub_const_to_16 data_time, CYCLES_FOR_READING_TIMER

	;; CLC
	;; LDA data_time
	;; ADC total_data_time
	;; STA total_data_time
	;; LDA data_time + 1
	;; ADC total_data_time + 1
	;; STA total_data_time + 1
	;; LDA #0
	;; ADC total_data_time + 2
	;; STA total_data_time + 2

	;; CLC
	;; LDA sector_time
	;; ADC total_sector_time
	;; STA total_sector_time
	;; LDA sector_time + 1
	;; ADC total_sector_time + 1
	;; STA total_sector_time + 1
	;; LDA #0
	;; ADC total_sector_time + 2
	;; STA total_sector_time + 2

	cmp_16 data_time, total_data_time
	bcs no_new_mini_data_time
	copy_16 total_data_time, data_time
no_new_mini_data_time:

	cmp_16 sector_time, total_sector_time
	bcs no_new_mini_sector_time
	copy_16 total_sector_time, sector_time
no_new_mini_sector_time:

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

	;; CLC
	;; ROL total_data_time
	;; ROL total_data_time + 1
	;; ROL total_data_time + 2

	;; CLC
	;; ROL total_sector_time
	;; ROL total_sector_time + 1
	;; ROL total_sector_time + 2


	;; Now the calibration is complete, we compute various
	;; timings for the IRQ handler.

	;; full sector time

	LDA total_sector_time
	STA disk_irq_handler2::full_sector_time
	LDA total_sector_time + 1
	STA disk_irq_handler2::full_sector_time + 1


	;; total data time + TOLERANCE

	CLC
	LDA total_data_time
	ADC #<TOLERANCE
	STA disk_irq_handler2::data_time_plus_tolerance
	LDA total_data_time + 1
	ADC #>TOLERANCE
	STA disk_irq_handler2::data_time_plus_tolerance + 1

	;; 2 x full sector time

	CLC
	LDA disk_irq_handler2::full_sector_time
	ROL
	STA disk_irq_handler2::twice_full_sector_time
	LDA disk_irq_handler2::full_sector_time + 1
	ROL
	STA disk_irq_handler2::twice_full_sector_time + 1


	;; full sector time - 2 x tolerance

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

	.proc locate_drive_head

	; Restart the motor

	ldx #SLOT_SELECT
.if ::DRIVE_SELECT = $80
	LDA DRV2_SLCT, X
.endif
	LDA MOTOR_ON, X

	LDA #SLOT_SELECT
	STA slotz
	CLC
notyet:
	ldx #SLOT_SELECT
	jsr rdadr16
	bcs notyet

	;; Now we know where it is, set up the seek routine to go
	;; to our destinatiob

	LDA track
	ASL
	STA curtrk

	RTS
	.endproc


;;; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


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
