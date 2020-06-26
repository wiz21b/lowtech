;; This code is (c) 2019 Stéphane Champailler
;;; It is published under the terms of the
;;; GNU GPL License Version 3.

;;; Part of this code (see below) is copied from the PT3 player by Vince "Deater" Weaver and is licensed accordingly


	.include "defs.s"
dummy_pointer = 254

	MUSIC = 1
	RUN_CHECK_DISK = 0

	.segment "LOADER"

	.export first_page
	.export init_file_load
	.export read_in_pogress
	.export start_player

	;; Those two things to allow the FSTBT
	;; loader to continue to run. This is in place
	;; for the loader to start in $0800 AND NOWHERE ELSE.

	.byte 1
	JMP $6000

;;; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	JMP run
	.include "read_sector.s"

disk_toc: .include "build/loader_toc.s"
	.export txt_ofs

txt_ofs:
	.word $400,$480,$500,$580,$600,$680,$700,$780
	.word $428,$4A8,$528,$5A8,$628,$6A8,$728,$7A8
	.word $450,$4D0,$550,$5D0,$650,$6D0,$750,$7D0

;;; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

run:

	;LDA tick_records
	JSR locate_drive_head


	;; CLC
	;; JSR init_disk_read

	;; interrupt runs
	;; mods data are in place

	;; .ifdef MUSIC
	;; JSR start_player
	;; .endif

	;init_track_read  32, 0, 33, 15, $40


	;; LDA sector_retries
	;; LDA sector_status

	LDA #FILE_PT3
	JSR load_file_no_irq

	;; ;; B800
	;; TUNE_PACKED = $6000
	;; TUNE_ADDRESS = $B800

	;; LDA #<TUNE_PACKED
	;; STA LZSA_SRC_LO
	;; LDA #>TUNE_PACKED
	;; STA LZSA_SRC_HI

	;; LDA #<TUNE_ADDRESS
	;; STA LZSA_DST_LO
	;; LDA #>TUNE_ADDRESS
	;; STA LZSA_DST_HI

	;; JSR DECOMPRESS_LZSA2_FAST




;;; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	.if RUN_CHECK_DISK = 1

	LDA #FILE_CHECK_DISK
	JSR load_file_no_irq
	JSR $6000

	.endif

	;; LDA #FILE_EARTH
	;; JSR load_file_no_irq
	;; LDA #FILE_BIG_SCROLL
	;; JSR load_file_no_irq

	;JSR calibration_procedure

	.ifdef MUSIC
	JSR start_player
	.endif

	;; Setting those up before activating language card RAM bank
	;; seems important. Without that, things go totally wrong
	;; (interrupt seems to trigger random writes in memory,
	;; leading to unpredictable crashes).

	;; lda	#<interrupt_handler
	;; sta	$fffe
	;; lda	#>interrupt_handler
	;; sta	$ffff
	;; lda	#<interrupt_handler
	;; sta	$03fe
	;; lda	#>interrupt_handler
	;; sta	$03ff

	set_irq_vector interrupt_handler

	LDA LC_RAM_SELECT
	LDA LC_RAM_SELECT


;; 	;; Set the next interrupt just before a sector address
;; 	;; block.

;; 	sei
;; wait_sector:
;; 	ldx #SLOT_SELECT
;; 	jsr rdadr16
;; 	lda sect
;; 	cmp #1
;; 	bne wait_sector

;; 	ldx #SLOT_SELECT
;; 	jsr read16

;; 	.ifdef MUSIC
;; 	JSR start_player2
;; 	.endif

;;  	lda #0
;;  	sta MOCK_6522_T1CL	; write into low-order latch
;; 	lda #10		; #$31 = 49 => *3/4 = 36
;;  	sta MOCK_6522_T1CH	; write into high-order latch,
;; 	cli
;; zzz:
;; 	NOP
;; 	JMP zzz


	LDA #FILE_THREED
	JSR load_file_no_irq

	JSR start_interrupts

	LDA #FILE_DATA_3D_0
	JSR load_file;_no_irq
	LDA #FILE_DATA_3D_1
	JSR load_file;_no_irq


	LDA #FILE_DATA_3D_2
	JSR $6000

;;; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	LDA #FILE_PICTURE
	JSR load_file
	LDA #FILE_VERTI_SCROLL
	JSR load_file
	JSR $6000

;;; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	.proc load_file
	;; A = file index

	JSR init_file_load
read_more:
	jsr debug_disk
	LDA read_in_pogress
	CMP #1
	BEQ read_more
	;BCS read_more

	jsr debug_disk

	RTS
	.endproc



;;; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	.proc load_file_no_irq
	;; A = file index

	JSR init_file_load
read_more:
	;jsr debug_disk

	JSR read_sector_in_track
	;BCS read_more
	LDA read_in_pogress
	CMP #1
	BEQ read_more
	RTS
	.endproc



