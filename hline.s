start_y:	.byte 0

.macro hline_7pixels_masked clearing
	.scope

	;; slope is for 7 pixels jumps
	;; slope * width-in-block/7 is the slope we need
	;; (width-in-block is inside [1,6] => we can precompute the
	;; divisions values).
	;; slope is 8 bit.8 bit fixed point. We can note : h*256+l
	;; => slope * x = h*256*x + l*x (l and h are in [0,255])
	;; x is in [1,2,3,4,5,6], so if it is even :
	;; [1,3,5] and [1,2,3]*2
	;; so 2,3,5

tile_loop:
	;;  dummy_ptr := hgr2_offset[ old_y]

	;LDY fy + 1 		; old_fy
	LDY start_y
	LDA (hgr_offsets_lo),Y
	STA dummy_ptr
	LDA (hgr_offsets_hi),Y
	STA dummy_ptr + 1

.ifblank clearing
	LDY y_count
	LDA (tile_ptr),Y	; A := tile[ y_count]
	CLC
	ROR
	;AND mask		; A := tile[ y_count] & mask
	;ORA #128+64

	;LDA #$ff
	LDY fx+1
	ORA (dummy_ptr),Y	; A := (tile[ y_count] & mask) | hgr[fx]
.else
	LDY fx+1
	LDA #$00
.endif

	STA (dummy_ptr),Y

	INC start_y
	DEC y_count		; 0 included in the loop
	BPL tile_loop

	.endscope
.endmacro


;; ------------------------------------------------------------


.macro hline_7pixels_setup direction, clearing
	.scope

	;; All computations assume that we draw 7 pixels (in the
	;; horizontal direction) each time. However, the first pixels
	;; of a line can be less than that.
	;; For example, an horizontal line starting at (3,5) will
	;; first use pixels (3,5), (4,5), (5,5), (6,5), that is, 4
	;; pixels out of seven.

	;; Computes :
	;;  - y_count : number of lines to go down while drawing
	;;    the next 7 horizontal pixels
	;;  - fy as old fy + slope
	;;  - tile_ptr : the pointer to tiles data (if not clearing screen)

	;; old_fy := int(fy)
	lda fy + 1
	;; old_fy = 42 ($2A)
	sta old_fy
	sta self_mod_delta + 1

	;; the slope gives how many pixels we go down every 7 horizontal
	;; pixels
	;; fy := fy + slope
	add16 fy, slope
	;;  fy+1 : $24 (36) -- 93ac

	;; y_count = int(fy) - old_fy == how many pixels we will go
	;; down while drawing horizontal pixels.

	.if ::direction = ::LEFT_TO_RIGHT
	LDA old_fy
	STA start_y

	LDA fy + 1		; =36
	SEC
self_mod_delta:
	SBC #0			; self-mod (= old_fy)
	;;  y_count = 6
	STA y_count		; y_count := fy - old_fy

	.else

	;; Direction of decreasing Y (bottom of screen to top)

	LDA fy + 1
	STA start_y
self_mod_delta:
	LDA #0			;self-mod (= old_fy)
	SEC
	SBC fy + 1
	STA y_count		; y_count := old_fy - fy
	.endif

	;; Figure out the tile we'll draw
	;; (note we don't set up anything if we clear
	;; the drawings :-))

.ifblank clearing
	.if ::direction = ::LEFT_TO_RIGHT
	;; store_16 self_mod + 1, HTILE_0
	store_16 tile_ptr, HTILE_0
	;; here !!!!
	.else
	;; store_16 self_mod + 1, HTILE_UP
	store_16 tile_ptr, HTILE_UP
	.endif

	LDA y_count
	ASL
	ASL
	ASL
	;; add_a_to_16 self_mod + 1
	add_a_to_16 tile_ptr
	;;  HTILE_UP_6
.endif

	.endscope
.endmacro


;; ------------------------------------------------------------


.macro draw_hline direction, clearing
	.scope

	;; Disable effect of ROR/ADC strategy
	LDA #255
	STA x_shift

	;; fy + 1

	LDY fy+1
	LDA (hgr_offsets_lo),Y
	STA dummy_ptr
	LDA (hgr_offsets_hi),Y
	STA dummy_ptr + 1

	;; length byte contains a length (5 bits) and a mask index
	;; (3 bits)
	;; 5 bits = 0-31 => width from 0 to 31*7=231 pixels

	LDA length
	AND #$7
	TAY
	LDA hline_masks_left, Y
	STA mask

	LDA length
	LSR
	LSR
	LSR
	STA length

	;; ;; fx + 1 = $5A (90)
	;; LDY fx + 1
	;; LDA div7,Y
	;; ;; div7 = 12 (90/7=12.85 => 12*7 = 84)
	;; TAY
	;; LDA #%001010101
	;; STA (dummy_ptr),Y


	lda length
	cmp #1
	bpl draw		; greater or equal
	rts
draw:

	ldy fx+1
	lda div7,Y
	sta fx+1

	hline_7pixels_setup direction, clearing
	;; hline_7pixels_masked clearing
	inc fx+1
	dec length
	bne no_special_left
	rts

no_special_left:

	LDA length
	cmp #2			; length >= 2
	bpl loop
	jmp rightmost_tile
loop:
	hline_7pixels_setup direction, clearing

	;; Choose the code segment to run to draw the line

	;LDY fy + 1
	LDY start_y

	.ifblank clearing
	LDA (line_code_ptr_lo), Y
	STA jsr_self_mod + 1
	LDA (line_code_ptr_hi), Y
	STA jsr_self_mod +1 + 1

	.else
	LDA (blank_line_code_ptr_lo), Y
	STA jsr_self_mod + 1
	LDA (blank_line_code_ptr_hi), Y
	STA jsr_self_mod +1 + 1
	LDA #0
	.endif

	LDY y_count
	LDX fx+1
	CLV
	CLC
	;JMP skip_drawing

jsr_self_mod:
	jsr line0		; This address will be self modified
skip_drawing:

	inc fx+1		; we always draw from left to right
	dec length 		; length := length - 1
	;BNE loop

	LDA length
	CMP #2
	BPL loop

	CMP #0
	BEQ all_done

rightmost_tile:
	;; LDY #0
	;; LDA (line_data_ptr),Y
	;; LSR
	;; LSR
	;; LSR
	;; LSR
	;; LSR
	;; AND #$7
	;; TAY
	;; LDA hline_masks_right, Y
	;; STA mask

	;; hline_7pixels_setup direction, clearing
	;; hline_7pixels_masked clearing
all_done:
	RTS


	.endscope
.endmacro



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
	adc #8
	add_a_to_16 tile_ptr2b

	ldy fx+1
	lda div7,Y
	sta fx+1

	LDY tile_ptr2a
	STY tile_ptr
	LDY tile_ptr2a + 1
	STY tile_ptr + 1

	LDX fx+1		; From now on X must be preserved

	;; 70 cycles for tile set up
	;; 18 cycles / line
	;; 70+18=88 to 70+7*18=196 for 7 pixels => 13 to 28 cycle/pixel
	;; Optimization : user JSR (or BRK) instead of RTS (or RTI)
	;; and RTS instead of JSR to avoid computing call addresses.

loop:

	.if ::direction = ::TOP_DOWN
	CLC
	LDY fy+1		; SAve for later
	LDA fy
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
	BCC loop2
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
	LDA #$00
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
	LDA #$00
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

	.endscope
	.endmacro
