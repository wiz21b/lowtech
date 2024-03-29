;; This code is (c) 2019 Stéphane Champailler
;;; It is published under the terms of the
;;; GNU GPL License Version 3.

;;; Part of this code (see below) is copied from the PT3 player by Vince "Deater" Weaver and is licensed accordingly


	.include "defs.s"

	;MUSIC = 1
	RUN_CHECK_DISK = 0

	.segment "LOADER"

	.export first_page
	.export init_file_load, load_file, handle_track_progress
	.export start_player
	.export FILE_ICEBERG_LOAD_ADDR
	.export current_pattern_smc, current_line_smc, current_subframe_smc

	;; Clear Apple ][ logo at top of text screen
	LDA #$A0		; space
clear_apple_loop:
	clear_apple = * + 1
	STA $400 + 39
	DEC clear_apple
	BNE clear_apple_loop

;;; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	JSR detect_apple
	JSR detect_mocking_board
	JSR mockingboard_detect
	JSR mockingboard_patch
	JSR calibration
	;JSR start_player
	;set_irq_vector disk_irq_handler2

;;; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	FIRST_PART  = 1
	THREED_PART = 1


	;; Setting those up before activating language card RAM bank
	;; seems important. Without that, things go totally wrong
	;; (interrupt seems to trigger random writes in memory,
	;; leading to unpredictable crashes).

	set_irq_vector disk_irq_handler2

	;; LDA LC_RAM_SELECT
	;; LDA LC_RAM_SELECT


	;; LDA #'A'
	;; STA $400

        LDA #FILE_PT3
	JSR load_file_no_irq

	LDA #<FILE_PT3_LOAD_ADDR
	STA LZSA_SRC_LO
	LDA #>FILE_PT3_LOAD_ADDR
	STA LZSA_SRC_HI

	LDA #<PT3_LOC
	STA LZSA_DST_LO
	LDA #>PT3_LOC
	STA LZSA_DST_HI

	JSR DECOMPRESS_LZSA2_FAST

	.if FIRST_PART = 0
	LDA #FILE_THREED
	JSR load_file_no_irq
	LDA #FILE_DATA_3D_0
	JSR load_file_no_irq
	LDA #FILE_DATA_3D_1
	JSR load_file_no_irq
	.endif

	.ifdef MUSIC
	JSR start_player
	.endif

	;; LDA #'B'
	;; STA $401

	;; -----------------------------------------------------------



	.if FIRST_PART = 1
	;; LDA #FILE_EARTH
	;; JSR load_file_no_irq
	LDA #FILE_BIG_SCROLL
	JSR load_file_no_irq
	;; LDA #FILE_MAIN_MUSIC
	;; JSR load_file_no_irq
	.endif

	.ifdef MUSIC
	JSR start_interrupts
	.endif
	.if FIRST_PART = 1
	JSR $6000
	.endif

	;;  Back from first part

	;; -----------------------------------------------------------

	;; Start new sound track

	;; LDA #1
	;; STA DONE_PLAYING

	;; LDA #>FILE_MAIN_MUSIC_LOAD_ADDR
	;; LDY #>PT3_LOC
	;; LDX #(FILE_MAIN_MUSIC_SIZE+255) / 256
	;; JSR page_copy

	;; JSR start_player


	;; -----------------------------------------------------------

	;; LDA #FILE_THREED
	;; .ifdef MUSIC
	;; JSR load_file
	;; .else
	;; JSR load_file_no_irq
	;; .endif

	.if THREED_PART = 1
	THREED_ADDRESS = $6000

	LDA #<FILE_THREED_LOAD_ADDR
	STA LZSA_SRC_LO
	LDA #>FILE_THREED_LOAD_ADDR
	STA LZSA_SRC_HI

	LDA #<THREED_ADDRESS
	STA LZSA_DST_LO
	LDA #>THREED_ADDRESS
	STA LZSA_DST_HI

	JSR DECOMPRESS_LZSA2_FAST

	JSR $6000
	.endif


	;; -----------------------------------------------------------

the_end:

	.if THREED_PART = 0
	LDA #FILE_ICEBERG
	JSR load_file
	.endif

	LDA #FILE_VERTI_SCROLL + 128
	JSR load_file

	VERTI_SCROLL_ADDRESS = $6000
	LDA #<FILE_VERTI_SCROLL_LOAD_ADDR
	STA LZSA_SRC_LO
	LDA #>FILE_VERTI_SCROLL_LOAD_ADDR
	STA LZSA_SRC_HI
	LDA #<VERTI_SCROLL_ADDRESS
	STA LZSA_DST_LO
	LDA #>VERTI_SCROLL_ADDRESS
	STA LZSA_DST_HI
	JSR DECOMPRESS_LZSA2_FAST

	JSR $6000


;;; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	.ifdef DEBUG

	.proc debug_disk

	LDA current_track
	AND #%00001111
	TAX
	LDA hexa_apple,X
	STA $05D0,X

	;SEI
	LDY #0
draw_status:
	TYA

	CLC
	ADC #2

	;; sector is translated to line

	ASL
	TAX
	LDA txt_ofs+1,X
	STA smc + 2
	LDA txt_ofs,X
	STA smc + 1

	TYA
	TAX
	LDA sector_status,X

	;BEQ noz

	BNE not_draw_blank
	LDA #'.'+$80
not_draw_blank:

	;; pha
	;; tya
	;; tax
	;; pla

	LDX current_track
	;LDX #10
	;; CPX #10
	;; BPL noz
smc:
	STA $0400,X
noz:

	INY
	CPY #16
	BNE draw_status
	;CLI
	RTS

txt_ofs:
	.word $400,$480,$500,$580,$600,$680,$700,$780
	.word $428,$4A8,$528,$5A8,$628,$6A8,$728,$7A8
	.word $450,$4D0,$550,$5D0,$650,$6D0,$750,$7D0

	.endproc

	.endif			; DEBUG

;;; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	.include "lib.s"
	.include "decompress_fast_v2.s"
	.include "read_sector.s" ; RWTS code

	;.byte "---MUSIC"
	.include "pt3_lib/zp.inc"
	.include "pt3_lib/hardware.inc" ; some firmware locations
	.include "pt3_lib/pt3_lib_core.s"
	.include "pt3_lib/pt3_lib_init.s"
	.include "pt3_lib/pt3_lib_mockingboard_setup.s"
	.include "pt3_lib/pt3_lib_irq_handler.s"
	;.include "pt3_lib/interrupt_handler.s"
	; if you're self patching, detect has to be after
	; interrupt_handler.s
	;.byte "---FILE_LOAD"
disk_toc:
	.include "toc_equs.inc"
	.include "toc_data.inc"
	.include "file_load.s"

	;;; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	;; Stuff after this JUNK mark will be used during loader's init
	;; and will be erased by other data afterwards.

	.byte "JUNK"
	.include "pt3_lib/pt3_lib_mockingboard_detect.s"
	.include "file_load_init.s"


	.proc start_player
	;; When DONE_PLAYING is different than 0, the palyer doesn't
	;;  play anymore (but the IRQ keeps going)
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
