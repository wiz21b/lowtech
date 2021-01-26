
.proc pause

	STA pause_count + 1
	LDA #$FF
	STA pause_count

	;store_16 pause_count, 1000
loop:
	dec16 pause_count
	lda pause_count
	bne loop
	lda pause_count+1
	bne loop
	rts

pause_count:	.word 0

.endproc


	.proc clear_hgr
	;; A = color to clear with

	sta smc + 1
	store_16 dummy_pointer, HGR_RAM
	ldx #$40

	;; HGR memory is $4000 bytes => $40 x 256

clear_hgr_loop:

smc:
	LDA #$00

	LDY #0
clear_block:
	STA (dummy_pointer), Y
	DEY
	BNE clear_block

	INC dummy_pointer + 1
	DEX
	BNE clear_hgr_loop

	RTS
	.endproc


hexa:
hexa_apple:
	.byte $30,$31,$32,$33,$34,$35,$36,$37,$38,$39
	.byte $1,$2,$3,$4,$5,$6

;hexa:		.byte "0123456789ABCDEF"
STATUS_BUFFER = $7D0	; $750 $650
;; draw_status:

;; 	LDA ticks
;; 	AND #$F
;; 	TAY
;; 	LDA hexa,Y
;; 	STA STATUS_BUFFER+4

;; 	LDA ticks
;; 	AND #$F0
;; 	LSR
;; 	LSR
;; 	LSR
;; 	LSR
;; 	TAY
;; 	LDA hexa,Y
;; 	STA STATUS_BUFFER+3

;; 	LDA ticks+1
;; 	AND #$F
;; 	TAY
;; 	LDA hexa,Y
;; 	STA STATUS_BUFFER+2

;; 	LDA ticks+1
;; 	AND #$F0
;; 	LSR
;; 	LSR
;; 	LSR
;; 	LSR
;; 	TAY
;; 	LDA hexa,Y
;; 	STA STATUS_BUFFER+1

;; 	RTS
