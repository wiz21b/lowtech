	KBD_CLEAR = $C010
	KBD_INPUT = $C000


;;; This code is (c) 2019 Stéphane Champailler
;;; It is published under the terms of the
;;; GNU GPL License Version 3.

;;; Part of this code (see below) is copied from the PT3 player by Vince "Deater" Weaver and is licensed accordingly

	;; .import rdadr16, read16, buf, curtrk, seek, sect
	;; .import current_track, init_file_load, read_sector_in_track, read_in_pogress, read_sector_status

	.include "defs.s"

	.macro set_timer_to_const value

	LDY #4
	lda	#<(value)
	sta	(MB_Base),Y	; write into low-order latch,

	;; Once the MSB is set, the counter starts counting

	INY
	lda	#>(value)
	sta	(MB_Base),Y	; write into high-order latch

	.endmacro

	MB_Base = $F0
	Temp = $FF
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

	;SLOT_SELECT	= $60	; 0 (drive 1) 110 (slot 6) 0000
	;; MOCK_6522_ACR	= $C40B	; 6522 #1 auxilliary control register
	;; MOCK_6522_IER	= $C40E	; 6522 #1 interrupt enable register
	;; MOCK_6522_T1CL	= $C404	; 6522 #1 t1 low order latches
	;; MOCK_6522_T1CH	= $C405	; 6522 #1 t1 high order counter




	CYCLES_FOR_READING_TIMER = 28 	; not entirely exact !
					; the first read_timer shoul not
					; include the last STA.

	.macro read_timer2 target

	;; Total : 28 cycles. Don't forget to remove those
	;; from the total measurements, else you'll time
	;; the chronometer time as well !

	LDY #4			; 2 cycles
	LDX sector_count	; 4 cycles

	;; Read LSB *first* (See 6522 counter fix macro below)

	LDA (MB_Base),Y 	; 5 cycles; read MOCK_6522_T1CH
	sta target, X		; (*) 5 cycles

	;; Read MSB
	INY			; (*) 2 cycles
	LDA (MB_Base),Y		; (*) 5 cycles; read MOCK_6522_T1CL
	sta target+1,X		; 5 cycles

	;; (*) cycles that count as "time between reading
	;; LSB and MSB)

	.endmacro


	.macro read_timer_direct target

	LDY #4			; 2 cycles
	LDA (MB_Base),Y 	; 5 cycles; read MOCK_6522_T1CH
	sta target		; (*) 4 cycles
	INY			; (*) 2 cycles
	LDA (MB_Base),Y		; (*) 5 cycles; read MOCK_6522_T1CL
	sta target+1		; 4 cycles

	.endmacro



	;; Number of cycles betwwen the moment we read the
	;; LSB of the 6522 counter and the MSB.
	CYCLES_BETWEEN_LSB_MSB_6522_READ = 12

	.macro fix_6522_read_value read_value_6522
	.scope
	;; When reading the 6522 counter, LSB first then MSB,
	;; the LSB is always n cycles too early compared to
	;; the moment were the MSB was read. By substracting
	;; those cycle from the LSB, we "delay" it to the moment
	;; where the MSB was read. So it has the value it would
	;; have had if it were to be read at the same time the
	;; the MSB is read. Notice we don't touch the MSB.

	;; read_value_6522 = value (word) that was read from
	;; the 6522 counter. This must have been read LSB
	;; first and MSB second.

	LDA read_value_6522
	SEC
	SBC #CYCLES_BETWEEN_LSB_MSB_6522_READ
	STA read_value_6522

	.endscope
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
	.align 256


	.include "read_sector.s" ; RWTS code


	.macro sector_read_code
	;; regular_sector_read_test

	;; LATCH_ADVANCED_STATUS = 1
	;; SECTOR_READ = 2
	;; SECTOR_SEEK = 4
	;; SECTOR_RDADR = 8


	LDA read_in_pogress
	BEQ no_read

	JSR read_sector_in_track

	LDA read_sector_status
	AND #SECTOR_READ
	BNE skip_pause

	LDA read_sector_status
	AND #SECTOR_RDADR
	BNE data_read

	LDA read_sector_status
	AND #SECTOR_SEEK
	BNE latch_advance
	BEQ skip_pause

