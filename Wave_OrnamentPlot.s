;Wave_OrnamentPlot.s
;   0123456789012345678901234567890123456789
;18 --SAMPLES--+---VOL-SEQ F----+-ORNAMENT--
;19 00 Sample01|00 +N +E +T P+05|00 L +00 XX
;20 01 Sample02|01 +N +E +T P+05|01   +01 XX
;21 02 Sample03|02 +N +E +T P+05|02   -01 XX
;22 03 Sample04|03 +N +E +T P+05|03   --- XX
;23 04 Sample05|04 +N +E +T P+05|04   --- XX
;24 05 Sample06|05 +N +E +T P+05|05   --- XX
;25 06 Sample07|06 +N +E +T P+05|06   --- XX
;26 07 Sample08|07 +N +E +T P+05|07   --- XX
DisplayOrnamentID
	lda #<$BB80+37+40*18
	sta screen
	lda #>$BB80+37+40*18
	sta screen+1
	lda OrnamentID
	ldx #128
	ldy #00
	jmp Display1DH

;Ornaments
;Split into header and data areas
;Data(Up to 32 bytes)
; B0-6
;  0-127 Offset
; B7
;  0 Note Offset(-128 to +127)
;  1 End(End(0) or Loop back offset(1-127))

OrnamentCursorPlot
	ldx OrnamentCursorY
	lda OrnamentScreenRowAddressLo,x
	sta screen
	lda OrnamentScreenRowAddressHi,x
	sta screen+1
	ldy #8
.(
loop1	lda (screen),y
	ora #128
	sta (screen),y
	dey
	bpl loop1
.)
	rts

OrnamentScreenRowAddressLo
 .byt <$BB80+28+40*19
 .byt <$BB80+28+40*20
 .byt <$BB80+28+40*21
 .byt <$BB80+28+40*22
 .byt <$BB80+28+40*23
 .byt <$BB80+28+40*24
 .byt <$BB80+28+40*25
 .byt <$BB80+28+40*26
OrnamentScreenRowAddressHi
 .byt >$BB80+28+40*19
 .byt >$BB80+28+40*20
 .byt >$BB80+28+40*21
 .byt >$BB80+28+40*22
 .byt >$BB80+28+40*23
 .byt >$BB80+28+40*24
 .byt >$BB80+28+40*25
 .byt >$BB80+28+40*26

OrnamentPlot
	;
	lda #<$BB80+28+40*19
	sta screen
	lda #>$BB80+28+40*19
	sta screen+1
	
	;Calculate ornament address into source
	jsr FetchOrnamentAddress

	lda #8
	sta ScreenRows
	
	ldy OrnamentBaseIndex
	sty SourceIndex
.(	
loop1	;Display sign
	ldy SourceIndex
	lda (ornament),y
	beq skip3
	ldy #5
	ldx #00
	jsr DisplaySigned8DD
	jmp skip2
skip3	ldy #5
	lda #8
	sta (screen),y
	iny
	sta (screen),y
	iny
	sta (screen),y
	iny
	sta (screen),y

skip2	;Display Ornament Index
	lda SourceIndex
	ldy #00
	ldx #00
	jsr Display2DD
	
	ldy #2
	lda #1
	sta (screen),y
	ldy #4
	lda #6
	sta (screen),y

	;Display Loop Flag
	lda #"L"
	ldx OrnamentID
	ldy mmOrnamentLoops,x
	cpy SourceIndex
	beq skip1
	lda #8
skip1	ldy #3
	sta (screen),y
	
	jsr nl_screen
	inc SourceIndex
	
	dec ScreenRows
	bne loop1
.)
	rts	
	
FetchOrnamentAddress
	lda OrnamentID
	asl
	asl
	asl
	asl
	asl
	sta ornament
	lda #>mmOrnamentMemory
	adc #00
	sta ornament+1
	lda ornament
	adc #<mmOrnamentMemory
	sta ornament
.(
	bcc skip1
	inc ornament+1
skip1	rts
.)
