start_y:	.byte 0
start_x:	.byte 0

	;; FIXME : left/right bitmask clipping routine
	;; is anti-optimized :-) Needs a lot of reworking
	;; to be performant.

.macro hline_7pixels_masked mask_byte, debug
	.scope

	;; X = offset on HGR line
	;; Y = Y position
	;; tile_ptr is set to the proper tile

	STX start_x
	STY start_y

	LDA mask_byte
	EOR #$FF
	STA mask_byte

	;; In fact it's min( slope+1, # of active bits in mask)
	LDX slope+1

tile_loop:
	;;  dummy_ptr := hgr2_offset[ old_y]

	LDY start_y
	LDA (hgr_offsets_lo),Y
	STA dummy_ptr
	LDA (hgr_offsets_hi),Y
	STA dummy_ptr + 1


	TXA
	TAY
	LDA (tile_ptr),Y	; A := tile[ y_count]

	LDY start_x
	ORA mask_byte		; A := tile[ y_count] & mask
	AND (dummy_ptr),Y	; A := (tile[ y_count] & mask) | hgr[fx]

	.ifnblank debug
	;LDA #$0
	LDA mask_byte
	.endif

	STA (dummy_ptr),Y

	INC start_y
	DEX
	BPL tile_loop

	LDX start_x
	.endscope
.endmacro


;;; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

.macro draw_hline2 direction, clearing
	.scope

	.if ::direction = ::TOP_DOWN
	.else
	;; Make the slope positive
	LDA slope + 1
	AND #$7F
	STA slope + 1
	.endif
	;; .ifblank clearing
	;; rts
	;; .endif

	;; We always draw from left to right

	;; fy + 1

	LDA length
	AND #$3
	ASL
	TAY
	LDA hline_masks_left, Y
	STA mask

	LDA length
	LSR
	LSR
	STA length


	lda length
	cmp #1
	bpl draw		; greater or equal
	rts
draw:
	.if ::direction = ::TOP_DOWN
	;; store_16 self_mod + 1, HTILE_0
	store_16 tile_ptr2a, HTILE_0
	store_16 tile_ptr2b, HTILE_0
	;; here !!!!
	.else
	;; store_16 self_mod + 1, HTILE_UP
	store_16 tile_ptr2a, HTILE_UP
	store_16 tile_ptr2b, HTILE_UP
	.endif

	;; Choose the tile

	LDA slope+1		; msb
	ASL			; Each tile is padded to 8 bytes
	ASL
	ASL

	TAX
	add_a_to_16 tile_ptr2a
	TXA

	clc
	adc #8			; Bytes per tile
	add_a_to_16 tile_ptr2b

	ldy fx+1
	lda div7,Y
	sta fx+1

	LDY tile_ptr2a
	STY tile_ptr
	LDY tile_ptr2a + 1
	STY tile_ptr + 1

	LDX fx+1		; From now on X must be preserved

	.ifblank clearing
	JSR clip_left
	DEC length
	BEQ clip_right
	.endif

	;; 70 cycles for tile set up
	;; 18 cycles / line
	;; 70+18=88 to 70+7*18=196 for 7 pixels => 13 to 28 cycle/pixel
	;; Optimization : user JSR (or BRK) instead of RTS (or RTI)
	;; and RTS instead of JSR to avoid computing call addresses.

loop:

	.if ::direction = ::TOP_DOWN
	LDY fy+1		; SAve for later
	LDA fy
	CLC
	ADC slope
	STA fy
	BCS loop2		; Too much error accumulated
	TYA
	ADC slope+1
	STA fy+1
	.else
	SEC
	;; bottom up drawing
	;; So this "fy" is the lower part of the tile
	LDA fy
	SBC slope
	STA fy
	BCC loop2		; SBC works with an inverse carry
	LDA fy+1
	SBC slope+1
	STA fy+1
	TAY			; save old fy for later

	.endif


	;; Y = old fy
	.ifblank clearing
	LDA (notb_line_code_ptr_lo), Y
	STA jsr_self_mod + 1
	LDA (notb_line_code_ptr_hi), Y
	STA jsr_self_mod +1 + 1
	.else
	LDA (blank_line_code_ptr_lo), Y
	STA jsr_self_mod + 1
	LDA (blank_line_code_ptr_hi), Y
	STA jsr_self_mod +1 + 1
	LDA #BACKGROUND_COLOR
	.endif

	LDY slope+1
	CLV
