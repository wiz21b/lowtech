block_draw:
	;; dummy_ptr = data source
loop_row:
	;; A = Y of current line
	TAX

	;; offset: dummy_ptr2 :=
	;;     hgr_offset[X] + block_page_select + h_pos
	CLC

	LDA hgr2_offsets_lo,X
xpos = * + 1
	ADC #0
	STA dummy_ptr2
	LDA hgr2_offsets_hi,X
block_page_select = * + 1
	ADC #0
	STA dummy_ptr2+1

row_width = * + 1
	LDY #0
	DEY			; fix the number for the loop

byte_loop:
	LDA (dummy_ptr),Y
	;LDA #$55
	STA (dummy_ptr2),Y
	DEY
	BPL byte_loop

	;; Advance the source pointer
	CLC
	LDA dummy_ptr
	ADC row_width
	STA dummy_ptr
	LDA dummy_ptr+1
	ADC #0
	STA dummy_ptr+1

	INC ypos_start

block_draw_entry_point:
	ypos_start = * + 1
	LDA #0

	ypos_end = * + 1
	CMP #0
	BNE loop_row

	RTS
