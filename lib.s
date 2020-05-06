.proc pause

	store_16 pause_count, 1000
loop:
	dec16 pause_count
	lda pause_count
	bne loop
	lda pause_count+1
	bne loop
	rts

pause_count:	.word 0

.endproc


clear_hgr:
	store_16 dummy_pointer, (HGR_RAM + $4000)

clear_hgr_loop:
	dec16 dummy_pointer

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



hexa:		.asciiz "0123456789ABCDEF"
ticks:		.word $0000
STATUS_BUFFER = $7D0	; $750 $650
draw_status:

	LDA ticks
	AND #$F
	TAY
	LDA hexa,Y
	STA STATUS_BUFFER+4

	LDA ticks
	AND #$F0
	LSR
	LSR
	LSR
	LSR
	TAY
	LDA hexa,Y
	STA STATUS_BUFFER+3

	LDA ticks+1
	AND #$F
	TAY
	LDA hexa,Y
	STA STATUS_BUFFER+2

	LDA ticks+1
	AND #$F0
	LSR
	LSR
	LSR
	LSR
	TAY
	LDA hexa,Y
	STA STATUS_BUFFER+1

	RTS
