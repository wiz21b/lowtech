;;; This code is (c) 2019 Stéphane Champailler
;;; It is published under the terms of the
;;; GUN GPL License Version 3.

	.segment "CODE"

	.import ticks
	.import init_file_load, load_file, handle_track_progress
	.import current_pattern_smc, current_line_smc

	.include "defs.s"
	.include "precalc_def.s"

	text_pointer	= 240
	cursor_script_ndx = 250
	x_pos	= 252
	y_pos	= 254
	dummy_ptr3	= 244
	dummy_ptr	= 246
	scroll_matric_ptr       = 248
	dummy_ptr2		= 248

	.include "build/toc_equs.inc"

	FILE1 = FILE_THREED
	FILE2 = FILE_DATA_3D_0
	FILE3 = FILE_DATA_3D_1

	;; store_16  dummy_ptr, filename_FILLER
	;; store_16  iobuffer, ($6000-1024)
	;; store_16 file_buffer, $6000
	;; JSR load_file

	;; store_16 dummy_ptr, filename_SONG
	;; store_16 file_buffer, $4000
	;; JSR load_file

	;; store_16 dummy_ptr, filename_EARTH
	;; store_16 file_buffer, $2000
	;; JSR load_file

	lda #$0
	ldx #$40
	JSR clear_hgr2
	lda #$0
	ldx #$20
	JSR clear_hgr2

	LDA $C052
	;LDA $C054		; Page 1
	LDA $C055		;Page 2
	LDA $C057
	LDA $C050 ; display graphics; last for cleaner mode change (according to Apple doc)

	LDA #FILE1
	JSR init_file_load

	LDA #$10
	JSR wait_pt3_beat

	CURSOR_BASE_COLOR = 128 + 7

	LDA #$20
	STA block_page_select
	STA filled_block_page_select

	store_16 cursor_script_ndx, cursor_script
read_script:
	LDY #0
	LDA (cursor_script_ndx),Y

	CMP #$FF
	BNE script_not_done
	LDA #0
	STA cursor_color
	JSR clear_cursor

	JMP text_pane

script_not_done:
	LDA cursor_color
	PHA
	LDA #0
	STA cursor_color
	JSR clear_cursor

	LDY #0
	LDA (cursor_script_ndx),Y
	STA cursor_pos_x
	INY
	LDA (cursor_script_ndx),Y
	STA cursor_pos_y
	INY
	LDA (cursor_script_ndx),Y
	TAX
	INY
	LDA (cursor_script_ndx),Y
	BEQ pause_mode

	STX dummy_ptr
	STA dummy_ptr + 1

	INY
	LDA (cursor_script_ndx),Y ; width
	LDX cursor_pos_x

	CMP #64			; letters without are offset by +128
	BPL no_cursor_push

	;; X = letter pos (not cursor pos)
	;; A = letter width

	CLC
	ADC cursor_pos_x
	;; SEC
	;; SBC #0
	STA cursor_pos_x
no_cursor_push:
	; X = x pos
	LDA (cursor_script_ndx),Y ; width
	AND #127
	JSR draw_letter

	LDX #8

pause_mode:
	STX cursor_script_wait
go_on:
	PLA
	LDA #CURSOR_BASE_COLOR
	STA cursor_color
	LDA #0
	STA cursor_time
	JSR clear_cursor
	add_const_to_16 cursor_script_ndx,5

cursor_blink:
	DEC cursor_script_wait
	LDA cursor_script_wait
	BNE script_wait
	JMP read_script
script_wait:
	INC cursor_time
	LDA cursor_time
	CMP #20
	BNE pause_cursor
	LDA #0
	STA cursor_time

	LDA cursor_color
	EOR #CURSOR_BASE_COLOR
	STA cursor_color
	JSR clear_cursor

pause_cursor:
	JSR handle_track_progress
	LDA #1
	JSR pause
	jmp cursor_blink

clear_cursor:
	LDX cursor_pos_x
	STX filled_xpos		; it will start on X = 30 (measured in bytes)
	LDA #1
	STA filled_row_width		; the width of the block, in bytes

	LDA cursor_pos_y
	STA filled_ypos_start		; the block will be drawn from ypos_start
	CLC
	ADC #19
	STA filled_ypos_end		; to ypos_end

	LDA cursor_color
	STA filled_block_color
	jsr filled_block_draw_entry_point
	RTS


