
;;; This code is (c) 2019 Stéphane Champailler
;;; It is published under the terms of the
;;; GNU GPL License Version 3.

;;; Part of this code (see below) is copied from the PT3 player by Vince "Deater" Weaver and is licensed accordingly

	;; .import rdadr16, read16, buf, curtrk, seek, sect
	;; .import current_track, init_file_load, read_sector_in_track, read_in_pogress, read_sector_status

	.include "defs.s"



	debug_ptr = $86
	debug_ptr2 = $88
	dummy_ptr2	= $8A
	dummy_ptr	= $8C
	dummy_pointer	= $8E

	.macro print_str data, address
	LDA #<(data)
	STA print_str_helper::smc1+1
	LDA #>(data)
	STA print_str_helper::smc1+1+1

	LDA #<(address)
	STA print_str_helper::smc2+1
	LDA #>(address)
	STA print_str_helper::smc2+1+1

	JSR print_str_helper
	.endmacro


	.macro print_timer source
	lda source + 1
	jsr byte_to_text
	INC debug_ptr		; A byte takes 2 characters on screen
	INC debug_ptr

	lda source
	jsr byte_to_text
	INC debug_ptr
	INC debug_ptr
	.endmacro


	.macro print_timer2 source

	lda source + 1
	jsr byte_to_text
	INC debug_ptr		; A byte takes 2 characters on screen
	INC debug_ptr

	lda source
	jsr byte_to_text
	INC debug_ptr
	INC debug_ptr

	.endmacro



;;; ==================================================================

	.segment "CODE"

;; 	fix_6522_read_value tester
;; 	fix_6522_read_value tester2
;; tester:	.word $03E6
;; tester2:	.word $03FE

	JMP start_point

	.align 256
	PT3_LOC = *
	.incbin "data/2UNLIM2.pt3" ;FR.PT3"
	;.align 256

disk_toc:
	;; 1st track, 1st sector, last track, last sector, 1st memory page
	.byte 3,9,4,11,$E0
	.byte 6,0,6,15,$E0

	.byte 0,0,0,3,$04
	.byte 6,4,7,2,$E0
	.byte 0,0,0,3,$04

	.include "read_sector.s" ; RWTS code

	.include "pt3_lib/zp.inc"
	.include "pt3_lib/hardware.inc" ; some firmware locations
	.include "pt3_lib/pt3_lib_core.s"
	.include "pt3_lib/pt3_lib_init.s"
	.include "pt3_lib/pt3_lib_mockingboard_setup.s"
	;; .include "pt3_lib/interrupt_handler.s"
	.include "pt3_lib/pt3_lib_irq_handler.s"
	.include "file_load.s"



	;.include "irq.s"

	;; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	.proc print_str_helper
	;;  not in a proc so I can SMC from the macro
	LDY #0
loop:
smc1:
	LDA $0000,Y
	BNE not_end
	RTS
not_end:
	CLC
	;; ASCII is : $20 = space ! " # ... 0 (= $30) 1 2 3 ... A (= $41)
	;; Apple :    $A0 = space,...       0 (= $B0),...       A (= $C1)
	ADC #$80
smc2:
	STA $0000,Y
	INY
	JMP loop
	.endproc

	.proc print_text
	.endproc

	;; ASCII is : $20 = space ! " # ... 0 (= $30) 1 2 3 ... A (= $41)
	;; Apple :    $A0 = space,...       0 (= $B0),...       A (= $C1)
hexa_apple:
	.byte $30,$31,$32,$33,$34,$35,$36,$37,$38,$39
	.byte $41,$42,$43,$44,$45,$46
hexa_apple_inverse:
	.byte $30,$31,$32,$33,$34,$35,$36,$37,$38,$39
	.byte $01,$02,$03,$04,$05,$06

	;; .byte $7,$8,$9,$A,$B,$C,$D,$E,$F,$10,$11,$12,$13
	;; .byte $14,$15,$16,$17,$18,$19,$1A,$1B,$1C,$1D,$1E,$1F

txt_ofs:
	.word $400,$480,$500,$580,$600,$680,$700,$780
	.word $428,$4A8,$528,$5A8,$628,$6A8,$728,$7A8
	.word $450,$4D0,$550,$5D0,$650,$6D0,$750,$7D0

