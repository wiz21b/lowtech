;; This code is (c) 2019 Stéphane Champailler
;;; It is published under the terms of the
;;; GNU GPL License Version 3.

;;; Part of this code (see below) is copied from the PT3 player by Vince "Deater" Weaver and is licensed accordingly


	.include "defs.s"

DEBUG = 0
ONE_PAGE = 0

	text_pointer	= 240
	dummy_pointer	= 242
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



	;; lda #0
	;; jsr clear_hgr

	.if DEBUG
	LDA $C053
	.else
	LDA $C052	     ; mix text and gfx (c052 = full text/gfx)
	.endif

	LDA $C054		; Page 1
	;; LDA $C055		;Page 2
	LDA $C057
	LDA $C050 ; display graphics; last for cleaner mode change (according to Apple doc)

	.ifdef MUSIC
	JSR start_player
	.endif



	LDA #>$2000
	LDX #>$4000
	LDY #$20
	jsr mem_copy


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

last_pause:
	;; jmp last_pause



	LDX #20
scroll_column_1line:
	JSR vscroll_move_p0_1line
	INX
	CPX #39
	BNE scroll_column_1line

	jsr vscroll2
;; 	LDX #39
;; scroll_column2b:
;; 	JSR vscroll_move_p2
;; 	DEX
;; 	BPL scroll_column2b

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

	LDA letter_ptrs_rol0_lo,X
	STA dummy_ptr
	LDA letter_ptrs_rol0_hi,X
	STA dummy_ptr + 1

	LDY #0
	LDA (dummy_ptr),Y	; letter width (in bytes)
	STA hcount_base



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
	.word letter_ptrs_rol0_lo
	.word letter_ptrs_rol0_hi
	.word letter_ptrs_rol1_lo
	.word letter_ptrs_rol1_hi
	.word letter_ptrs_rol2_lo
	.word letter_ptrs_rol2_hi
	.word letter_ptrs_rol3_lo
	.word letter_ptrs_rol3_hi



	.include "lib.s"

vscroll_move:
	.include "data/vscroll.s"
vscroll_move_p2:
	.include "data/vscroll2.s"
vscroll_move_p0_1line:
	.include "data/vscroll3.s"



	.align $100
picture_data:
	;.incbin "data/TITLEPIC.BIN"

	.include "data/alphabet.s"


