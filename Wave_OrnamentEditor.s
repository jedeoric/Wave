;Ornament Editor

OrnamentTemp01
 .byt 0
OrnamentKeyDescriptionIDList
 .byt 8,9,77,16,17,68,18,19,20,21,23,65,38,39,61,63,64,62,60,27,28,30,31,32,34,35,36,37,74,75,103
OrnamentKeyAreaIDList
 .dsb 11,78
 .dsb 8,81
 .dsb 9,80
 .dsb 2,82
 .byt 79

OrnamentKeyVectorLo
 .byt <oe_Up
 .byt <oe_Down
 .byt <GenericHelp 
 .byt <oe_PreviousOrnament
 .byt <oe_NextOrnament
 .byt <oe_Use
 .byt <oe_SwitchList
 .byt <oe_SwitchPattern
 .byt <oe_SwitchSample
 .byt <oe_SwitchEffect
 .byt <oe_SwitchMenu
 .byt <oe_LoopHere
 .byt <oe_Increment
 .byt <oe_Decrement
 .byt <oe_ToggleSign
 .byt <oe_InsertGap
 .byt <oe_DeleteGap
 .byt <oe_Delete
 .byt <oe_End
 .byt <oe_HighlightUp
 .byt <oe_HighlightDown
 .byt <oe_Copy
 .byt <oe_Cut
 .byt <oe_Paste
 .byt <oe_Grab
 .byt <oe_Drop
 .byt <oe_CopyLast
 .byt <oe_CopyNext
 .byt <oe_Play
 .byt <TurnOffMusic
 .byt <oe_WipeOrnament
OrnamentKeyVectorHi
 .byt >oe_Up
 .byt >oe_Down
 .byt >GenericHelp 
 .byt >oe_PreviousOrnament
 .byt >oe_NextOrnament
 .byt >oe_Use
 .byt >oe_SwitchList
 .byt >oe_SwitchPattern
 .byt >oe_SwitchSample
 .byt >oe_SwitchEffect
 .byt >oe_SwitchMenu
 .byt >oe_LoopHere
 .byt >oe_Increment
 .byt >oe_Decrement
 .byt >oe_ToggleSign
 .byt >oe_InsertGap
 .byt >oe_DeleteGap
 .byt >oe_Delete
 .byt >oe_End
 .byt >oe_HighlightUp
 .byt >oe_HighlightDown
 .byt >oe_Copy
 .byt >oe_Cut
 .byt >oe_Paste
 .byt >oe_Grab
 .byt >oe_Drop
 .byt >oe_CopyLast
 .byt >oe_CopyNext
 .byt >oe_Play
 .byt >TurnOffMusic
 .byt >oe_WipeOrnament

oe_WipeOrnament
	jsr FetchOrnamentAddress
	ldy #31
	lda #00
.(
loop1	sta (ornament),y
	dey
	bpl loop1
.)
	ldx OrnamentID
	lda #128
	sta mmOrnamentLoops,x
	rts
	

oe_Up              	;UP
	lda OrnamentCursorY
.(
	beq skip1
	dec OrnamentCursorY
rent1	rts
skip1	lda OrnamentBaseIndex
	beq rent1
.)
	dec OrnamentBaseIndex
	rts

oe_Down            	;DOWN
	lda OrnamentCursorY
	cmp #7
.(
	bcs skip1
	inc OrnamentCursorY
rent1	rts
skip1	lda OrnamentBaseIndex
	cmp #31-7
	bcs rent1
.)
	inc OrnamentBaseIndex
	rts

oe_PreviousOrnament	;CTRL+-
	jsr ValidateOrnamentAndReport
.(
	bcs skip1
	lda OrnamentID
	beq skip1
	dec OrnamentID
	jsr DisplayOrnamentID
skip1	rts
.)
	
oe_NextOrnament    	;CTRL+=
	jsr ValidateOrnamentAndReport
.(
	bcs skip1
	lda OrnamentID
	cmp #14
	bcs skip1
	inc OrnamentID
	jsr DisplayOrnamentID
skip1	rts
.)

oe_Use    ;Switch to Pattern Editor and Insert this Ornament in the row
	ldy PatternCursorY
	jsr FetchPatternRowAddress
	;What channel are we on?
	ldy PatternCursorX
	ldx PatternX2Channel,y
	;Convert channel 0,1,2 to 3,6,9
	ldy Channel2EffectOffset,x
	lda (source),y
	and #15
	sta OrnamentTemp01
	lda OrnamentID
	clc
	adc #1
	asl
	asl
	asl
	asl
	ora OrnamentTemp01
	sta (source),y
	
	;Display it
	jsr PatternPlot
	
	;Now switch to PatternEditor
	jmp oe_SwitchPattern

oe_SwitchList
	jsr ValidateOrnamentAndReport
.(
	bcs skip1
	lda #LISTEDITOR
	sta EditorID
skip1	rts
.)

oe_SwitchPattern
	jsr ValidateOrnamentAndReport
.(
	bcs skip1
	lda #PATTERNEDITOR
	sta EditorID
skip1	rts
.)

oe_SwitchEffect
	jsr ValidateOrnamentAndReport
.(
	bcs skip1
	lda #EFFECTEDITOR
	sta EditorID
skip1	rts
.)

oe_SwitchSample
	jsr ValidateOrnamentAndReport
.(
	bcs skip1
	lda #SAMPLEVIEWER
	sta EditorID
skip1	rts
.)

oe_SwitchMenu
	jsr ValidateOrnamentAndReport
