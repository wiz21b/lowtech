.macro hline_7pixels_masked
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
	;;  dummy_ptr := hgr2_offset[ y_current]

	LDY y_current 		; old_fy
	LDA (hgr_offsets_lo),Y
	STA dummy_ptr
	LDA (hgr_offsets_hi),Y
	STA dummy_ptr + 1

.ifblank clearing
	;; A := tile[ y_count]
	LDY y_count
	LDA (dummy_ptr2),Y

	AND mask

	LDY fx+1
	ORA (dummy_ptr),Y
	;; LDA #$FF
.else
	LDY fx+1
	LDA #$00
.endif

	STA (dummy_ptr),Y

	INC y_current
	DEC y_count
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

	;; old_fy := int(fy)
	lda fy + 1
	sta self_mod_delta + 1

	;; the slope gives how many pixels we go down every 7 horizontal
	;; pixels
	;; fy := fy + slope
	add16 fy, slope

	;; y_count = int(fy) - old_fy == how many pixel we will go
	;; down while drawing horizontal pixels.

	.if ::direction = ::LEFT_TO_RIGHT
	LDA fy + 1
	SEC
self_mod_delta:
	SBC #00			; self-mod
	STA y_count
	.else
self_mod_delta:
	LDA #0			;self-mod
	SEC
	SBC fy + 1
	STA y_count
	.endif

	;;  Figure out the tile we'll draw

.ifblank clearing
	.if ::direction = ::LEFT_TO_RIGHT
	;; store_16 self_mod + 1, HTILE_0
	store_16 tile_ptr, HTILE_0
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
.endif

	.endscope
.endmacro


;; ------------------------------------------------------------


.macro draw_hline direction, clearing
	.scope


	ldy fx + 1
	lda modulo7,Y		; a mask actually
	beq no_special_left
no_special_left:



loop:
	hline_7pixels_setup direction, clearing

	;; Choose the code segment to run to draw the line

	.ifblank clearing
	LDY fy + 1
	LDA (line_code_ptr_lo), Y
	STA jsr_self_mod + 1
	LDA (line_code_ptr_hi), Y
	STA jsr_self_mod +1 + 1
	.else
	LDY fy + 1
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


	inc fx+1
	dec length 		; length := length - 1
	BNE loop

	rts


	.endscope
.endmacro
