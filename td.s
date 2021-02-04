	END_OF_TRACK = $FE
	END_OF_MOVIE = $FF
	PICTURE_LOAD = $FD

;;; This code is (c) 2019-2020 Stéphane Champailler
;;; It is published under the terms of the
;;; GNU GPL License Version 3.

;;; Part of this code (see below) is copied from the PT3 player by Vince "Deater" Weaver and is licensed accordingly

	.import init_file_load
	.import load_file
	.import first_page
	.import read_in_pogress
	.import file_being_loaded
	.import read_sector_in_track
	.import useless_sector
	.import sector_status
	.import handle_track_progress


	.include "defs.s"
	.include "build/xbin_lines_const.s"

MOCK_6522_T1CL	=	$C404	; 6522 #1 t1 low order latches
MOCK_6522_T1CH	=	$C405	; 6522 #1 t1 high order counter

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
dummy_ptr3	= 250
line_data_ptr	= 250
tile_ptr	= 252
mul1 = dummy_ptr
mul2 = dummy_ptr+1
dummy_ptr2	= 252
dummy_ptr	= 254
dummy_pointer	= 254

BYTES_PER_LINE	= threed_line_size_marker - line_data_frame1


	.segment "CODE"

	STA next_file_to_load
				;JSR init_disk_read	; Must be done before any read sector

	.if GR_ONLY = 1
	LDA $C051		; text
	LDA $C052		; all text, no mix
	LDA $C054		; primary page
	.endif
	.if GR_ONLY = 0

	.ifdef DEBUG
	LDA $C053
	.else
	LDA $C052	     ; mix text and gfx (c052 = full text/gfx)
	.endif

	LDA $C054		; Page 1
	;; LDA $C055		;Page 2
	LDA $C057
	LDA $C050 ; display graphics; last for cleaner mode change (according to Apple doc)

	.endif


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

	store_16 line_data_ptr1, lines_data

	copy_16 line_data_ptr, line_data_ptr1
	jsr skip_a_frame2
	copy_16 line_data_ptr2, line_data_ptr


	;store_16 line_data_ptr2, lines_data + SECOND_FRAME_OFFSET

				; 	add_const_to_16 line_data_ptr2, LINES_TO_DO * BYTES_PER_LINE +1
demo3:

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
	jsr skip_a_frame2

	copy_16 line_data_ptr1, line_data_ptr


	.else			;--------------------------------

;;; ;;;;;;;; TWO PAGES ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	;; Page flipping mode

all_lines:
	jsr draw_to_page4

	;; Clear past frame
	copy_16 line_data_ptr, line_data_ptr1
	LDA #$0
	STA color
	JSR draw_or_erase_multiple_lines

	jsr skip_a_frame2
	jsr skip_a_frame2
	BCC go_on
	JMP all_done
go_on:
	;; Draw new frame
	copy_16 line_data_ptr1, line_data_ptr

	LDA #1
	STA color
	JSR draw_or_erase_multiple_lines

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

	jsr skip_a_frame2
	jsr skip_a_frame2
	BCS all_done
	copy_16 line_data_ptr2, line_data_ptr

	LDA #1
	STA color
	JSR draw_or_erase_multiple_lines

	.if  GR_ONLY = 0
	LDA $C054		; Show page 2
	LDA $C057
	LDA $C050 ; display graphics; last for cleaner mode change
	.endif

	.endif 			; TWO PAGES
;;; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	;; We pause a bit of time before
	;; loading a new file. Ths is to ensure
	;; that both line data pointers are on
	;; the same page. The wait is triggered
	;; by setting "end of block" to a counter.
	;; When it's 255, it means we're not waiting
	;; anything.

disk_stuff:
	JSR handle_track_progress

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


;; 	INC frame_count
;; 	LDA frame_count
;; infini_freeze:
;; 	CMP #3
	;BEQ infini_freeze


	JMP all_lines
all_done:
	.if GR_ONLY = 0
	LDA $C055	; Show page 4
	LDA $C057
	LDA $C050 	; display graphics; last for cleaner mode change
	.endif


	;; store_16 dummy_ptr2, hgr4_offsets_lo
	;; store_16 dummy_ptr3, hgr4_offsets_hi
	;; JSR clear_hgr_band
	;; store_16 dummy_ptr2, hgr2_offsets_lo
	;; store_16 dummy_ptr3, hgr2_offsets_hi
	;; JSR clear_hgr_band

	;; Finish file load
still_stuff_to_read:
	JSR handle_track_progress
	BCS still_stuff_to_read

	RTS


	;; jmp demo3

frame_count:
	.byte 0

;;; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	.proc draw_or_erase_multiple_lines



	;store_16 line_data_ptr, $E000 ; DEBUG !!!

