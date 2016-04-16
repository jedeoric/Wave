;Wave_ListPlot.s
;0-23 Pattern (0-23)
;128+ Loop(128==End)

ListCursorPlot
	lda ListCursorX
	asl
	asl
	tay
	ldx #3
.(
loop1	lda $BB80+1+40*2,y
	ora #128
	sta $BB80+1+40*2,y
	iny
	dex
	bne loop1
.)
	rts
	

ListPlot
	lda #<$BB80+1+40*1
	sta screen
	lda #>$BB80+1+40*1
	sta screen+1
	
	lda ListCursorBase
	sta ListPlotTempX
	lda #10
	sta ListColumnCount
.(
loop1	lda ListColumnCount
	cmp #6
	beq skip2
	bcc skip2
	ldy #00
	lda ListPlotTempX
	ldx #128
	jsr Display3DD

skip2	;Calculate if we need to highlight(inverse) this entry
	lda #00
	ldy leHighlightingFlag
	beq skip6
	ldy ListPlotTempX
	cpy leHighlightStartX
	bcc skip6
	cpy leHighlightEndX
	beq skip5
	bcs skip6
skip5	lda #128
skip6	sta leInverseFlag

	ldy ListPlotTempX
	lda mmListMemory,y
	bpl skip3
	ldy #40
	lda #8
	ora leInverseFlag
	sta (screen),y
	iny
	ora leInverseFlag
	sta (screen),y
	iny
	ora leInverseFlag
	sta (screen),y
	jmp skip4

skip3	ldy ListPlotTempX
	lda #"L"
	cpy mmListHeader
	beq skip1
	lda #"P"
skip1	ldy #40
	ora leInverseFlag
	sta (screen),y

	ldy ListPlotTempX
	lda mmListMemory,y
	and #31
	ldy #41
	ldx leInverseFlag
	jsr Display2DD
	
skip4	lda #4
	jsr add_screen
	
	inc ListPlotTempX
	dec ListColumnCount
	bne loop1
.)
	rts	