mb_header:	.byte "MOCKINGBOARD:",0
apple_header:	.byte "APPLE 2",0
lang_card_text:	.byte "LANG. CARD",0




;;; ==================================================================
;;; ==================================================================
;;; ==================================================================
;;; ==================================================================

start_point:
	JSR show_screen
no_key:
	JSR read_keyboard
	BEQ no_key

	JSR detect_apple
	JSR clear_txt

	JSR detect_mocking_board
	JSR clear_txt

	jsr	mockingboard_detect
	bcc	mocking_not_found
	jsr	mockingboard_patch
mocking_not_found:

	JSR check_cycles

	JSR check_load_file_without_irq
	JSR clear_txt

all_tests_loop:

	jsr stop_mockingboard_interrupts

	JSR clear_txt
	JSR check_diskii

	JSR clear_txt
	JSR calibration_check

	JSR clear_txt
	JSR check_music_disk_based_replay

	JSR clear_txt
	JSR check_basic_irq_plus_disk_replay2

	;; JSR clear_txt
	;; JSR check_basic_irq_replay

	;; JSR clear_txt
	;; JSR check_basic_irq_plus_disk_replay


	JMP all_tests_loop

	BRK

;;; ==================================================================
	.proc check_cycles

	print_str hardware_detect_txt, $400
	print_str cycles_to_read_timer_txt, $500
	print_str version_txt, $550

	.ifdef APPLEWIN_FIX
	print_str applewinfix_in_place, $580
	.endif

	;; See https://github.com/AppleWin/AppleWin/issues/701

	LDA MB_Base + 1
	STA smc1
	STA smc2

	LDY #5
	LDA #$01
	smc1 = * + 2
	STA $C504
	LDA #$F0
	smc2 = * + 2
	STA $C505

	;; I pick a 5 cycles instructions to read the MSB
	;; I expect the MSB to change from $F0 to $EF during
	;; the LDA cycles, just before it actually fetches the
	;; MSB value (on the last of its cycles).

	LDA (MB_Base),Y		; On AppleWin, here, A == $F0 (***)

	CMP #$F0
	BNE not_applewin

	print_str applewin_detected, $600
	jmp done_awin_detect
not_applewin:
	print_str applewin_not_detected, $600

done_awin_detect:

	store_16 debug_ptr, $500
	set_timer_to_const $FFFF
	read_timer2 dummy

	LDA dummy+1
	JSR byte_to_text
	INC debug_ptr
	INC debug_ptr
	LDA dummy
	JSR byte_to_text


	print_str hitakey_txt, $650

no_key:
	JSR read_keyboard
	BEQ no_key

	RTS

	.include "build/version.inc"
applewinfix_in_place:	.byte "APPLEWIN FIX COMPILED IN",0
applewin_detected:	.byte "APPLEWIN WAS DETECTED !",0
applewin_not_detected:	.byte "APPLEWIN NOT DETECTED !",0
cycles_to_read_timer_txt:	.byte "???? CYCLES TO READ TIMER",0
hardware_detect_txt:	.byte "HARDWARE DETECTION",0
hitakey_txt:	.byte "HIT A KEY TO CONTINUE",0

	.align 256		; Avoid page boundary crossing penalty
dummy:	.word 0
sector_count:	.byte 0

	.endproc
;;; ==================================================================

	.proc check_load_file_without_irq
	JSR locate_drive_head	; Motor on !
	LDA #2
	JSR load_file_no_irq

	print_str space_line, $680
	print_str space_line, $700
	print_str space_line, $780
	print_str blank_line, $428
	print_str message1, $4A8
	print_str message2, $528
	print_str message3, $5A8
	print_str message4, $628
	print_str blank_line, $6A8
	print_str space_line, $728
	print_str space_line, $7A8
	print_str space_line, $450

no_key:
	JSR read_keyboard
	BEQ no_key
	RTS
