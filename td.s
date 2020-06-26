;;; This code is (c) 2019 Stéphane Champailler
;;; It is published under the terms of the
;;; GNU GPL License Version 3.

;;; Part of this code (see below) is copied from the PT3 player by Vince "Deater" Weaver and is licensed accordingly

	.import init_file_load
	.import first_page
	.import read_in_pogress
	.import file_being_loaded
	.import read_sector_in_track
	.import useless_sector
	.import sector_status

	.include "defs.s"

MOCK_6522_T1CL	=	$C404	; 6522 #1 t1 low order latches
MOCK_6522_T1CH	=	$C405	; 6522 #1 t1 high order counter

	DEBUG = 0
	ONE_PAGE = 0
	GR_ONLY = 0

x_shift = $84

	debug_ptr = $86
	debug_ptr2 = $88

tile_ptr2a	= 212

notb_line_code_ptr_lo = 214
notb_line_code_ptr_hi = 216

tile_ptr2b	= 218
old_fx = 220
old_fy = 222
length	= 224
y_current 	= 226
y_count 	= 228
fx 	= 230
fy 	= 232
slope 	= 234
hgr_offsets_lo	= 236
hgr_offsets_hi	= 238
blank_line_code_ptr_lo	= 240
line_code_ptr_lo	= 242
blank_line_code_ptr_hi	= 244
line_code_ptr_hi	= 246

self_mod_ptr	= $82
line_data_ptr	= 250
tile_ptr	= 252
dummy_ptr2	= 252
dummy_ptr	= 254
dummy_pointer	= 254

LINES_TO_DO	= 6
BYTES_PER_LINE	= 6

	.segment "CODE"


	STA next_file_to_load
				;JSR init_disk_read	; Must be done before any read sector
	lda #$ff
	jsr clear_hgr

	.if GR_ONLY = 1
	LDA $C051		; text
	LDA $C052		; all text, no mix
	LDA $C054		; primary page
	.endif

				;JSR check_timer
	.if GR_ONLY = 0

	.if DEBUG
	LDA $C053
	.else
	LDA $C052	     ; mix text and gfx (c052 = full text/gfx)
	.endif

	LDA $C054		; Page 1
	;; LDA $C055		;Page 2
	LDA $C057
	LDA $C050 ; display graphics; last for cleaner mode change (according to Apple doc)

	.endif

	;; .ifdef MUSIC
	;; JSR start_player
	;; .endif


loop_infinite:
	;jmp loop_infinite
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
	;store_16 ticks, 0
	.endif



	;; 1.04 pour 27 images => 25 fps



	.if ONE_PAGE		; ------------------------------------

;;; ;;;;;;;; ONE PAGE ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


	.if GR_ONLY = 0
	LDA $C054		; Show page 2
	LDA $C057
	LDA $C050
	.endif

	jsr draw_to_page2

all_lines:
	copy_16 line_data_ptr, line_data_ptr1
	LDA #1
	STA color
	JSR draw_or_erase_multiple_lines

	copy_16 line_data_ptr, line_data_ptr1
	LDA #0
	STA color
	JSR draw_or_erase_multiple_lines

	copy_16 line_data_ptr, line_data_ptr1
	jsr skip_a_frame

	copy_16 line_data_ptr1, line_data_ptr


	.else			;--------------------------------

;;; ;;;;;;;; TWO PAGES ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	;; Page flipping mode

all_lines:
	jsr draw_to_page4

	copy_16 line_data_ptr, line_data_ptr1
	LDA #$0
	STA color
	JSR draw_or_erase_multiple_lines

	jsr skip_a_frame
	copy_16 line_data_ptr1, line_data_ptr

	LDA #1
	STA color
	JSR draw_or_erase_multiple_lines
	BCS all_done

	.if GR_ONLY = 0
	LDA $C055	; Show page 4
	LDA $C057
	LDA $C050 	; display graphics; last for cleaner mode change
	.endif

	;; -----------------------------------------------
freeze:
	jsr draw_to_page2

	copy_16 line_data_ptr, line_data_ptr2

	LDA #$0
	STA color
	JSR draw_or_erase_multiple_lines

	jsr skip_a_frame
	copy_16 line_data_ptr2, line_data_ptr

	LDA #1
	STA color
	JSR draw_or_erase_multiple_lines
	BCS all_done

	.if  GR_ONLY = 0
	LDA $C054		; Show page 2
	LDA $C057
	LDA $C050 ; display graphics; last for cleaner mode change
	.endif

	.endif 			; TWO PAGES