;;; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;

cursor_time:	.byte 0
cursor_color:	.byte 0
cursor_pos_x:	.byte 0
cursor_pos_y:	.byte 0
cursor_script:
	CURSOR_SPEED=10
	CURSOR_X = 1
	.byte CURSOR_X,10,100,0,0
	.byte CURSOR_X,30,50,0,0
	.byte CURSOR_X,50,50,0,0
	.byte CURSOR_X,70,CURSOR_SPEED,0,0
	.byte CURSOR_X,90,CURSOR_SPEED,0,0
	.byte CURSOR_X,110,CURSOR_SPEED,0,0
	.byte CURSOR_X,130,CURSOR_SPEED,0,0
	.byte CURSOR_X,162,CURSOR_SPEED,0,0

	CONSOLE_LETTER_HEIGHT = 19
.byte 1,162,<mainlogo0,>mainlogo0,1
.byte 2,162,<mainlogo1,>mainlogo1,3
.byte 5,162,<mainlogo2,>mainlogo2,3
.byte 8,162,<mainlogo3,>mainlogo3,3
.byte 11,162,<mainlogo4,>mainlogo4,3
.byte 14,162,<mainlogo5,>mainlogo5,3
.byte 17,162,<mainlogo6,>mainlogo6,1
.byte 18,162,<mainlogo7,>mainlogo7,3

	;.byte 21,162,<mainlogo8,>mainlogo8,5
	.byte 21,162,200,0,0
	;.byte 21,162,<mainlogo8,>mainlogo8,4+128
	.byte 18,162,<mainlogo8,>mainlogo8,4+128
	.byte 17,162,<mainlogo8,>mainlogo8,4+128
	.byte 14,162,<mainlogo8,>mainlogo8,4+128
	.byte 11,162,<mainlogo8,>mainlogo8,4+128
	.byte 8,162,<mainlogo8,>mainlogo8,4+128
	.byte 5,162,<mainlogo8,>mainlogo8,4+128
	.byte 2,162,<mainlogo8,>mainlogo8,4+128
	.byte 1,162,<mainlogo8,>mainlogo8,4+128
	.byte 1,162,100,0,0
	.byte $ff

cursor_script_wait:	.byte 0

	.proc draw_earth
	;; A = HGR page select (0 or $20)

	STA block_page_select

	store_16 dummy_ptr, earth_block

	LDX #0
	STX xpos		; it will start on X = 30 (measured in bytes)
	LDA #40
	STA row_width		; the width of the block, in bytes

	LDA #154
	STA ypos_start		; the block will be drawn from ypos_start
	LDA #192
	STA ypos_end		; to ypos_end


	;; dummy_ptr = src of data

 	JSR block_draw_entry_point
	RTS
	.endproc

draw_letter:
	STX xpos		; it will start on X = 30 (measured in bytes)
	STA row_width		; the width of the block, in bytes

	LDA #162
	STA ypos_start		; the block will be drawn from ypos_start
	LDA #162+CONSOLE_LETTER_HEIGHT
	STA ypos_end		; to ypos_end

	;; dummy_ptr = src of data

 	JSR block_draw_entry_point
	RTS

;;; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

text_pane:
	;;  We're showing HGR page 2 and drawing on page 1
	LDA #$0
	JSR draw_earth
	JSR stars_fixed
	JSR stars

wait_beat1:
	LDA current_pattern_smc + 1
	CMP #1
	BNE wait_beat1


	.ifdef DEBUG
	LDA $C053
	.else
	LDA $C052	     ; mix text and gfx (c052 = full text/gfx)
	.endif

	LDA $C054		; 55
	LDA $C057
	LDA $C050 ; display graphics; last for cleaner mode change (according to Apple doc)

	store_16 text_pointer, m2_the_message
	JSR draw_text_line_animated

	;; All of this because we have to re-prepare HGR2
	;; for the big scroll

	;; We're showing page 1
	;; Copy visible page to hidden page 2

	LDA #>$2000
	LDX #>$4000
	LDY #$20
	jsr mem_copy

	;; Switch to hidden page
	LDA $C052	     ; mix text and gfx (c052 = full text/gfx)
	LDA $C055		; 55
	LDA $C057
	LDA $C050 ; display graphics; last for cleaner mode change (according to Apple doc)

	;;  Rebuild starfiled $2000 page from scratch

	lda #$0
	ldx #$20
	JSR clear_hgr2
	LDA #$0
	JSR draw_earth
	JSR stars_fixed
	JSR stars

	.ifndef DEBUG
