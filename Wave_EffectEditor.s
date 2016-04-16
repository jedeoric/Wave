;Effect Editor


EffectKeyDescriptionIDList
 .byt 8,9,77,14,15,67,18,19,20,22,23,55,56,57,58,59,65,60,38,39,75,63,64,62,27,28,30,31,32,34,35,36,37,73
 .byt 102
EffectKeyAreaIDList
 .dsb 11,78
 .dsb 9,81
 .byt 82
 .dsb 3,81
 .dsb 9,80
 .byt 82
 .byt 79

EffectKeyVectorLo
 .byt <ee_Up
 .byt <ee_Down
 .byt <GenericHelp 
 .byt <ee_PreviousEffect
 .byt <ee_NextEffect
 .byt <ee_Use
 .byt <ee_SwitchList
 .byt <ee_SwitchPattern
 .byt <ee_SwitchSample
 .byt <ee_SwitchOrnament
 .byt <ee_SwitchMenu
 .byt <ee_ToggleNoise
 .byt <ee_ToggleEG
 .byt <ee_ToneOff
 .byt <ee_SetPitch
 .byt <ee_SetVolume
 .byt <ee_LoopHere
 .byt <ee_SetEndLoop
 .byt <ee_Increment
 .byt <ee_Decrement
 .byt <TurnOffMusic
 .byt <ee_InsertGap
 .byt <ee_DeleteGap
 .byt <ee_Delete
 .byt <ee_HighlightUp
 .byt <ee_HighlightDown
 .byt <ee_Copy
 .byt <ee_Cut
 .byt <ee_Paste
 .byt <ee_Grab
 .byt <ee_Drop
 .byt <ee_CopyLast
 .byt <ee_CopyNext
 .byt <ee_Play
 .byt <ee_WipeEffect
EffectKeyVectorHi
 .byt >ee_Up
 .byt >ee_Down
 .byt >GenericHelp 
 .byt >ee_PreviousEffect
 .byt >ee_NextEffect
 .byt >ee_Use
 .byt >ee_SwitchList
 .byt >ee_SwitchPattern
 .byt >ee_SwitchSample
 .byt >ee_SwitchOrnament
 .byt >ee_SwitchMenu
 .byt >ee_ToggleNoise
 .byt >ee_ToggleEG
 .byt >ee_ToneOff
 .byt >ee_SetPitch
 .byt >ee_SetVolume
 .byt >ee_LoopHere
 .byt >ee_SetEndLoop
 .byt >ee_Increment
 .byt >ee_Decrement
 .byt >TurnOffMusic
 .byt >ee_InsertGap
 .byt >ee_DeleteGap
 .byt >ee_Delete
 .byt >ee_HighlightUp
 .byt >ee_HighlightDown
 .byt >ee_Copy
 .byt >ee_Cut
 .byt >ee_Paste
 .byt >ee_Grab
 .byt >ee_Drop
 .byt >ee_CopyLast
 .byt >ee_CopyNext
 .byt >ee_Play
 .byt >ee_WipeEffect
 
ee_WipeEffect
	jsr FetchEffectAddress
	ldy #31
	lda #00
.(
loop1	sta (effect),y
	dey
	bpl loop1	
.)
	ldx EffectID
	lda #128
	sta mmEffectLoops,x
	rts

ee_Up
	lda EffectCursorY
.(
	beq skip1
	dec EffectCursorY
skip2	rts
skip1	lda EffectBaseIndex
	beq skip2
.)
	dec EffectBaseIndex
	rts

ee_Down
	lda EffectCursorY
	cmp #7
.(
	bcs skip1
	inc EffectCursorY
skip2	rts
skip1	lda EffectBaseIndex
	cmp #31-7
	bcs skip2
.)
	inc EffectBaseIndex
	rts

ee_PreviousEffect
	;Prohibit switching if Effect invalid
	jsr ValidateEffectAndReport
	bcs ee_PreviousEffectSkip1
	lda EffectID
	beq ee_PreviousEffectSkip1
	dec EffectID
ee_PreviousEffectRent1
	lda #00
	sta EffectCursorY
	sta EffectBaseIndex
	jsr DisplayEffectID
ee_PreviousEffectSkip1
	rts

ee_NextEffect
	;Prohibit switching if Effect invalid
	jsr ValidateEffectAndReport
	bcs ee_PreviousEffectSkip1
	lda EffectID
	cmp #14
	bcs ee_PreviousEffectSkip1
	inc EffectID
	jmp ee_PreviousEffectRent1

ee_Use	;Switch to Pattern Editor and Insert this sample in the row
	ldy PatternCursorY
	jsr FetchPatternRowAddress
	;What channel are we on?
	ldy PatternCursorX
	ldx PatternX2Channel,y
	;Convert channel 0,1,2 to 3,6,9
	ldy Channel2EffectOffset,x
	lda (source),y
	and #$F0
	sta EffectTemp01
	lda EffectID
	clc
	adc #1
	ora EffectTemp01
	sta (source),y
	
	;Display it
	jsr PatternPlot
	
	;Now switch to PatternEditor
	jmp ee_SwitchPattern