;;; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


;;; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

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

	.endproc

;;; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	.proc debug_disk
	rts

;; 	LDA current_track
;; 	AND #%00001111
;; 	TAX
;; 	LDA hexa_apple,X
;; 	STA $05D0,X

;; 	;SEI
;; 	LDY #0
;; draw_status:
;; 	TYA

;; 	CLC
;; 	ADC #2

;; 	;; sector is translated to line

;; 	ASL
;; 	TAX
;; 	LDA txt_ofs+1,X
;; 	STA smc + 2
;; 	LDA txt_ofs,X
;; 	STA smc + 1

;; 	TYA
;; 	TAX
;; 	LDA sector_status,X

;; 	;BEQ noz

;; 	BNE not_draw_blank
;; 	LDA #'.'+$80
;; not_draw_blank:

;; 	;; pha
;; 	;; tya
;; 	;; tax
;; 	;; pla

;; 	LDX current_track
;; 	;LDX #10
;; 	;; CPX #10
;; 	;; BPL noz
;; smc:
;; 	STA $0400,X
;; noz:

;; 	INY
;; 	CPY #16
;; 	BNE draw_status
;; 	;CLI
;; 	RTS
	.endproc


;;; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	.include "lib.s"
	.include "pt3_lib/zp.inc"

;;; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	;; https://github.com/deater/dos33fsprogs/tree/master/pt3_lib
start_player:

	lda	#0
	sta	DONE_PLAYING
	lda	#1
	sta LOOP

	;; LDA #13
	;; STA $402

	;; jsr	mockingboard_detect
	;; bcc	mocking_not_found

	;; jsr	mockingboard_patch
mocking_not_found:
	jsr	mockingboard_init

	jsr	pt3_init_song
	jsr	reset_ay_both
	jsr	clear_ay_both

	rts

;; start_player2:
;; 	;; This will enable RAM read/write on Language Card
;; 	jsr	mockingboard_setup_interrupt

;; 	;============================
;; 	; Init the Mockingboard
;; 	;============================


;; 	;==================
;; 	; init song
;; 	;==================

;; 	;jsr	pt3_init_song

;; 	;============================
;; 	; Enable 6502 interrupts
;; 	;============================
;; 	cli ; clear interrupt mask

;; 	RTS

	; some firmware locations
	.include "pt3_lib/hardware.inc"
	.include "pt3_lib/pt3_lib_core.s"
	.include "pt3_lib/pt3_lib_init.s"
	.include "pt3_lib/pt3_lib_mockingboard_setup.s"


	.export ticks
ticks:	.word 0

;;; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	.macro sector_read_code
	LDA #0
	STA time_expand

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
	lda #$02
	sta buf + 1
	lda #0
	sta buf
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

	;.include "pt3_lib/interrupt_handler.s"
	.include "irq.s"

	; if you're self patching, detect has to be after
	; interrupt_handler.s
	.include "pt3_lib/pt3_lib_mockingboard_detect.s"


;; read_any_sector:
;; 	RTS

;; irq_count:	.byte 0

;; 	.proc pause_2_irq
;; not_done:
;; 	LDA irq_count
;; 	CMP #2
;; 	;BMI not_done
;; done:
;; 	LDA #0
;; 	STA irq_count
;; 	JSR VBLANK_GSE
;; 	rts

;; 	VERTBLANK = $C019
;; 	bMachine         = $0A

;; VBLANK_GSE:
;;         LDA bMachine
;; LVBL1:
;;         CMP VERTBLANK
;;         BPL LVBL1                         ; attend fin vbl

;;         LDA bMachine
;; LVBL2:
;;         CMP VERTBLANK
;;         BMI LVBL2                         ; attend fin display
;;         RTS
;; 	.endproc

	; .include "decompress_fast_v2.s"

	;; debug_ptr = $86

;;; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; 	.proc calibration_procedure

;; 	sei
;; 	lda %01000000		; Clear interrupt enable bit for timer 1
;; 	sta MOCK_6522_IER

;; 	lda #$0		; One-shot mode, no PB7
;; 	sta MOCK_6522_ACR

;; 	;; bring the read head upon a sector

;; 	ldx #SLOT_SELECT
;; 	jsr rdadr16
;; 	ldx #SLOT_SELECT
;; 	jsr read16

;; one_more:

;; 	;; set 6522 T1 counter to FFFF
;; 	lda #$FF
;; 	sta MOCK_6522_T1CL	; write into low-order latch
;; 	lda #$FF
;; 	sta MOCK_6522_T1CH	; write into high-order latch,

;; not_yet:
;; 	ldx #SLOT_SELECT
;; 	jsr rdadr16
;; 	;bcs not_yet
;; 	;; ldx #SLOT_SELECT
;; 	;; jsr read16


;; 	lda sect
;; 	asl
;; 	tax
;; 	lda txt_ofs,X
;; 	sta debug_ptr
;; 	lda txt_ofs+1,X
;; 	sta debug_ptr+1