space_line:	.byte "                                        ",0
blank_line:	.byte "########################################",0
message1:	.byte "--- IF THE SCREEN IS GARBLED AND IF  ---",0
message2:	.byte "--- YOU CAN READ THIS THEN THE FIRST ---",0
message3:	.byte "--- TEST IS O.K.                     ---",0
message4:	.byte "---                      HIT A KEY ! ---",0
	.endproc

;;; ==================================================================

	.proc calibration_check

	CALIBRATION_RUNS = 128	;MUST BE 128 (hardcoded computations)
	TIMES_YPOS = $700
	TIMES2_YPOS = $780

	print_str calibration_header, $400
	print_str wait, $500

	JSR calibration


	LDA #0
draw_loop:
	PHA
	ASL
	TAX

	lda sector_times + 1,X
	sta sector_time+1
	lda sector_times,X
	sta sector_time

	;; lda data_times + 1,X
	;; sta data_time+1
	;; lda data_times,X
	;; sta data_time

	;; Fix the value read from the 6522 (MSB/LSB incoherence)

	fix_6522_read_value sector_time
	;fix_6522_read_value data_time

	;; The 6522 counts down to zero, but we count the other way

	sub_16_to_const sector_time, TIMER_START
	;sub_16_to_const data_time, TIMER_START

	;; Remove the time it took to measure the time :-)

	sub_const_to_16 sector_time, CYCLES_FOR_READING_TIMER
	;sub_const_to_16 data_time, CYCLES_FOR_READING_TIMER

	;; scale x2 to have a better picture

	CLC
	LDA sector_time
	ROL
	LDA sector_time + 1
	ROL

	SEC
	SBC #>(2*ONE_80TH)
	CLC
	ADC #20
	TAX
	LDA #'S'+$80
	STA $580,X

	PLA
	CMP #CALIBRATION_RUNS - 1
	BEQ done_loop
	CLC
	ADC #1
	JMP draw_loop
done_loop:

	print_str mire, $500
	print_str mire, $600
	print_str times_txt, TIMES_YPOS
	print_str times2_txt, TIMES2_YPOS

	store_16 debug_ptr, TIMES_YPOS + 18
	print_timer2 total_data_time
	store_16 debug_ptr, TIMES2_YPOS + 18
	print_timer2 total_sector_time

	print_str hitakey_txt, $650
no_key:
	JSR read_keyboard
	BEQ no_key

	RTS

sector_time:	.word 0

wait:			.byte "PLEASE WAIT...",0
calibration_header:	.byte "CALIBRATION",0
mire:	.byte "--------------------!-------------------",0
times_txt:	.byte "MIN DATA READ:   $.... CYCLES",0
times2_txt:	.byte "MIN SECTOR READ: $.... CYCLES, EXP:$31E7",0
hitakey_txt:	.byte "HIT A KEY TO CONTINUE",0

	.endproc

;;; ==================================================================

	.proc check_music_disk_based_replay

	lda #$07
	sta buf + 1
	lda #$D0
	sta buf

	print_str disk_replay_header, $400

	;; LDX #$FF
	;; STX read_sector_simulation

	JSR locate_drive_head	; Motor on !
	JSR start_player


infiniloop2:

	inc $400+39		; Show we're doing something

	ldx #SLOT_SELECT
	JSR rdadr16
	ldx #SLOT_SELECT
	JSR read16
	ldx #SLOT_SELECT
	JSR rdadr16

	JSR pt3_irq_handler

	JSR read_keyboard
	BEQ no_key

	jsr	reset_ay_both
	jsr	clear_ay_both

	RTS
no_key:

	JMP infiniloop2

disk_replay_header:	.byte "DISK REPLAY AT 40HZ",0

	.endproc


;;; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	.proc check_basic_irq_replay

	print_str irq_replay_header, $400

	JSR start_player

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


	set_irq_vector basic_irq_handler


	JSR start_interrupts
	set_timer_to_const 1022000/50

infiniloop:
	JSR read_keyboard
	BEQ no_key
	jsr stop_mockingboard_interrupts
	jsr	reset_ay_both
	jsr	clear_ay_both
	RTS
no_key:

	JMP infiniloop

