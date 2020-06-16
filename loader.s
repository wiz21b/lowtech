;; This code is (c) 2019 Stéphane Champailler
;;; It is published under the terms of the
;;; GNU GPL License Version 3.

;;; Part of this code (see below) is copied from the PT3 player by Vince "Deater" Weaver and is licensed accordingly


	.include "defs.s"
dummy_pointer = 254

	.segment "LOADER"

	JMP run
disk_toc:
	.include "build/loader_toc.s"

;;; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	.proc init_track_read2
	;;  A = file index in TOC

	;;  Compute A * 5
	STA smc + 1
	ASL
	ASL
	CLC
smc:
	ADC #0
	TAX

	SEI			; Don't forget we might read sector from inside an interrupt !
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
	LDA #0			; FIXME should not be necessary
	STA sectors_to_read

	LDA current_track
	JSR init_disk_read

	LDA #1
	STA read_in_pogress

	CLI
	RTS
	.endproc

	.include "read_sector.s"

;;; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

run:

	;; interrupt runs
	;; mods data are in place

	;; .ifdef MUSIC
	;; JSR start_player
	;; .endif

	;init_track_read  32, 0, 33, 15, $40



	LDA #FILE_PT3
	JSR load_file_no_irq
	;JSR start_player


;;  	JSR start_player
;; zzz:
;; 	NOP
;; 	JMP zzz

;;; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


	JSR start_player

	;; Setting those up before activating language card RAM bank
	;; seems important. Without that, things go totally wrong
	;; (interrupt seems to trigger random writes in memory,
	;; leading to unpredictable crashes).

	lda	#<interrupt_handler
	sta	$fffe
	lda	#>interrupt_handler
	sta	$ffff
	lda	#<interrupt_handler
	sta	$03fe
	lda	#>interrupt_handler
	sta	$03ff

	LDA LC_RAM_SELECT
	LDA LC_RAM_SELECT
	JSR start_player2

	LDA #FILE_EARTH
	JSR load_file
	LDA #FILE_BIG_SCROLL
	JSR load_file
	JSR $6000

	LDA #FILE_THREED
	JSR load_file
	LDA #FILE_DATA_THREED
	JSR load_file

	;LDA LC_RAM_SELECT

;; stop:
;; 	jmp stop

	JSR $6000

	LDA #FILE_PICTURE
	JSR load_file
	LDA #FILE_VERTI_SCROLL
	JSR load_file
	JSR $6000

;;; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	.proc load_file
	;; A = file index

	JSR init_track_read2
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

	.proc debug_disk

	;SEI
	LDY #0
draw_status:
	TYA

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
	LDA #'-'+$80
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
	STA $400,X
noz:

	INY
	CPY #16
	BNE draw_status
	;CLI
	RTS
	.endproc


txt_ofs:
	.word $400,$480,$500,$580,$600,$680,$700,$780
	.word $428,$4A8,$528,$5A8,$628,$6A8,$728,$7A8
	.word $450,$4D0,$550,$5D0,$650,$6D0,$750,$7D0


;;; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	.proc load_file_no_irq
	;; A = file index

	JSR init_track_read2
read_more:
	jsr debug_disk

	JSR read_sector_in_track
	;BCS read_more
	LDA read_in_pogress
	CMP #1
	BEQ read_more
	RTS
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

	jsr	mockingboard_detect
	bcc	mocking_not_found

	jsr	mockingboard_patch
mocking_not_found:
	jsr	mockingboard_init

	jsr	pt3_init_song
	jsr	reset_ay_both
	jsr	clear_ay_both

	rts

start_player2:
	;; This will enable RAM read/write on Language Card
	jsr	mockingboard_setup_interrupt

	;============================
	; Init the Mockingboard
	;============================


	;==================
	; init song
	;==================

	;jsr	pt3_init_song

	;============================
	; Enable 6502 interrupts
	;============================
	cli ; clear interrupt mask

	RTS

	; some firmware locations
	.include "pt3_lib/hardware.inc"
	.include "pt3_lib/pt3_lib_core.s"
	.include "pt3_lib/pt3_lib_init.s"
	.include "pt3_lib/pt3_lib_mockingboard_setup.s"
	.include "pt3_lib/interrupt_handler.s"
	; if you're self patching, detect has to be after
	; interrupt_handler.s
	.include "pt3_lib/pt3_lib_mockingboard_detect.s"


read_any_sector:
	RTS

irq_count:	.byte 0

	.proc pause_2_irq
not_done:
	LDA irq_count
	CMP #2
	;BMI not_done
done:
	LDA #0
	STA irq_count
	JSR VBLANK_GSE
	rts

	VERTBLANK = $C019
	bMachine         = $0A

VBLANK_GSE:
        LDA bMachine
LVBL1:
        CMP VERTBLANK
        BPL LVBL1                         ; attend fin vbl

        LDA bMachine
LVBL2:
        CMP VERTBLANK
        BMI LVBL2                         ; attend fin display
        RTS
	.endproc