wait_beat:
	LDA current_line_smc + 1
	BNE wait_beat
	.endif

	LDA $C052	     ; mix text and gfx (c052 = full text/gfx)
	LDA $C054		; 55
	LDA $C057
	LDA $C050 ; display graphics; last for cleaner mode change (according to Apple doc)

; ====================================================================

big_loop:

	LDA #0
	STA subcount
	lda #0
	sta count

loop2:

;; 	INC frame_trigger
;; wait_frame_trigger:
;; 	LDA frame_trigger
;; 	CMP #0
;; 	BEQ wait_frame_trigger

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
	add_const_to_16 dummy_ptr, matrix_rows ; matrix_rows[count + row_loop << 1]

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

;; 	CMP #130
;; 	BNE dont_load
;; 	LDA #FILE3
;; 	JSR init_file_load
;; dont_load:
	BMI don_load2
	JSR handle_track_progress
don_load2:
	jmp loop2
reset2:
	;store_16  ticks, 0

	;jmp big_loop

	RTS


;; hexa:		.asciiz "0123456789ABCDEF"
;; ticks:		.word $0000
;; STATUS_BUFFER = $7D0	; $750 $650
;; draw_status:

;; 	LDA ticks
;; 	AND #$F
;; 	TAY
;; 	LDA hexa,Y
;; 	STA STATUS_BUFFER+4

;; 	LDA ticks
;; 	AND #$F0
;; 	LSR
;; 	LSR
;; 	LSR
;; 	LSR
;; 	TAY
;; 	LDA hexa,Y
;; 	STA STATUS_BUFFER+3

;; 	LDA ticks+1
;; 	AND #$F
;; 	TAY
;; 	LDA hexa,Y
;; 	STA STATUS_BUFFER+2

;; 	LDA ticks+1
;; 	AND #$F0
;; 	LSR
;; 	LSR
;; 	LSR
;; 	LSR
;; 	TAY
;; 	LDA hexa,Y
;; 	STA STATUS_BUFFER+1

;; 	RTS





count:	.byte 0
subcount:	.byte 8
column_loop:	.byte 0
row_loop:	.byte 0
y_matrix:	.byte 0
vert_count:	.byte 0

; =============================================================================

jump_table_ptr	= dummy_ptr	; zero page
jump_ptr:	.word 0


copy_block:

	TAY			; Bloc to draw. First one has number 1.
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



;;; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	.proc draw_text_line_animated


	TEXT_PANE_START = 7
	LINE_HEIGHT = 12

	LDA #TEXT_PANE_START
	STA x_pos

	LDA #(192 - LINE_HEIGHT*8)/2 - LINE_HEIGHT
	STA y_pos

	LDY #0
	STY message_ndx

show_message_loop0:

	LDY message_ndx
	LDA (text_pointer),Y

	CMP #255		; text end marker
	BEQ end_text

	CMP #254
	BNE not_end_of_line		; text line end marker

	LDA #TEXT_PANE_START
	STA x_pos

	LDA y_pos
	CLC
	ADC #LINE_HEIGHT
	STA y_pos
	JMP continue_loop0

not_end_of_line:
	CMP #253
	BNE not_a_space

	LDA x_pos
	CLC
	ADC #7
	STA x_pos
	JMP continue_loop0

not_a_space:
	TAX

	.ifndef DEBUG
wait_beat:
	LDA current_line_smc + 1
	CMP pt3_last_line
	BEQ wait_beat
	STA pt3_last_line

	.endif

	JSR draw_letter_full


continue_loop0:
	INC message_ndx

	LDA message_ndx

	CMP #1
	BNE not_file2
	LDA #FILE2
	JSR init_file_load
	JMP just_load
not_file2:
	CMP #40
	BNE not_file3
	LDA #FILE3
	JSR init_file_load
not_file3:
just_load:
	JSR handle_track_progress
	JMP show_message_loop0

end_text:
	RTS

message_ndx:	.byte 0
pt3_last_line:	.byte 0
	.endproc