latch_advance:
	LDA #0
	STA sector_shift
	jmp skip_pause
no_read:
        ldx #SLOT_SELECT
	JSR rdadr16
data_read:
	ldx #SLOT_SELECT
	jsr read16

no_latch_advance:
skip_pause:
	LDA curtrk
	CLC
	ROR
	TAX
	LDA hexa_apple,X
	STA $7d0+38
	.endmacro


	.include "pt3_lib/zp.inc"
	.include "pt3_lib/hardware.inc" ; some firmware locations
	.include "pt3_lib/pt3_lib_core.s"
	.include "pt3_lib/pt3_lib_init.s"
	.include "pt3_lib/pt3_lib_mockingboard_setup.s"



	;.include "pt3_lib/interrupt_handler.s"
	; if you're self patching, detect has to be after
	; interrupt_handler.s
	.include "pt3_lib/pt3_lib_mockingboard_detect.s"


	.include "irq.s"

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
	ADC #$80
smc2:
	STA $0000,Y
	INY
	JMP loop
	.endproc

hexa_apple:
	.byte $30,$31,$32,$33,$34,$35,$36,$37,$38,$39
	.byte $1,$2,$3,$4,$5,$6
	.byte $7,$8,$9,$A,$B,$C,$D,$E,$F,$10,$11,$12,$13
	.byte $14,$15,$16,$17,$18,$19,$1A,$1B,$1C,$1D,$1E,$1F

txt_ofs:
	.word $400,$480,$500,$580,$600,$680,$700,$780
	.word $428,$4A8,$528,$5A8,$628,$6A8,$728,$7A8
	.word $450,$4D0,$550,$5D0,$650,$6D0,$750,$7D0

mb_header:	.byte "MOCKINGBOARD:",0
apple_header:	.byte "APPLE 2",0
lang_card_text:	.byte "LANG. CARD",0

	READ_SECTOR = 1
	MUSIC_LONG = 2
	MUSIC_REGULAR = 3
	MUSIC_SHORT = 4

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

	NB_READ_SECTOR_STATES = * - read_sector_states


;;; ==================================================================
;;; ==================================================================
;;; ==================================================================
;;; ==================================================================

start_point:
	JSR detect_apple

	JSR clear_txt

	JSR detect_mocking_board
	JSR clear_txt

	jsr	mockingboard_detect
	bcc	mocking_not_found
	jsr	mockingboard_patch
mocking_not_found:


	;; Crucial for interrupts to work !!!

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

	JSR clear_txt


	lda #$07
	sta buf + 1
	lda #$D0
	sta buf


all_tests_loop:
	JSR clear_txt
	JSR check_music_disk_based_replay

	;; JSR clear_txt
	;; JSR check_basic_irq_replay

	;; JSR clear_txt
	;; JSR check_diskii

	;; JSR clear_txt
	;; JSR check_basic_irq_plus_disk_replay

	JSR clear_txt
	JSR check_basic_irq_plus_disk_replay2

	JMP all_tests_loop

	BRK


	;; JSR check_diskii_with_irq



;; files_loop:
;; 	LDA file_being_loaded			; threeD data => page $d000, won't overwrite us !
;; 	INC file_being_loaded
;; 	JSR init_file_load

;; 	LDA #'*'+$80
;; 	STA $750+36

;; wait_file:
;; 	LDA read_in_pogress
;; 	BNE wait_file


;; pause:
;; 	LDA #'P'+$80
;; 	STA $750+35
;; 	JSR scroll_text
;; 	INC loop_count2
;; 	LDA loop_count2
;; 	AND #127
;; 	BNE pause

;; 	JMP files_loop


;; loop_count:	.byte 0
;; loop_count2:	.byte 0
;; file_being_loaded:	.byte 3

;;; ==================================================================

	.proc check_music_disk_based_replay

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

;; 	set_irq_vector interrupt_handler_music
;; 	LDA LC_RAM_SELECT
;; 	LDA LC_RAM_SELECT

;; 	JSR start_interrupts

;; 	set_timer_const 1000000/50