hgr2_offsets_lo:
	.byte <$2000	; 0
	.byte <$2400	; 1
	.byte <$2800	; 2
	.byte <$2C00	; 3
	.byte <$3000	; 4
	.byte <$3400	; 5
	.byte <$3800	; 6
	.byte <$3C00	; 7
	.byte <$2080	; 8
	.byte <$2480	; 9
	.byte <$2880	; 10
	.byte <$2C80	; 11
	.byte <$3080	; 12
	.byte <$3480	; 13
	.byte <$3880	; 14
	.byte <$3C80	; 15
	.byte <$2100	; 16
	.byte <$2500	; 17
	.byte <$2900	; 18
	.byte <$2D00	; 19
	.byte <$3100	; 20
	.byte <$3500	; 21
	.byte <$3900	; 22
	.byte <$3D00	; 23
	.byte <$2180	; 24
	.byte <$2580	; 25
	.byte <$2980	; 26
	.byte <$2D80	; 27
	.byte <$3180	; 28
	.byte <$3580	; 29
	.byte <$3980	; 30
	.byte <$3D80	; 31
	.byte <$2200	; 32
	.byte <$2600	; 33
	.byte <$2A00	; 34
	.byte <$2E00	; 35
	.byte <$3200	; 36
	.byte <$3600	; 37
	.byte <$3A00	; 38
	.byte <$3E00	; 39
	.byte <$2280	; 40
	.byte <$2680	; 41
	.byte <$2A80	; 42
	.byte <$2E80	; 43
	.byte <$3280	; 44
	.byte <$3680	; 45
	.byte <$3A80	; 46
	.byte <$3E80	; 47
	.byte <$2300	; 48
	.byte <$2700	; 49
	.byte <$2B00	; 50
	.byte <$2F00	; 51
	.byte <$3300	; 52
	.byte <$3700	; 53
	.byte <$3B00	; 54
	.byte <$3F00	; 55
	.byte <$2380	; 56
	.byte <$2780	; 57
	.byte <$2B80	; 58
	.byte <$2F80	; 59
	.byte <$3380	; 60
	.byte <$3780	; 61
	.byte <$3B80	; 62
	.byte <$3F80	; 63
	.byte <$2028	; 64
	.byte <$2428	; 65
	.byte <$2828	; 66
	.byte <$2C28	; 67
	.byte <$3028	; 68
	.byte <$3428	; 69
	.byte <$3828	; 70
	.byte <$3C28	; 71
	.byte <$20A8	; 72
	.byte <$24A8	; 73
	.byte <$28A8	; 74
	.byte <$2CA8	; 75
	.byte <$30A8	; 76
	.byte <$34A8	; 77
	.byte <$38A8	; 78
	.byte <$3CA8	; 79
	.byte <$2128	; 80
	.byte <$2528	; 81
	.byte <$2928	; 82
	.byte <$2D28	; 83
	.byte <$3128	; 84
	.byte <$3528	; 85
	.byte <$3928	; 86
	.byte <$3D28	; 87
	.byte <$21A8	; 88
	.byte <$25A8	; 89
	.byte <$29A8	; 90
	.byte <$2DA8	; 91
	.byte <$31A8	; 92
	.byte <$35A8	; 93
	.byte <$39A8	; 94
	.byte <$3DA8	; 95
	.byte <$2228	; 96
	.byte <$2628	; 97
	.byte <$2A28	; 98
	.byte <$2E28	; 99
	.byte <$3228	; 100
	.byte <$3628	; 101
	.byte <$3A28	; 102
	.byte <$3E28	; 103
	.byte <$22A8	; 104
	.byte <$26A8	; 105
	.byte <$2AA8	; 106
	.byte <$2EA8	; 107
	.byte <$32A8	; 108
	.byte <$36A8	; 109
	.byte <$3AA8	; 110
	.byte <$3EA8	; 111
	.byte <$2328	; 112
	.byte <$2728	; 113
	.byte <$2B28	; 114
	.byte <$2F28	; 115
	.byte <$3328	; 116
	.byte <$3728	; 117
	.byte <$3B28	; 118
	.byte <$3F28	; 119
	.byte <$23A8	; 120
	.byte <$27A8	; 121
	.byte <$2BA8	; 122
	.byte <$2FA8	; 123
	.byte <$33A8	; 124
	.byte <$37A8	; 125
	.byte <$3BA8	; 126
	.byte <$3FA8	; 127
	.byte <$2050	; 128
	.byte <$2450	; 129
	.byte <$2850	; 130
	.byte <$2C50	; 131
	.byte <$3050	; 132
	.byte <$3450	; 133
	.byte <$3850	; 134
	.byte <$3C50	; 135
	.byte <$20D0	; 136
	.byte <$24D0	; 137
	.byte <$28D0	; 138
	.byte <$2CD0	; 139
	.byte <$30D0	; 140
	.byte <$34D0	; 141
	.byte <$38D0	; 142
	.byte <$3CD0	; 143
	.byte <$2150	; 144
	.byte <$2550	; 145
	.byte <$2950	; 146
	.byte <$2D50	; 147
	.byte <$3150	; 148
	.byte <$3550	; 149
	.byte <$3950	; 150
	.byte <$3D50	; 151
	.byte <$21D0	; 152
	.byte <$25D0	; 153
	.byte <$29D0	; 154
	.byte <$2DD0	; 155
	.byte <$31D0	; 156
	.byte <$35D0	; 157
	.byte <$39D0	; 158
	.byte <$3DD0	; 159
	.byte <$2250	; 160
	.byte <$2650	; 161
	.byte <$2A50	; 162
	.byte <$2E50	; 163
	.byte <$3250	; 164
	.byte <$3650	; 165
	.byte <$3A50	; 166
	.byte <$3E50	; 167
	.byte <$22D0	; 168
	.byte <$26D0	; 169
	.byte <$2AD0	; 170
	.byte <$2ED0	; 171
	.byte <$32D0	; 172
	.byte <$36D0	; 173
	.byte <$3AD0	; 174
	.byte <$3ED0	; 175
	.byte <$2350	; 176
	.byte <$2750	; 177
	.byte <$2B50	; 178
	.byte <$2F50	; 179
	.byte <$3350	; 180
	.byte <$3750	; 181
	.byte <$3B50	; 182
	.byte <$3F50	; 183
	.byte <$23D0	; 184
	.byte <$27D0	; 185
	.byte <$2BD0	; 186
	.byte <$2FD0	; 187
	.byte <$33D0	; 188
	.byte <$37D0	; 189
	.byte <$3BD0	; 190
	.byte <$3FD0	; 191
