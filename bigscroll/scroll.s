;;; This code is (c) 2019 Stéphane Champailler
;;; It is published under the terms of the
;;; GUN GPL License Version 3.

;;; Part of this code (see below) is copied from the PT3 player by Vince "Deater" Weaver and is licensed accordingly

	.segment "CODE_0C00"

	.include "defs.s"
	.include "precalc_def.s"

DEBUG = 1

scroll_matric_ptr       = 252
dummy_ptr2		= 252
dummy_ptr		= 254

	store_16  dummy_ptr, filename_FILLER
	store_16  iobuffer, ($6000-1024)
	store_16 file_buffer, $6000
	JSR load_file

	store_16 dummy_ptr, filename_SONG
	store_16 file_buffer, $4000
	JSR load_file


	jsr clear_hgr
	JSR stars_fixed

	.if DEBUG
	LDA $C053
	.else
	LDA $C052	     ; mix text and gfx (c052 = full text/gfx)
	.endif

	LDA $C054
	LDA $C057
	LDA $C050 ; display graphics; last for cleaner mode change (according to Apple doc)


	JSR start_player

; =============================================================================

big_loop:

	LDA #0
	STA subcount
	lda #0
	sta count

loop2:

wait_frame_trigger:
	LDA frame_trigger
	CMP #0
	BEQ wait_frame_trigger

	;; LDA ticks
	;; AND #1
	;; BEQ nogr

;; 	LDA $C052	     ; mix text and gfx (c052 = full text/gfx)
;; 	LDA $C054
;; 	LDA $C057
;; 	LDA $C050 ; display graphics; last for cleaner mode change (according to Apple doc)

;; 	JMP donegr
;; nogr:
;; 	LDA $C052	     ; mix text and gfx (c052 = full text/gfx)
;; 	LDA $C054
;; 	LDA $C056
;; 	LDA $C050 ; display graphics; last for cleaner mode change (according to Apple doc)

donegr:

	LDA #0
	STA row_loop
	STA frame_trigger
loop1:
	; count = offset; row_loop = [0..39]
	; actual row = count + row_loop

	; Read the scroll matrix, one row at a time
	; (a row is displayed as a vertical on the hgr screen)

	lda row_loop
	clc
	adc count
	sta dummy_ptr
	lda #0
	sta dummy_ptr + 1
	asl16 dummy_ptr
	add_const_to_16 dummy_ptr, matrix_rows

	ldy #0
	lda (dummy_ptr),Y
	sta scroll_matric_ptr
	iny
	lda (dummy_ptr),Y
	sta scroll_matric_ptr + 1

	;; Because of the way we build the code that draw the tiles,
	;; all tiles can be drawn in one sequence.

.REPEAT 13,j
	LDY #j
 	LDA (scroll_matric_ptr),Y
 	BEQ end_row_loop
	JSR copy_block
.ENDREPEAT

end_row_loop:

	INC row_loop
	LDA row_loop
	cmp #40
	BEQ clip_right
	JMP loop1

