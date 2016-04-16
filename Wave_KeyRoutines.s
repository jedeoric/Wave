;Wave_KeyRoutines.s

CommonControl
	jsr RefreshEditor
CommonLoop
	ldx EditorID
	lda EditorCursorPlotRoutineLo,x
.(
	sta vector1+1
	lda EditorCursorPlotRoutineHi,x
	sta vector1+2
vector1	jsr $dead
	
loop1	jsr CommonInkey
	sta CompositeKey
;twi999	nop
;	jmp twi999
	;If in help editor wipe the cursor
	ldx EditorID
	cpx #HELPEDITOR
	bne skip3
	jsr DeleteHelpCursor
	
skip3	;Switch off Pattern highlighting when no soft key
	lda CompositeKey
;	ldx EditorID
;	cpx #1
;	bne skip2
	and #%11000000
	bne skip2
	lda #00
	sta peHighlightingFlag
	sta leHighlightingFlag
	sta eeHighlightingFlag
	
skip2	ldy EditorHardKeyCodeTableLo,x
	sty hkey
	ldy EditorHardKeyCodeTableHi,x
	sty hkey+1
	ldy EditorKeyCodeTableLoVectorLo,x
	sty vectorlo
	ldy EditorKeyCodeTableLoVectorHi,x
	sty vectorlo+1
	ldy EditorKeyCodeTableHiVectorLo,x
	sty vectorhi
	ldy EditorKeyCodeTableHiVectorHi,x
	sty vectorhi+1
	
	ldy EditorUltimateKey,x
	
loop2	lda (hkey),y
	cmp CompositeKey
	beq skip1
	dey
	bpl loop2
	jmp CommonLoop
	
skip1	lda (vectorlo),y
	sta vector3+1
	lda (vectorhi),y
	sta vector3+2
	lda EditorID
	sta OldEditorID
vector3	jsr $dead
.)
	ldx EditorID
	cpx OldEditorID
.(
	beq skip1
	cpx #HELPEDITOR
	beq skip1
	jsr DisplayPrompt_Message
	;Delete old cursor
	ldx OldEditorID
	jsr RefreshEditor2
	jmp CommonLoop
skip1	jsr RefreshEditor
.)
	jmp CommonLoop

RefreshEditor
	ldx EditorID
RefreshEditor2
	lda EditorRefreshRoutineLo,x
.(
	sta vector4+1
	lda EditorRefreshRoutineHi,x
	beq skip1
	sta vector4+2

vector4	jmp $DEAD
skip1	rts
.)


HardKey	.byt 0
EditorCursorPlotRoutineLo
 .byt <ListCursorPlot	;LISTEDITOR	0
 .byt <PatternCursorPlot	;PATTERNEDITOR	1
 .byt <OrnamentCursorPlot	;ORNAMENTEDITOR	2
 .byt <EffectCursorPlot	;EffectEDITOR	3
 .byt <SampleCursorPlot	;SAMPLEVIEWER	4
 .byt <MenuCursorPlot	;TOPMENU		5
 .byt <HelpCursorPlot	;HELPEDITOR	6
EditorCursorPlotRoutineHi
 .byt >ListCursorPlot	;LISTEDITOR	0
 .byt >PatternCursorPlot	;PATTERNEDITOR	1
 .byt >OrnamentCursorPlot	;ORNAMENTEDITOR	2
 .byt >EffectCursorPlot	;EffectEDITOR	3
 .byt >SampleCursorPlot	;SAMPLEVIEWER	4
 .byt >MenuCursorPlot	;TOPMENU		5
 .byt >HelpCursorPlot	;HELPEDITOR	6
EditorRefreshRoutineLo
 .byt <ListPlot		;LISTEDITOR	0
 .byt <PatternPlot		;PATTERNEDITOR	1
 .byt <OrnamentPlot		;ORNAMENTEDITOR	2
 .byt <EffectPlot		;EffectEDITOR	3
 .byt <SamplePlot		;SAMPLEVIEWER	4
 .byt <MenuPlot		;TOPMENU		5
 .byt 0			;HELPEDITOR	6
EditorRefreshRoutineHi
 .byt >ListPlot		;LISTEDITOR	0
 .byt >PatternPlot		;PATTERNEDITOR	1
 .byt >OrnamentPlot		;ORNAMENTEDITOR	2
 .byt >EffectPlot		;EffectEDITOR	3
 .byt >SamplePlot		;SAMPLEVIEWER	4
 .byt >MenuPlot		;TOPMENU		5
 .byt 0			;HELPEDITOR	6