hgr2_offsets_hi:
	.byte >$2000	; 0
	.byte >$2400	; 1
	.byte >$2800	; 2
	.byte >$2C00	; 3
	.byte >$3000	; 4
	.byte >$3400	; 5
	.byte >$3800	; 6
	.byte >$3C00	; 7
	.byte >$2080	; 8
	.byte >$2480	; 9
	.byte >$2880	; 10
	.byte >$2C80	; 11
	.byte >$3080	; 12
	.byte >$3480	; 13
	.byte >$3880	; 14
	.byte >$3C80	; 15
	.byte >$2100	; 16
	.byte >$2500	; 17
	.byte >$2900	; 18
	.byte >$2D00	; 19
	.byte >$3100	; 20
	.byte >$3500	; 21
	.byte >$3900	; 22
	.byte >$3D00	; 23
	.byte >$2180	; 24
	.byte >$2580	; 25
	.byte >$2980	; 26
	.byte >$2D80	; 27
	.byte >$3180	; 28
	.byte >$3580	; 29
	.byte >$3980	; 30
	.byte >$3D80	; 31
	.byte >$2200	; 32
	.byte >$2600	; 33
	.byte >$2A00	; 34
	.byte >$2E00	; 35
	.byte >$3200	; 36
	.byte >$3600	; 37
	.byte >$3A00	; 38
	.byte >$3E00	; 39
	.byte >$2280	; 40
	.byte >$2680	; 41
	.byte >$2A80	; 42
	.byte >$2E80	; 43
	.byte >$3280	; 44
	.byte >$3680	; 45
	.byte >$3A80	; 46
	.byte >$3E80	; 47
	.byte >$2300	; 48
	.byte >$2700	; 49
	.byte >$2B00	; 50
	.byte >$2F00	; 51
	.byte >$3300	; 52
	.byte >$3700	; 53
	.byte >$3B00	; 54
	.byte >$3F00	; 55
	.byte >$2380	; 56
	.byte >$2780	; 57
	.byte >$2B80	; 58
	.byte >$2F80	; 59
	.byte >$3380	; 60
	.byte >$3780	; 61
	.byte >$3B80	; 62
	.byte >$3F80	; 63
	.byte >$2028	; 64
	.byte >$2428	; 65
	.byte >$2828	; 66
	.byte >$2C28	; 67
	.byte >$3028	; 68
	.byte >$3428	; 69
	.byte >$3828	; 70
	.byte >$3C28	; 71
	.byte >$20A8	; 72
	.byte >$24A8	; 73
	.byte >$28A8	; 74
	.byte >$2CA8	; 75
	.byte >$30A8	; 76
	.byte >$34A8	; 77
	.byte >$38A8	; 78
	.byte >$3CA8	; 79
	.byte >$2128	; 80
	.byte >$2528	; 81
	.byte >$2928	; 82
	.byte >$2D28	; 83
	.byte >$3128	; 84
	.byte >$3528	; 85
	.byte >$3928	; 86
	.byte >$3D28	; 87
	.byte >$21A8	; 88
	.byte >$25A8	; 89
	.byte >$29A8	; 90
	.byte >$2DA8	; 91
	.byte >$31A8	; 92
	.byte >$35A8	; 93
	.byte >$39A8	; 94
	.byte >$3DA8	; 95
	.byte >$2228	; 96
	.byte >$2628	; 97
	.byte >$2A28	; 98
	.byte >$2E28	; 99
	.byte >$3228	; 100
	.byte >$3628	; 101
	.byte >$3A28	; 102
	.byte >$3E28	; 103
	.byte >$22A8	; 104
	.byte >$26A8	; 105
	.byte >$2AA8	; 106
	.byte >$2EA8	; 107
	.byte >$32A8	; 108
	.byte >$36A8	; 109
	.byte >$3AA8	; 110
	.byte >$3EA8	; 111
	.byte >$2328	; 112
	.byte >$2728	; 113
	.byte >$2B28	; 114
	.byte >$2F28	; 115
	.byte >$3328	; 116
	.byte >$3728	; 117
	.byte >$3B28	; 118
	.byte >$3F28	; 119
	.byte >$23A8	; 120
	.byte >$27A8	; 121
	.byte >$2BA8	; 122
	.byte >$2FA8	; 123
	.byte >$33A8	; 124
	.byte >$37A8	; 125
	.byte >$3BA8	; 126
	.byte >$3FA8	; 127
	.byte >$2050	; 128
	.byte >$2450	; 129
	.byte >$2850	; 130
	.byte >$2C50	; 131
	.byte >$3050	; 132
	.byte >$3450	; 133
	.byte >$3850	; 134
	.byte >$3C50	; 135
	.byte >$20D0	; 136
	.byte >$24D0	; 137
	.byte >$28D0	; 138
	.byte >$2CD0	; 139
	.byte >$30D0	; 140
	.byte >$34D0	; 141
	.byte >$38D0	; 142
	.byte >$3CD0	; 143
	.byte >$2150	; 144
	.byte >$2550	; 145
	.byte >$2950	; 146
	.byte >$2D50	; 147
	.byte >$3150	; 148
	.byte >$3550	; 149
	.byte >$3950	; 150
	.byte >$3D50	; 151
	.byte >$21D0	; 152
	.byte >$25D0	; 153
	.byte >$29D0	; 154
	.byte >$2DD0	; 155
	.byte >$31D0	; 156
	.byte >$35D0	; 157
	.byte >$39D0	; 158
	.byte >$3DD0	; 159
	.byte >$2250	; 160
	.byte >$2650	; 161
	.byte >$2A50	; 162
	.byte >$2E50	; 163
	.byte >$3250	; 164
	.byte >$3650	; 165
	.byte >$3A50	; 166
	.byte >$3E50	; 167
	.byte >$22D0	; 168
	.byte >$26D0	; 169
	.byte >$2AD0	; 170
	.byte >$2ED0	; 171
	.byte >$32D0	; 172
	.byte >$36D0	; 173
	.byte >$3AD0	; 174
	.byte >$3ED0	; 175
	.byte >$2350	; 176
	.byte >$2750	; 177
	.byte >$2B50	; 178
	.byte >$2F50	; 179
	.byte >$3350	; 180
	.byte >$3750	; 181
	.byte >$3B50	; 182
	.byte >$3F50	; 183
	.byte >$23D0	; 184
	.byte >$27D0	; 185
	.byte >$2BD0	; 186
	.byte >$2FD0	; 187
	.byte >$33D0	; 188
	.byte >$37D0	; 189
	.byte >$3BD0	; 190
	.byte >$3FD0	; 191