;;; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	LDX #15
show_sectors:
	lda sector_status,X
	sta $6d0,X
	DEX
	BPL show_sectors
	;; We pause a bit of time before
	;; loading a new file. Ths is to ensure
	;; that both line data pointers are one
	;; the same page. The wait is triggered
	;; by setting "end of block" to a counter.
	;; When it's 255, it means we're not waiting
	;; anything.

disk_stuff:
	LDA end_of_block
	CMP #255		; we're not waiting anything
	BEQ no_track_load
	CMP #0			; we reached the end of the counter
	BEQ wait_track_load	; so we can start to load the next file
	DEC end_of_block	; we still have to wait some more
	JMP no_track_load
wait_track_load:
	LDA #255		; We're done waiting
	STA end_of_block
	LDA next_file_to_load
	JSR init_file_load
	INC next_file_to_load
no_track_load:

	JMP all_lines
all_done:

	RTS


	jmp demo3

lazy2:
	.byte 0

;;; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

.proc draw_or_erase_multiple_lines

one_more_line:

	JSR draw_or_erase_a_line

	add_const_to_16 line_data_ptr, BYTES_PER_LINE

	LDY #0
	LDA (line_data_ptr),Y

	AND #31
	CMP #3
	BMI one_more_line	; A < 3 ?

	BEQ end_of_frame	; A = 3 => end of frame

	CMP #4
	BEQ end_of_all_frames

	;; A = 5 : end of data file,
	;store_16 line_data_ptr, $E000


	;; Since we draw on alternating pages, we'll come
	;; here twice in sequence at the end of each block.
	;; We thus make sure we don't do the same work
	;; twice.

;; 	INC end_of_block
;; 	LDA end_of_block
;; 	CMP #2
;; 	BNE dont_init_load
;; 	LDA #0
;; 	STA end_of_block

	;; Guard against delay in the track read

;; wait_read:
;; 	LDA read_in_pogress
;; 	CMP #0
;; 	BNE wait_read


	;; This is a huge hack to avoid counting the right moment
	;;  to start loading data (rememebr we're dealing with two
	;; buffers, with skip frames, redraws, etc. where it's quite
	;; difficult to know when to start loading new data)
	;; FIXME Although it works, I'm sure this wastes some time.

	LDA #2
	STA end_of_block


load_already_initiated:
dont_init_load:

	LDA line_data_ptr + 1
	AND #$F0
	EOR #($D0 ^ $E0)
	STA line_data_ptr + 1
	LDA #0
	STA line_data_ptr


	;; FIXME 	add_const_to_16 line_data_ptr, BYTES_PER_LINE
	CLC
	RTS

end_of_all_frames:
	store_16 line_data_ptr, lines_data
	SEC
	RTS

end_of_frame:
	add_const_to_16 line_data_ptr, 1
	CLC
	RTS

	.endproc
end_of_block:	.byte 255

;;; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	.proc wait_disk_read
wait_read2:
	inc $2000
	;; JSR read_sector_in_track

	LDA read_in_pogress
	CMP #0
	BNE wait_read2
	rts
	.endproc


	.import txt_ofs
	.import sect, old_sect, ace_jump, base_jump_pause, ticks
	.import distance_to_next_sector, sector_status

;; ;;; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; 	.proc instru_read_sector_in_track

;; 	LDA stop_count
;; 	BNE dont_stop
;; full_freeze:
;; 	;JMP full_freeze

;; dont_stop:
;; 	LDA read_in_pogress
;; 	BNE do_read
;; 	RTS
;; do_read:

;; 	LDA ace_jump
;; 	BEQ no_ace_jump
;; 	STA $7D0+38
;; 	RTS

;; no_ace_jump:

;; 	LDA base_jump_pause
;; 	BEQ no_jump_pause

;; 	LDA ticks
;; wait:
;; 	CMP ticks
;; 	BEQ wait
;; 	DEC base_jump_pause
;; 	RTS

;; no_jump_pause:
;; 	JSR read_sector_in_track

;; 	.if  ::DEBUG = 1

;; 	LDA useless_sector
;; 	BNE failed_a_sector