EditorUltimateKey
 .byt 26			;LISTEDITOR	0
 .byt 54			;PATTERNEDITOR	1
 .byt 30			;ORNAMENTEDITOR	2
 .byt 34			;EFFECTEDITOR	3
 .byt 10			;SAMPLEVIEWER	4
 .byt 6			;TOPMENU		5
 .byt 5			;HELPEDITOR	6
EditorHardKeyCodeTableLo
 .byt <mmListHardKeys	;LISTEDITOR	0
 .byt <mmPatternHardKeys	;PATTERNEDITOR	1
 .byt <mmOrnamentHardKeys	;ORNAMENTEDITOR	2
 .byt <mmEffectHardKeys	;EffectEDITOR	3
 .byt <mmSampleHardKeys	;SAMPLEVIEWER	4
 .byt <mmMenuHardKeys	;TOPMENU		5
 .byt <HelpHardKeys		;HELPEDITOR	6
EditorHardKeyCodeTableHi
 .byt >mmListHardKeys	;LISTEDITOR	0
 .byt >mmPatternHardKeys	;PATTERNEDITOR	1
 .byt >mmOrnamentHardKeys	;ORNAMENTEDITOR	2
 .byt >mmEffectHardKeys	;EffectEDITOR	3
 .byt >mmSampleHardKeys	;SAMPLEVIEWER	4
 .byt >mmMenuHardKeys	;TOPMENU		5
 .byt >HelpHardKeys		;HELPEDITOR	6
EditorKeyCodeTableLoVectorLo
 .byt <ListKeyVectorLo
 .byt <PatternKeyVectorLo
 .byt <OrnamentKeyVectorLo
 .byt <EffectKeyVectorLo
 .byt <SampleKeyVectorLo
 .byt <MenuKeyVectorLo
 .byt <HelpKeyVectorLo
EditorKeyCodeTableLoVectorHi
 .byt >ListKeyVectorLo
 .byt >PatternKeyVectorLo
 .byt >OrnamentKeyVectorLo
 .byt >EffectKeyVectorLo
 .byt >SampleKeyVectorLo
 .byt >MenuKeyVectorLo
 .byt >HelpKeyVectorLo
EditorKeyCodeTableHiVectorLo
 .byt <ListKeyVectorHi
 .byt <PatternKeyVectorHi
 .byt <OrnamentKeyVectorHi
 .byt <EffectKeyVectorHi
 .byt <SampleKeyVectorHi
 .byt <MenuKeyVectorHi
 .byt <HelpKeyVectorHi
EditorKeyCodeTableHiVectorHi
 .byt >ListKeyVectorHi
 .byt >PatternKeyVectorHi
 .byt >OrnamentKeyVectorHi
 .byt >EffectKeyVectorHi
 .byt >SampleKeyVectorHi
 .byt >MenuKeyVectorHi
 .byt >HelpKeyVectorHi
EditorKeyDescriptionIDListLo
 .byt <ListKeyDescriptionIDList
 .byt <PatternKeyDescriptionIDList
 .byt <OrnamentKeyDescriptionIDList
 .byt <EffectKeyDescriptionIDList
 .byt <SampleKeyDescriptionIDList
 .byt <MenuKeyDescriptionIDList
EditorKeyDescriptionIDListHi
 .byt >ListKeyDescriptionIDList
 .byt >PatternKeyDescriptionIDList
 .byt >OrnamentKeyDescriptionIDList
 .byt >EffectKeyDescriptionIDList
 .byt >SampleKeyDescriptionIDList
 .byt >MenuKeyDescriptionIDList
EditorKeyAreaIDListLo
 .byt <ListKeyAreaIDList
 .byt <PatternKeyAreaIDList
 .byt <OrnamentKeyAreaIDList
 .byt <EffectKeyAreaIDList
 .byt <SampleKeyAreaIDList
 .byt <MenuKeyAreaIDList
EditorKeyAreaIDListHi
 .byt >ListKeyAreaIDList
 .byt >PatternKeyAreaIDList
 .byt >OrnamentKeyAreaIDList
 .byt >EffectKeyAreaIDList
 .byt >SampleKeyAreaIDList
 .byt >MenuKeyAreaIDList

	