clip_right:

	jsr stars

	;; The subcount determines the offset insde a tile
	;; its values are multiplied by 4 so that it can be reused
	;; for some addressing (that's an optimization)

	CLC
	LDA subcount
	ADC #2*ROL_SPEED
	STA subcount

	CMP #16
	BEQ reset
	jmp loop2

reset:
	LDA #0
	STA subcount


	INC count
	LDA count
	CMP matrix_row_count
	BEQ reset2
	jmp loop2
reset2:
	.if DEBUG
	jsr draw_status
	.endif

	store_16  ticks, 0

	jmp big_loop

	RTS


hexa:		.asciiz "0123456789ABCDEF"
ticks:		.word $0000
STATUS_BUFFER = $7D0	; $750 $650
draw_status:

	LDA ticks
	AND #$F
	TAY
	LDA hexa,Y
	STA STATUS_BUFFER+4

	LDA ticks
	AND #$F0
	LSR
	LSR
	LSR
	LSR
	TAY
	LDA hexa,Y
	STA STATUS_BUFFER+3

	LDA ticks+1
	AND #$F
	TAY
	LDA hexa,Y
	STA STATUS_BUFFER+2

	LDA ticks+1
	AND #$F0
	LSR
	LSR
	LSR
	LSR
	TAY
	LDA hexa,Y
	STA STATUS_BUFFER+1

	RTS





count:	.byte 0
subcount:	.byte 8
column_loop:	.byte 0
row_loop:	.byte 0
y_matrix:	.byte 0
vert_count:	.byte 0

; =============================================================================

jump_table_ptr	= dummy_ptr	; zero page
jump_ptr:	.word 0

times8hi:
	.REPEAT 64,i
	.byte (i * 8 * 2 + $6000) >> 8
	.ENDREP
times8lo:
	.REPEAT 64,i
	.byte (i * 8 * 2 + $6000) & 255
	.ENDREP

copy_block:

	TAY
	LDA times8lo,Y
	STA jump_table_ptr
	LDA times8hi,Y
	STA jump_table_ptr+1

	LDY subcount

	; copy value from table to jump pointer
	LDA (jump_table_ptr),Y
	STA jump_ptr

	INY
	LDA (jump_table_ptr),Y
	STA jump_ptr + 1

	LDY row_loop
	JMP (jump_ptr)





clear_hgr:
	store_16 dummy_pointer, (HGR_RAM + $2000)

clear_hgr_loop:
	dec16 dummy_pointer

	LDA #0
	LDY #0
	STA (dummy_pointer), Y


	lda #$20
	cmp dummy_pointer + 1
	bne clear_hgr_loop
	lda #0
	cmp dummy_pointer
	bne clear_hgr_loop

	RTS


load_file:
	LDA #<(filename_bfr+1)
	STA dummy_ptr2
	LDA #>(filename_bfr+1)
	STA dummy_ptr2+1

	LDY #0
copy_filename:
	LDA (dummy_ptr),Y
	BEQ done_copy_filename
	STA (dummy_ptr2),Y
	INY
	JMP copy_filename
done_copy_filename:
	STY filename_bfr

	jsr $BF00	; ret code in A
	.byte $C8	; OPEN
	.word open_file_param

	LDA ref_num0
	STA ref_num1
	STA ref_num2

	jsr $BF00	; ret code in A
	.byte $CA	; READ
	.word read_file_param

	jsr $BF00	; ret code in A
	.byte $CC	; CLOSE
	.word close_file_param
	RTS


stars:
	LDX #3
	.include "build/stars.s"
    	rts

stars_fixed:
	.include "build/stars2.s"
	RTS

	.include "build/matrix.s"

filename_FILLER:	.asciiz "FILLER"
filename_SONG:	.asciiz "SONG"

open_file_param:
	.byte 3	; three params
	.word filename_bfr
iobuffer:
	.word $5000		; I/O 1024 bytes buffer address
ref_num0:
	.byte 0
filename_bfr:
	.byte 6 ; length
	.byte 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0

read_file_param:
	.byte 4	; three params
ref_num1:
	.byte 0 ; ref_number
file_buffer:	.word $6000	; where to put the data
	.word 20000	; requested length to read
	.word 0	; actual length


close_file_param:
	.byte 1	; three params
ref_num2:
	.byte 0



frame_trigger:	.byte 0
read_any_sector:
	add_const_to_16 ticks, 1
	inc frame_trigger
	RTS



;;; The following code is (c) Vince "Deater" Weaver an dis not covered by the GNU GPL License


	PT3_LOC = $4000


	.include "pt3_lib/zp.inc"

	;; https://github.com/deater/dos33fsprogs/tree/master/pt3_lib
start_player:
	lda	#0
	sta	DONE_PLAYING
	lda	#1
	sta LOOP

	;jsr	mockingboard_detect
	;jsr	mockingboard_patch
	jsr	mockingboard_init
	jsr	mockingboard_setup_interrupt

	;============================
	; Init the Mockingboard
	;============================

	jsr	reset_ay_both
	jsr	clear_ay_both

	;==================
	; init song
	;==================

	jsr	pt3_init_song

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

	.include "build/bs_precalc.s"
