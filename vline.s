	.macro advance_tile_vertically mdirection

	CLC
	LDA fx
	ADC slope
	STA fx
	LDA fx+1		; int(fx)
	sta old_fx
	tax			; Save for later
	ADC slope+1
	STA fx+1

	;; Find the tile to draw. We build a 8 bits index structured
	;; like this :
	;;  ..DDDSSS :
	;;    S = pixel to the right of the top one (assuming we're
	;;        at the top of the tile)
	;;    D = delta between old x (at top of the tile) and new x
	;;        (at bottom)
	;; => we can reach 64 different tiles.

	;;  Compute the .SSS part
	lda modulo7, X
	sta dummy_ptr		; The offset (rol factor)

	;;  Compute the .DDD part

	;; It's tricky ! When we compare old_fx and fx,
	;; remember that old_fx is on the first line of the tile
	;; but fx is on the first line of the tile below. For
	;; this computation to be exact, fx should be computed
	;; on the last line of the *same* tile as old_fx !
	;; To compensate for that, we modify the modulo7_times8
	;; table !

	.if mdirection = ::RIGHT_TO_LEFT
	lda old_fx
	sec
	sbc fx + 1		; remember fx+1 is int(fx) => old_fx - int(fx) which is >= 0
	.else
	lda fx + 1
	sec
	sbc old_fx		; => int(fx) - old_fx which is >= 0
	.endif

	tax
	lda modulo7_times8, X	; ("round" of int(fx)-old_fx) * 8

	;; Merge the ..DDD... and .....SSS parts
	ora dummy_ptr

	tax

	;; Now X is the index of the tile, so we can load
	;; and set its pointer

	.if mdirection = ::RIGHT_TO_LEFT

	LDA tiles_lr_ptrs_lo, X
	STA tile_ptr
	LDA tiles_lr_ptrs_hi, X
	STA tile_ptr + 1

	.else

	LDA tiles_ptrs_lo, X
	STA tile_ptr
	LDA tiles_ptrs_hi, X
	STA tile_ptr + 1

	.endif

	.endmacro

old_opcode:	.byte 0
self_mod_flag:	.byte 0
length_mod7:	.byte 0
length_div7:	.byte 0
tiles_length:	.byte 2		; length - 1 (so length is always >= 1)

modulo7_times8:
	;; This table is tricky. It's not actually mod 7
	;; It's max( TILE-SIZE - 1, x % TILE_SIZE) * 8
	.byte 0*8,1*8,2*8,3*8,4*8,5*8,6*8,6*8

;;; 56 instructions pers block.
;;; and 7 * 6 instructions in the generated code
;;; => total 56 + 7*6 = 98 per block => 98/7 = +/- 13 instructions per pixel
;;; if full block drawn...
;;; if half block drawn : 98 + (7*6) / 2 = 119 => 119 / 3 = +/- 20 instructions per pixel
;;;  but i miss some more additional block setup...

;;; Golombeck : 27 instructions per pixel in center loop.

	.macro draw_vline direction, clearing
	;; direction = RIGHT_TO_LEFT or LEFT_TO_RIGHT
	;; clearing set : we'll clear pixels, else we'll draw.

	.scope

	LDA #6			; 0 - tiles_length inclusive => 7.
	STA tiles_length

	;; Prepare for unconditional branching
	;; Make sure you don't break that further away
	CLV

	LDX length
	LDA modulo7, X
	STA length_mod7
	LDA div7, X
	STA length_div7
	CMP #0
	BNE at_least_one_tile
	RTS

at_least_one_tile:

loop_start:

	advance_tile_vertically ::direction

loop_start2:
	;; tax

	;; ;; Now X is the index of the tile, so we can load
	;; ;; and set its pointer

	;; .if ::direction = ::RIGHT_TO_LEFT

	;; LDA tiles_lr_ptrs_lo, X
	;; STA tile_ptr
	;; LDA tiles_lr_ptrs_hi, X
	;; STA tile_ptr + 1

	;; .else

	;; LDA tiles_ptrs_lo, X
	;; STA tile_ptr
	;; LDA tiles_ptrs_hi, X
	;; STA tile_ptr + 1

	;; .endif

	;; Self modify the drawing code to handle the "tile break"
	;; moment


	;; ----------------- Test code for ROR strategy !!!

	;; if the tile has no break, then we don't draw it
	;; This works with regular slef-mod code.