;; infiniloop:
;; 	INC $400
;; 	JMP infiniloop

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
	STA current_track
        ldx #SLOT_SELECT
	JSR seek

	print_str irq_disk_replay_header, $400

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


	set_irq_vector disk_irq_handler2


	JSR start_interrupts
	set_timer_to_const 1022000/40

	JSR read_keyboard
infiniloop:
	JSR read_keyboard
	BEQ infiniloop

	jsr stop_mockingboard_interrupts
	jsr	reset_ay_both
	jsr	clear_ay_both
	RTS

irq_disk_replay_header:	.byte "ADVANCED IRQ + DISK READ REPLAY",0

	.endproc

	;;  ---------------------------------------------------

	.proc disk_irq_handler2

	;; 2aec => wait = 3d0 / 660
	;; 2Bec => wait = 2d0 / 550
	;; 2CEC => too small

	ONE_80TH = $31E7	; 1022000/80

	;; For Mame
	;; DISK_READ_TIME = $3180	; Time to read the addr+data part of a sector
	;; TOLERANCE = $200 ; That's the minimum I can get

	;; For AppleWin DSK

	;DISK_READ_TIME = $2B10
	;TOLERANCE = $100

	;; For AppleWin WOZ

	DISK_READ_TIME = $3180	; Time to read the addr+data part of a sector
	DATA_READ_TIME = $2D60
	TOLERANCE = $180

	php
	pha
	txa
	pha			; save X
	tya
	pha			; save Y

	;LDA	$C404		; Allow the next IRQ from the 6522
	LDY #$04
	LDA (MB_Base),Y

	LDY stepper
	INY
	CPY #NB_READ_SECTOR_STATES
	BNE stepper_good
	LDY #0
stepper_good:
	STY stepper

	LDA read_sector_states,Y

	CMP #MUSIC_LONG
	BEQ music_long
	CMP #MUSIC_REGULAR
	BEQ music_regular
	CMP #MUSIC_SHORT
	BEQ music_short
	CMP #READ_SECTOR
	BEQ read_sector

infiniloop:
	JMP infiniloop

music_regular:
	set_timer_to_const DISK_READ_TIME
	JSR pt3_irq_handler
	JMP exit_interrupt

music_short:
	set_timer_to_const DISK_READ_TIME - 2*TOLERANCE
	JSR pt3_irq_handler
	JMP exit_interrupt

music_long:
	set_timer_to_const 2*DISK_READ_TIME
	JSR pt3_irq_handler
	JMP exit_interrupt

read_sector:
	ldx #SLOT_SELECT
	JSR rdadr16
	ldx #SLOT_SELECT
	JSR read16

	;; This is tricky ! Doing a pause this way
	;; ensures that the next PT3 beat will be played
	;; at the right time but also it makes sure we
	;; resync our timings on the disk speed. This way
	;; we prevent an accumulation of errors on the timer's
	;; interrupts.

	set_timer_to_const TOLERANCE

	;; DEBUG -----------------------------------------------------

	LDY sect
	LDA $500,Y
	EOR #('#' ^ ' ')
	STA $500,Y

exit_interrupt:
	pla
	tay			; restore Y
	pla
	tax			; restore X
	pla			; restore a
	plp

	RTI

stepper:	.byte 0
timer_read:	.word 0

	.endproc




;;; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	.proc check_basic_irq_plus_disk_replay

	LDA #0
	STA current_track
        ldx #SLOT_SELECT
	JSR seek

	print_str irq_disk_replay_header, $400

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


	set_irq_vector disk_irq_handler


	JSR start_interrupts
	set_timer_to_const 1022000/40

	JSR read_keyboard
infiniloop:
	JSR read_keyboard
	BEQ infiniloop

	jsr stop_mockingboard_interrupts
	jsr	reset_ay_both
	jsr	clear_ay_both
	RTS

