	GR_RAM	 	= $400
	GR2_RAM	 	= $800
	HGR_RAM		= $2000

	OPCODE_NOP 	= $EA
	OPCODE_DEX 	= $CA
	OPCODE_INX 	= $E8
	OPCODE_BMI 	= $30
	OPCODE_BEQ 	= $F0
	OPCODE_BPL 	= $10

	LC_RAM_SELECT	= $C08B	; 4K Bank A, RAM read, Write enabled

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
