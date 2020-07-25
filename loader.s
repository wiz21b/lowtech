;; This code is (c) 2019 Stéphane Champailler
;;; It is published under the terms of the
;;; GNU GPL License Version 3.

;;; Part of this code (see below) is copied from the PT3 player by Vince "Deater" Weaver and is licensed accordingly


	.include "defs.s"
dummy_pointer = 254

	;MUSIC = 1
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





;;; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	.if RUN_CHECK_DISK = 1

	LDA #FILE_CHECK_DISK
	JSR load_file_no_irq
	JSR $6000

	.endif

	;; Setting those up before activating language card RAM bank
	;; seems important. Without that, things go totally wrong
	;; (interrupt seems to trigger random writes in memory,
	;; leading to unpredictable crashes).

	set_irq_vector interrupt_handler

	LDA LC_RAM_SELECT
	LDA LC_RAM_SELECT


	.ifdef MUSIC
	LDA #<FILE_PT3_LOAD_ADDR
	STA LZSA_SRC_LO
	LDA #>FILE_PT3_LOAD_ADDR
	STA LZSA_SRC_HI

	LDA #<PT3_LOC
	STA LZSA_DST_LO
	LDA #>PT3_LOC
	STA LZSA_DST_HI

	JSR DECOMPRESS_LZSA2_FAST

	JSR start_player
	.endif

	;; -----------------------------------------------------------

	LDA #FILE_EARTH
	JSR load_file_no_irq
	LDA #FILE_BIG_SCROLL
	JSR load_file_no_irq

	.ifdef MUSIC
	JSR start_interrupts
	.endif
	JSR $6000


	;; -----------------------------------------------------------

	LDA #FILE_THREED
	.ifdef MUSIC
	JSR load_file;_no_irq
	.else
	JSR load_file_no_irq
	.endif

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

	LDA #FILE_DATA_3D_0
	.ifdef MUSIC
	JSR load_file;_no_irq
	.else
	JSR load_file_no_irq
	.endif
	LDA #FILE_DATA_3D_1
	.ifdef MUSIC
	JSR load_file;_no_irq
	.else
	JSR load_file_no_irq
	.endif

	;; JSR start_interrupts

	LDA #FILE_DATA_3D_2
	JSR $6000

	;; -----------------------------------------------------------

the_end:
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
	.ifdef DEBUG
	jsr debug_disk
	.endif
	LDA read_in_pogress
	CMP #1
	BEQ read_more
	;BCS read_more

	.ifdef DEBUG
	jsr debug_disk
	.endif

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

	.endif

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


	; some firmware locations
	.include "pt3_lib/hardware.inc"
	.include "pt3_lib/pt3_lib_core.s"
	.include "pt3_lib/pt3_lib_init.s"
	.include "pt3_lib/pt3_lib_mockingboard_setup.s"


	.export ticks
ticks:	.word 0

;;; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	.macro sector_read_code

	LDA read_in_pogress
	BEQ read_sector_sim

	.ifdef DEBUG
	LDA #$0
	STA $2010
	.endif

	JSR read_sector_in_track

	LDA read_sector_status
	BEQ read_sector_sim

	AND #SECTOR_READ
	BNE skip_pause

	LDA read_sector_status
	AND #SECTOR_RDADR
	BNE data_read

	LDA read_sector_status
	AND #SECTOR_SEEK
	BNE latch_advance
	BEQ skip_pause
read_sector_sim:
	.ifdef DEBUG
	LDA #$FF
	STA $2010
	.endif
	set_timer_const $3179
	LDA #1
	STA read_sector_simulation

	JMP exit_interrupt

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
	.include "decompress_fast_v2.s"