irq_disk_replay_header:	.byte "BASIC IRQ + DISK READ REPLAY AT 40HZ",0

	.endproc

	;;  ---------------------------------------------------

	.proc disk_irq_handler

	;; 2aec => wait = 3d0 / 660
	;; 2Bec => wait = 2d0 / 550
	;; 2CEC => too small

	ONE_80TH = $31E7	; 1022000/80

	;; For Mame
	;; DISK_READ_TIME = $3180	; Time to read the addr+data part of a sector
	;; TOLERANCE = $200 ; That's the minimum I can get

	;; For AppleWin DSK

	;DISK_READ_TIME = $2B10
	;TOLERANCE = $100

	;; For AppleWin WOZ

	DISK_READ_TIME = $30B0	; Time to read the addr+data part of a sector
	TOLERANCE = $200

	PAUSE_UNTIL_MUSIC = DISK_READ_TIME + TOLERANCE	; $33E6
	PAUSE_UNTIL_RDADR = DISK_READ_TIME - 2*TOLERANCE  ; $2B6A ; $27EC = 1022000/80 * 0.87

	php
	pha
	txa
	pha			; save X
	tya
	pha			; save Y


	INC stepper
	LDA stepper
	STA $400 + 39
	CMP #$FF
	BNE no_head_move	; FIXITI!

	;; LDA #0
	;; STA stepper 		; back to disk step

	;; INC current_track
	;; LDA current_track
	;; CLC
	;; ADC #$B0
	;; STA $400+38

	;; LDA current_track
	;; ldx #SLOT_SELECT
	;; JSR seek
	;; JMP exit_interrupt

no_head_move:
	AND #$01
	BEQ music_step

disk_step:
	LDA stepper
	CMP #$2F
	BNE read_sector
shift_a_sector:
	ldx #SLOT_SELECT
	JSR rdadr16
	ldx #SLOT_SELECT
	JSR rdadr16

	LDA #0
	STA stepper
	JMP exit_interrupt

read_sector:
	ldx #SLOT_SELECT
	JSR rdadr16
	BCS disk_step

	read_timer_direct timer_read

	set_timer_to_const PAUSE_UNTIL_MUSIC 	; $3465 = 1022000/80 * 1.04

	ldx #SLOT_SELECT
	JSR read16

	;; DEBUG -----------------------------------------------------

	sub_16_to_const timer_read, PAUSE_UNTIL_RDADR
	LDA stepper
	LSR
	AND #15
	ASL
	TAX
	LDA txt_ofs + 6,X
	STA debug_ptr
	LDA txt_ofs + 6 +1,X
	STA debug_ptr+1
	print_timer2 timer_read

	INC debug_ptr
	LDA sect
	jsr byte_to_text


	JMP exit_interrupt

music_step:
	set_timer_to_const PAUSE_UNTIL_RDADR
	JSR pt3_irq_handler

exit_interrupt:

	;; FIXME this must be SMC'ed to handle MockingBoard
	;; on another port.
	;LDA	$C404		; Allow the next IRQ from the 6522
	LDY #$04
	LDA (MB_Base),Y


	pla
	tay			; restore Y
	pla
	tax			; restore X
	pla			; restore a
	plp

	RTI

stepper:	.byte 0
timer_read:	.word 0

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


	.proc check_diskii

	STA KBD_CLEAR

	print_str header, $400
	print_str seek_header, $650

all_tracks_loop:
	print_str track0_header, $480

	JSR locate_drive_head	; Motor on

	;; Make sure we're not bothered by interrupts
	;; (this code may be useless, depending on the context)


	LDA #0
	STA current_track
        ldx #SLOT_SELECT
	JSR seek

	print_str blank_line_header, $480

	.align 256, $EA		; NOP opcode
track_loop:
	LDA #0
	STA sector_count

sector_loop:
	TIMER_START = $FFFF - 32

	set_timer_to_const TIMER_START

	;; How much time to readaddr

read_addr_error:
	ldx #SLOT_SELECT
	jsr rdadr16
	bcs read_addr_error

	read_timer2 addr_times

	;; Remember what we have read (so we can verify that
	;; we actually read what we expect to read)

	LDX sector_count
	LDA sect
	STA read_sectors,X
	LDA track
	STA read_tracks,X

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

	ADC #<$6D0
	STA debug_ptr
	LDA #>$6D0
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

	sub16 data_time, addr_time

	print_timer2 addr_time
	INC debug_ptr
	print_timer2 data_time

	add16 data_time, addr_time

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