jsr_self_mod:
	JSR line0

loop_continue:
	INX			; Advance X position by 7 pixels (1 byte)
	DEC length 		; length := length - 1
	BNE loop
	;; LDA length
	;; CMP #2
	;; BPL loop

	.ifblank clearing
	JMP clip_right
	.endif
	RTS

loop2:
	.if ::direction = ::TOP_DOWN
	LDA fy+1
	ADC slope+1
	STA fy+1
	.else
	LDA fy+1
	SBC slope+1
	STA fy+1
	TAY 			; save old fy for later
	.endif

	;; Y = old fy
	.ifblank clearing
	LDA (notb_line_code_ptr_lo), Y
	STA jsr_self_mod2 + 1
	LDA (notb_line_code_ptr_hi), Y
	STA jsr_self_mod2 +1 + 1
	.else
	LDA (blank_line_code_ptr_lo), Y
	STA jsr_self_mod2 + 1
	LDA (blank_line_code_ptr_hi), Y
	STA jsr_self_mod2 +1 + 1
	LDA #BACKGROUND_COLOR
	.endif

	LDY tile_ptr2b
	STY tile_ptr
	LDY tile_ptr2b + 1
	STY tile_ptr + 1

	LDY slope+1
	INY
	CLV
jsr_self_mod2:
	JSR line0

	LDY tile_ptr2a
	STY tile_ptr
	LDY tile_ptr2a + 1
	STY tile_ptr + 1
	BVC loop_continue	; unconditional jump

	;;  ----------------------------------------------------------

clip_right:
	.if ::direction = ::TOP_DOWN
	LDY fy+1		; SAve for later
	LDA fy
	CLC
	ADC slope
	STA fy
	BCS loop2_clip_right		; Too much error accumulated
	TYA
	ADC slope+1
	STA fy+1
	.else
	SEC
	;; bottom up drawing
	;; So this "fy" is the lower part of the tile
	LDA fy
	SBC slope
	STA fy
	BCC loop2_clip_right		; SBC works with an inverse carry
	LDA fy+1
	SBC slope+1
	STA fy+1
	TAY			; save old fy for later

	.endif

	JSR draw_masked_tile_right
	rts


loop2_clip_right:
	.if ::direction = ::TOP_DOWN
	LDA fy+1
	ADC slope+1
	STA fy+1
	.else
	LDA fy+1
	SBC slope+1
	STA fy+1
	TAY 			; save old fy for later
	.endif

	JSR draw_masked_tile_right
	rts

	;; -----------------------------------------------------------

clip_left:
	.if ::direction = ::TOP_DOWN
	LDY fy+1		; SAve for later
	LDA fy
	CLC
	ADC slope
	STA fy
	BCS loop2_clip		; Too much error accumulated
	TYA
	ADC slope+1
	STA fy+1
	.else
	SEC
	;; bottom up drawing
	;; So this "fy" is the lower part of the tile
	LDA fy
	SBC slope
	STA fy
	BCC loop2_clip		; SBC works with an inverse carry
	LDA fy+1
	SBC slope+1
	STA fy+1
	TAY			; save old fy for later

	.endif

	JSR draw_masked_tile_left
	INX
	DEC length 		; length := length - 1
	rts


loop2_clip:
	.if ::direction = ::TOP_DOWN
	LDA fy+1
	ADC slope+1
	STA fy+1
	.else
	LDA fy+1
	SBC slope+1
	STA fy+1
	TAY 			; save old fy for later
	.endif

	JSR draw_masked_tile_left

	INX
	DEC length 		; length := length - 1
	rts

	.endscope
	.endmacro

draw_masked_tile_left:
	hline_7pixels_masked mask
	RTS
draw_masked_tile_right:
	hline_7pixels_masked mask_right
	RTS
