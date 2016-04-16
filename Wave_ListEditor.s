;List Editor

ListKeyDescriptionIDList
 .byt 6,7,77,19,20,21,22,23
 .byt 25,26,30,32,34,35,36,37
 .byt 38,39,62,63,64,65,60,69,86
 .byt 100,75
ListKeyAreaIDList
 .dsb 8,78
 .dsb 8,80
 .dsb 7,79
 .dsb 2,82
 .byt 79,82


ListKeyVectorLo
 .byt <le_Left
 .byt <le_Right
 .byt <GenericHelp 
 .byt <le_SwitchPattern
 .byt <le_SwitchSample
 .byt <le_SwitchEffect
 .byt <le_SwitchOrnament
 .byt <le_SwitchMenu
 .byt <le_HighlightLeft
 .byt <le_HighlightRight
 .byt <le_Copy
 .byt <le_Paste
 .byt <le_Grab
 .byt <le_Drop
 .byt <le_CopyLast
 .byt <le_CopyNext
 .byt <le_Increment
 .byt <le_Decrement
 .byt <le_Delete
 .byt <le_InsertGap
 .byt <le_DeleteGap
 .byt <le_LoopHere
 .byt <le_EndHere
 .byt <le_PlayPattern
 .byt <le_PlayMusic
 .byt <le_WipeList
 .byt <TurnOffMusic

ListKeyVectorHi
 .byt >le_Left
 .byt >le_Right
 .byt >GenericHelp 
 .byt >le_SwitchPattern
 .byt >le_SwitchSample
 .byt >le_SwitchEffect
 .byt >le_SwitchOrnament
 .byt >le_SwitchMenu
 .byt >le_HighlightLeft
 .byt >le_HighlightRight
 .byt >le_Copy
 .byt >le_Paste
 .byt >le_Grab
 .byt >le_Drop
 .byt >le_CopyLast
 .byt >le_CopyNext
 .byt >le_Increment
 .byt >le_Decrement
 .byt >le_Delete
 .byt >le_InsertGap
 .byt >le_DeleteGap
 .byt >le_LoopHere
 .byt >le_EndHere
 .byt >le_PlayPattern
 .byt >le_PlayMusic
 .byt >le_WipeList
 .byt >TurnOffMusic

le_WipeList
	lda #128
	sta mmListHeader
	jmp EraseListMemory
	

le_Left
	lda ListCursorX
.(
	beq skip1
	dec ListCursorX
skip2	rts
skip1	lda ListCursorBase
	beq skip2
.)
	dec ListCursorBase
	rts
le_Right
	lda ListCursorX
	cmp #9
.(
	bcs skip1
	inc ListCursorX
skip2	rts
skip1	lda ListCursorBase
	cmp #127-9
	bcs skip2
.)
	inc ListCursorBase
	rts
le_SwitchOrnament
	lda #ORNAMENTEDITOR
	sta EditorID
	rts
le_SwitchPattern
	;Set Pattern to selected list entry Pattern
	lda ListCursorBase
	clc
	adc ListCursorX
	tax
	lda mmListMemory,x
.(
	bmi skip1
	sta PatternID
 	jsr DisplayPatternID
 	jsr PatternPlot
	lda #PATTERNEDITOR
	sta EditorID
skip1	rts
.)

le_SwitchEffect
	lda #EFFECTEDITOR
	sta EditorID
	rts
le_SwitchSample
	lda #SAMPLEVIEWER
	sta EditorID
	rts
le_SwitchMenu
	lda #TOPMENU
	sta EditorID
	rts

le_HighlightLeft
	;Cannot begin to highlight by highlighting left
	lda leHighlightingFlag
.(
	beq skip1
	jsr le_Left
	;Recede highlight end to next entry
	lda ListCursorBase
	clc
	adc ListCursorX
	cmp leHighlightStartX
	bcs skip1
	;Turn off highlighting
	lda #00
	sta leHighlightingFlag
skip1	dec leHighlightEndX
.)
	rts
	
leHighlightingFlag	.byt 0
leHighlightStartX   .byt 0
leHighlightEndX     .byt 0

le_HighlightRight
	lda leHighlightingFlag
	bne leContinueHighlightingRight
leInitialiseHighlighting
	;Allign Highlight to Channel group start
	lda ListCursorBase
	clc
	adc ListCursorX
	sta leHighlightStartX
	sta leHighlightEndX
	lda #128
	sta CopyBufferContents
	lda #1
	sta leHighlightingFlag
	rts

