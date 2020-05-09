;;; This code is (c) 2019 Stéphane Champailler
;;; It is published under the terms of the
;;; GNU GPL License Version 3.

;;; Part of this code (see below) is copied from the PT3 player by Vince "Deater" Weaver and is licensed accordingly


	.include "defs.s"
	.include "pt3_player/zp.inc"

DEBUG = 0

old_fx = 220
old_fy = 222
length	= 224
y_current 	= 226
y_count 	= 228
fx 	= 230
fy 	= 232
slope 	= 234
hgr_offsets_lo = 236
hgr_offsets_hi = 238
blank_line_code_ptr_lo	= 240
line_code_ptr_lo	= 242
blank_line_code_ptr_hi	= 244
line_code_ptr_hi	= 246

self_mod_ptr	= 6
line_data_ptr	= 250
tile_ptr       = 252
dummy_ptr2		= 252
dummy_ptr		= 254

LINES_TO_DO	= 6
BYTES_PER_LINE	= 6

	jmp dummy_test

dummy_test:
	;; LDA #$1
	;; CMP #$1
	;; BPL dummytest


	jsr clear_hgr

	.if DEBUG
	LDA $C053
	.else
	LDA $C052	     ; mix text and gfx (c052 = full text/gfx)
	.endif

	LDA $C054		; Page 1
	;; LDA $C055		;Page 2
	LDA $C057
	LDA $C050 ; display graphics; last for cleaner mode change (according to Apple doc)

	;; jsr draw_tile_line

	;; 8.62 sec for 127*19 = 2413 lines;
	;; +/- 280 lines per second
	;; 127 * (1+2+3+...+20)*7 pixels = 127 * 20*21/2 * 7 = 186690 pixels => +- 46 cycles per pixel

	;; new time : 2413 / 8.16 = 298 lines / second
	;; 19 lines in 3 1/50th of seconds => +/- 271 lines / sec

	;; 289 lines de 70 ppixels en moyenne par seconde => 28 lines of 70 pixels per seconds

	;; jsr init_the_shit
	;; LDA #$1
	;; STA DONE_PLAYING

	store_16 line_data_ptr1, line_data_frame1
	store_16 line_data_ptr2, line_data_frame2

	; 	add_const_to_16 line_data_ptr2, LINES_TO_DO * BYTES_PER_LINE +1
demo3:
	;; jsr clear_hgr
	.if DEBUG
	store_16 ticks, 0
	.endif



;; 	jsr draw_to_page2
;; 	store_16 line_data_ptr, lines_data + 0*BYTES_PER_LINE
;; 	LDA #1
;; 	STA color
;; 	lda #110
;; 	sta deb_lines_to_do
;; debugger1:
;; 	JSR draw_or_erase_a_line
;; 	add_const_to_16 line_data_ptr, BYTES_PER_LINE
;; 	dec deb_lines_to_do
;; 	bne debugger1
;; 	jmp demo3
;; deb_lines_to_do:	.byte 0


	;; 1.04 pour 27 images => 25 fps