;; 	;store_16 debug_ptr,$7D0
;; 	lda sect
;; 	jsr byte_to_text

;; 	;; clc
;; 	;; lda debug_ptr
;; 	;; adc #2
;; 	;; sta debug_ptr

;; 	clc
;; 	lda debug_ptr
;; 	adc #3
;; 	sta debug_ptr
;; 	lda #$FF
;; 	sec
;; 	sbc MOCK_6522_T1CH	; write into high-order latch,
;; 	jsr byte_to_text

;; 	jmp one_more

;; 	NOP
;; 	NOP
;; 	JSR start_player
;; 	JSR start_player2

;; 	;; Without that, mame messes up things. I'm under
;; 	;; the impression that if I don't do it, it fails
;; 	;; to send the IRQ properly (at the right speed).
;; 	;; FIXME not sure

;; 	;; LDA  #%01000000
;;         ;; STA  $C50E

;; calibration0:

;; calibration:

;; 	;jmp calibration

;; 	;;  Tell the 6522 to not send IRQ anymore

;; 	;; LDA  #%01000000
;;         ;; STA  $C40E

;; 	;; jsr	pt3_init_song
;; 	;; jsr	reset_ay_both
;; 	;; jsr	clear_ay_both

;; 	;JSR align_sector_zero


;; 	LDA #0
;; 	STA ticks
;; wait_ticks:
;; 	LDA ticks
;; 	CMP calibration_step
;; 	BMI wait_ticks

;; 	;SEI
;; wait_sector_n:
;; 	ldx #SLOT_SELECT
;; 	jsr rdadr16
;; 	CLI
;; 	bcs wait_sector_n

;; 	ldx sect
;; 	lda hexa,x
;; 	clc
;; 	adc #$80
;; 	LDX calibration_step
;; 	INC calibration_step

;; 	;; After x ticks, I'm at sector N
;; 	;; 16 sector at 5 rps => 80 sectors per seconds
;; 	;; 1 sector = 0.0125 sec
;; 	;; scan tick speed = 0.01

;; 	;; 0.01 - 0.0125
;; 	;; 0.02 - 0.0125
;; 	;; 0.03 - 0.0250
;; 	;; 0.04 - 0.0375
;; 	;; 0.05 - 0.05
;; 	;; 0.07 - 0.0625

;; calib_smc:
;; 	STA $400,X

;; 	;; 200/sec => un appel tous les 0.005 sec
;; 	;; une track : 1/5 seconde = 0.2
;; 	;; => il faut 40 ticks pour faire une track

;; 	CPX #39
;; 	BNE calibration

;; stop:
;; 	LDA #0
;; 	sta calibration_step


;; 	lda calibration_run
;; 	clc
;; 	adc #1
;; 	and #15
;; 	sta calibration_run
;; 	asl
;; 	TAX
;; 	lda txt_ofs,X
;; 	sta calib_smc + 1
;; 	lda txt_ofs+1,X
;; 	sta calib_smc + 2

;; 	JMP calibration

;; 	.endproc

;; 	.proc align_sector_zero

;; 	SEI
;; wait_sector_zero:
;; 	ldx #SLOT_SELECT
;; 	jsr rdadr16
;; 	bcs wait_sector_zero

;; 	lda sect
;; 	cmp #0
;; 	bne wait_sector_zero

;; 	;; Restart the clock so we know when it starts exactly
;; 	;; (else a counter may still be running somewhere)
;; 	;; This way, the next IRQ is exactly "CLOCK_SPEED" away.

;; 	;; MOCK_6522_T1CL=$C404	; 6522 #1 t1 low order latches
;; 	;; MOCK_6522_T1CH=$C405	; 6522 #1 t1 high order counter

;; 	lda	#<CLOCK_SPEED	; 40
;; 	sta	MOCK_6522_T1CL	; write into low-order latch
;; 	lda	#>CLOCK_SPEED	; 9C
;; 	sta	MOCK_6522_T1CH	; write into high-order latch,

;; 	LDA #0
;; 	STA ticks
;; 	CLI

	;; RTS
	;; .endproc

;;; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	;; .proc byte_to_text
	;; ;; A = byte
	;; ;; debug_ptr = pointer to where to write
	;; PHA
	;; CLC
	;; ROR
	;; CLC
	;; ROR
	;; CLC
	;; ROR
	;; CLC
	;; ROR
	;; TAX
	;; LDA hexa_apple,X
	;; CLC
	;; ADC #$80
	;; ldy #0
	;; sta (debug_ptr),Y

	;; PLA
	;; INY
	;; AND #15			; 4 lo bits of timer
	;; TAX
	;; LDA hexa_apple,X
	;; CLC
	;; ADC #$80
	;; sta (debug_ptr),Y

	;; rts
	;; .endproc