draw_or_erase_frame:
	;; jmp draw_or_erase_frame

	;; Start parsing a new frame

	LDY #1			; Skip frame size in bytes
	LDA (line_data_ptr),Y	; paths count OR special command
	INY

	CMP #PICTURE_LOAD
	BNE not_load_a_picture

	LDY #3
	LDA (line_data_ptr),Y	; paths count
	INY			; position on first edges count
	JMP draw_paths

not_load_a_picture:
	CMP #END_OF_TRACK
	BEQ end_of_track

	CMP #END_OF_MOVIE
	BEQ end_of_movie


draw_paths:
	STA paths_count

next_path:
	LDA (line_data_ptr),Y	; Number of edges in one path
	INY
	STA edge_count
next_edge:
	;; Edges are like this : P0-P1-P2, and that
	;; gives [P0-P1],[P1-P2]

	LDA (line_data_ptr),Y
	INY
	STA x1
	LDA #0
	STA x1+1
	LDA (line_data_ptr),Y
	INY
	STA y1

	STY frame_offset	; store for later

	LDA (line_data_ptr),Y
	INY
	STA x2
	LDA #0
	STA x2+1
	LDA (line_data_ptr),Y
	STA y2

	JSR draw_or_erase_a_line

	LDY frame_offset	; restore

	DEC edge_count
	BNE next_edge

	INY			; skip the last point of the path.
	INY
	DEC paths_count
	BNE next_path

	STY frame_offset
	LDY #1			; Skip frame size in bytes
	LDA (line_data_ptr),Y	; paths count OR special command
	CMP #PICTURE_LOAD
	;BEQ draw_a_picture
end_of_track:
end_of_movie:
	RTS

draw_a_picture:
	copy_16 dummy_ptr, line_data_ptr
	LDA frame_offset
	add_a_to_16 dummy_ptr
	LDA #$0
	STA block_page_select
	JSR load_a_picture

	copy_16 dummy_ptr, line_data_ptr
	LDA frame_offset
	add_a_to_16 dummy_ptr
	LDA #$20
	STA block_page_select
	JSR load_a_picture
	RTS



load_a_picture:

	;; line_data_ptr+Y points to the data we need
	;; but line_data_ptr will have to be moved on the next frame

	;; LDY #0
	;; LDA (hgr_offsets_hi),Y
	;; SEC
	;; SBC #$20
	;; STA block_page_select

	LDA #0
	STA ypos_start		; the block will be drawn from ypos_start
	LDA #190
	STA ypos_end		; to ypos_end
	LDA #36			; it will start on X (measured in bytes)
	STA xpos

	LDA #4			; the width of the block, in bytes
	STA row_width

	;; dummy_ptr = src of data

	;; LDA #$60
	;; STA dummy_ptr + 1
	;; LDA #0
	;; STA dummy_ptr
	JMP block_draw_entry_point

	.include "block_draw.s"


frame_offset:	.byte 0
paths_count:	.byte 0
edge_count:	.byte 0

	.endproc


;;; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	.proc skip_a_frame2

	;; Move to next frame

	LDY #1
	LDA (line_data_ptr),Y	; What kind of frame have we ?
	CMP #PICTURE_LOAD
	BNE regular_frame

	;; Picture load frames a re a bit special, they have picture
	;; data followed by vector data.

	INY			; Load the MSB of the byte count
	LDA (line_data_ptr),Y
	TAX

	LDY #0
	LDA (line_data_ptr),Y	; LSB of the byte count
	CLC
	ADC line_data_ptr
	STA line_data_ptr
	TXA			; remember the MSB
	ADC line_data_ptr+1
	STA line_data_ptr+1
	BCC process_next_frame	; Always taken

regular_frame:
	LDY #0
	LDA (line_data_ptr),Y	; read byte count




	;; Position ourselves at the beginning of the
	;; next frame.
	;; Note that on end of movie, the byte count is zero.

	add_a_to_16 line_data_ptr

process_next_frame:
	;; Detect various ends

	INY			; Y := 1, skip byte count
	LDA (line_data_ptr),Y	; read path count OR special command


	CMP #END_OF_TRACK
	BEQ end_of_track

	CMP #END_OF_MOVIE
	BNE go_on

	LDA #255
	STA end_of_block
	SEC
	RTS

end_of_track:
	;;  Switch banks
	LDA line_data_ptr + 1
	AND #$F0
	EOR #($D0 ^ $E0)
	STA line_data_ptr + 1
	LDA #0
	STA line_data_ptr

	;; Trigger next file read (later)
	LDA #4
	STA end_of_block

go_on:
	CLC
	RTS

	.endproc

;;; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