;;; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


	.proc draw_letter_full

	;; X = letter to draw
	;; x_pos, y_pos : where to draw
	;; page : page to draw to


	;;  Locate the letter

	STX letter_id

	LDA y_pos
	PHA

	LDA #0
	STA letter_line

	;; Select appropraitely "ROL-led" letter data

	LDX x_pos
	LDA div3,X		; pay attention! no exactly // 3 !
	STA x_pos_byte
	STA x_pos_byte_old

	LDA modulo3,X
	ASL			; times 4 (letter_tables entries are
	ASL			; 2x2 bytes long)
	TAX

	;; indirect pointer to "lo" table
	LDA letter_tables2,X
	STA dummy_ptr3
	INX
	LDA letter_tables2,X
	STA dummy_ptr3 +1
	INX

	LDY letter_id
	LDA (dummy_ptr3),Y	; lo_table[ Y]
	STA dummy_ptr


	;; indirect pointer to "hi" table
	LDA letter_tables2,X
	STA dummy_ptr3
	INX
	LDA letter_tables2,X
	STA dummy_ptr3 +1
	INX

	LDY letter_id
	LDA (dummy_ptr3),Y	; "hi" table + Y
	STA dummy_ptr+1

	LDY #0
	LDA (dummy_ptr),Y	; letter width
	STA hcount_base


	;; skip lines

	LDA #2			; skip 2 info bytes
	STA letter_pos

letter_vertical_loop:

	LDA x_pos_byte_old
	STA x_pos_byte

	;; Pointer to HGR line
	LDX y_pos
hdl0:
	LDA hgr4_offsets_lo,X
	STA dummy_ptr2
	LDA hgr4_offsets_hi,X
	; EOR hgr_page_select ($40 + $20 = $60)
	EOR #$60
	STA dummy_ptr2 + 1


	;; This is very special. It's to account for Apple
	;; weird HGR byte structure

	;; LDA x_pos_byte
	;; AND #1
	;; BNE letter_line_loop_rolled

letter_line_loop:


	;; draw specific line

	LDX hcount_base		; how many bytes to copy
horizontal_loop:
	LDY letter_pos
	LDA (dummy_ptr),Y	; letter data

	LDY x_pos_byte
	ORA (dummy_ptr2),Y
	STA (dummy_ptr2),Y	; update screen

	INC x_pos_byte
	INC letter_pos
	DEX
	BNE horizontal_loop

finish_loop:
	INC y_pos

	LDA letter_line
	CLC
	ADC #1
	STA letter_line

	CMP #10
	BNE letter_vertical_loop


	LDY #1			; read pixel width of letter
	LDA (dummy_ptr),Y
	CLC
	ADC x_pos
	STA x_pos

	PLA
	STA y_pos

	RTS

;; letter_line_loop_rolled:

;; 	;; ;; Pointer to HGR line
;; 	;; LDX y_pos
;; 	;; LDA hgr2_offsets_lo,X
;; 	;; STA dummy_ptr2
;; 	;; LDA hgr2_offsets_hi,X
;; 	;; STA dummy_ptr2 + 1

;; 	LDX hcount_base
;; 	CLC
;; horizontal_loop_rolled:
;; 	LDY letter_pos
;; 	LDA (dummy_ptr),Y	; letter data
;; 	ROL
;; 	AND #$7F

;; 	LDY x_pos_byte
;; 	ORA (dummy_ptr2),Y
;; 	STA (dummy_ptr2),Y	; update screen

;; 	;; Bring the carry in place for next iteration
;; 	LDY letter_pos
;; 	LDA (dummy_ptr),Y	; letter data
;; 	ROL
;; 	ROL

;; 	INC x_pos_byte
;; 	INC letter_pos
;; 	DEX
;; 	BNE horizontal_loop_rolled

;; 	JMP finish_loop


hcount:	.byte 0
hcount_base:	.byte 0
letter_line:	.byte 0
x_rol:	.byte 0
x_pos_byte:	.byte 0
x_pos_byte_old:	.byte 0
letter_id:	.byte 0
letter_pos:	.byte 0

message_ndx:	.byte 0

letter_tables2:
	.word f2_letter_ptrs_rol0_lo
	.word f2_letter_ptrs_rol0_hi

	.endproc

;;; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; clear_hgr:
;; 	store_16 dummy_pointer, (HGR_RAM + $2000)