;; 	LDX sect
;; 	LDA #'!'+$80
;; 	STA $7d0 + 20,X
;; 	RTS

;; failed_a_sector:
;; 	DEC stop_count

;; 	.import current_track
;; 	LDX current_track
;; 	LDA hexa,X
;; 	CLC
;; 	STA $7d0+17

;; 	LDX #15
;; copy_status:
;; 	LDA #'.'+$80
;; 	STA $7D0,X
;; 	STA $7D0+20,X

;; 	LDA sector_status,X
;; 	BEQ empty_status
;; not_empty_status:
;; 	LDA #'-'
;; 	BNE draw_status
;; empty_status:
;; 	LDA #'.'
;; draw_status:
;; 	CLC
;; 	ADC #$80
;; 	STA $7D0,X
;; 	DEX
;; 	BPL copy_status

;; mark_sector:
;; 	LDX #23*2
;; 	LDA txt_ofs+1,X
;; 	STA debug_ptr + 1
;; 	LDA txt_ofs,X
;; 	STA debug_ptr

;; 	LDA useless_sector
;; 	ASL
;; 	ASL
;; 	ASL
;; 	ASL
;; 	ASL
;; 	ASL
;; 	STA smc1 + 1

;; 	LDY sect
;; 	CPY #15
;; 	BMI good_sect
;; 	LDY #20
;; 	LDA #'?'+$80
;; 	BNE show_sect
;; good_sect:
;; 	LDA hexa,Y
;; show_sect:
;; 	CLC
;; smc1:
;; 	ADC #0

;; 	STA $7D0,Y

;; 	;; LDY old_sect
;; 	;; LDA #'X'
;; 	;; STA $7D0,Y


;; 	JSR distance_to_next_sector

;; 	.import ace_jump_target
;; 	.import CLOCK_SPEED

;; 	PHA
;; 	lda	#<CLOCK_SPEED	; 40
;; 	sta	MOCK_6522_T1CL	; write into low-order latch
;; 	lda	#>CLOCK_SPEED	; 9C
;; 	sta	MOCK_6522_T1CH	; write into high-order latch,
;; 	PLA

;; 	STA ace_jump

;; 	;; A = ticks to wait for ace jump
;; 	CLC
;; 	ROR
;; 	TAX
;; 	LDA hexa,X
;; 	CLC
;; 	ADC #$80
;; 	STA $7d0 + 19

;; 	TYA			; Y = distance
;; 	TAX
;; 	LDA hexa,X
;; 	CLC
;; 	ADC #$80
;; 	STA $7d0 + 18
;; 	TYA

;; 	CLC
;; 	ADC sect
;; 	AND #15
;; 	STA ace_jump_target
;; 	TAX
;; 	LDA $7D0,X
;; 	SEC
;; 	SBC #$80
;; 	STA $7D0,X

;; 	.endif 				; debug

;; 	RTS

;; useless_sectors:	.byte 0
;; stop_count:	.byte 23

;; 	.endproc


;;; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	.proc skip_a_frame

one_more_line:

	add_const_to_16 line_data_ptr, BYTES_PER_LINE

	LDY #0
	LDA (line_data_ptr),Y

	AND #31			; 5 bits
	CMP #3
	BMI one_more_line	; A < 3 ?
	BEQ end_of_frame	; A = 3 => end of frame

	CMP #4
	BEQ end_of_all_frames

	; A = 5 : end of memory block
end_of_memblock:
	jsr wait_disk_read

	;; A = 5 end of block
	LDA line_data_ptr + 1
	AND #$F0
	EOR #($D0 ^ $E0)
	STA line_data_ptr + 1
	LDA #0
	STA line_data_ptr
	RTS

end_of_all_frames:
	store_16 line_data_ptr, lines_data
	RTS

end_of_frame:
	add_const_to_16 line_data_ptr, 1
	RTS

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
	CMP #1
	BNE unsupported_command
	jsr draw_vline_full
unsupported_command:
	rts
.endproc

.proc draw_to_page4
	store_16 line_code_ptr_lo, p2_line_ptrs_lo
	store_16 line_code_ptr_hi, p2_line_ptrs_hi
	store_16 blank_line_code_ptr_lo, p2_blank_line_ptrs_lo
	store_16 blank_line_code_ptr_hi, p2_blank_line_ptrs_hi
	store_16 hgr_offsets_lo, hgr4_offsets_lo
	store_16 hgr_offsets_hi, hgr4_offsets_hi

	store_16 notb_line_code_ptr_lo, notb_p2_line_ptrs_lo
	store_16 notb_line_code_ptr_hi, notb_p2_line_ptrs_hi
	RTS