leContinueHighlightingRight
	;Move List Cursor Right
	jsr le_Right
	lda ListCursorBase
	clc
	adc ListCursorX
	sta leHighlightEndX
	rts

le_Copy
	lda leHighlightingFlag
.(
	beq skip1
	ldy #00
	ldx leHighlightStartX
loop1	lda mmListMemory,x
	sta CopyBuffer,y
	inx
	iny
	cpx leHighlightEndX
	beq loop1
	bcc loop1
	lda #00
	sta leHighlightingFlag
	lda #LISTEDITOR
	sta CopyBufferContents
skip1	rts
.)	
	
le_Paste
	lda CopyBufferContents
	cmp #LISTEDITOR
.(
	bne skip1
	lda leHighlightEndX
	sec
	sbc leHighlightStartX
	sta leTemp01
	lda ListCursorBase
	clc
	adc ListCursorX
	tax
	ldy #00
	
loop1	lda CopyBuffer,y
	sta mmListMemory,x
	
	inx
	bmi skip1
	
	iny
	cpy leTemp01
	beq loop1
	bcc loop1
skip1	rts
.)

le_Grab
	lda ListCursorBase
	clc
	adc ListCursorX
	tax
	lda mmListMemory,x
	sta Grabbed_ListEntryByte
DisplayGrabbedListEntry
	ldx #<$BB80+36+40*1
	stx screen
	ldx #>$BB80+36+40*1
	stx screen+1
	ldy #00
	pha
	lda #"P"+128
	sta (screen),y
	iny
	pla
	ldx #128
	jmp Display2DD
	
le_Drop
	lda ListCursorBase
	clc
	adc ListCursorX
	tax
	lda Grabbed_ListEntryByte
.(
	bmi skip1
	sta mmListMemory,x
skip1	rts
.)
	
le_CopyLast
	lda ListCursorBase
	clc
	adc ListCursorX
.(
	beq skip1
	tax
	lda mmListMemory-1,x
	sta mmListMemory,x
skip1	rts
.)

le_CopyNext
	lda ListCursorBase
	clc
	adc ListCursorX
	cmp #127
.(
	beq skip1
	tax
	lda mmListMemory+1,x
	sta mmListMemory,x
skip1	rts
.)
	

le_Increment
	lda ListCursorBase
	clc
	adc ListCursorX
	tax
	lda mmListMemory,x
	cmp #34
.(
	bcs skip1
	
	clc
	adc #1
	sta mmListMemory,x
	cmp mmUltimatePattern
	bcc skip1
	sta mmUltimatePattern
skip1	rts	
.)

le_Decrement
	lda ListCursorBase
	clc
	adc ListCursorX
	tax
	lda mmListMemory,x
.(
	beq skip1
	dec mmListMemory,x
skip1	rts
.)

le_Delete
	lda ListCursorBase
	clc
	adc ListCursorX
	tax
	lda #00
	sta mmListMemory,x
	rts

le_InsertGap
	lda ListCursorBase
	clc
	adc ListCursorX
	sta leTemp01
	ldx #126
.(
loop1	lda mmListMemory,x
	sta mmListMemory+1,x
	dex
	cpx leTemp01
	bcs loop1
.)
	ldx leTemp01
	lda #00
	sta mmListMemory,x
	rts
	
le_DeleteGap
	lda ListCursorBase
	clc
	adc ListCursorX
	tax
.(
loop1	lda mmListMemory+1,x
	sta mmListMemory,x
	inx
	bpl loop1
.)
	lda #00
	sta mmListMemory+127
	rts
le_EndHere
	lda ListCursorBase
	clc
	adc ListCursorX
	tax
	lda #128
	sta mmListMemory,x
	rts
	

le_LoopHere
	lda ListCursorBase
	clc
	adc ListCursorX
	sta mmListHeader
	rts

le_PlayPattern
	;Ensure music is stopped
	lda #00
	sta pzMusicElementActivity
	sta pzPatternRowPlayFlag
	;Calculate pattern row address
	sei
	lda ListCursorBase
	clc
	adc ListCursorX
	tax
	ldy mmListMemory,x
	lda PatternAddressLo,y
	sta pmPattern
	lda PatternAddressHi,y
	sta pmPattern+1
	;Call ProcPattern for single row execution
	lda #64
	sta pzPatternRowCounter
	sta pzMusicElementActivity
	cli
	rts

le_PlayMusic
	jmp CommencePlayFromList

