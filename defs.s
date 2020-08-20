	GR_RAM	 	= $400
	GR2_RAM	 	= $800
	HGR_RAM		= $2000

	OPCODE_NOP 	= $EA
	OPCODE_DEX 	= $CA
	OPCODE_INX 	= $E8
	OPCODE_BMI 	= $30
	OPCODE_BEQ 	= $F0
	OPCODE_BPL 	= $10

	KBD_CLEAR = $C010
	KBD_INPUT = $C000
	ONE_80TH = 1022000/80 	; 1/80th of a second

	LC_RAM_SELECT	= $C08B	; 4K Bank A, RAM read, Write enabled

	MB_Base = $5E		; WORD ! Base addres of MockingBoard
				; $60-$7F = PT3 player ZP addresses

	;; FIXME Reuse the on efrom the PT3 player

.macro store_8 target, const
	lda #(const)
	sta target
.endmacro


.macro store_16 target, const
	lda #<(const)
	sta target
	lda #>(const)
	sta target + 1
.endmacro


.macro copy_16 target, const
	lda const
	sta target
	lda const + 1
	sta target + 1
.endmacro

; decrease 16-bit counters
; A destroyed
.macro dec16 target
	.local j
	LDA target
	BNE j	; "bne * + 5" would not work in zp
	DEC target + 1
j:
	DEC target	; low byte
.endmacro



.macro add_a_to_16 target
        ; Add A to .target
	; A is destroyed
        CLC			; 2 c
	ADC target		; 3 zp or 4 absolute
	STA target		; 3 zp or 4 absolute
	LDA #0			; 2
	ADC target + 1		; 3 or 4
	STA target + 1		; 3 or 4 => 16 or 20 cycles
.endmacro





; 16 bit word := 16 bit word + 16 bit const
.macro add_const_to_16 target, const
	CLC
	LDA target     ; low byte
	ADC #<(const)
	STA target

	LDA target+1	; high byte
	ADC #>(const)
	STA target+1
.endmacro


.macro	add16 target, mem_b
	;; DEPRECATED Use add_mem_16 instead !
	CLC
	LDA target
	ADC mem_b
	STA target
	LDA target + 1
	ADC mem_b + 1
	STA target + 1

.endmacro


	;; target := target - mem_b
.macro	sub16 target, mem_b
	SEC
	LDA target
	SBC mem_b
	STA target
	LDA target + 1
	SBC mem_b + 1
	STA target + 1
.endmacro

; 16 bit word := 16 bit word - 16 bit const
.macro sub_const_to_16 target, const
	SEC
	LDA target     ; low byte
	SBC #<(const)
	STA target

	LDA target+1	; high byte
	SBC #>(const)
	STA target+1
.endmacro

; 16 bit word := 16 bit word - 16 bit const
.macro sub_16_to_const target, const
	SEC
	LDA #<(const)     ; low byte
	SBC target
	STA target

	LDA #>(const)	; high byte
	SBC target+1
	STA target+1
.endmacro


; 16 bit word := 16 bit word + 16 bit const
.macro add_mem_16 target, source
	CLC
	LDA target     ; low byte
	ADC source
	STA target

	LDA target+1	; high byte
	ADC source+1
	STA target+1
.endmacro


.macro	asl16 target
	clc
	rol target	; low byte
	rol target + 1	; hi byte
	.endmacro


	;; Deprecated because can't SMC MockingBoard slot

	.macro set_timer_const value
	lda	#>(value)	; 9C
	;CLC
	;; ADC time_expand
	sta	MOCK_6522_T1CH	; write into high-order latch,
	lda	#<(value)
	sta	MOCK_6522_T1CL	; write into low-order latch
	.endmacro


	.macro set_irq_vector target
	;; This assumes the Language Card bank is activated !
	lda	#<target
	sta	$fffe
	lda	#>target
	sta	$ffff
	;; lda	#<target
	;; sta	$03fe
	;; lda	#>target
	;; sta	$03ff
	.endmacro


	;; Computes A := A * 5 (so A must be < 51)
	.macro mul_a_by_5
	.scope
	STA smc + 1
	ASL
	ASL
	;; Carry is cleared, else A was too big to be multiplied
smc:
	ADC #0
	.endscope
	.endmacro



	TIMER_START = $FFFF - 32

	.macro set_timer_to_const value

	LDY #4
	lda	#<(value)
	sta	(MB_Base),Y	; write into low-order latch,

	INY
	lda	#>(value)
	sta	(MB_Base),Y	; write into high-order latch

	.endmacro

	.macro set_timer_to_target value

	LDY #4
	lda	value
	sta	(MB_Base),Y	; write into low-order latch,

	INY
	lda	value + 1
	sta	(MB_Base),Y	; write into high-order latch

	.endmacro


	CYCLES_FOR_READING_TIMER = 28 	; not entirely exact !
					; the first read_timer shoul not
					; include the last STA.

	.macro read_timer2 target

	;; Total : 28 cycles. Don't forget to remove those
	;; from the total measurements, else you'll time
	;; the chronometer time as well !

	LDY #4			; 2 cycles
	LDX sector_count	; 4 cycles

	;; Read LSB *first* (See 6522 counter fix macro below)

	LDA (MB_Base),Y 	; 5 cycles; read MOCK_6522_T1CH
	sta target, X		; (*) 5 cycles

	;; Read MSB
	INY			; (*) 2 cycles
	LDA (MB_Base),Y		; (*) 5 cycles; read MOCK_6522_T1CL
	sta target+1,X		; 5 cycles

	;; (*) cycles that count as "time between reading
	;; LSB and MSB)

	.endmacro


	.macro read_timer_direct target

	LDY #4			; 2 cycles
	LDA (MB_Base),Y 	; 5 cycles; read MOCK_6522_T1CH
	sta target		; (*) 4 cycles
	INY			; (*) 2 cycles
	LDA (MB_Base),Y		; (*) 5 cycles; read MOCK_6522_T1CL
	sta target+1		; 4 cycles

	.endmacro



	;; Number of cycles betwwen the moment we read the
	;; LSB of the 6522 counter and the MSB.
	CYCLES_BETWEEN_LSB_MSB_6522_READ = 12

	.macro fix_6522_read_value read_value_6522
	.scope
	;; When reading the 6522 counter, LSB first then MSB,
	;; the LSB is always n cycles too early compared to
	;; the moment were the MSB was read. By substracting
	;; those cycle from the LSB, we "delay" it to the moment
	;; where the MSB was read. So it has the value it would
	;; have had if it were to be read at the same time the
	;; the MSB is read. Notice we don't touch the MSB.

	;; read_value_6522 = value (word) that was read from
	;; the 6522 counter. This must have been read LSB
	;; first and MSB second.

	LDA read_value_6522
	SEC
	SBC #CYCLES_BETWEEN_LSB_MSB_6522_READ
	STA read_value_6522

	.endscope
	.endmacro