data_time:	.word 0
addr_time:	.word 0

read_sectors:	.word 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
read_tracks:	.word 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
addr_times:	.word 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
data_times:	.word 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
total_times:	.word 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0

header:	.byte "TR S ADDR DATA SUM  TR S ADDR DATA SUM",0
seek_header:	.byte "TRACK SEEK TIME:",0
track0_header:	.byte "    *** GOING BACK TO TRACK ZERO ***    ",0
blank_line_header:	.byte "                                        ",0

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

;;; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	.proc interrupt_handler_dummy

	PHP
	INC $7D0
	PLP

	RTI

	.endproc


;;; ==================================================================


;;; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	.macro regular_sector_read_test
	INC loop_count
	LDA loop_count
	AND #63
	BNE just_sector

	LDA curtrk
	CLC
	ADC #2
        ldx #SLOT_SELECT
	JSR seek

	;; In the test, this seems to be NOT necessary
	LDA #0
	STA sector_shift

	LDA curtrk
	CLC
	ROR
	TAX
	LDA hexa_apple,X
	STA $7d0+38


just_sector:
	LDA loop_count
	AND #%11110000
	CLC
	ROR
	ROR
	ROR
	ROR
	TAX
	LDA hexa_apple,x
	STA $7d0+39

        ldx #SLOT_SELECT
	JSR rdadr16

	ldx #SLOT_SELECT
	jsr read16
	.endmacro

;;; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;






;;; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	.proc check_diskii_with_irq

	set_irq_vector interrupt_handler_music
	LDA LC_RAM_SELECT
	LDA LC_RAM_SELECT

	JSR start_player
	JSR start_interrupts

;; wait_sector_zero:
;;         ldx #SLOT_SELECT
;; 	JSR rdadr16		; stabilize
;; 	LDA sect
;; 	BNE wait_sector_zero

;; 	SEI
;; 	set_irq_vector interrupt_handler_music

;; 	;; MOCK_6522_ACR = C40B
;; 	;; bits 7 and 6 controls the timer1 operating mode
;; 	;; $40 = Generate continuous interrupts, PB7 is disabled.
;; 	lda	#%01000000
;; 	sta	MOCK_6522_ACR	; ACR register

;; 	lda	#%01111111	; clear all interrupt "enables"
;; 	sta	MOCK_6522_IER	; IER register (interrupt enable)

;; 	lda	#%11000000	; set timer1 IRQ enable
;; 	sta	MOCK_6522_IER	; IER register (interrupt enable)



;; 	lda	#$7F		; clear all interrupt flags
;; 	set_timer_const $FFFE
;; 	CLI

	RTS
	.endproc



start_player:
	lda	#0
	sta	DONE_PLAYING
	lda	#1
	sta LOOP


	jsr	mockingboard_init

	jsr	pt3_init_song
	jsr	reset_ay_both
	jsr	clear_ay_both

	rts



	.proc init_file_load
	;;  A = file index in TOC

wait_lock:
	LDX read_in_pogress
	BNE wait_lock

	CMP file_being_loaded
	BEQ file_in_load
	STA file_being_loaded

	;;  Compute A * 5
	STA smc + 1
	ASL
	ASL
	CLC
smc:
	ADC #0
	TAX

	;SEI			; Don't forget we might read sector from inside an interrupt !
	LDA disk_toc,X
	STA first_track
	STA current_track

	LDA disk_toc+1,X
	STA first_sector
	LDA disk_toc+2,X
	STA last_track
	LDA disk_toc+3,X
	STA last_sector
	LDA disk_toc+4,X
	STA first_page

	;; PHA
	;; LDA #0			; FIXME should not be necessary
	;; STA sectors_to_read

	LDA #1
	STA read_in_pogress

	;; PLA
	;CLI
file_in_load:
	RTS

.export file_being_loaded
file_being_loaded:	.byte $FF
disk_toc: .include "build/loader_toc.s"

	.endproc



;;; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


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
	;; by the mouse.

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

	.proc read_keyboard

	LDA KBD_INPUT
	BPL no_good_key
	STA KBD_CLEAR
	RTS
no_good_key:
	LDA #$0
	RTS
	.endproc
