;DumpCompilationToPrinter.s

;Print 2DH with preceding Dollar
;A=Value
LPrint2DH
	lda #"$"
	jsr ROM_LPRINT_BYTE
	
	lda $00
	lsr
	lsr
	lsr
	lsr
	jsr LPrintHexDigit
	
	lda $00
	and #15
LPrintHexDigit
	cmp #10
.(
	bcc skip1
	adc #7
skip1	adc #48
.)
	jmp ROM_LPRINT_BYTE
