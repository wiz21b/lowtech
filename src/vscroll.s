;; This code is (c) 2019 Stéphane Champailler
;;; It is published under the terms of the
;;; GNU GPL License Version 3.

;;; Part of this code (see below) is copied from the PT3 player by
;;; Vince "Deater" Weaver and is licensed accordingly


	.include "defs.s"
	.import current_pattern_smc, current_line_smc, current_subframe_smc

DEBUG = 0
ONE_PAGE = 0

	text_pointer	= 240
	hgr_ptr = 244
	letter_pos = 247
	x_pos	= 248
	y_pos	= 249
	dummy_ptr3	= 250
	dummy_ptr2	= 252
	dummy_ptr	= 254


LINES_TO_DO	= 6
BYTES_PER_LINE	= 6
	TEXT_X_MARGIN = 70

	.segment "CODE"


	;; HGR2 is displayed

	LDA #$80
	LDX #$20
	JSR clear_hgr2
	LDA #$0
	STA block_page_select
	JSR draw_iceberg

	LDA $C054		; Page 1
	LDA $C057
	LDA $C050 ; display graphics; last for cleaner mode change (according to Apple doc)

	;; HGR is displayed

	LDA #$80
	LDX #$40
	JSR clear_hgr2

	LDA #$20
	STA block_page_select
	JSR draw_iceberg

	LDA $C055		; Page 2
	LDA $C057
	LDA $C050 ; display graphics; last for cleaner mode change (accord

	LDA #TEXT_X_MARGIN
	STA x_pos
	LDY #10
	STY y_pos
	store_16 text_pointer, the_message
	;JSR draw_full_text

	;JSR draw_line_once

	;; .repeat 6,i
	;; LDA #i
	;; STA specific_line
	;; LDA #SCROLL_BOTTOM_LINE + i
	;; STA y_pos
	;; LDA #TEXT_X_MARGIN
	;; STA x_pos
	;; JSR draw_text_line
	;; .endrepeat

	;; ;JSR next_text_line

	;; .repeat 6,i
	;; LDA #i
	;; STA specific_line
	;; LDA #SCROLL_BOTTOM_LINE + 10 +i
	;; STA y_pos
	;; LDA #TEXT_X_MARGIN + 1
	;; STA x_pos
	;; JSR draw_text_line
	;; .endrepeat

;;; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

loop_infinite:

	JSR pause_2_irq

	SCROLL_BOTTOM_LINE = 191

	LDA $C055		;Page 2
	LDA $C057
	LDA $C050 ; display graphics; last for cleaner mode change (according to Apple doc)
	LDA #0
	STA hgr_page_select


	JSR vscroll1
	JSR copy_last_lines
	JSR clear_last_lines
 	LDA #SCROLL_BOTTOM_LINE
	STA y_pos
	JSR scroll_one_line

	JSR pause_2_irq
	LDA $C054		; Page 1
	LDA $C057
	LDA $C050 ; display graphics; last for cleaner mode change (according to Apple doc)
	LDA #$60
	STA hgr_page_select

	JSR vscroll2
	JSR copy_last_lines
	JSR clear_last_lines
 	LDA #SCROLL_BOTTOM_LINE
	STA y_pos
	JSR scroll_one_line

	;;  This doesn't work too well
;; 	LDA current_subframe_smc+1
;; sync_to_beat:
;; 	CMP current_subframe_smc+1
;; 	BEQ sync_to_beat

	jmp loop_infinite

hgr_page_select:
	.byte $0

;;; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	.proc vscroll1

	LDX #20
scroll_column:
	JSR vscroll_move
	INX
	CPX #39
	BNE scroll_column
	RTS
	.endproc

	.proc vscroll2
	LDX #20
scroll_column:
	JSR vscroll_move_p2
	INX
	CPX #39
	BNE scroll_column
	RTS
	.endproc

mem_copy:
	;; A = source page
	;; X = dest page
	;; Y = numberof pages

	STA RELs1+2
	STX RELd1+2

	;;  copy one page
	ldx #$00
RELs1:	lda picture_data,x
RELd1:	sta $2000,x
        inx
        bne RELs1

        inc RELs1+2
        inc RELd1+2

	dey
        bne RELs1
	RTS

;;; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	.proc clear_last_lines

	LDX #SCROLL_BOTTOM_LINE
letter_line_loop3:
	LDA hgr2_offsets_lo,X
	STA dummy_ptr2
	LDA hgr2_offsets_hi,X
	EOR hgr_page_select
	STA dummy_ptr2 + 1

	LDY #20
	LDA #0
line_loop3:
	STA (dummy_ptr2),Y
	INY
	CPY #40
	BNE line_loop3

	INX
	CPX #SCROLL_BOTTOM_LINE+1
	BNE letter_line_loop3
	RTS
	.endproc

;;; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	.proc copy_last_lines

	LDX #SCROLL_BOTTOM_LINE
letter_line_loop2:
	;;  source
	LDA hgr4_offsets_lo,X	; -1 to take scroll into account
	STA dummy_ptr3
	LDA hgr4_offsets_hi,X
	EOR hgr_page_select
	STA dummy_ptr3 + 1
	;;  destination
	LDA hgr2_offsets_lo-1,X
	STA dummy_ptr2
	LDA hgr2_offsets_hi-1,X
	EOR hgr_page_select
	STA dummy_ptr2 + 1


	LDY #20
line_loop:
	LDA (dummy_ptr3),Y
	STA (dummy_ptr2),Y
	INY
	CPY #40
	BNE line_loop

	INX
	CPX #SCROLL_BOTTOM_LINE+2
	;BNE letter_line_loop2

	rts
	.endproc

;;; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	.proc scroll_one_line

	LETTER_HEIGHT = 6

	LDA interline
	CMP #0
	BEQ not_interline

insert_interline:
	INC y_pos
	DEC interline
	RTS

not_interline:
	LDA #TEXT_X_MARGIN
	STA x_pos
	JSR draw_text_line

	;;  Save Y from here on !

	LDA specific_line
	CMP #LETTER_HEIGHT-1
	BEQ last_line_drawn

	INC y_pos
	INC specific_line
	RTS

last_line_drawn:
	LDA #0
	STA specific_line

	LDA #SCROLL_BOTTOM_LINE
	STA y_pos

	;;  Y is on last processed character, save it !
	JSR next_text_line

	LDA #1
	STA interline

	RTS
interline:	.byte 0
	.endproc

;;; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	.proc next_text_line

	LDA (text_pointer),Y
	CMP #255
	BNE not_end_of_text

	;;  Loop the text
	LDA #TEXT_X_MARGIN
	STA x_pos
	store_16 text_pointer, the_message
	RTS

not_end_of_text:
	INY 			; skip marker
	TYA
	add_a_to_16 text_pointer

	LDA #TEXT_X_MARGIN
	STA x_pos

	RTS
	.endproc

;;; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


	.proc draw_text_line
	;; Returns Y as pointer to end of the string

	LDY #0
	STY message_ndx

show_message_loop0:
	LDY message_ndx
	LDA (text_pointer),Y

	CMP #255		; text end marker
	BEQ end_of_line

	CMP #254
	BEQ end_of_line		; text line end marker

	CMP #253
	BNE not_a_space

	LDA x_pos
	CLC
	ADC #3
	STA x_pos
	JMP continue_loop0

not_a_space:
	TAX
	JSR draw_letter_line


continue_loop0:
	INC message_ndx
	JMP show_message_loop0

end_text:
end_of_line:
	RTS

	.endproc

;;; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; 	.proc draw_text_pane

;; 	LDA #TEXT_X_MARGIN
;; 	STA x_pos
;; 	LDY #10
;; 	STY y_pos

;; 	LDX #0
;; 	STX message_ndx
;; show_message_loop:
;; 	LDX message_ndx
;; 	LDA the_message,X

;; 	CMP #255
;; 	BEQ end_text

;; 	CMP #254
;; 	BNE not_end_string

;; 	LDA #TEXT_X_MARGIN
;; 	STA x_pos
;; 	LDA y_pos
;; 	CLC
;; 	ADC #7
;; 	STA y_pos
;; 	JMP continue_loop

;; not_end_string:
;; 	cmp #253
;; 	BNE not_a_space

;; 	LDA x_pos
;; 	CLC
;; 	ADC #3
;; 	STA x_pos
;; 	JMP continue_loop

;; not_a_space:
;; 	TAX
;; 	jsr draw_letter

;; continue_loop:
;; 	LDX message_ndx
;; 	INX
;; 	STX message_ndx
;; 	JMP show_message_loop

;; end_text:
;; 	RTS

;; 	.endproc




;;; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	.proc draw_letter_line

	;; X = letter to draw
	;; x_pos, y_pos : where to draw
	;; page : page to draw to

	;;  Locate the letter

	STX letter_id

	LDA #0
	STA letter_line

	;; Select appropraitely "ROL-led" letter data

	LDX x_pos
	LDA div3,X		; pay attention! no exactly // 3 !
	STA x_pos_byte

	LDA modulo3,X
	ASL			; times 4 (letter_tables entries are
	ASL			; 2x2 bytes long)
	TAX

	;; indirect pointer to "lo" table
	LDA letter_tables,X
	STA dummy_ptr3
	INX
	LDA letter_tables,X
	STA dummy_ptr3 +1
	INX

	LDY letter_id
	LDA (dummy_ptr3),Y	; lo_table[ Y]
	STA dummy_ptr


	;; indirect pointer to "hi" table
	LDA letter_tables,X
	STA dummy_ptr3
	INX
	LDA letter_tables,X
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
	LDX specific_line
skip_lines:
	CPX #0
	BEQ lines_skipped
	CLC
	ADC hcount_base
	DEX
	JMP skip_lines
lines_skipped:
	STA letter_pos


	;; Pointer to HGR line
	LDX y_pos
hdl0:
	LDA hgr2_offsets_lo,X
	STA dummy_ptr2
	LDA hgr2_offsets_hi,X
	EOR hgr_page_select
	STA dummy_ptr2 + 1


	;; This is very special. It's to account for Apple
	;; weird HGR byte structure

	LDA x_pos_byte
	AND #1
	BNE letter_line_loop_rolled

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
	LDY #1			; read pixel width of letter
	LDA (dummy_ptr),Y
	CLC
	ADC x_pos
	STA x_pos

	RTS

letter_line_loop_rolled:

	;; ;; Pointer to HGR line
	;; LDX y_pos
	;; LDA hgr2_offsets_lo,X
	;; STA dummy_ptr2
	;; LDA hgr2_offsets_hi,X
	;; STA dummy_ptr2 + 1

	LDX hcount_base
	CLC
horizontal_loop_rolled:
	LDY letter_pos
	LDA (dummy_ptr),Y	; letter data
	ROL
	AND #$7F

	LDY x_pos_byte
	ORA (dummy_ptr2),Y
	STA (dummy_ptr2),Y	; update screen

	;; Bring the carry in place for next iteration
	LDY letter_pos
	LDA (dummy_ptr),Y	; letter data
	ROL
	ROL

	INC x_pos_byte
	INC letter_pos
	DEX
	BNE horizontal_loop_rolled

	JMP finish_loop


hcount:	.byte 0
hcount_base:	.byte 0
letter_line:	.byte 0
x_rol:	.byte 0
x_pos_byte:	.byte 0
letter_id:	.byte 0

	.endproc

specific_line:	.byte 0

letter_tables:
	.word f1_letter_ptrs_rol0_lo
	.word f1_letter_ptrs_rol0_hi
	.word f1_letter_ptrs_rol1_lo
	.word f1_letter_ptrs_rol1_hi
	.word f1_letter_ptrs_rol2_lo
	.word f1_letter_ptrs_rol2_hi
	.word f1_letter_ptrs_rol3_lo
	.word f1_letter_ptrs_rol3_hi

;;; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;





vscroll_move:
	.include "vscroll1.s"
vscroll_move_p2:
	.include "vscroll2.s"

	.align $100
picture_data:
	.include "alphabet.s"
	.include "hgr_ofs.s"

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
message_ndx:	.byte 0
scroll_count: .byte 0


read_any_sector:
	inc irq_count
	NOP
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

	;; .align $100
	;; PT3_LOC = *
	;; .incbin "data/FR.PT3"
	;; .repeat 255
	;; .byte 0
	;; .endrepeat

	.include "block_draw.s"
	.include "toc_equs.inc"

draw_iceberg:
	LDA #20
	STA ypos_start		; the block will be drawn from ypos_start
	LDA #170
	STA ypos_end		; to ypos_end
	LDA #0			; it will start on X (measured in bytes)
	STA xpos

	LDA #18			; the width of the block, in bytes - 1
	STA row_width

	;; dummy_ptr = src of data

	LDA #>FILE_ICEBERG_LOAD_ADDR
	STA dummy_ptr + 1
	LDA #<FILE_ICEBERG_LOAD_ADDR
	STA dummy_ptr

	JMP block_draw_entry_point
	RTS


	;; ------------------------------------------------------------

	.proc clear_hgr2
	;; A = color to clear with
	;; X = page : $20 or $40

	sta smc + 1
	STX dummy_ptr + 1
	LDX #0
	STX dummy_ptr

	ldx #$20

	;; HGR memory is $4000 bytes => $40 x 256

clear_hgr_loop:

smc:
	LDA #$00

	LDY #0
clear_block:
	STA (dummy_ptr), Y
	DEY
	BNE clear_block

	INC dummy_ptr + 1
	DEX
	BNE clear_hgr_loop

	RTS
	.endproc
