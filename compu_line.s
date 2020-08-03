	;; 56 sec old code
	;; 63 sec new code => +- 12% slower.
compute_line_parameters:

	;;  Compute abs(delta Y) (y is one byte)

	LDA y1
	CMP y2
	BMI y1_smaller	; y1 < y2

	BNE go_on		;FIXME Handle horizontal lines correctly !
	;RTS
go_on:
;;; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; MOSTLY VERTICAL LINE

	SEC			; dx = y1 - y2
	LDA y1
	SBC y2
	JMP done1
y1_smaller:
	SEC			; dx = y2 - y1
	LDA y2
	SBC y1
done1:
	STA dy_positive

	;;  Compute abs(delta X) (x is two bytes)
	;; We make th ehypothesis that |dx| <= 255
	SEC
	LDA x2
	SBC x1
	STA dx
	STA dx_positive
	LDA x2 + 1
	SBC x1 + 1
	;; STA dx + 1
	;; STA dx_positive + 1

	;; Is dx positive ?
	BCS dx_is_positive	; yes it is

	;; dx_positive = - dx_positive
	SEC
        LDA #0
        SBC dx_positive+0
        STA dx_positive+0
        ;; LDA #0
        ;; SBC dx_positive+1
        ;; STA dx_positive+1
dx_is_positive:

	;; at this point : 0 <= {dx,dy}_positive <= 255
	;; Indeed, because although x1 and x2 belongs to [0,279]
	;; we make it so that their delta is [0,255]

	LDA dx_positive
	CMP dy_positive
	BNE dx_different_dy

	;; 45° line. It's a special case because in that
	;; case dx/dy == 1 and this triggers some overflows
	;; in my table lookups (esp. the 1/x table)

	LDA #$FF
	STA slope65536
	LDA #6			; TILE-SIZE - 1
	STA slope65536+1
	BNE dx_equals_dy	; branch
	RTS
dx_different_dy:

	BMI dx_smaller_dy	; dx < dy
	JMP dx_bigger_dy

dx_smaller_dy:
	;; dx < dy case => slope = dx/dy

	LDA dx_positive
	LDY dy_positive
	JSR divide_times_tile_size

dx_equals_dy:
	LDA y1
	CMP y2
	BMI y_correctly_ordered
	JSR swap_p1_p2
y_correctly_ordered:

	;; At this point P1.y < P2.Y

	LDA x1
	CMP x2
	BMI x_correctly_ordered
	JSR swap_slope_sign
x_correctly_ordered:


	;; FIXME I move things from lo-byte to hi-byte
	;; that's very dirty

	LDA #0
	STA fx
	LDA x1
	STA fx+1

	LDA #0
	STA fy
	LDA y1
	STA fy+1

	LDA dy_positive
	STA length
	LDA slope65536
	STA slope
	LDA slope65536+1
	STA slope+1
	jsr draw_vline_full

	RTS

;;; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; MOSTLY HORIZONTAL LINE
	;; 262 cycles + 2*slope_by_7 (136 cycles) => 534 cycles
	;; + divide_times_... (445) = 979 cycles
	;; approx for 20 segments = 20000 cycles
	;; 8 fps = 125000 cycles/frame

dx_bigger_dy:

	;; dx > dy case => slope = dy/dx

	LDA dy_positive
	LDY dx_positive
	JSR divide_times_tile_size

	LDA x1
	CMP x2
	BMI x_correctly_ordered2
	JSR swap_p1_p2
x_correctly_ordered2:

	;; At this point, x1 < x2 => dx > 0

	LDA y1
	CMP y2
	BMI y_correctly_ordered2

	LDA slope65536+1
	ORA #$80
	STA slope65536+1