irq_replay_header:	.byte "BASIC IRQ REPLAY AT 50HZ",0

	.endproc


	.proc basic_irq_handler

	php
	pha
	txa
	pha			; save X
	tya
	pha			; save Y

	inc $480

	;; FIXME this must be SMC'ed to handle MockingBoard
	;; on another port.
	LDY #$04
	LDA (MB_Base),Y
	;LDA	$C404		; Allow the next IRQ from the 6522

	JSR pt3_irq_handler

exit_interrupt:

	pla
	tay			; restore Y
	pla
	tax			; restore X
	pla			; restore a
	plp
	RTI

	.endproc



;;; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;



;;; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;



	.proc check_basic_irq_plus_disk_replay2

	LDA #0
	STA big_loops
	STA loaded_file

	print_str irq_disk_replay_header, $400
	print_str track_message, $500

	print_str constants_message, $650
	store_16 debug_ptr, $6D0
	print_timer the_tolerance
	inc debug_ptr
	print_timer disk_irq_handler2::full_sector_time
	inc debug_ptr
	print_timer disk_irq_handler2::data_time_plus_tolerance
	inc debug_ptr
	print_timer disk_irq_handler2::twice_full_sector_time
	inc debug_ptr
	print_timer disk_irq_handler2::full_sector_time_minus_twice_tolerance

	JSR start_player



	set_irq_vector disk_irq_handler2

	LDA loaded_file
	JSR init_file_load

	;; Make the test reproducible
wait_sector_zero:
	ldx #SLOT_SELECT
	JSR rdadr16
	LDA sect
	BNE wait_sector_zero

	JSR start_interrupts
	;set_timer_to_const 1022000/40

infiniloop:
	JSR display_track_info
	;JSR display_timings_info

	LDA sectors_to_read_in_track
	BNE still_stuff_to_read

	INC big_loops
	LDA big_loops
	ADC #'A'+$80
	STA $400 + 39

	JSR display_track_info
	JSR display_timings_info

	JSR handle_track_progress
	BCS still_stuff_to_read


	LDA loaded_file
	CLC
	ADC #1
	AND #1
	STA loaded_file

	JSR init_file_load

still_stuff_to_read:


	JSR read_keyboard
	BEQ infiniloop

	jsr stop_mockingboard_interrupts
	jsr	reset_ay_both
	jsr	clear_ay_both
	RTS



display_track_info:

	lda current_track
	clc
	adc #3
	asl
	tax
	lda txt_ofs,x
	sta debug_ptr
	lda txt_ofs+1,x
	sta debug_ptr+1

	lda current_track
	jsr byte_to_text

	inc debug_ptr
	inc debug_ptr
	inc debug_ptr

	ldy #15
show_sector_status:
	lda sector_status_debug,y
	beq to_read
	tax
	dex
	lda hexa_apple_inverse,X
	jmp was_read
to_read:
	lda #'.'+$80
was_read:
	sta (debug_ptr),Y
	dey
	bpl show_sector_status

	RTS


display_timings_info:
	LDA #0
	STA counter
loop1:
	;; Counter & 15 == row
	lda counter
	and #15
	clc
	ADC #4
	asl
	tax
	lda txt_ofs,x
	sta debug_ptr
	lda txt_ofs+1,x
	sta debug_ptr+1

	;; (counter >> 4) == column
	LDA counter
	LSR
	LSR
	LSR
	LSR
	mul_a_by_5

	;; The board is on the right side of the screen
	CLC
	ADC #21

	ADC debug_ptr
	STA debug_ptr
	LDA #0
	ADC debug_ptr+1
	STA debug_ptr+1

	LDX counter
	LDA disk_times_hi,X
	STA dummy + 1
	LDA disk_times_lo,X
	STA dummy

	LDA #$0
	CMP dummy + 1
	BNE not_zero
	CMP dummy
	BNE not_zero

	LDA #'.'+$80
	LDY #0
	STA (debug_ptr),Y
	INC debug_ptr

	LDA counter
	JSR byte_to_text

	LDY #2
	LDA #'.'+$80
	STA (debug_ptr),Y
	INY
	LDA #' ' + $80
	STA (debug_ptr),Y

	JMP display_done

