;TestRoutines.s

TestKeys
	lda #48
	sta $BFDC
	lda #"6"
	sta $BFDE
	lda #"3"
	sta $BFDF
	
	jsr CommonInkey
	pha
	asl
	rol
	rol
	and #3
	ora #48
	sta $BFDC
	pla
	and #63
	ldy #<$BFDE
	sty screen
	ldy #>$BFDE
	sty screen+1
	ldy #00
	jsr Display2DD
	jmp TestKeys