y_correctly_ordered2:

	;; Prepare *LEFT* side of the line data ----------------------

	;; Since [x1+1] th hi-bits of x1 are a multiple
	;; of 256, they go around the modulo7 table (which
	;; is 256 bytes) => x % 7 = (n*256 + x) % 7 =
	;; tbl[n*256 + x] = tbl[x]

	LDX x1
	LDA modulo7,X
	STA left_mask		; left_mask == x1 % TILE_SIZE
	BEQ dont_fix_y1		; x1 % TILE_SIZE == 0 => nothing to fix
				; 'cos we're already on the left tile
				; boundary.

	;; Now we extend the segment on its left so that it begins on
	;; a tile boundary. We add what's needed to the x coordinate
	;; and we compute the corresponding y.

	;; First we compute y
	TAX
	JSR slope_by_7		; work = slope256 * left_mask (X)

	LDA slope65536+1
	AND #$80
	BEQ fix_y1_slope_positive
	LDA y1
	CLC
	ADC work + 1
	JMP fix_y1_slope_positive2
fix_y1_slope_positive:
	LDA y1
	SEC
	SBC work+1
fix_y1_slope_positive2:
	STA y1			; y1 := y1 - (x1 % TILE_SIZE) * slope

	;; work == (x1 % TILE_SIZE) * (TILE_SIZE*slope)

	;; second we compute x

	;; LDA x1
	;; SEC
	;; SBC left_mask
	;; STA x1			; x1 == x1 - (x1 % TILE_SIZE))
	;; LDA x1 + 1
	;; SBC #0
	;; STA x1 + 1

dont_fix_y1:

	;; -----------------------------------------------------------
	;; Now we extend the segment on its right

	;; Prepare *RIGHT* side of the line data

	;; if x = 2, then x % 7 = 2.
	;; x == 2 means we end the line of the third (0,1,2) pixel
	;; of the tile. We must add 4 to reach the rightmost pixel
	;; of the tile (x=6).
	;; In this case, (7 - 1) - (x % 7).

	LDX x2
	LDA modulo7,X
	STA right_mask		; right_mask == x2 % TILE_SIZE

	LDA #7-1		; TILE_SIZE - 1
	SEC
	SBC right_mask		; TILE_SIZE - 1 - (x2 % TILE_SIZE)

	;; A == 0 if (x2 % TILE_SIZE)  == TILE_SIZE - 1 (rightmost
	;; pixel of the tile). If A == 0, then the multiplication
	;; by the slope will be 0 too, so y2 will remain unchanged,
	;; as well as x2.

	BEQ dont_fix_y2

	STA work

	;; CLC
	;; ADC x2
	;; STA x2			; x2 := x2 + (TILE_SIZE - 1 - (x2 % TILE_SIZE))
	;; LDA x2+1
	;; ADC #0
	;; STA x2+1

	LDX work		; X := TILE_SIZE - 1 - (x2 % TILE_SIZE)
	JSR slope_by_7		; work (16 bits) := X * slope_by_256

	LDA slope65536+1
	AND #$80
	BEQ fix_y2_slope_positive

	LDA y2
	SEC
	SBC work+1		; work = X (8 bits) by slope_by_256
	jmp fix_y2_slope_positive2 ; FIXME short jump
fix_y2_slope_positive:
	LDA y2
	CLC
	ADC work+1		; work = X (8 bits) by slope_by_256
fix_y2_slope_positive2:
	STA y2			; y2 += (TILE_SIZE - 1 - (x2 % TILE_SIZE)) * slope_by_256

dont_fix_y2:

	;; -----------------------------------------------------------
	;; Compute the number of tiles we need
	;; to draw (usually one left-clipped, a few complete and
	;; onr right-clipped). The length is inclusive, so we go
	;; from x1/7 to x2/7, inclusive. Therefore the length is
	;; always >= 1. A length of one means that the left-clipped
	;; and the right-clipped one are the same (they overlap).

	LDX x2
	LDA div7,X

	LDX x1
	SEC
	SBC div7, X

	CLC
	ADC #1
	STA length