not_zero:
	;fix_6522_read_value dummy
	sub_16_to_const dummy, $FFFF

	LDA dummy + 1
	JSR byte_to_text
	INC debug_ptr
	INC debug_ptr
	LDA dummy
	JSR byte_to_text

	INC debug_ptr
	INC debug_ptr
	LDX counter
	LDA disk_times_sect,X
	TAX
	LDA hexa_apple_inverse,X
	LDY #0
	STA (debug_ptr),Y

display_done:
	LDY counter
	LDA #$00
	;; STA disk_times_hi,Y
	;; STA disk_times_lo,Y


	INC counter
	LDA counter
	CMP #48
	BEQ done_looping
	JMP loop1
done_looping:

	;; LDY #1
	;; LDA disk_times_lo,Y
	;; ADC #1
	;; STA disk_times_lo,Y

	RTS

the_tolerance:	.word TOLERANCE
loaded_file:	.byte 0
big_loops:	.byte 0
counter:	.byte 0
dummy:	.word 0

irq_disk_replay_header:	.byte "ADVANCED IRQ + DISK READ REPLAY",0
track_message:	.byte "TR 0123456789ABCDEF  IDLE TIME",0
constants_message:	.byte "T... S... D+T. 2*S. S-2*T",0
	.endproc



;;; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


	.proc stop_mockingboard_interrupts
	SEI
	lda #$0		; One-shot mode, no PB7
	ldy #$0B
	sta (MB_Base),Y ; MOCK_6522_ACR

	lda #%01111111		; Clear all interrupt enable bits
				;sta MOCK_6522_IER
	LDY #$0E
	sta (MB_Base),Y
	CLI

	RTS
	.endproc

;;; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	.proc check_diskii

	STA KBD_CLEAR

	print_str header, $400
	print_str seek_header, $5D0

all_tracks_loop:
	print_str track0_header, $480

	JSR locate_drive_head	; Motor on
	lda #$07
	sta buf + 1
	lda #$D0
	sta buf

	;; Make sure we're not bothered by interrupts
	;; (this code may be useless, depending on the context)


	LDA #0
	STA current_track
        ldx #SLOT_SELECT
	JSR seek

	print_str blank_line_header, $480

	;.align 256, $EA		; NOP opcode
track_loop:

	LDA #256-2 ;; Go back one iteration (see timer init below)
	STA sector_count

	;; Stabilize the read process. This way, all the
	;; sectors are read in the same conditions.

	ldx #SLOT_SELECT
	jsr rdadr16
	ldx #SLOT_SELECT
	jsr read16


	;; A dummy read to make sure the first timer read will be
	;; done at the same moment as the other iterations

	;; NOTE 1 : At this point, it'll write its results in
	;; read_sectors + 254 so make sure to have enough
	;; dummy buffer

	read_timer2 read_sectors

	;; Dive there to make sure we time the first iteration just
	;; like the others.

	jmp end_loop

sector_loop:
	;; How much time to readaddr

	;; Be careful ! We start measuring at an unknown place here.
	;; It is expected to be right after the data portion of the
	;; sector. But between the enf of that portion and the
	;; beginning of the addr field, remember there's a small gap.
	;; So what we measure here is the time to read that gap plus
	;; the time to read the addr field.

	ldx #SLOT_SELECT
	jsr rdadr16
	;bcs read_addr_error

;; 	ldx #25
;; read_addr_error:
;; 	dex
;; 	bne read_addr_error

	read_timer2 addr_times

	;; Remember what we have read (so we can verify that
	;; we actually read what we expect to read)

	LDX sector_count	; 4 cycles
	LDA sect		; 4 cycles
	STA read_sectors,X	; 5 cycles
	LDA track		; 4 cycles
	STA read_tracks,X	; 5 cycles => total = 22 cycles

	;; How much time to read data

read_data_error:
	ldx #SLOT_SELECT
	jsr read16
	bcs read_data_error
	read_timer2 data_times

end_loop:
	LDA sector_count
	CLC
	ADC #2
	STA sector_count

	set_timer_to_const TIMER_START

	LDA sector_count
	CMP #SECTORS_PER_TRACK*2
	BNE sector_loop

	JSR read_keyboard
	BEQ no_key
	RTS