all_lines:

	jsr draw_to_page4

	copy_16 line_data_ptr, line_data_ptr1
	LDA #0
	STA color
	JSR draw_or_erase_multiple_lines
	nop
	nop

	copy_16 line_data_ptr1, line_data_ptr

	LDA #1
	STA color
	JSR draw_or_erase_multiple_lines

	LDA $C055	; Show page 4
	LDA $C057
	LDA $C050 	; display graphics; last for cleaner mode change (accor
	;; -----------------------------------------------
	jsr draw_to_page2

	copy_16 line_data_ptr, line_data_ptr2

	LDA #0
	STA color
	JSR draw_or_erase_multiple_lines

	copy_16 line_data_ptr2, line_data_ptr

	LDA #1
	STA color
	JSR draw_or_erase_multiple_lines

	LDA $C054		; Show page 2
	LDA $C057
	LDA $C050 ; display graphics; last for cleaner mode change (accor

	;jsr $FD0C		; wait key hit

	;jsr  pause
	JMP all_lines
all_done:

	.if DEBUG
	jsr draw_status
	.endif

	jmp demo3

line_data_ptr1:	.word 0
line_data_ptr2:	.word 0


.proc draw_or_erase_multiple_lines
	lda #LINES_TO_DO
	sta lines_to_do

one_more_line:

	JSR draw_or_erase_a_line

	add_const_to_16 line_data_ptr, BYTES_PER_LINE

	LDY #0
	LDA (line_data_ptr),Y

	AND #31
	CMP #3
	BMI one_more_line	; A < 3 ?

	BEQ end_of_frame	; A = 3
	CMP #4			; A = 4
	BEQ end_of_all_frames

	RTS

end_of_all_frames:
	store_16 line_data_ptr, lines_data
	RTS

end_of_frame:
	add_const_to_16 line_data_ptr, 1
	RTS


lines_to_do:	.byte 0
.endproc

.proc draw_or_erase_a_line

	;; line_data_ptr must be set
	;; color must be set

	jsr copy_line_data

	LDY #0
	LDA (line_data_ptr),Y
	AND #31

	CMP #0
	BNE vline
	jsr draw_hline_full
	rts
vline:
	jsr draw_vline_full
	rts
.endproc

.proc draw_to_page4
	store_16 line_code_ptr_lo, p2_line_ptrs_lo
	store_16 line_code_ptr_hi, p2_line_ptrs_hi
	store_16 blank_line_code_ptr_lo, p2_blank_line_ptrs_lo
	store_16 blank_line_code_ptr_hi, p2_blank_line_ptrs_hi
	store_16 hgr_offsets_lo, hgr4_offsets_lo
	store_16 hgr_offsets_hi, hgr4_offsets_hi
	RTS
.endproc

.proc draw_to_page2
	store_16 line_code_ptr_lo, line_ptrs_lo
	store_16 line_code_ptr_hi, line_ptrs_hi
	store_16 blank_line_code_ptr_lo, blank_line_ptrs_lo
	store_16 blank_line_code_ptr_hi, blank_line_ptrs_hi
	store_16 hgr_offsets_lo, hgr2_offsets_lo
	store_16 hgr_offsets_hi, hgr2_offsets_hi
	rts
.endproc


copy_line_data:
	LDY #1

	LDA #0
	STA fx
	LDA (line_data_ptr),Y
	STA fx + 1

	INY
	LDA #0
	STA fy
	LDA (line_data_ptr),Y
	STA fy + 1

	INY
	LDA (line_data_ptr),Y
	STA length

	INY
	LDA (line_data_ptr),Y
	STA slope
	INY
	LDA (line_data_ptr),Y
	STA slope + 1
	RTS


color:	.byte 1

;; fx:	.word 100*256
;; fy:	.word 0
;; slope:	.word $FFFF - $0200 + 1
;; length:	.byte 20

sub_test:	.word $0001
;; old_fx:	.byte 0
;; old_fy:	.byte 0
loops:	.byte 127
;; hloops:	.byte 1
mask:	.byte 0
mask_left:	.byte 0
mask_right:	.byte 0




;;; x-begin, y-begin, x-end, slope

x_start:	.byte 0
y_start:	.byte 0
x_end:	.byte 0

x7_start:	.byte 0
x7_end:	.byte 0

.proc draw_hline_full
	;; beginning of the line

	LDX x_start

	LDA div7,X
	STA x7_start

	LDA modulo7,X
	TAX
	LDA hline_masks_left, X
	STA mask_left


	;; end of the line

	LDX x_end

	LDA div7,X
	STA x7_end

	LDA modulo7,X
	TAX
	LDA hline_masks_right, X
	STA mask_right

	LDA color
	BEQ erase

	LDA slope + 1
	AND #$80
	BEQ draw_down

	JSR draw_hline_up
	RTS
draw_down:
	JSR draw_hline
	RTS

erase:
	LDA slope + 1
	AND #$80
	BEQ erase_down

	JSR erase_hline_up
	RTS
erase_down:
	JSR erase_hline
	RTS

.endproc




.proc draw_vline_full

	;; beginning of the line

	;; LDX x_start

	;; LDA div7,X
	;; STA x7_start

	;; LDA modulo7,X
	;; TAX
	;; LDA hline_masks_left, X
	;; STA mask_left


	;; end of the line

	;; LDX x_end

	;; LDA div7,X
	;; STA x7_end

	;; LDA modulo7,X
	;; TAX
	;; LDA hline_masks_right, X
	;; STA mask_right

	LDA color
	CMP #0
	BEQ erase

	LDA slope + 1
	AND #80
	BEQ draw_down

	JSR draw_vline_right_left
	RTS
draw_down:
	JSR draw_vline_left_right   ; draw_frame_line
	RTS

erase:
	LDA slope + 1
	AND #80
	BEQ erase_down

	JSR erase_vline_right_left
	RTS
erase_down:
	JSR erase_vline_left_right
	RTS
.endproc



.proc draw_hline_tile_masked

tile_loop:
	LDY old_fy
	LDA hgr2_offsets_lo,Y
	STA dummy_ptr
	LDA hgr2_offsets_hi,Y
	STA dummy_ptr + 1

	LDY y_count
	LDA (dummy_ptr2),Y
	AND mask

	LDY fx
	ORA (dummy_ptr),Y
	;; LDA #$FF
	STA (dummy_ptr),Y

	INC old_fy
	DEC y_count
	BPL tile_loop

	rts

;; y_count:	.byte 0

.endproc








modulo7:
	.repeat 256,I
	.byte	I .MOD 7
	.endrep

div7:
	.repeat 256,I
	.byte I / 7		; integer division, no rounding
	.endrep


	;; .repeat 256/7+1,I
	;; .repeat 7
	;; .byte	I
	;; .endrep
	;; .endrep

	.include "htiles.s"
	.include "precalc.s"
	.include "tiles.s"
	.include "tiles_lr.s"

	;; Tools
	.include "lib.s"
	;; .include "player.s"

	;; Macros to generate line drawing code
	NO_BREAK_INDICATOR = $7F
	RIGHT_TO_LEFT = 1
	LEFT_TO_RIGHT = 2
	.include "vline.s"
	.include "hline.s"

lines_data:
	.include "lines.s"
	;; nb_lines:	.byte (* - lines_data) / BYTES_PER_LINE
.proc draw_vline_right_left
	draw_vline RIGHT_TO_LEFT
.endproc

.proc draw_vline_left_right
	draw_vline LEFT_TO_RIGHT
.endproc

.proc erase_vline_right_left
	draw_vline RIGHT_TO_LEFT,1
.endproc

.proc erase_vline_left_right
	draw_vline LEFT_TO_RIGHT,1
.endproc

.proc draw_hline
	draw_hline LEFT_TO_RIGHT
.endproc

.proc draw_hline_up
	draw_hline RIGHT_TO_LEFT
.endproc

.proc erase_hline
	draw_hline LEFT_TO_RIGHT, 1
.endproc

.proc erase_hline_up
	draw_hline RIGHT_TO_LEFT, 1
.endproc
