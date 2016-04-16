;Wave_SamplePlot.s
SampleCursorPlot
	ldx SampleCursorY
	lda SampleCursorScreenRowAddressLo,x
	sta screen
	lda SampleCursorScreenRowAddressHi,x
	sta screen+1
	ldy #6
.(
loop1	lda (screen),y
	ora #128
	sta (screen),y
	dey
	bpl loop1
.)
	rts

SampleCursorScreenRowAddressLo
 .byt <$BB83+40*19
 .byt <$BB83+40*20
 .byt <$BB83+40*21
 .byt <$BB83+40*22
 .byt <$BB83+40*23
 .byt <$BB83+40*24
 .byt <$BB83+40*25
SampleCursorScreenRowAddressHi
 .byt >$BB83+40*19
 .byt >$BB83+40*20
 .byt >$BB83+40*21
 .byt >$BB83+40*22
 .byt >$BB83+40*23
 .byt >$BB83+40*24
 .byt >$BB83+40*25
	
SamplePlot
	;Plot 7 Samples
	lda #<$BB83+40*19
	sta screen
	lda #>$BB83+40*19
	sta screen+1
	lda #<mmSampleNames
	sta source
	lda #>mmSampleNames
	sta source+1
	ldx #7
.(
loop2	ldy #6
loop1	lda (source),y
	sta (screen),y
	dey
	bpl loop1
	jsr nl_screen
	lda #8
	jsr add_source
	dex
	bne loop2
.)
	rts