no_key:
	JSR show_track

	LDA current_track
	CMP #TRACKS_PER_SIDE - 1
	BNE next_track

	JMP all_tracks_loop
	RTS

next_track:

	INC current_track

	set_timer_to_const TIMER_START

	JMP no_track_error
error_track:
	LDA current_track
	CLC
	ADC #'0'
	STA $400
no_track_error:
	LDA current_track
	ASL
        ldx #SLOT_SELECT
	JSR seek
	BCS error_track

	;; Looking at seek's routine, it looks like it spend
	;; some time on waiting for read head stabilisation.
	;; Therefore, I don't need to wait.

	read_timer_direct timer
	fix_6522_read_value timer
	sub_16_to_const timer, TIMER_START

	LDA current_track
	AND #$7
	STA smc + 1
	ASL			; mul A by 5
	ASL
smc:
	ADC #$0

	ADC #<$650
	STA debug_ptr
	LDA #>$650
	STA debug_ptr + 1
	print_timer timer


	JMP track_loop



	;; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	;; Display routines

show_track:
	LDA #0
	STA loop_sect

show_track_loop:

 	LDA loop_sect
	CLC
	LSR

	;; A = sector number
	CLC
	ASL
	ADC #4
	TAX
	LDA txt_ofs,X
	STA debug_ptr
	LDA txt_ofs+1,X
	STA debug_ptr+1

	LDA current_track
	AND #$1
	BEQ first_col
	LDA #20
first_col:

	CLC
	ADC debug_ptr
	STA debug_ptr
	LDA #0
	ADC debug_ptr+1
	STA debug_ptr+1


	LDX loop_sect
	LDA read_tracks,X
	TAX

	;LDA current_track
	jsr byte_to_text
	INC debug_ptr
	INC debug_ptr
	INC debug_ptr

	LDX loop_sect
	LDA read_sectors,X
	TAX

	LDA hexa_apple,X
	CLC
	ADC #$80
	LDY #0
	sta (debug_ptr),Y
	INC debug_ptr

	INC debug_ptr

	LDA MB_Base
	CMP #$FF
	BNE has_mb
	JMP skip_mb_data
has_mb:
	;; Copy some data to ease computations

	LDX loop_sect

	lda addr_times + 1,X
	sta addr_time+1
	lda addr_times,X
	sta addr_time

	lda data_times + 1,X
	sta data_time+1
	lda data_times,X
	sta data_time

	;; Fix the value read from the 6522 (MSB/LSB incoherence)

	fix_6522_read_value addr_time
	fix_6522_read_value data_time

	;; The 6522 counts down to zero, but we count the other way

	sub_16_to_const addr_time, TIMER_START
	sub_16_to_const data_time, TIMER_START

	;; Remove the time it took to measure the time :-)

	sub_const_to_16 addr_time, CYCLES_FOR_READING_TIMER
	sub_const_to_16 data_time, CYCLES_FOR_READING_TIMER

	;; Compute sector time
	copy_16 sector_time, data_time

	sub16 sector_time, addr_time

	;; Adjust for timer code
	sub_const_to_16 sector_time, CYCLES_FOR_READING_TIMER+22

	print_timer2 addr_time
	INC debug_ptr
	print_timer2 sector_time

	;add16 data_time, addr_time

	INC debug_ptr
	print_timer data_time

skip_mb_data:
	LDA loop_sect
	CLC
	ADC #2
	STA loop_sect

	CMP #SECTORS_PER_TRACK*2
	BEQ done_showing_track
	JMP show_track_loop
done_showing_track:
	rts


a_pause:
	STY a_pause2+1
a_pause2:
	LDY #95
a_pause1:
	DEY			; 2 cycles
	BNE a_pause1		; 3 cycles
	DEX
	BNE a_pause2
	CLC
	RTS

loop_sect:	.byte 0
sector_count:	.byte 0
timer:	.word 0
timer2:	.word 0
timer3:	.word 0