.endproc

.proc draw_to_page2
	store_16 line_code_ptr_lo, line_ptrs_lo
	store_16 line_code_ptr_hi, line_ptrs_hi
	store_16 blank_line_code_ptr_lo, blank_line_ptrs_lo
	store_16 blank_line_code_ptr_hi, blank_line_ptrs_hi
	store_16 hgr_offsets_lo, hgr2_offsets_lo
	store_16 hgr_offsets_hi, hgr2_offsets_hi

	store_16 notb_line_code_ptr_lo, notb_line_ptrs_lo
	store_16 notb_line_code_ptr_hi, notb_line_ptrs_hi
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


line_data_ptr1:	.word 0
line_data_ptr2:	.word 0
lines_to_do:	.byte 0
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
next_file_to_load:	.byte 0

.proc draw_hline_full

	LDY #0
	LDA (line_data_ptr),Y
	LSR
	LSR
	LSR
	LSR
	LSR
	AND #7
	TAY
	LDA hline_masks_right, Y
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










	;; .repeat 256/7+1,I
	;; .repeat 7
	;; .byte	I
	;; .endrep
	;; .endrep


	;; Tools
	.include "lib.s"

	;; Macros to generate line drawing code
	NO_BREAK_INDICATOR = $7F
	BACKGROUND_COLOR = $FF
	RIGHT_TO_LEFT = 1
	LEFT_TO_RIGHT = 2
	TOP_DOWN = 2
	BOTTOM_UP = 1
	CLEARING = 1
	DRAWING = 2
	;.global RIGHT_TO_LEFT, LEFT_TO_RIGHT
	.include "vline.s"
	.include "hline.s"

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
	draw_hline2 TOP_DOWN
.endproc

.proc draw_hline_up
	draw_hline2 BOTTOM_UP
.endproc

.proc erase_hline
	draw_hline2 TOP_DOWN, 1
.endproc

.proc erase_hline_up
	draw_hline2 BOTTOM_UP, 1
.endproc


;; 	;PT3_LOC = $0C00
;; 	.include "pt3_lib/zp.inc"

;; 	;; https://github.com/deater/dos33fsprogs/tree/master/pt3_lib
;; start_player:
;; 	lda	#0
;; 	sta	DONE_PLAYING
;; 	lda	#1
;; 	sta LOOP

;; 	;jsr	mockingboard_detect
;; 	;jsr	mockingboard_patch
;; 	jsr	mockingboard_init
;; 	jsr	mockingboard_setup_interrupt

;; 	;============================
;; 	; Init the Mockingboard
;; 	;============================

;; 	jsr	reset_ay_both
;; 	jsr	clear_ay_both

;; 	;==================
;; 	; init song
;; 	;==================

;; 	jsr	pt3_init_song

;; 	;============================
;; 	; Enable 6502 interrupts
;; 	;============================
;; 	cli ; clear interrupt mask

;; 	RTS

	;; ; some firmware locations
	;; .include "pt3_lib/hardware.inc"
	;; .include "pt3_lib/pt3_lib_core.s"
	;; .include "pt3_lib/pt3_lib_init.s"
	;; .include "pt3_lib/pt3_lib_mockingboard_setup.s"
	;; .include "pt3_lib/interrupt_handler.s"
	;; ; if you're self patching, detect has to be after
	;; ; interrupt_handler.s
	;; .include "pt3_lib/pt3_lib_mockingboard_detect.s"

	;; DATA ////////////////////////////////////////////////////
	.include "build/precalc.s"
	.proc read_any_sector
	RTS
	.endproc

modulo7:
	.repeat 256,I
	.byte	I .MOD 7
	.endrep

div7:
	.repeat 256,I
	.byte I / 7		; integer division, no rounding
	.endrep

	.include "build/htiles.s"
	.include "build/tiles.s"
	.include "build/tiles_lr.s"






	;; /////////////////////////////////////////////////////////
	;; D000 SEGMENT
	;; /////////////////////////////////////////////////////////

	.segment "RAM_D000"


lines_data:

;; line_data_frame1:
;; line_data_frame2:

	.include "build/lines.s"