;; 	CMP #NO_BREAK_INDICATOR
;; 	BNE draw_breaks
;; 	JMP no_undo_self_mod	; skip this tile entirely
;; draw_breaks:
	;;  Cancel ROR/ADC effect
	;; Note that x_shift is corectly set (corresponds
	;; to DEX/INX)
	;; PHA
	;; LDA #255
	;; STA x_shift
	;; PLA

	.ifblank clearing

	;; Choose the code segment to run to draw or clear
	;; the line. self_mod will contain a pointer to
	;; that code and it's part of a JSR opcode which will
	;; do the jump.

	LDY fy + 1
	LDA (line_code_ptr_lo), Y
	STA self_mod + 1
	LDA (line_code_ptr_hi), Y
	STA self_mod +1 + 1

	.if ::direction = ::RIGHT_TO_LEFT
	LDA #254
	.else
	LDA #0
	.endif
	STA x_shift

	.else
	;; X = number of the tile we will draw

	.if ::direction = ::RIGHT_TO_LEFT
	LDA tiles_lr_breaks_indices,X
	.else
	LDA tiles_breaks_indices,X
	.endif


	STOPPER = 0

	STA self_mod_flag
	CMP tiles_length		; 2/3d of times, no self mod is necessary
	BPL no_self_mod


	CLC
	ADC fy + 1
	TAY 	;; Y = (fy + 1) + tile_length

	;; self_mod_ptr :=
	;;      blank_line_code_ptr + (blank_pcsm0-blank_line0)

	CLC
	LDA (blank_line_code_ptr_lo), Y
	ADC #<(blank_pcsm0-blank_line0)
	STA self_mod_ptr
	LDA (blank_line_code_ptr_hi), Y
	ADC #>(blank_pcsm0-blank_line0)
	STA self_mod_ptr + 1

	;; Now we apply the self modifications.
	;; It consists in replacing th BMI
	;; by something else. We'll undo that
	;; self modification once the code has been
	;; executed.


	.if ::direction = ::RIGHT_TO_LEFT
	LDA #OPCODE_DEX
	.else
	LDA #OPCODE_INX
	.endif
	LDY #0
	STA (self_mod_ptr),Y

	INY
	LDA (self_mod_ptr),Y
	STA old_opcode
	LDA #OPCODE_NOP
	STA (self_mod_ptr),Y

no_self_mod:
	;; Choose the code segment to run to draw or clear
	;; the line. self_mod will contain a pointer to
	;; that code and it's part of a JSR opcode which will
	;; do the jump.
	LDY fy + 1
	LDA (blank_line_code_ptr_lo), Y
	STA self_mod + 1
	LDA (blank_line_code_ptr_hi), Y
	STA self_mod +1 + 1
	.endif			; end clearing code ------------------



	;; Y = how many lines to draw (zero included => if Y = 2
	;; then 3 lines will be drawn)
count:
	LDY tiles_length


	;; X = x position of the tile to draw
	LDX old_fx
	LDA div7, X
	TAX

	.ifnblank clearing
	;; When clearing, A is the color.
	LDA #$0
	.endif

	CLC
self_mod:
	jsr line0		; This address will be self modified


	.ifnblank clearing
	LDA self_mod_flag
	CMP #NO_BREAK_INDICATOR
	BEQ no_undo_self_mod

	;; Undo the self modifications

	LDA #OPCODE_BMI
	LDY #0
	STA (self_mod_ptr),Y

	LDA old_opcode
	INY
	STA (self_mod_ptr),Y
no_undo_self_mod:

	.endif


	LDA fy + 1
	CLC
	ADC #7
	STA fy + 1

	DEC length_div7
	BEQ tile_done
	JMP loop_start
tile_done:

	LDA length_mod7
	CMP #0
	BEQ really_done

	STA tiles_length
	LDA #1
	STA length_div7
	LDA #0
	STA length_mod7
	advance_tile_vertically ::direction
	;; FIXME This block should be optimized (ie it is only needed
	;; when tiles_length is not 6, that is when a tile is clipped

	LDA #6
	SEC
	SBC tiles_length
	CLC
	ADC tile_ptr
	STA tile_ptr
	LDA #0
	ADC tile_ptr + 1
	STA tile_ptr + 1


	JMP loop_start2

really_done:
	RTS

	.endscope
	.endmacro