hgr4_offsets_lo:
	.byte <$4000	; 0
	.byte <$4400	; 1
	.byte <$4800	; 2
	.byte <$4C00	; 3
	.byte <$5000	; 4
	.byte <$5400	; 5
	.byte <$5800	; 6
	.byte <$5C00	; 7
	.byte <$4080	; 8
	.byte <$4480	; 9
	.byte <$4880	; 10
	.byte <$4C80	; 11
	.byte <$5080	; 12
	.byte <$5480	; 13
	.byte <$5880	; 14
	.byte <$5C80	; 15
	.byte <$4100	; 16
	.byte <$4500	; 17
	.byte <$4900	; 18
	.byte <$4D00	; 19
	.byte <$5100	; 20
	.byte <$5500	; 21
	.byte <$5900	; 22
	.byte <$5D00	; 23
	.byte <$4180	; 24
	.byte <$4580	; 25
	.byte <$4980	; 26
	.byte <$4D80	; 27
	.byte <$5180	; 28
	.byte <$5580	; 29
	.byte <$5980	; 30
	.byte <$5D80	; 31
	.byte <$4200	; 32
	.byte <$4600	; 33
	.byte <$4A00	; 34
	.byte <$4E00	; 35
	.byte <$5200	; 36
	.byte <$5600	; 37
	.byte <$5A00	; 38
	.byte <$5E00	; 39
	.byte <$4280	; 40
	.byte <$4680	; 41
	.byte <$4A80	; 42
	.byte <$4E80	; 43
	.byte <$5280	; 44
	.byte <$5680	; 45
	.byte <$5A80	; 46
	.byte <$5E80	; 47
	.byte <$4300	; 48
	.byte <$4700	; 49
	.byte <$4B00	; 50
	.byte <$4F00	; 51
	.byte <$5300	; 52
	.byte <$5700	; 53
	.byte <$5B00	; 54
	.byte <$5F00	; 55
	.byte <$4380	; 56
	.byte <$4780	; 57
	.byte <$4B80	; 58
	.byte <$4F80	; 59
	.byte <$5380	; 60
	.byte <$5780	; 61
	.byte <$5B80	; 62
	.byte <$5F80	; 63
	.byte <$4028	; 64
	.byte <$4428	; 65
	.byte <$4828	; 66
	.byte <$4C28	; 67
	.byte <$5028	; 68
	.byte <$5428	; 69
	.byte <$5828	; 70
	.byte <$5C28	; 71
	.byte <$40A8	; 72
	.byte <$44A8	; 73
	.byte <$48A8	; 74
	.byte <$4CA8	; 75
	.byte <$50A8	; 76
	.byte <$54A8	; 77
	.byte <$58A8	; 78
	.byte <$5CA8	; 79
	.byte <$4128	; 80
	.byte <$4528	; 81
	.byte <$4928	; 82
	.byte <$4D28	; 83
	.byte <$5128	; 84
	.byte <$5528	; 85
	.byte <$5928	; 86
	.byte <$5D28	; 87
	.byte <$41A8	; 88
	.byte <$45A8	; 89
	.byte <$49A8	; 90
	.byte <$4DA8	; 91
	.byte <$51A8	; 92
	.byte <$55A8	; 93
	.byte <$59A8	; 94
	.byte <$5DA8	; 95
	.byte <$4228	; 96
	.byte <$4628	; 97
	.byte <$4A28	; 98
	.byte <$4E28	; 99
	.byte <$5228	; 100
	.byte <$5628	; 101
	.byte <$5A28	; 102
	.byte <$5E28	; 103
	.byte <$42A8	; 104
	.byte <$46A8	; 105
	.byte <$4AA8	; 106
	.byte <$4EA8	; 107
	.byte <$52A8	; 108
	.byte <$56A8	; 109
	.byte <$5AA8	; 110
	.byte <$5EA8	; 111
	.byte <$4328	; 112
	.byte <$4728	; 113
	.byte <$4B28	; 114
	.byte <$4F28	; 115
	.byte <$5328	; 116
	.byte <$5728	; 117
	.byte <$5B28	; 118
	.byte <$5F28	; 119
	.byte <$43A8	; 120
	.byte <$47A8	; 121
	.byte <$4BA8	; 122
	.byte <$4FA8	; 123
	.byte <$53A8	; 124
	.byte <$57A8	; 125
	.byte <$5BA8	; 126
	.byte <$5FA8	; 127
	.byte <$4050	; 128
	.byte <$4450	; 129
	.byte <$4850	; 130
	.byte <$4C50	; 131
	.byte <$5050	; 132
	.byte <$5450	; 133
	.byte <$5850	; 134
	.byte <$5C50	; 135
	.byte <$40D0	; 136
	.byte <$44D0	; 137
	.byte <$48D0	; 138
	.byte <$4CD0	; 139
	.byte <$50D0	; 140
	.byte <$54D0	; 141
	.byte <$58D0	; 142
	.byte <$5CD0	; 143
	.byte <$4150	; 144
	.byte <$4550	; 145
	.byte <$4950	; 146
	.byte <$4D50	; 147
	.byte <$5150	; 148
	.byte <$5550	; 149
	.byte <$5950	; 150
	.byte <$5D50	; 151
	.byte <$41D0	; 152
	.byte <$45D0	; 153
	.byte <$49D0	; 154
	.byte <$4DD0	; 155
	.byte <$51D0	; 156
	.byte <$55D0	; 157
	.byte <$59D0	; 158
	.byte <$5DD0	; 159
	.byte <$4250	; 160
	.byte <$4650	; 161
	.byte <$4A50	; 162
	.byte <$4E50	; 163
	.byte <$5250	; 164
	.byte <$5650	; 165
	.byte <$5A50	; 166
	.byte <$5E50	; 167
	.byte <$42D0	; 168
	.byte <$46D0	; 169
	.byte <$4AD0	; 170
	.byte <$4ED0	; 171
	.byte <$52D0	; 172
	.byte <$56D0	; 173
	.byte <$5AD0	; 174
	.byte <$5ED0	; 175
	.byte <$4350	; 176
	.byte <$4750	; 177
	.byte <$4B50	; 178
	.byte <$4F50	; 179
	.byte <$5350	; 180
	.byte <$5750	; 181
	.byte <$5B50	; 182
	.byte <$5F50	; 183
	.byte <$43D0	; 184
	.byte <$47D0	; 185
	.byte <$4BD0	; 186
	.byte <$4FD0	; 187
	.byte <$53D0	; 188
	.byte <$57D0	; 189
	.byte <$5BD0	; 190
	.byte <$5FD0	; 191
