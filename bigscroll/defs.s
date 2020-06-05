HGR_RAM		= $2000
dummy_pointer	= 254


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

.macro store_16 target, const
	lda #<const
	sta target
	lda #>const
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


; 16 bit word := 16 bit word + 16 bit const
.macro add_const_to_16 target, const
	CLC
	LDA target     ; low byte
	ADC #<const
	STA target

	LDA target+1	; high byte
	ADC #>const
	STA target+1
.endmacro


.macro	asl16 target
	clc
	rol target	; low byte
	rol target + 1	; hi byte
.endmacro