.proc draw_or_erase_multiple_lines_old

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
	inc $2002
	inc $4000
	inc $4002
	JSR handle_track_progress
	BCS wait_read2
	RTS
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

	;; LDY #6

	;; LDA (line_data_ptr),Y
	;; STA x1
	;; INY
	;; LDA (line_data_ptr),Y
	;; STA x1 + 1

	;; INY
	;; LDA (line_data_ptr),Y
	;; STA y1

	;; INY
	;; LDA (line_data_ptr),Y
	;; STA x2
	;; INY
	;; LDA (line_data_ptr),Y
	;; STA x2 + 1

	;; INY
	;; LDA (line_data_ptr),Y
	;; STA y2

	.include "compu_line.s"




slope65536:	.word 0
slope256_2:	.word 0
slope_by_256:	.byte 0
work:	.word 0
dx:	.word 0
dy:	.byte 0
dx_positive:	.byte 0
dy_positive:	.byte 0
work1:	.byte 0
work2:	.byte 0
left_mask:	.byte 0
right_mask:	.byte 0
clip_flags:	.byte 0

.endproc

x1:	.word 0
y1:	.byte 0
x2:	.word 0
y2:	.byte 0


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

;; 	.proc multiply_8
;; 	;; Multiply mul1 * mul2

;; 	LDA #0
;; 	CMP mul2		; Clear Carry too
;; 	BEQ by0

;; 	dec mul2	; decrement mul2 because we will be adding with carry set for speed (an extra one)

;; 	ror mul1
;; 	bcc b1
;; 	adc mul2
;; b1:
;; 	ror
;; 	ror mul1
;; 	bcc b2
;; 	adc mul2
;; b2:
;; 	ror
;; 	ror mul1
;; 	bcc b3
;; 	adc mul2
;; b3:
;; 	ror
;; 	ror mul1
;; 	bcc b4
;; 	adc mul2
;; b4:
;; 	ror
;; 	ror mul1
;; 	bcc b5
;; 	adc mul2
;; b5:
;; 	ror
;; 	ror mul1
;; 	bcc b6
;; 	adc mul2
;; b6:
;; 	ror
;; 	ror mul1
;; 	bcc b7
;; 	adc mul2
;; b7:
;; 	ror
;; 	ror mul1
;; 	bcc b8
;; 	adc mul2
;; b8:
;; 	ror
;; 	ror mul1
;; 	inc mul2
;; 	rts
;; by0:
;; 	STA mul1
;; 	RTS
;; 	.endproc







	;; .repeat 256/7+1,I
	;; .repeat 7
	;; .byte	I
	;; .endrep
	;; .endrep


	;; Tools
	.include "lib.s"

	;; Macros to generate line drawing code
	NO_BREAK_INDICATOR = $7F
	BACKGROUND_COLOR = $7F
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
	direction = TOP_DOWN
	clearing = 0
	.include "hline_base.s"
.endproc

.proc draw_hline_up
	direction = BOTTOM_UP
	clearing = 0
	.include "hline_base.s"
.endproc

.proc erase_hline
	direction = TOP_DOWN
	clearing = 1
	.include "hline_base.s"
.endproc

.proc erase_hline_up
	direction = BOTTOM_UP
	clearing = 1
	.include "hline_base.s"
.endproc

	.proc clear_hgr_band
	LDA #191
	STA clear_hgr_y_count
clear_hgr_loop:
clear_hgr_y_count = * + 1
	LDY #191
	LDA (dummy_ptr2),Y
	STA dummy_ptr
	LDA (dummy_ptr3),Y
	STA dummy_ptr + 1

	LDY #0

	LDA #$0
	STA (dummy_ptr),Y
	INY
	STA (dummy_ptr),Y
	INY

	LDA #$7F
clear_hgr_line_loop:
	STA (dummy_ptr),Y
	INY
	CPY #38
	BNE clear_hgr_line_loop

	LDA #$0
	STA (dummy_ptr),Y
	INY
	STA (dummy_ptr),Y

	DEC clear_hgr_y_count
	LDA clear_hgr_y_count
	CMP #$FF
	BNE clear_hgr_loop


	RTS
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
	.repeat 256,I		; I starts at zero.
	.byte	I .MOD 7
	.endrep

div7:
	.repeat 256,I
	.byte I / 7		; integer division, no rounding
	.endrep

	.include "build/htiles.s"
	.include "build/tiles.s"
	.include "build/tiles_lr.s"
one_over_x:
	.include "build/divtbl.s"






	;; /////////////////////////////////////////////////////////
	;; D000 SEGMENT
	;; /////////////////////////////////////////////////////////

	.segment "RAM_D000"


lines_data:

;; line_data_frame1:
;; line_data_frame2:

	.include "build/lines.s"