;; clear_hgr_loop:
;; 	dec16 dummy_pointer

;; 	LDA #0
;; 	LDY #0
;; 	STA (dummy_pointer), Y


;; 	lda #$20
;; 	cmp dummy_pointer + 1
;; 	bne clear_hgr_loop
;; 	lda #0
;; 	cmp dummy_pointer
;; 	bne clear_hgr_loop

;; 	RTS


;; load_file:
;; 	LDA #<(filename_bfr+1)
;; 	STA dummy_ptr2
;; 	LDA #>(filename_bfr+1)
;; 	STA dummy_ptr2+1

;; 	LDY #0
;; copy_filename:
;; 	LDA (dummy_ptr),Y
;; 	BEQ done_copy_filename
;; 	STA (dummy_ptr2),Y
;; 	INY
;; 	JMP copy_filename
;; done_copy_filename:
;; 	STY filename_bfr

;; 	jsr $BF00	; ret code in A
;; 	.byte $C8	; OPEN
;; 	.word open_file_param

;; 	LDA ref_num0
;; 	STA ref_num1
;; 	STA ref_num2

;; 	jsr $BF00	; ret code in A
;; 	.byte $CA	; READ
;; 	.word read_file_param

;; 	jsr $BF00	; ret code in A
;; 	.byte $CC	; CLOSE
;; 	.word close_file_param
;; 	RTS


stars:
	LDX #3
	.include "build/stars.s"
    	rts

stars_fixed:
	.include "build/stars2.s"
	RTS

	.include "build/matrix.s"

;; filename_FILLER:	.asciiz "FILLER"
;; filename_SONG:	.asciiz "SONG"
;; filename_EARTH:	.asciiz "EARTH"

;; open_file_param:
;; 	.byte 3	; three params
;; 	.word filename_bfr
;; iobuffer:
;; 	.word $5000		; I/O 1024 bytes buffer address
;; ref_num0:
;; 	.byte 0
;; filename_bfr:
;; 	.byte 6 ; length
;; 	.byte 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0

;; read_file_param:
;; 	.byte 4	; three params
;; ref_num1:
;; 	.byte 0 ; ref_number
;; file_buffer:	.word $6000	; where to put the data
;; 	.word 20000	; requested length to read
;; 	.word 0	; actual length


;; close_file_param:
;; 	.byte 1	; three params
;; ref_num2:
;; 	.byte 0



frame_trigger:	.byte 0
read_any_sector:
	RTS
;; 	add_const_to_16 ticks, 1
;; 	inc frame_trigger
;; 	RTS



;;; The following code is (c) Vince "Deater" Weaver an dis not covered by the GNU GPL License


;; 	PT3_LOC = $4000


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

;; 	; some firmware locations
;; 	.include "pt3_lib/hardware.inc"
;; 	.include "pt3_lib/pt3_lib_core.s"
;; 	.include "pt3_lib/pt3_lib_init.s"
;; 	.include "pt3_lib/pt3_lib_mockingboard_setup.s"
;; 	.include "pt3_lib/interrupt_handler.s"
;; 	; if you're self patching, detect has to be after
;; 	; interrupt_handler.s
;; 	.include "pt3_lib/pt3_lib_mockingboard_detect.s"


	.align $100 		; FIXME do nothing
bs_precalc:
	.include "build/bs_precalc.s"

times8hi:
	.REPEAT 64,i			; i starts at 0
	.byte >bs_precalc + ((i * 8 * 2)   >> 8)
	.ENDREP
times8lo:
	.REPEAT 64,i
	.byte <bs_precalc + ((i * 8 * 2)  & 255)
	.ENDREP

	.include "../data/alphabet2.s"
	.include "../build/hgr_ofs.s"
div3:
	;;  Converts color X (so from 0 to 270/2, beacuse a color
	;;  pixel is made of 2 bits) to byte offset.
	.repeat 20,I
	.byte 2*I, 2*I, 2*I, 2*I, 2*I+1, 2*I+1, 2*I+1
	.endrep

modulo3:
	.repeat 20,I
	.byte	0,1,2,3,0,1,2
	.endrep


	.include "../lib.s"


mem_copy:
	;; A = source page
	;; X = dest page
	;; Y = numberof pages

	STA RELs1+2
	STX RELd1+2

	;;  copy one page
	ldx #$00