sector_time:	.word 0
data_time:	.word 0
addr_time:	.word 0

	;; The timer read functions will put their result here
	;; If we have page cros boundaries, then the timer
	;; function will be a cycle off. Since we "fix" the LSB
	;; once it is read and that fix is based on the number of cycles
	;; it took to read the MSB, a page boundary crossing can
	;; change the way the fix works. This could lead for example
	;; a fix that instead of turing a LSB=9 into a 0 to a LSB=9
	;; into a $FF, a 255 cycles difference !

	.align 256
read_sectors:	.word 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0 ; 16 words
read_tracks:	.word 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
addr_times:	.word 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
data_times:	.word 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
total_times:	.word 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0

	;; See NOTE 1 above (and don't move read_sectors)
	.word 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	.word 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	.word 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0

header:	.byte "TR S ADDR DATA SUM  TR S ADDR DATA SUM",0
seek_header:	.byte "TRACK SEEK TIME:",0
track0_header:	.byte "    *** GOING BACK TO TRACK ZERO ***    ",0
blank_line_header:	.byte "                                        ",0

current_track:	.byte 0
	.endproc







	.proc clear_txt

	LDA #$A0
	LDY #$0
clear:
	STA $400,Y
	STA $500,Y
	STA $600,Y
	STA $700,Y
	DEY
	BNE clear

	print_str apple_header, $750 + 20

	LDA apple_model
	CLC
	ADC #$80
	STA $750 + 20 + 7

	print_str mb_header, $750

	LDA #$50 + 14
	STA debug_ptr
	LDA #$07
	STA debug_ptr + 1
	print_timer MB_Base

	LDA has_language_card
	BEQ no_lang_card
	print_str lang_card_text, $750 + 20 + 7 + 2

no_lang_card:

	LDX #40
flash:
	LDA $750-1,X
	CMP #$C0
	BPL letters
	SEC
	SBC #$80
	BCS donesub
letters:
	SEC
	SBC #$C0
donesub:
	STA $750-1,X
	DEX
	BNE flash

	RTS

	.endproc


;;; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; 	.proc scroll_text

;; 	LDA #0
;; line_loop:
;; 	STA line_count

;; 	TAY

;; 	ASL
;; 	TAX
;; 	LDA txt_ofs+1,X
;; 	STA debug_ptr + 1
;; 	LDA txt_ofs,X
;; 	STA debug_ptr

;; 	INY
;; 	TYA
;; 	ASL
;; 	TAX
;; 	LDA txt_ofs+1,X
;; 	STA debug_ptr2 + 1
;; 	LDA txt_ofs,X
;; 	STA debug_ptr2

;; 	LDY #39
;; move_line:
;; 	LDA (debug_ptr2),Y
;; 	STA (debug_ptr),Y
;; 	DEY
;; 	BPL move_line

;; 	LDA line_count
;; 	CLC
;; 	ADC #1
;; 	CMP #23
;; 	BNE line_loop


;; ;; 	LDA #23
;; ;; 	ASL
;; ;; 	TAX
;; ;; 	LDA txt_ofs+1,X
;; ;; 	STA debug_ptr + 1
;; ;; 	LDA txt_ofs,X
;; ;; 	STA debug_ptr

;; ;; 	LDY #39
;; ;; 	LDA #' '+$80
;; ;; clear_line:
;; ;; 	STA (debug_ptr),Y
;; ;; 	DEY
;; ;; 	BNE clear_line

;; 	rts
;; line_count:	.byte 0

;; 	.endproc

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


	.proc read_keyboard

	LDA KBD_INPUT
	BPL no_good_key
	STA KBD_CLEAR
	RTS
no_good_key:
	LDA #$0
	RTS
	.endproc


	;.segment "RAM_A000"

	;; Approx 1256 bytes

	; if you're self patching, detect has to be after
	; interrupt_handler.s
	.include "pt3_lib/pt3_lib_mockingboard_detect.s"
	.include "file_load_init.s"




	.proc show_screen

	store_16 smc1+1, $400
	store_16 smc2+1, intro_screen

	LDY #4
copy_screen:
	LDX #0
copy_block:
smc2:
	LDA intro_screen,X
smc1:
	STA $400,X
	DEX
	BNE copy_block

	INC smc1 + 2
	INC smc2 + 2
	DEY
	BNE copy_screen
	RTS
	.endproc

intro_screen:
	.incbin "build/introtext.bin"