hgr4_offsets_hi:
	.byte >$4000	; 0
	.byte >$4400	; 1
	.byte >$4800	; 2
	.byte >$4C00	; 3
	.byte >$5000	; 4
	.byte >$5400	; 5
	.byte >$5800	; 6
	.byte >$5C00	; 7
	.byte >$4080	; 8
	.byte >$4480	; 9
	.byte >$4880	; 10
	.byte >$4C80	; 11
	.byte >$5080	; 12
	.byte >$5480	; 13
	.byte >$5880	; 14
	.byte >$5C80	; 15
	.byte >$4100	; 16
	.byte >$4500	; 17
	.byte >$4900	; 18
	.byte >$4D00	; 19
	.byte >$5100	; 20
	.byte >$5500	; 21
	.byte >$5900	; 22
	.byte >$5D00	; 23
	.byte >$4180	; 24
	.byte >$4580	; 25
	.byte >$4980	; 26
	.byte >$4D80	; 27
	.byte >$5180	; 28
	.byte >$5580	; 29
	.byte >$5980	; 30
	.byte >$5D80	; 31
	.byte >$4200	; 32
	.byte >$4600	; 33
	.byte >$4A00	; 34
	.byte >$4E00	; 35
	.byte >$5200	; 36
	.byte >$5600	; 37
	.byte >$5A00	; 38
	.byte >$5E00	; 39
	.byte >$4280	; 40
	.byte >$4680	; 41
	.byte >$4A80	; 42
	.byte >$4E80	; 43
	.byte >$5280	; 44
	.byte >$5680	; 45
	.byte >$5A80	; 46
	.byte >$5E80	; 47
	.byte >$4300	; 48
	.byte >$4700	; 49
	.byte >$4B00	; 50
	.byte >$4F00	; 51
	.byte >$5300	; 52
	.byte >$5700	; 53
	.byte >$5B00	; 54
	.byte >$5F00	; 55
	.byte >$4380	; 56
	.byte >$4780	; 57
	.byte >$4B80	; 58
	.byte >$4F80	; 59
	.byte >$5380	; 60
	.byte >$5780	; 61
	.byte >$5B80	; 62
	.byte >$5F80	; 63
	.byte >$4028	; 64
	.byte >$4428	; 65
	.byte >$4828	; 66
	.byte >$4C28	; 67
	.byte >$5028	; 68
	.byte >$5428	; 69
	.byte >$5828	; 70
	.byte >$5C28	; 71
	.byte >$40A8	; 72
	.byte >$44A8	; 73
	.byte >$48A8	; 74
	.byte >$4CA8	; 75
	.byte >$50A8	; 76
	.byte >$54A8	; 77
	.byte >$58A8	; 78
	.byte >$5CA8	; 79
	.byte >$4128	; 80
	.byte >$4528	; 81
	.byte >$4928	; 82
	.byte >$4D28	; 83
	.byte >$5128	; 84
	.byte >$5528	; 85
	.byte >$5928	; 86
	.byte >$5D28	; 87
	.byte >$41A8	; 88
	.byte >$45A8	; 89
	.byte >$49A8	; 90
	.byte >$4DA8	; 91
	.byte >$51A8	; 92
	.byte >$55A8	; 93
	.byte >$59A8	; 94
	.byte >$5DA8	; 95
	.byte >$4228	; 96
	.byte >$4628	; 97
	.byte >$4A28	; 98
	.byte >$4E28	; 99
	.byte >$5228	; 100
	.byte >$5628	; 101
	.byte >$5A28	; 102
	.byte >$5E28	; 103
	.byte >$42A8	; 104
	.byte >$46A8	; 105
	.byte >$4AA8	; 106
	.byte >$4EA8	; 107
	.byte >$52A8	; 108
	.byte >$56A8	; 109
	.byte >$5AA8	; 110
	.byte >$5EA8	; 111
	.byte >$4328	; 112
	.byte >$4728	; 113
	.byte >$4B28	; 114
	.byte >$4F28	; 115
	.byte >$5328	; 116
	.byte >$5728	; 117
	.byte >$5B28	; 118
	.byte >$5F28	; 119
	.byte >$43A8	; 120
	.byte >$47A8	; 121
	.byte >$4BA8	; 122
	.byte >$4FA8	; 123
	.byte >$53A8	; 124
	.byte >$57A8	; 125
	.byte >$5BA8	; 126
	.byte >$5FA8	; 127
	.byte >$4050	; 128
	.byte >$4450	; 129
	.byte >$4850	; 130
	.byte >$4C50	; 131
	.byte >$5050	; 132
	.byte >$5450	; 133
	.byte >$5850	; 134
	.byte >$5C50	; 135
	.byte >$40D0	; 136
	.byte >$44D0	; 137
	.byte >$48D0	; 138
	.byte >$4CD0	; 139
	.byte >$50D0	; 140
	.byte >$54D0	; 141
	.byte >$58D0	; 142
	.byte >$5CD0	; 143
	.byte >$4150	; 144
	.byte >$4550	; 145
	.byte >$4950	; 146
	.byte >$4D50	; 147
	.byte >$5150	; 148
	.byte >$5550	; 149
	.byte >$5950	; 150
	.byte >$5D50	; 151
	.byte >$41D0	; 152
	.byte >$45D0	; 153
	.byte >$49D0	; 154
	.byte >$4DD0	; 155
	.byte >$51D0	; 156
	.byte >$55D0	; 157
	.byte >$59D0	; 158
	.byte >$5DD0	; 159
	.byte >$4250	; 160
	.byte >$4650	; 161
	.byte >$4A50	; 162
	.byte >$4E50	; 163
	.byte >$5250	; 164
	.byte >$5650	; 165
	.byte >$5A50	; 166
	.byte >$5E50	; 167
	.byte >$42D0	; 168
	.byte >$46D0	; 169
	.byte >$4AD0	; 170
	.byte >$4ED0	; 171
	.byte >$52D0	; 172
	.byte >$56D0	; 173
	.byte >$5AD0	; 174
	.byte >$5ED0	; 175
	.byte >$4350	; 176
	.byte >$4750	; 177
	.byte >$4B50	; 178
	.byte >$4F50	; 179
	.byte >$5350	; 180
	.byte >$5750	; 181
	.byte >$5B50	; 182
	.byte >$5F50	; 183
	.byte >$43D0	; 184
	.byte >$47D0	; 185
	.byte >$4BD0	; 186
	.byte >$4FD0	; 187
	.byte >$53D0	; 188
	.byte >$57D0	; 189
	.byte >$5BD0	; 190
	.byte >$5FD0	; 191

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
	.align $100
	PT3_LOC = *
	.incbin "data/FR.PT3"
	.repeat 255
	.byte 0
	.endrepeat