.(
	bcs skip1
	lda #TOPMENU
	sta EditorID
skip1	rts
.)


oe_LoopHere        	;SHFT+L
	jsr TurnOffMusic
	ldy OrnamentID
	lda OrnamentBaseIndex
	clc
	adc OrnamentCursorY
	cmp mmOrnamentLoops,y
.(
	bne skip1
	lda #128	
skip1	sta mmOrnamentLoops,y
.)
	rts

oe_End
	jsr TurnOffMusic
	jsr FetchOrnamentAddress
	lda OrnamentBaseIndex
	clc
	adc OrnamentCursorY
	tay
	lda #00
	sta (ornament),y
	rts
	
	
oe_Increment       	;=
	jsr TurnOffMusic
	jsr FetchOrnamentAddress
	lda OrnamentBaseIndex
	clc
	adc OrnamentCursorY
	tay
	lda (ornament),y
	adc #1
	sta (ornament),y
	rts
	
oe_Decrement       	;-
	jsr TurnOffMusic
	jsr FetchOrnamentAddress
	lda OrnamentBaseIndex
	clc
	adc OrnamentCursorY
	tay
	lda (ornament),y
	sec
	sbc #1
	sta (ornament),y
	rts

oe_ToggleSign      	;SPACE
	jsr TurnOffMusic
	jsr FetchOrnamentAddress
	lda OrnamentBaseIndex
	clc
	adc OrnamentCursorY
	tay
	lda (ornament),y
	eor #128
	sta (ornament),y
	rts
	
oe_InsertGap       	;I
	jsr TurnOffMusic
	jsr FetchOrnamentAddress
	lda OrnamentBaseIndex
	clc
	adc OrnamentCursorY
	cmp #31
.(
	bcs skip1
	sta OrnamentTemp01
	ldy #30
loop1	lda (ornament),y
	iny
	sta (ornament),y
	dey
	dey
	bmi skip2
	cpy OrnamentTemp01
	bcs loop1
skip2	ldy OrnamentTemp01
	lda #00
	sta (ornament),y
skip1	rts
.)

oe_DeleteGap       	;D
	jsr TurnOffMusic
	jsr FetchOrnamentAddress
	lda OrnamentBaseIndex
	clc
	adc OrnamentCursorY
	tay
.(
loop1	iny
	lda (ornament),y
	dey
	sta (ornament),y
	iny
	cpy #32
	bcc loop1
	ldy #31
	lda #00
	sta (ornament),y
skip1	rts
.)

oe_Delete          	;DEL
	jsr TurnOffMusic
	jsr FetchOrnamentAddress
	lda OrnamentBaseIndex
	clc
	adc OrnamentCursorY
	tay
	lda #128
	sta (ornament),y
	rts

oe_HighlightUp     	;SHFT+UP
oe_HighlightDown   	;SHFT+DOWN
oe_Copy            	;CTRL+C
oe_Cut             	;CTRL+X
oe_Paste           	;CTRL+V
oe_Grab            	;J
oe_Drop            	;K
	rts

oe_CopyLast        	;L
	jsr TurnOffMusic
	jsr FetchOrnamentAddress
	lda OrnamentBaseIndex
	clc
	adc OrnamentCursorY
.(
	beq skip1
	tay
	dey
	lda (ornament),y
	iny
	sta (ornament),y
skip1	rts
.)

oe_CopyNext        	;N
	jsr TurnOffMusic
	jsr FetchOrnamentAddress
	lda OrnamentBaseIndex
	clc
	adc OrnamentCursorY
.(
	beq skip1
	tay
	iny
	lda (ornament),y
	dey
	sta (ornament),y
skip1	rts
.)

oe_Play            	;RETURN
	jsr ValidateOrnamentAndReport
.(
	bcs skip3
	sei
	
	;Ensure music is stopped
	lda #00
	sta pzMusicElementActivity
	sta pzPatternRowPlayFlag
	sta pbFlag
	sta pmEffectIndex
	sta pmOrnamentIndex
	
	;Use Effect 15
	lda #15
	sta pmEffectID
	;Use this Ornament
	lda OrnamentID
	sta pmOrnamentID
	
	;If Current Pattern Channel holds note then use that otherwise C-3
	ldy PatternCursorY
	jsr FetchPatternRowAddress
	ldx PatternCursorX
	ldy PatternX2ChannelsNoteOffset,x
	lda (source),y
	lsr
	lsr
	cmp #62
	bcc skip1
	lda #36
	sta pmPatternNote
	lda #15
	sta pmPatternVolume
	jmp skip2
skip1	sta pmPatternNote
	
	;Use volume
	lda (source),y
	and #3
	tax
	lda pmEntriesRealVolume,x
	sta pmPatternVolume
skip2
	;Turn on Effect A and Ornament A
	lda #%00001001
	sta pzMusicElementActivity
;twi999	nop
;	jmp twi999
	cli
skip3	rts
.)

ValidateOrnamentAndReport
	jsr ValidateOrnament
.(
	bcc skip3
	ldx #97
	jsr DisplayPrompt_Message
	sec
	rts
skip3	ldx #96
.)
	jsr DisplayPrompt_Message
	clc
	rts

ValidateOrnament
	;Only one case needs to be cared for
	;and that is where Loop is set to a row that contains an End
	ldx EffectID
	ldy mmOrnamentLoops,x
.(
	bmi skip1
	lda pmOrnamentAddressLo,x
	sta source
	lda pmOrnamentAddressHi,x
	sta source+1
	lda (source),y
	cmp #00
	beq skip2
skip1	clc
skip2	rts
.)
	