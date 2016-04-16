;Wave_HelpEditor.s

HelpHardKeys
 .byt 28		;UP		heUp
 .byt 44		;DOWN		heDown
 .byt 128+28	;CTRL+UP		hePageUp
 .byt 128+44	;CTRL+DOWN	hePageDown
 .byt 39		;RETURN		heChange
 .byt 33		;ESC		heQuit
HelpKeyVectorLo
 .byt <heUp
 .byt <heDown
 .byt <hePageUp
 .byt <hePageDown
 .byt <heChange
 .byt <heQuit
HelpKeyVectorHi
 .byt >heUp
 .byt >heDown
 .byt >hePageUp
 .byt >hePageDown
 .byt >heChange
 .byt >heQuit

heUp
	lda HelpCursorY
.(
	beq skip1
	dec HelpCursorY
skip1	rts
.)

heDown	lda HelpPage
	asl
	asl
	sta hpTemp01
	asl
	sec
	adc hpTemp01
	adc HelpPage
	adc HelpCursorY
	ldx PreviousEditorID
	cmp EditorUltimateKey,x
.(
	beq skip1
	bcs skip2
skip1	lda HelpCursorY
	cmp #12
	bcs skip2
	inc HelpCursorY
skip2	rts
.)

hePageUp
	lda HelpPage
.(
	beq skip1
	dec HelpPage
	jsr ClearPatternArea
	jsr HelpPlot
skip1	rts
.)

hePageDown	;Around 50 keys max which is 4 pages
	lda HelpPage
	clc
	adc #1
	
	asl
	asl
	sta hpTemp01
	asl
	adc hpTemp01
	adc HelpPage
	ldx PreviousEditorID
	cmp EditorUltimateKey,x
.(
;	beq skip1
	bcs skip2
skip1	inc HelpPage
	jsr ClearPatternArea
	jsr HelpPlot
	ldy #00
	sty HelpCursorY
skip2	rts
.)
		
heChange
	lda HelpPage
	asl
	asl
	sta hpTemp01
	asl
	adc hpTemp01
	adc HelpPage
	adc HelpCursorY
	sta hpTemp01

	ldx #91
	jsr DisplayPrompt_Message
	jsr FlushInputBuffer
	jsr WaitOnKey
	;Does this key already exist?
	ldx PreviousEditorID
	ldy EditorHardKeyCodeTableLo,x
	sty hkey
	ldy EditorHardKeyCodeTableHi,x
	sty hkey+1
	ldy EditorUltimateKey,x
.(
loop1	cmp (hkey),y
	bne skip1
	ldx #92
	cpy hpTemp01
	bne skip2
skip1	dey
	bpl loop1
	;Change the key
	ldy hpTemp01
	sta (hkey),y
	jsr ClearPatternArea
	jsr HelpPlot
	ldx #93
skip2	jmp DisplayPrompt_Message
.)	

heQuit
	jsr RestorePatternArea
	jsr RestorePatternLegend
	jsr PatternPlot
	lda PreviousEditorID
	sta EditorID
	rts