RELs1:	lda $FF00,x
RELd1:	sta $2000,x
        inx
        bne RELs1

        inc RELs1+2
        inc RELd1+2

	dey
        bne RELs1
	RTS

	;; -----------------------------------------------------------

;; block_draw:
;; 	LDA #100
;; 	STA ypos_start		; the block will be drawn from ypos_start
;; 	LDA #180
;; 	STA ypos_end		; to ypos_end
;; 	LDA #30			; it will start on X = 30 (measured in bytes)
;; 	STA xpos

;; 	LDA #5			; the width of the block, in bytes
;; 	STA row_width

;; 	;; dummy_ptr = src of data

;; 	LDA #$C0
;; 	STA dummy_ptr + 1
;; 	LDA #0
;; 	STA dummy_ptr

;; 	JMP block_draw_entry_point

;; loop_row:
;; 	;; A = Y of current line
;; 	TAX

;; 	;; offset: dummy_ptr2 := hgr_offset[X] + h_pos
;; 	CLC
;; 	LDA hgr4_offsets_lo,X
;; xpos = * + 1
;; 	ADC #0
;; 	STA dummy_ptr2
;; 	LDA hgr4_offsets_hi,X
;; 	ADC #0
;; 	STA dummy_ptr2+1

;; row_width = * + 1
;; 	LDY #0

;; byte_loop:
;; 	LDA (dummy_ptr),Y
;; 	STA (dummy_ptr2),Y
;; 	DEY
;; 	BPL byte_loop

;; 	;; Advance the source pointer
;; 	CLC
;; 	LDA dummy_ptr
;; 	ADC row_width
;; 	STA dummy_ptr
;; 	LDA dummy_ptr+1
;; 	ADC #0
;; 	STA dummy_ptr+1

;; 	INC ypos_start

;; block_draw_entry_point:
;; 	ypos_start = * + 1
;; 	LDA #0

;; 	ypos_end = * + 1
;; 	CMP #0
;; 	BNE loop_row

;; 	RTS


;;; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	.include "block_draw.s"
mainlogo0:
	.incbin "build/imphobia0.blk"
mainlogo1:
	.incbin "build/imphobia1.blk"
mainlogo2:
	.incbin "build/imphobia2.blk"
mainlogo3:
	.incbin "build/imphobia3.blk"
mainlogo4:
	.incbin "build/imphobia4.blk"
mainlogo5:
	.incbin "build/imphobia5.blk"
mainlogo6:
	.incbin "build/imphobia6.blk"
mainlogo7:
	.incbin "build/imphobia7.blk"
mainlogo8:
	.incbin "build/imphobia8.blk"
earth_block:
	.incbin "build/earth.blk"

	.proc clear_hgr2
	;; A = color to clear with
	;; X = page = $20 or $40

	sta smc + 1
	STX dummy_pointer + 1
	LDX #0
	STX dummy_pointer
	ldx #$20

	;; HGR memory is $4000 bytes => $40 x 256

clear_hgr_loop:

smc:
	LDA #$00

	LDY #0
clear_block:
	STA (dummy_pointer), Y
	DEY
	BNE clear_block

	INC dummy_pointer + 1
	DEX
	BNE clear_hgr_loop

	RTS
	.endproc



filled_block_draw:

filled_loop_row:
	;; A = Y of current line
	TAX

	;; offset: dummy_ptr2 := hgr_offset[X] + h_pos
	CLC
	LDA hgr2_offsets_lo,X
filled_xpos = * + 1
	ADC #0
	STA dummy_ptr2
	LDA hgr2_offsets_hi,X
filled_block_page_select = * + 1
	ADC #0
	STA dummy_ptr2+1

filled_row_width = * + 1
	LDY #0
	DEY			; fix the number for the loop

filled_byte_loop:
filled_block_color = * + 1
	LDA #0
	STA (dummy_ptr2),Y
	DEY
	BPL filled_byte_loop

	INC filled_ypos_start

filled_block_draw_entry_point:
	filled_ypos_start = * + 1
	LDA #0

	filled_ypos_end = * + 1
	CMP #0
	BNE filled_loop_row

	RTS

	.proc wait_pt3_beat
wait_beat:
	CMP current_line_smc + 1
	BNE wait_beat
	RTS
	.endproc