;;; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	LDY left_mask
	LDA hline_masks_left, Y
	STA mask_left

	LDY right_mask
	LDA hline_masks_right, Y
	STA mask_right

	;; Initialize fx=0; fx+1=? (1 word)
	;; fy=0, fy+1=? (1 word)

	LDA #0
	STA fx
	LDA x1
	STA fx+1

	LDA #0
	STA fy
	LDA y1
	STA fy+1

	LDA slope65536
	STA slope
	LDA slope65536+1
	STA slope+1

	jsr draw_hline_full

	RTS



;;; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Common subroutines
;;; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


divide_times_tile_size:
	;; 179 cycle without subroutines
	;; + 2 * multiply_8 (133 cycles)
	;; => 179 + 266 = 445 cycles

	;; Compute : slope65536 (word) := TILE_SIZE (7) * A * (256/Y)
	;; A and Y are positive numbers (0 <= A,y < 256)
	;; Y is expected to be > A => 0 < A/Y < 1
	;; Threfore, although the general principle is to multiply
	;; A (8 bits) by a 16 bit 65536*1/Y table, the end result is
	;; 24 bits BUT < 65536 ! ( if A/Y < 1, then 65536*A/Y < 65536,
	;; then A*65536/Y < 65536 => A * tbl[Y] < 65536 ). In other
	;; words, if one knows A, then it must choose Y such that
	;; A/Y < 1

	;; a * 65536 * 1/b
	;; si B = 65536 * 1/b = Bh * 256 + Bl
	;; a * B = a * Bh * 256 (24 bits) + a * Bl (16 bits)
	;; => pour revenir à 16 bits; on shift tout de 8 vers la droite.
	;; (a * 65536 * 1/ b) >> 8 = 256 * a * 1/b
	;; = (a * Bh * 256 (24 bits) + a * Bl (16 bits)) >> 8
	;; = a*Bh (16 bits) + (a * Bl >> 8) (8bits)

	;; Je multiplie ça par TILE_SIZE
	;; Donc 7 * [a*Bh (16 bits) + (a * Bl >> 8) (8bits)]
	;; c'est sur 24 bits => shift de 8 vers la droite encore une fois
	;; 7 * [a*Bh (16 bits) + (a * Bl >> 8) (8bits)] >> 8
	;; [7 * a*Bh (24 bits) + 7 * (a * Bl >> 8) (16 bits)] >> 8
	;; (7 * a*Bh) >> 8 (16 bits) + (7 * (a * Bl >> 8) >> 8) (8 bits)

	;; => Bref, à la fin j'ai 7*a/b*256 sur 16 bits.


	;; Compute LSB of A * (1/Y * 65536)
	;; 0LL (the MSB is 0 because ratio < 1)

	PHA
	STA mul1
	TYA
	ASL
	TAX
	LDA one_over_x, X	; lobyte of table(65536/Y)[X]
	STA mul2
	JSR multiply_8		; A:m1 := mul1 * mul2

	STA slope65536+1
	LDA mul1
	STA slope65536

	;; Compute MSB of A * (1/Y * 65536)
	;; (so in the final 24 bits : 0M0 the MSB is 0
	;; because ratio < 1; the LSB is 0 (and not computed)
	;; because we compute the hi-bytes of the multiplication.

	PLA
	STA mul1
	TYA
	ASL
	TAX
	LDA one_over_x+1, X	; hibyte of table(65536/Y)[X]
	STA mul2
	;; FIXME this is overkill : we only need the LSB byte, not the MSB
	;; as the MSB is always zero ! So an early-out mechanism
	;; in the multiplication routine is necessary

	JSR multiply_8		; A:m1 := mul1 * mul2

	;; Sum MSB and LSB to get a 16 bits results
	;; 0LL + 0M0 = 0SS (we discard the last one)

	CLC
	LDA mul1
	ADC slope65536+1
	STA slope65536+1

	;; At this point, slope65536 == 65536*abs(A/Y)

	LDA slope65536
	STA work
	LDA slope65536+1
	STA work+1
	STA slope_by_256	; == 256*abs(A/Y), will be used later

	;; slope65536 * 7 (TILE_SIZE)
	LDA #0

	CLC
	ROL slope65536
	ROL slope65536+1		; slope65536 * 2
	ROL

	;; no need to clear carry as we'll discar the LSB
	ROL slope65536
	ROL slope65536+1		; * 4
	ROL
	ROL slope65536
	ROL slope65536+1 		; * 8
	ROL

	;; at this point : A:slope65536 (24 bits) == 8 * 65536*abs(A/Y)

	;; Now I do two things :
	;; 1/ Compute : 8 * 65536*abs(A/Y) - 65536*abs(A/Y) (=> == 7 * 65536*abs(A/Y))
	;; 2/ Shift the result 8 bits right so that slope65536 = 256 * 7 * abs(A/Y)
	TAY
	SEC
	LDA slope65536
	SBC work
	LDA slope65536+1
	SBC work+1
	STA slope65536
	TYA
	SBC #0
	STA slope65536+1		; slope65536 * 8 - 1 == slope65536 * 7

	RTS


;;; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

slope_by_7:
	;; 28 cycles + (1, or 3)*54 = avg 136 cycles

	;; Multiply X (8 bits) by slope_by_256 (256*a/b, that's
	;; 8 bits as a/b < 1)
	;; Result are put in 'work' (16 bits)
	;; Assume 0 < X <= 7. Slope256 is 8 bits positive int.
	;; FIXME Can be optimized : zeropage, better falg juggling,...


	LDA slope_by_256
	STA slope256_2
	LDA #0
	STA slope256_2 + 1

	LDA #0
	STA work
	STA work+1

	CLV
	TXA
slope_by_7_loop:
	CLC
	;; Pick least-significant bit and put it into carry
	ROR			; Affects Flags: N Z C
	BCC slope_by_7_rol	; The LSbit is zero.

slope_by_7_add:
	TAX
	CLC
	LDA slope256_2
	ADC work
	STA work
	LDA slope256_2+1
	ADC work+1
	STA work+1
	TXA

slope_by_7_rol:
	BEQ slope_by_7_done	; All the bits were read.
slope_by_7_go_on:
	CLC
	ROL slope256_2
	ROL slope256_2+1
	BVC slope_by_7_loop	; short jump
slope_by_7_done:
	RTS

;;; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

swap_slope_sign:
	LDA #0
	SEC
	SBC slope65536
	STA slope65536
	LDA #0
	SBC slope65536+1
	STA slope65536+1
	RTS

;;; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

swap_p1_p2:
	LDA x1
	LDX x2
	STA x2
	STX x1

	LDA x1+1
	LDX x2+1
	STA x2+1
	STX x1+1

	LDA y1
	LDX y2
	STA y2
	STX y1
	RTS

;;; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

multiply_8:
	;; Multiply mul1 * mul2
	;; Result in A:m1

	LDA #0
	CMP mul2		; Clear Carry too
	BEQ by0

	dec mul2	; decrement mul2 because we will be adding with carry set for speed (an extra one)

	ror mul1
	bcc b1
	adc mul2
b1:
	ror
	ror mul1
	bcc b2
	adc mul2
b2:
	ror
	ror mul1
	bcc b3
	adc mul2
b3:
	ror
	ror mul1
	bcc b4
	adc mul2
b4:
	ror
	ror mul1
	bcc b5
	adc mul2
b5:
	ror
	ror mul1
	bcc b6
	adc mul2
b6:
	ror
	ror mul1
	bcc b7
	adc mul2
b7:
	ror
	ror mul1
	bcc b8
	adc mul2
b8:
	ror
	ror mul1
	inc mul2
	rts
by0:
	STA mul1
	RTS
