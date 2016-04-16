;Wave_HelpList.s

;Generate a push scroll list of all editor keys broken down into individual sections
;0123456789012345678901234567890123456789
;Area     Key Description           Key
;NAVIGATE SWITCH TO ORNAMENT EDITOR CTRL O
HelpLegendText
 .byt 5,"AREA",8,8,8,8,8,"KEY",8,"DESCRIPTION",8,8,8,8,8,8,8,8,8,8,8,"KEY",8

PlotHelpLegend
	ldx #39
.(
loop1	lda HelpLegendText,x
	sta $BB80+40*4,x
	dex
	bpl loop1
.)
	rts

ClearPatternArea
	;Now clear pattern area
	lda #<$bb80+40*5
	sta screen
	lda #>$bb80+40*5
	sta screen+1
	ldx #13
.(
loop2	ldy #39
	lda #8
loop1	sta (screen),y
	dey
	bpl loop1
	jsr nl_screen
	dex
	bne loop2
.)
	rts

HelpCursorPlot
	ldy HelpCursorY
	lda ScreenYLOCL+5,y
	sta screen
	lda ScreenYLOCH+5,y
	sta screen+1
	ldy #39
.(
loop1	lda (screen),y
	ora #128
	sta (screen),y
	dey
	bpl loop1
.)
	rts
DeleteHelpCursor
	ldy HelpCursorY
	lda ScreenYLOCL+5,y
	sta screen
	lda ScreenYLOCH+5,y
	sta screen+1
	ldy #39
.(
loop1	lda (screen),y
	and #127
	sta (screen),y
	dey
	bpl loop1
.)
	rts

;Always display within pattern area only since this can be restored by full screen width.
HelpPlot
	ldx PreviousEditorID
	lda EditorKeyDescriptionIDListLo,x
	sta source
	lda EditorKeyDescriptionIDListHi,x
	sta source+1
	lda EditorKeyAreaIDListLo,x
	sta areaid
	lda EditorKeyAreaIDListHi,x
	sta areaid+1
	lda EditorHardKeyCodeTableLo,x
	sta hardkey
	lda EditorHardKeyCodeTableHi,x
	sta hardkey+1
	
	;Each Page contains up to 13 keys
	lda HelpPage
	;x1 x4 x8
	asl
	asl
	sta hpTemp01
	asl
	adc hpTemp01
	adc HelpPage
	sta ListIndex
	lda #05
	sta RowIndex

.(
loop1	;Display Area
	ldy ListIndex
	lda (areaid),y
	ldx #00
	ldy RowIndex
	jsr DisplayMessage
	
	;Display Key Description
	ldy ListIndex
	lda (source),y
	ldx #09
	ldy RowIndex
	jsr DisplayMessage

	;Display Soft Key
	ldy ListIndex
	lda (hardkey),y
	ldy #26
	and #%11000000
	beq skip1
	asl
	rol
	rol
	adc #82
	ldx #35
	ldy RowIndex
	jsr DisplayMessage
	
skip1	;Display Hard Key
	sty OffsetToKeyText
	ldy ListIndex
	lda (hardkey),y
	and #%00111111
	tax
	lda ASCIICode,x
	ldy OffsetToKeyText
	sta (screen),y
	
	jsr nl_screen
	
	inc ListIndex
	lda ListIndex
	ldx PreviousEditorID
	cmp EditorUltimateKey,x
	beq skip2
	bcs skip3
	
skip2	inc RowIndex
	lda RowIndex
	cmp #18
	bcc loop1
skip3	rts
.)