Channel2EffectOffset
 .byt 3,6,9

ee_SwitchList
	lda #LISTEDITOR
ee_SwitchCommon
	pha
	jsr ValidateEffectAndReport
.(
	bcs skip1
	pla
	sta EditorID
	rts
skip1	pla
	rts
.)

ee_SwitchPattern
	lda #PATTERNEDITOR
	jmp ee_SwitchCommon

ee_SwitchOrnament
	lda #ORNAMENTEDITOR
	jmp ee_SwitchCommon

ee_SwitchSample
	lda #SAMPLEVIEWER
	jmp ee_SwitchCommon

ee_SwitchMenu
	lda #TOPMENU
	jmp ee_SwitchCommon


	
ee_ToggleNoise	;Toggle between Noise Off (1) and Set Noise (5)
	jsr TurnOffMusic
	jsr FetchEffectAddress
	lda (effect),y
	and #%00011111
	sta EffectTemp01
	lda (effect),y
	and #%11100000
	cmp #%00100000
.(
	beq skip1
	lda #%00100000
	ora EffectTemp01
	sta (effect),y
	rts
skip1	lda #%10100000
.)
ee_ToggleNoiseRent1
	ora EffectTemp01	
	sta (effect),y
	rts

ee_ToggleEG	;Toggle between EG Off (2) and Set EGPer (6)
	jsr TurnOffMusic
	jsr FetchEffectAddress
	lda (effect),y
	and #%00011111
	sta EffectTemp01
	lda (effect),y
	and #%11100000
	cmp #%01000000
.(
	beq skip1
	lda #%01000000
	ora EffectTemp01
	sta (effect),y
	rts
skip1	lda #%11000000
.)
	jmp ee_ToggleNoiseRent1

ee_SetEndLoop
	lda #0
	jmp ee_SetPitchRent1
	
ee_Drop
	lda Grabbed_EffectEntryByte
	jmp ee_SetPitchRent1

ee_ToneOff
	lda #%01100000
	jmp ee_SetPitchRent1

ee_SetPitch
	lda #32*7
ee_SetPitchRent1
	pha
	jsr TurnOffMusic
	jsr FetchEffectAddress
	pla
	sta (effect),y
	rts

ee_SetVolume
	lda #32*4
	jmp ee_SetPitchRent1

ee_LoopHere
	jsr TurnOffMusic
	ldx EffectID
	lda EffectCursorY
	clc
	adc EffectBaseIndex
	;If on same row as loop is already set then turn off looping
	cmp mmEffectLoops,x
.(
	bne skip1
	lda #128	
skip1	sta mmEffectLoops,x
.)
	rts
ee_Increment
	jsr TurnOffMusic
	jsr FetchEffectAddress
	lda (effect),y
	and #%11100000
	sta EffectTemp01
	lda (effect),y
	clc
	adc #1
	jmp ee_DecrementRent1
	
ee_Decrement
	jsr TurnOffMusic
	jsr FetchEffectAddress
	lda (effect),y
	and #%11100000
	sta EffectTemp01
	lda (effect),y
	sec
	sbc #1
ee_DecrementRent1
	and #31
	ora EffectTemp01
	sta (effect),y
	rts


ee_InsertGap
	jsr TurnOffMusic
	jsr FetchEffectAddress
	sta EffectTemp01
	ldy #30
.(
loop1	lda (effect),y
	iny
	sta (effect),y
	dey
	dey
	bmi skip1
	cpy EffectTemp01
	bcs loop1
skip1	ldy EffectTemp01
.)
	jmp ee_DeleteGapRent1

	
ee_DeleteGap
	jsr TurnOffMusic
	jsr FetchEffectAddress
.(
loop1	iny
	lda (effect),y
	dey
	sta (effect),y
	iny
	cpy #31
	bcc loop1
.)
	ldy #31
ee_DeleteGapRent1	
	lda #00
	sta (effect),y
	rts

ee_Delete
	jsr TurnOffMusic
	jsr FetchEffectAddress
	lda (effect),y
	and #%11100000
	ora #8*2
	sta (effect),y
	rts

ee_HighlightUp
	;Cannot begin to highlight by highlighting up
	lda eeHighlightingFlag
.(
	beq skip1
	jsr ee_Up
	;Recede highlight end to next entry
	lda EffectBaseIndex
	clc
	adc EffectCursorY
	cmp eeHighlightStartY
	bcs skip1
	;Turn off highlighting
	lda #00
	sta eeHighlightingFlag
skip1	dec eeHighlightEndY
.)
	rts
	
