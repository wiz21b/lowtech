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
	AND mask		; A := tile[ y_count] & mask
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

	;; fy + 1 = 2A (42)

	LDY fy+1
	LDA (hgr_offsets_lo),Y
	STA dummy_ptr
	LDA (hgr_offsets_hi),Y
	STA dummy_ptr + 1

	;; length byte contains a length (5 bits) and a mask index
	;; (3 bits)

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
	hline_7pixels_masked clearing
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

jsr_self_mod:
	jsr line0		; This address will be self modified

	inc fx+1		; we always draw from left to right
	dec length 		; length := length - 1
	;BNE loop

	LDA length
	CMP #2
	BPL loop

	CMP #0
	BEQ all_done

rightmost_tile:
	LDY #0
	LDA (line_data_ptr),Y
	LSR
	LSR
	LSR
	LSR
	LSR
	AND #$7
	TAY
	LDA hline_masks_right, Y
	STA mask

	hline_7pixels_setup direction, clearing
	hline_7pixels_masked clearing
all_done:
	RTS


	.endscope
.endmacro
