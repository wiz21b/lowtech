
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

	sta smc + 1
	store_16 dummy_pointer, (HGR_RAM + $4000)

clear_hgr_loop:
	dec16 dummy_pointer

smc:
	LDA #$00
	LDY #0
	STA (dummy_pointer), Y


	lda #$20
	cmp dummy_pointer + 1
	bne clear_hgr_loop
	lda #0
	cmp dummy_pointer
	bne clear_hgr_loop

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