eeHighlightingFlag	.byt 0
eeHighlightStartY   .byt 0
eeHighlightEndY     .byt 0

ee_HighlightDown
	lda eeHighlightingFlag
	bne eeContinueHighlightingDown
eeInitialiseHighlighting
	;Allign Highlight to Channel group start
	lda EffectBaseIndex
	clc
	adc EffectCursorY
	sta eeHighlightStartY
	sta eeHighlightEndY
	lda #EFFECTEDITOR
	sta CopyBufferContents
	lda #1
	sta eeHighlightingFlag
	rts

eeContinueHighlightingDown
	;Move List Cursor Right
	jsr ee_Down
	lda EffectBaseIndex
	clc
	adc EffectCursorY
	sta eeHighlightEndY
	rts

ee_Copy
	lda eeHighlightingFlag
.(
	beq skip1
	jsr FetchEffectAddress
	ldy eeHighlightStartY
	ldx #00
loop1	lda (effect),y
	sta CopyBuffer,x
	inx
	iny
	cpy eeHighlightEndY
	beq loop1
	bcc loop1
	lda #00
	sta eeHighlightingFlag
	lda #EFFECTEDITOR
	sta CopyBufferContents
skip1	rts
.)	

ee_Cut
	jsr TurnOffMusic
	lda eeHighlightingFlag
.(
	beq skip1
	jsr FetchEffectAddress
	ldy eeHighlightStartY
	ldx #00
loop1	lda (effect),y
	sta CopyBuffer,x
	lda #00
	sta (effect),y
	inx
	iny
	cpy eeHighlightEndY
	beq loop1
	bcc loop1
	lda #00
	sta eeHighlightingFlag
	lda #EFFECTEDITOR
	sta CopyBufferContents
skip1	rts
.)	

ee_Paste
	jsr TurnOffMusic
	lda CopyBufferContents
	cmp #EFFECTEDITOR
.(
	bne skip1
	lda eeHighlightEndY
	sec
	sbc eeHighlightStartY
	sta EffectTemp01
	jsr FetchEffectAddress
	ldx #00
	
loop1	lda CopyBuffer,x
	sta (effect),y
	
	iny
	cpy #32
	bcs skip1
	
	inx
	cpx EffectTemp01
	beq loop1
	bcc loop1
skip1	rts
.)


ee_Grab
	jsr FetchEffectAddress
	lda (effect),y
	sta Grabbed_EffectEntryByte
DisplayGrabbedEffectEntry
	lda #<$BB80+24+40*18
	sta screen
	lda #>$BB80+24+40*18
	sta screen+1
	lda #"G"+128
	ldy #00
	sta (screen),y
	jsr FetchEffectAddress
	tya
	ldy #01
	ldx #128
	jmp Display2DD

	
ee_CopyLast
	jsr TurnOffMusic
	jsr FetchEffectAddress
	sty EffectTemp01
	beq ee_CopySkip1
	ldy EffectCursorY
	dey
ee_CopyRent1
	tya
	clc
	adc EffectBaseIndex
	tay
	lda (effect),y
	ldy EffectTemp01
	sta (effect),y
ee_CopySkip1
	rts


ee_CopyNext
	jsr TurnOffMusic
	jsr FetchEffectAddress
	sty EffectTemp01
	cmp #31
	beq ee_CopySkip1
	ldy EffectCursorY
	iny
	jmp ee_CopyRent1

ee_Play
	jsr ValidateEffectAndReport
.(
	bcs skip3
	
	sei
	
	;Ensure music is stopped
	lda #00
	sta pzMusicElementActivity
	sta pzPatternRowPlayFlag
	sta pbFlag
	sta pmEffectIndex
	
	;Use this effect
	lda EffectID
	sta pmEffectID
	
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
	;Turn on Effect A
	lda #1
	sta pzMusicElementActivity
	cli
skip3	rts
.)



ValidateEffectAndReport
	jsr ValidateEffect
.(
	bcc skip3
	ldx #94
	jsr DisplayPrompt_Message
	sec
	rts
skip3	ldx #95
.)
	jsr DisplayPrompt_Message
	clc
	rts

ValidateEffect
	;Ensure a loop contains at least one Volume or EGPER event
	ldx EffectID
	clc
	lda mmEffectLoops,x
.(
	bmi skip3
	
	lda pmEffectAddressLo,x
	sta source
	lda pmEffectAddressHi,x
	sta source+1
	ldy #00
loop1	lda (source),y
	and #%11100000
	beq skip2
	cmp #%11000000
	beq skip4
	cmp #%10000000
	bne skip1
skip4	sty LastVolumeIndex
skip1	iny
	cpy #31
	bcc loop1
skip2	ldx EffectID
	lda mmEffectLoops,x
	cmp LastVolumeIndex
	;Carry Clear Ok
skip3	rts
.)

	
	
	