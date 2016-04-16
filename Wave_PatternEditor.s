;Wave_PatternEditor.s
peTemp01
 .byt 0
fpfTempX
 .byt 0
fpfTempY
 .byt 0
OldEditorID
 .byt 0

PatternKeyDescriptionIDList
 .byt 6,7,9,8,77,10,11,12,13,88,89,18,20,21,22,23
 .byt 25,26,28,27,29,30,31,32,33,34,35,36,37
 .byt 38,39,63,64,62
 .byt 46,46,46,46,46,46,46,53,53,53,53,53,53,53,54
 .byt 71,69,70,76,75,101
 
PatternKeyAreaIDList
 .dsb 16,78
 .dsb 13,80
 .dsb 5,79
 .dsb 15,81
 .dsb 82,82,82,79,82
 .byt 79
PatternKeyVectorLo
 .byt <pe_Left
 .byt <pe_Right
 .byt <pe_Down
 .byt <pe_Up
 .byt <GenericHelp 
 .byt <pe_TrackLeft
 .byt <pe_TrackRight
 .byt <pe_PageUp
 .byt <pe_PageDown
 .byt <pe_PreviousPattern
 .byt <pe_NextPattern
 .byt <pe_SwitchList
 .byt <pe_SwitchSample
 .byt <pe_SwitchEffect
 .byt <pe_SwitchOrnament
 .byt <pe_SwitchMenu
 .byt <pe_HighlightLeft
 .byt <pe_HighlightRight
 .byt <pe_HighlightDown
 .byt <pe_HighlightUp
 .byt <pe_HighlightAll
 .byt <pe_Copy
 .byt <pe_Cut
 .byt <pe_Paste
 .byt <pe_Merge
 .byt <pe_Grab
 .byt <pe_Drop
 .byt <pe_CopyLast
 .byt <pe_CopyNext
 .byt <pe_Increment
 .byt <pe_Decrement
 .byt <pe_InsertGap
 .byt <pe_DeleteGap
 .byt <pe_Delete
 .byt <pe_Octave
 .byt <pe_Octave
 .byt <pe_Octave
 .byt <pe_Octave
 .byt <pe_Octave
 .byt <pe_Octave
 .byt <pe_Octave
 .byt <pe_Note
 .byt <pe_Note
 .byt <pe_Note
 .byt <pe_Note
 .byt <pe_Note
 .byt <pe_Note
 .byt <pe_Note
 .byt <pe_Bar
 .byt <pe_PlayRow
 .byt <pe_PlayPattern
 .byt <pe_PlayMusic
 .byt <pe_DuplicatePattern
 .byt <TurnOffMusic
 .byt <pe_WipePattern
PatternKeyVectorHi
 .byt >pe_Left
 .byt >pe_Right
 .byt >pe_Down
 .byt >pe_Up
 .byt >GenericHelp 
 .byt >pe_TrackLeft
 .byt >pe_TrackRight
 .byt >pe_PageUp
 .byt >pe_PageDown
 .byt >pe_PreviousPattern
 .byt >pe_NextPattern
 .byt >pe_SwitchList
 .byt >pe_SwitchSample
 .byt >pe_SwitchEffect
 .byt >pe_SwitchOrnament
 .byt >pe_SwitchMenu
 .byt >pe_HighlightLeft
 .byt >pe_HighlightRight
 .byt >pe_HighlightDown
 .byt >pe_HighlightUp
 .byt >pe_HighlightAll
 .byt >pe_Copy
 .byt >pe_Cut
 .byt >pe_Paste
 .byt >pe_Merge
 .byt >pe_Grab
 .byt >pe_Drop
 .byt >pe_CopyLast
 .byt >pe_CopyNext
 .byt >pe_Increment
 .byt >pe_Decrement
 .byt >pe_InsertGap
 .byt >pe_DeleteGap
 .byt >pe_Delete
 .byt >pe_Octave
 .byt >pe_Octave
 .byt >pe_Octave
 .byt >pe_Octave
 .byt >pe_Octave
 .byt >pe_Octave
 .byt >pe_Octave
 .byt >pe_Note
 .byt >pe_Note
 .byt >pe_Note
 .byt >pe_Note
 .byt >pe_Note
 .byt >pe_Note
 .byt >pe_Note
 .byt >pe_Bar
 .byt >pe_PlayRow
 .byt >pe_PlayPattern
 .byt >pe_PlayMusic
 .byt >pe_DuplicatePattern
 .byt >TurnOffMusic
 .byt >pe_WipePattern

pe_WipePattern
	ldx PatternID
	jsr ErasePattern
	jmp PatternPlot

pe_Left
	lda PatternCursorX
.(
	beq skip1
	dec PatternCursorX
skip1	rts
.)

pe_Right
	lda PatternCursorX
	cmp #21
.(
	bcs skip1
	inc PatternCursorX
skip1	rts
.)

pe_Down	;Don't allow Cursor Below BAR?
	lda PatternCursorY
	cmp #63
.(
	bcs skip1
	inc PatternCursorY
skip1	rts
.)

pe_Up
	lda PatternCursorY
.(
	beq skip1
	dec PatternCursorY
skip1	rts
.)

pe_TrackLeft
	ldx PatternCursorX
	lda NextLogicalChannelXLeft,x
	sta PatternCursorX
	rts
;04 Nm S Eg8 N N#O VOSCP N#O VOSCP N#O VOSCP
;      0 1 2 3 4   56789 1   11111 1   11122
;                        0   12345 6   78901
;05 00 - --- - RST ----- RST ----- RST -----
NextLogicalChannelXLeft
 .byt 16,0,0,1
 .byt 3,4,4,4,4,4
 .byt 4,10,10,10,10,10
 .byt 10,16,16,16,16,16

pe_TrackRight
	ldx PatternCursorX
	lda NextLogicalChannelXRight,x
	sta PatternCursorX
	rts
;04 Nm S Eg8 N N#O VOSCP N#O VOSCP N#O VOSCP
;      0 1 2 3 4   56789 1   11111 1   11122
;                        0   12345 6   78901
;05 00 - --- - RST ----- RST ----- RST -----
NextLogicalChannelXRight
 .byt 1,3,3,4,10,10,10,10,10,10,16,16,16,16,16,16,0,0,0,0,0,0

	
pe_PageUp
	lda PatternCursorY
	sec
	sbc #12
.(
	bcs skip1
	lda #00
skip1	sta PatternCursorY
.)
	rts

pe_PageDown
	lda PatternCursorY
	clc
	adc #12
	cmp #64
.(
	bcc skip1
	lda #63
skip1	sta PatternCursorY
.)
	rts

pe_PreviousPattern
	lda PatternID
.(
	beq skip1
	dec PatternID
	jsr DisplayPatternID
skip1	rts
.)

pe_NextPattern
	ldx PatternID
	;Cannot have more than 35 patterns
	cpx #34
.(
	bcs skip1
	
	;If moving into extended patternS then ensure it is known and erase new pattern
	inx
	stx PatternID	;0-34
	cpx mmUltimatePattern
	bcc skip2
	stx mmUltimatePattern
skip2	jsr DisplayPatternID
skip1	rts	
.)

pe_SwitchList
	lda #LISTEDITOR
	sta EditorID
	rts
pe_SwitchSample
	;Select current Row sample as index in Sample
	;if none present then leave alone
	ldy PatternCursorY
	jsr FetchPatternRowAddress
	ldy #01
	lda (source),y
	and #7
.(
	beq skip1
	sta SampleCursorY
	dec SampleCursorY
skip1	lda #SAMPLEVIEWER
.)
	sta EditorID
	rts
pe_SwitchOrnament
	;Select current channels Ornament and set ornament to it
	;if none selected then leave alone
	ldy PatternCursorY
	jsr FetchPatternRowAddress
	ldx PatternCursorX
	ldy PatternX2ChannelsNoteOffset,x
	iny
	lda (source),y
	lsr
	lsr
	lsr
	lsr
.(
	beq skip1
	sta OrnamentID
	dec OrnamentID
	;Display Ornament ID
	jsr DisplayOrnamentID
	jsr OrnamentPlot
skip1	lda #ORNAMENTEDITOR
.)
	sta EditorID
	rts
pe_SwitchEffect
	;Select current channels Effect and set Effect to it
	;if none selected then leave alone
	ldy PatternCursorY
	jsr FetchPatternRowAddress
	ldx PatternCursorX
	ldy PatternX2ChannelsNoteOffset,x
	iny
	lda (source),y
	and #15
.(
	beq skip1
	sta EffectID
	dec EffectID
	;Display Ornament ID
	jsr DisplayEffectID
	jsr EffectPlot
skip1	lda #EFFECTEDITOR
.)
	sta EditorID
	rts
pe_SwitchMenu
	lda #TOPMENU
	sta EditorID
	rts

;Highlighting
;One may highlight S,EGC,N or any of the three Chip channels.
;These are in groups so highlighting columns of chip parameters or just eg period is not possible.
;Copying or Cutting to the Copy buffer (704 Bytes) then pasting.
;Pasting protects against pasting to a destination that does not follow the same format. For example
;copying from S,EGC,N and pasting to Chip A will not happen.

pe_HighlightLeft
	;Cannot begin to highlight by highlighting left
	lda peHighlightingFlag
.(
	beq skip1
	;Recede highlight end to next logical track left
	ldx PatternCursorX
	cpx peHighlightStartX
	beq skip1
	lda NextLogicalChannelXLeft,x
	sta PatternCursorX
	tax
	lda PatternCursorX2PatternFieldGroupEnd,x
	sta peHighlightEndX
skip1	rts
.)
	
peHighlightingFlag	.byt 0
peHighlightStartX   .byt 0
peHighlightStartY   .byt 0
peHighlightEndX     .byt 0
peHighlightEndY     .byt 0
CopyBufferContents	.byt 128
PatternCursorX2PatternFieldGroupStart
 .byt 0,1,1,3
 .byt 4,4,4,4,4,4
 .byt 10,10,10,10,10,10
 .byt 16,16,16,16,16,16
PatternCursorX2PatternFieldGroupEnd
 .byt 0,2,2,3
 .byt 9,9,9,9,9,9
 .byt 15,15,15,15,15,15
 .byt 21,21,21,21,21,21

pe_HighlightRight
	lda peHighlightingFlag
	bne peContinueHighlightingRight
peInitialiseHighlighting
	;Allign Highlight to Channel group start
	ldx PatternCursorX
	lda PatternCursorX2PatternFieldGroupStart,x
	sta peHighlightStartX
	lda PatternCursorX2PatternFieldGroupEnd,x
	sta peHighlightEndX
	lda PatternCursorY
	sta peHighlightStartY
	sta peHighlightEndY
	lda #128
	sta CopyBufferContents
	lda #1
	sta peHighlightingFlag
	rts

peContinueHighlightingRight
	;Track Right Pattern Cursor
	ldx PatternCursorX
	cpx #16
.(
	bcs skip1
	lda NextLogicalChannelXRight,x
	sta PatternCursorX
	tax
	lda PatternCursorX2PatternFieldGroupEnd,x
	sta peHighlightEndX
skip1	rts
.)

pe_HighlightDown
	lda peHighlightingFlag
	beq peInitialiseHighlighting
	ldy PatternCursorY
	cpy #63
.(
	bcs skip1
	iny
	sty PatternCursorY
	sty peHighlightEndY
skip1	rts
.)
	
pe_HighlightUp
	lda peHighlightingFlag
.(
	beq skip1
	;Recede highlight end back up
	ldy PatternCursorY
	cpy peHighlightStartY
	beq skip1
	dec PatternCursorY
	dec peHighlightEndY
skip1	rts
.)
	
pe_HighlightAll
	lda #0
	sta peHighlightStartX
	sta peHighlightStartY
	lda #20
	sta peHighlightEndX
	lda #63
	sta peHighlightEndY
	lda #1
	sta peHighlightingFlag
	rts

pe_Copy
	lda peHighlightingFlag
.(
	beq skip1
	lda #0
	jsr CopyHighlightedArea2CopyBuffer
	lda #00
	sta peHighlightingFlag
	lda #1
	sta CopyBufferContents
skip1	rts
.)
	
	
pe_Cut
	lda peHighlightingFlag
.(
	beq skip1
	lda #1
	jsr CopyHighlightedArea2CopyBuffer
	lda #00
	sta peHighlightingFlag
	lda #1
	sta CopyBufferContents
skip1	rts
.)

CopyHighlightedArea2CopyBuffer
	sta CopyTypeFlag
	ldy peHighlightStartY
.(
loop2	ldx peHighlightStartX
loop1	jsr peFetchPatternField
	jsr peStoreField2Buffer
	lda CopyTypeFlag
	beq skip1
	jsr peVoidPatternField
skip1	inx
	cpx peHighlightEndX
	beq loop1
	bcc loop1
	iny
	cpy peHighlightEndY
	beq loop2
	bcc loop2
.)
	rts	

peFetchPatternField
	stx fpfTempX
	sty fpfTempY
	jsr FetchPatternRowAddress
	ldx fpfTempX
	jsr FetchPatternFieldRange2
	ldx fpfTempX
	ldy fpfTempY
	rts

peVoidPatternField
	stx fpfTempX
	sty fpfTempY
	jsr FetchPatternRowAddress
	;Fetch byte part
	ldx fpfTempX
	ldy CursorX2RowOffsetByte,x
	;Byte written depends on X
	lda #3+62*4
	cpx #4
.(
	beq skip1
	cpx #5	;This avoids setting note at same time as volume
	beq skip2
	cpx #10
	beq skip1
	cpx #11	;This avoids setting note at same time as volume
	beq skip2
	cpx #16
	beq skip1
	cpx #17	;This avoids setting note at same time as volume
	beq skip2
	lda #00
skip1	sta (source),y
skip2	ldx fpfTempX
.)
	ldy fpfTempY
	rts


peStoreField2Buffer
	;If we treat buffer as pattern will we have problems pasting to another channel?
	stx fpfTempX
	sty fpfTempY
	pha
	;Fetch Buffer Row address
	lda BufferRowAddressLo,y
	sta source
	lda BufferRowAddressHi,y
	sta source+1
	ldx fpfTempX
	pla
	jsr StorePatternFieldRange2
	ldx fpfTempX
	ldy fpfTempY
	rts

pe_Paste
	lda #0
	jmp pe_Paste2
pe_Merge
	lda #1
	
pe_Paste2	sta CopyTypeFlag
	;Perform common checks
	jsr peIsPasteValid
.(
	bcc skip1
	lda PatternCursorY
	sta PasteY
	lda peHighlightStartY
	sta SourceY
loop2	lda PatternCursorX
	sta PasteX
	lda peHighlightStartX
	sta SourceX

loop1	jsr peFetchBufferField
	ldy CopyTypeFlag
	beq skip3
	jsr CheckPatternField
skip3	jsr peStoreBufferField

	inc PasteX
	
	;Check Destination X bounds
	lda PasteX
	cmp #22
	bcs skip2
	
	inc SourceX
	
	;Check Source X bounds
	lda SourceX
	cmp peHighlightEndX
	beq loop1
	bcc loop1

skip2	inc PasteY

	;Check Destination Y bounds
	lda PasteY
	cmp #64
	bcs skip1

	inc SourceY

	;Check Source X bounds
	lda SourceY
	cmp peHighlightEndY
	beq loop2
	bcc loop2
skip1	rts
.)
	

peFetchBufferField
	ldy SourceY
	lda BufferRowAddressLo,y
	sta source
	lda BufferRowAddressHi,y
	sta source+1
	ldx SourceX
	jmp FetchPatternFieldRange2

peStoreBufferField
	ldy PasteY
	pha
	jsr FetchPatternRowAddress
	ldx PasteX
	pla
	jmp StorePatternFieldRange2

CheckPatternField
	sta cpfField1
	ldy PasteY
	jsr FetchPatternRowAddress
	ldx PasteX
	jsr FetchPatternFieldRange2
	cpx #4
.(
	beq skip1
	cpx #10
	beq skip1
	cpx #16
	beq skip1
	cmp #0
	bne skip2	;Exit returning current field
	;Exit returning new field
skip3	lda cpfField1
	rts
skip1	sta cpfField2
	lsr
	lsr
	cmp #62
	beq skip3
	lda cpfField2
skip2	rts
.)

peIsPasteValid
	;Does buffer contain pattern data?
	lda CopyBufferContents
	cmp #PATTERNEDITOR
.(
	bne skip1
	
	;Is CursorX on Field group start?
	ldx PatternCursorX
	lda FieldGroupStartFlag,x
	beq skip1
	
	;Does highlight Start X point to the same type for Cursor X
	ldx PatternCursorX
	lda PatternCursorX2CommonType,x
	ldx peHighlightStartX
	cmp PatternCursorX2CommonType,x
	bne skip1
	
	sec
	rts
skip1	clc
.)
	rts

FieldGroupStartFlag
 .byt 1,1,0,1
 .byt 1,0,0,0,0,0
 .byt 1,0,0,0,0,0
 .byt 1,0,0,0,0,0
PatternCursorX2CommonType
 .byt 0,1,1,2
 .byt 3,3,3,3,3,3
 .byt 3,3,3,3,3,3
 .byt 3,3,3,3,3,3


BufferRowAddressLo
 .byt <CopyBuffer
 .byt <CopyBuffer+11*1
 .byt <CopyBuffer+11*2
 .byt <CopyBuffer+11*3
 .byt <CopyBuffer+11*4
 .byt <CopyBuffer+11*5
 .byt <CopyBuffer+11*6
 .byt <CopyBuffer+11*7
 .byt <CopyBuffer+11*8
 .byt <CopyBuffer+11*9
 .byt <CopyBuffer+11*10
 .byt <CopyBuffer+11*11
 .byt <CopyBuffer+11*12
 .byt <CopyBuffer+11*13
 .byt <CopyBuffer+11*14
 .byt <CopyBuffer+11*15
 .byt <CopyBuffer+11*16
 .byt <CopyBuffer+11*17
 .byt <CopyBuffer+11*18
 .byt <CopyBuffer+11*19
 .byt <CopyBuffer+11*20
 .byt <CopyBuffer+11*21
 .byt <CopyBuffer+11*22
 .byt <CopyBuffer+11*23
 .byt <CopyBuffer+11*24
 .byt <CopyBuffer+11*25
 .byt <CopyBuffer+11*26
 .byt <CopyBuffer+11*27
 .byt <CopyBuffer+11*28
 .byt <CopyBuffer+11*29
 .byt <CopyBuffer+11*30
 .byt <CopyBuffer+11*31
 .byt <CopyBuffer+11*32
 .byt <CopyBuffer+11*33
 .byt <CopyBuffer+11*34
 .byt <CopyBuffer+11*35
 .byt <CopyBuffer+11*36
 .byt <CopyBuffer+11*37
 .byt <CopyBuffer+11*38
 .byt <CopyBuffer+11*39
 .byt <CopyBuffer+11*40
 .byt <CopyBuffer+11*41
 .byt <CopyBuffer+11*42
 .byt <CopyBuffer+11*43
 .byt <CopyBuffer+11*44
 .byt <CopyBuffer+11*45
 .byt <CopyBuffer+11*46
 .byt <CopyBuffer+11*47
 .byt <CopyBuffer+11*48
 .byt <CopyBuffer+11*49
 .byt <CopyBuffer+11*50
 .byt <CopyBuffer+11*51
 .byt <CopyBuffer+11*52
 .byt <CopyBuffer+11*53
 .byt <CopyBuffer+11*54
 .byt <CopyBuffer+11*55
 .byt <CopyBuffer+11*56
 .byt <CopyBuffer+11*57
 .byt <CopyBuffer+11*58
 .byt <CopyBuffer+11*59
 .byt <CopyBuffer+11*60
 .byt <CopyBuffer+11*61
 .byt <CopyBuffer+11*62
 .byt <CopyBuffer+11*63
BufferRowAddressHi
 .byt >CopyBuffer
 .byt >CopyBuffer+11*1
 .byt >CopyBuffer+11*2
 .byt >CopyBuffer+11*3
 .byt >CopyBuffer+11*4
 .byt >CopyBuffer+11*5
 .byt >CopyBuffer+11*6
 .byt >CopyBuffer+11*7
 .byt >CopyBuffer+11*8
 .byt >CopyBuffer+11*9
 .byt >CopyBuffer+11*10
 .byt >CopyBuffer+11*11
 .byt >CopyBuffer+11*12
 .byt >CopyBuffer+11*13
 .byt >CopyBuffer+11*14
 .byt >CopyBuffer+11*15
 .byt >CopyBuffer+11*16
 .byt >CopyBuffer+11*17
 .byt >CopyBuffer+11*18
 .byt >CopyBuffer+11*19
 .byt >CopyBuffer+11*20
 .byt >CopyBuffer+11*21
 .byt >CopyBuffer+11*22
 .byt >CopyBuffer+11*23
 .byt >CopyBuffer+11*24
 .byt >CopyBuffer+11*25
 .byt >CopyBuffer+11*26
 .byt >CopyBuffer+11*27
 .byt >CopyBuffer+11*28
 .byt >CopyBuffer+11*29
 .byt >CopyBuffer+11*30
 .byt >CopyBuffer+11*31
 .byt >CopyBuffer+11*32
 .byt >CopyBuffer+11*33
 .byt >CopyBuffer+11*34
 .byt >CopyBuffer+11*35
 .byt >CopyBuffer+11*36
 .byt >CopyBuffer+11*37
 .byt >CopyBuffer+11*38
 .byt >CopyBuffer+11*39
 .byt >CopyBuffer+11*40
 .byt >CopyBuffer+11*41
 .byt >CopyBuffer+11*42
 .byt >CopyBuffer+11*43
 .byt >CopyBuffer+11*44
 .byt >CopyBuffer+11*45
 .byt >CopyBuffer+11*46
 .byt >CopyBuffer+11*47
 .byt >CopyBuffer+11*48
 .byt >CopyBuffer+11*49
 .byt >CopyBuffer+11*50
 .byt >CopyBuffer+11*51
 .byt >CopyBuffer+11*52
 .byt >CopyBuffer+11*53
 .byt >CopyBuffer+11*54
 .byt >CopyBuffer+11*55
 .byt >CopyBuffer+11*56
 .byt >CopyBuffer+11*57
 .byt >CopyBuffer+11*58
 .byt >CopyBuffer+11*59
 .byt >CopyBuffer+11*60
 .byt >CopyBuffer+11*61
 .byt >CopyBuffer+11*62
 .byt >CopyBuffer+11*63
CopyBuffer
 .dsb 704,0

pe_Grab
	ldy PatternCursorY
	jsr FetchPatternFieldRange
	sta Grabbed_PatternEntryByte
	;also store type of field
	ldx PatternCursorX
	lda PatternRowFieldType,x
	sta Grabbed_PatternEntryType
DisplayGrabbedPatternEntry
	ldy #<$bb80+36+40*3
	sty screen
	ldy #>$bb80+36+40*3
	sty screen+1
	tay
	;Type
	;0   0 if 0 plot - else Subtract 1 and display 1dd
	;1   1 if 0 plot -- else Subtract 1 and display 2dd
	;2   2 plot from cycle text
	;3   3 Display Denary
	;4   4 Display note
	;5   5 plot from volume table
	;6   7 if 0 plot - else Subtract 1 and display 1dh
	;7   7 if 0 plot - else Subtract 1 and display 1dh
	;8   6 plot from command table
	;9   3 Display Denary
	lda geDisplayFormatCodeLo,y
.(
	sta vector1+1
	lda geDisplayFormatCodeHi,y
	sta vector1+2
	ldy #00
	sec
	lda Grabbed_PatternEntryByte
vector1	jsr $dead
loop1	iny
	lda #8+128
	sta (screen),y
	cpy #3
	bcc loop1
.)
	rts

geDisplayFormatCodeLo
 .byt <pgePlot0
 .byt <pgePlot1
 .byt <pgePlot2
 .byt <pgePlot3
 .byt <pgePlot4
 .byt <pgePlot5
 .byt <pgePlot7
 .byt <pgePlot7
 .byt <pgePlot6
 .byt <pgePlot3
geDisplayFormatCodeHi
 .byt >pgePlot0
 .byt >pgePlot1
 .byt >pgePlot2
 .byt >pgePlot3
 .byt >pgePlot4
 .byt >pgePlot5
 .byt >pgePlot7
 .byt >pgePlot7
 .byt >pgePlot6
 .byt >pgePlot3

pgePlot0	;0   0 if 0 plot - else Subtract 1 and display 1dd 
	beq geDisplayHyphen
	sbc #1
	clc
	adc #48
	ora #128
	sta (screen),y
	rts
geDisplayDoubleHyphen
	lda #"-"
	ora #128
	sta (screen),y
	iny
geDisplayHyphen
	lda #"-"
	ora #128
	sta (screen),y
	rts
pgePlot1	;1   1 if 0 plot -- else Subtract 1 and display 2dd
	beq geDisplayDoubleHyphen
	sbc #1
	ldx #128
	jmp Display2DD
pgePlot2	;2   2 plot from cycle text
	tax
	lda CycleCharacter,x
	ora #128
	sta (screen),y
	rts
pgePlot3	;3   3 Display Denary
	cmp #10
.(
	bcc skip1
	adc #6
skip1	adc #48
.)
	ora #128
	sta (screen),y
	rts
pgePlot4	;4   4 Display note
	tax
	lda NoteText_Semitone,x
	ora #128
	sta (screen),y
	iny
	lda NoteText_Sharp,x
	ora #128
	sta (screen),y
	iny
	lda NoteText_Octave,x
	ora #128
	sta (screen),y
	rts
pgePlot5	;5   5 plot from volume table
	tax
	lda PatternVolumeDigit,x
	ora #128
	sta (screen),y
	rts
pgePlot6	;8   6 plot from command table
	tax
	lda CommandDigit,x
	ora #128
	sta (screen),y
	rts
pgePlot7	;7   7 if 0 plot - else Subtract 1 and display 1dh
	beq geDisplayHyphen
	sbc #1
	jmp pgePlot3

	
PatternRowFieldType
 .byt 0,1,2,3
 .byt 4,5,6,7,8,9
 .byt 4,5,6,7,8,9
 .byt 4,5,6,7,8,9
pe_Drop
	ldx PatternCursorX
	lda PatternRowFieldType,x
	cmp Grabbed_PatternEntryType
.(
	bne skip1
	ldy PatternCursorY
	jsr FetchPatternFieldRange
	lda Grabbed_PatternEntryByte
	jsr StorePatternFieldRange
skip1	rts
.)
pe_CopyLast
	ldy PatternCursorY
	beq cn_skip1
	dey
	jmp cn_Rent1
pe_CopyNext
	ldy PatternCursorY
	cpy #63
	beq cn_skip1
	iny
cn_Rent1	jsr FetchPatternFieldRange
	ldy PatternCursorY
	pha
	jsr FetchPatternRowAddress
	pla
	ldx PatternCursorX
	jsr StorePatternFieldRange2
cn_skip1	rts


pe_Increment
;	nop
;	jmp pe_Increment
	
	ldy PatternCursorY
	jsr FetchPatternFieldRange
	clc
	adc #01
	jmp StorePatternFieldRange

StorePatternFieldRange
	jsr IsNoteField
	bcs spfr_skip1
StorePatternFieldRange2
spfr_rent1
	;Shift Back
	ldy CursorX2ShiftSteps,x
	beq spfr_ShiftingDone
spfr_loop1
	asl
	dey
	bne spfr_loop1
spfr_ShiftingDone
	;Mask
	and FieldExtraction
	sta FieldExtraction
	ldy CursorX2RowOffsetByte,x
	lda (source),y
	and CursorX2NibbleMask,x
	ora FieldExtraction
	sta (source),y
	rts
spfr_skip1
	cmp #62
	bcc spfr_rent1
	lda #00
	jmp spfr_rent1

FetchPatternFieldRange
	jsr FetchPatternRowAddress
	;Fetch byte part
	ldx PatternCursorX
FetchPatternFieldRange2
	ldy CursorX2RowOffsetByte,x
	lda CursorX2NibbleMask,x
	eor #%11111111
	sta FieldExtraction
	and (source),y
	;Shift to Range
	ldy CursorX2ShiftSteps,x
.(
	beq ShiftingDone
loop1	lsr
	dey
	bne loop1
ShiftingDone
.)
	rts

pe_Decrement
	ldy PatternCursorY
	jsr FetchPatternFieldRange
	sec
	sbc #01
	jmp StorePatternFieldRange


pe_InsertGap
	;Insert gap in current column only
	
	ldy PatternCursorY
	cpy #63
.(
	bcs skip2
	ldy #62
loop1	jsr FetchPatternXFields
	iny
	jsr StorePatternXFields
	dey
	dey
	bmi skip1
	cpy PatternCursorY
	bcs loop1
skip1	ldy PatternCursorY
	jsr VoidPatternXFields
skip2	rts
.)

VoidPatternXFields
	jsr FetchPatternRowAddress

	;Fetch byte containing field
	ldx PatternCursorX
	ldy CursorX2GroupOffsetByte,x
	cpx #4
.(
	bcc skip1
	lda #$FB
	sta (source),y
	iny
	lda #00
	sta (source),y
	iny
	lda #00
	sta (source),y
	rts
skip1	cpx #00
	bne skip2
	lda (source),y
	and #%11111000
rent1	sta (source),y
	rts
skip2	cpx #3
	beq skip3
	lda #00
	jmp rent1
skip3	lda (source),y
.)
	and #%00000111
	sta (source),y
	rts

CursorX2GroupOffsetByte
 .byt 1
 .byt 0,0
 .byt 1
 .byt 2,2,2,2,2,2
 .byt 5,5,5,5,5,5
 .byt 8,8,8,8,8,8

;0
;1-2
;3
;4-9
;10-15
;16-21
FetchPatternXFields
	sty peTemp01
	jsr FetchPatternRowAddress
	
	;Fetch byte containing field
	ldx PatternCursorX
	ldy CursorX2GroupOffsetByte,x
	lda (source),y
	cpx #4
.(
	bcc skip1
	sta Buffer11+2
	iny
	lda (source),y
	sta Buffer11+1
	iny
skip1	lda (source),y
.)
	sta Buffer11
fpxfRent1	ldy peTemp01
	rts
	
StorePatternXFields
	sty peTemp01
	jsr FetchPatternRowAddress
	
	;Fetch byte containing field
	ldx PatternCursorX
	ldy CursorX2GroupOffsetByte,x
	cpx #4
.(
	bcc skip1
	lda Buffer11+2
	sta (source),y
	iny
	lda Buffer11+1
	sta (source),y
	iny
	lda Buffer11
rent1	sta (source),y
	jmp fpxfRent1
skip1	cpx #00
	bne skip2
	lda Buffer11
	and #7
	sta peTemp02
	lda (source),y
	and #%11111000
	ora peTemp02
	jmp rent1
skip2	cpx #3
	beq skip3
	lda Buffer11
	jmp rent1
skip3	lda Buffer11

	and #%11111000
	sta peTemp02
	lda (source),y
	and #%00000111
	ora peTemp02
	jmp rent1
.)
	
pe_DeleteGap
	ldy PatternCursorY
	cpy #63
.(
	bcs skip2
	iny
loop1	jsr FetchPatternXFields
	dey
	jsr StorePatternXFields
	iny
	iny
	cpy #64
	bcc loop1
skip1	ldy #63
	jsr VoidPatternXFields
skip2	rts
.)
	
FetchPatternRowMemory
	sty peTemp01
	jsr FetchPatternRowAddress
	ldy #10
.(
loop1	lda (source),y
	sta Buffer11,y
	dey
	bpl loop1
.)
	ldy peTemp01
	rts
StorePatternRowMemory
	sty peTemp01
	jsr FetchPatternRowAddress
	ldy #10
.(
loop1	lda Buffer11,y
	sta (source),y
	dey
	bpl loop1
.)
	ldy peTemp01
	rts
VoidPatternRowMemory	
	sty peTemp01
	jsr FetchPatternRowAddress
	ldy #10
.(
loop1	lda VoidPatternRow,y
	sta (source),y
	dey
	bpl loop1
.)
	ldy peTemp01
	rts
Buffer11
PatternUsed
 .dsb 24,0
VoidPatternRow
 .byt 0,0,251,0,0,251,0,0,251,0,0

pe_Delete
	;If currently highlighting an area we should Delete the area
	;peHighlightingFlag	
	
	ldy PatternCursorY
	jsr FetchPatternFieldRange
	jsr IsNoteField
.(
	bcs skip1
	lda #00
	jmp StorePatternFieldRange2
skip1	lda #$FB	;62
.)
	;jsr StorePatternFieldRange2
	ldy CursorX2RowOffsetByte,x
	sta (source),y
	iny
	lda #00
	sta (source),y
	iny
	sta (source),y
	rts


IsNoteField
	ldx PatternCursorX
	cpx #4
.(
	beq skip1
	cpx #10
	beq skip1
	cpx #16
	beq skip1
	clc
skip1	rts
.)

CursorX2RowOffsetByte
 .byt 1	;00 Sample
 .byt 0	;01 EGPeriod
 .byt 0	;02 Cycle
 .byt 1	;03 Noise
 .byt 2	;04 A Note
 .byt 2	;05 A Volume
 .byt 3	;06 A Effect
 .byt 3	;07 A Ornament
 .byt 4	;08 A Command
 .byt 4	;09 A Param
 .byt 5	;10 B Note
 .byt 5	;11 B Volume
 .byt 6	;12 B Effect  
 .byt 6	;13 B Ornament
 .byt 7	;14 B Command
 .byt 7	;15 B Param
 .byt 8	;16 C Note
 .byt 8	;17 C Volume
 .byt 9	;18 C Effect  
 .byt 9	;19 C Ornament
 .byt 10	;20 C Command
 .byt 10	;21 C Param
CursorX2ShiftSteps
 .byt 0	;00 Sample  
 .byt 2   ;01 EGPeriod
 .byt 0   ;02 Cycle   
 .byt 3   ;03 Noise   
 .byt 2   ;04 A Note  
 .byt 0   ;05 A Volume
 .byt 0	;06 A Effect  
 .byt 4	;07 A Ornament
 .byt 0	;08 A Command
 .byt 3	;09 A Param
 .byt 2   ;10 B Note  
 .byt 0   ;11 B Volume
 .byt 0	;12 B Effect  
 .byt 4	;13 B Ornament
 .byt 0	;14 B Command
 .byt 3	;15 B Param
 .byt 2   ;16 C Note  
 .byt 0   ;17 C Volume
 .byt 0	;18 C Effect  
 .byt 4	;19 C Ornament
 .byt 0	;20 C Command
 .byt 3	;21 C Param
  
CursorX2NibbleMask
 .byt %11111000	;00 Sample  
 .byt %00000011     ;01 EGPeriod
 .byt %11111100     ;02 Cycle   
 .byt %00000111     ;03 Noise   
 .byt %00000011     ;04 A Note  
 .byt %11111100     ;05 A Volume
 .byt %11110000	;06 A Effect
 .byt %00001111	;07 A Ornament
 .byt %11111000	;08 A Command
 .byt %00000111	;09 A Param
 .byt %00000011     ;10 B Note  
 .byt %11111100     ;11 B Volume
 .byt %11110000	;12 B Effect
 .byt %00001111	;13 B Ornament
 .byt %11111000	;14 B Command
 .byt %00000111	;15 B Param
 .byt %00000011     ;16 C Note  
 .byt %11111100     ;17 C Volume
 .byt %11110000	;18 C Effect
 .byt %00001111	;19 C Ornament
 .byt %11111000	;20 C Command
 .byt %00000111	;21 C Param
ASCIICode
 .byt "7JMK UY8NT69,IHL5RB;.OG0VF4-)PE/1!Z"
 .byt 0,"&?A$XQ2#*]S",0,"3DC'([W="

pe_Octave
	ldy PatternCursorY
	jsr FetchNSO
	lda Pattern_Octave
	cmp #65
.(
	bcc skip1
	lda #"C"
	sta Pattern_Semitone
	lda #"-"
	sta Pattern_Sharp
skip1	ldx CompositeKey
.)
	lda ASCIICode,x
	sta Pattern_Octave
	jmp StoreNSO

pe_Note
	ldy PatternCursorY
	jsr FetchNSO
	lda Pattern_Octave
	cmp #65
.(
	bcc skip1
	lda #"-"
	sta Pattern_Sharp
	lda #"3"
	sta Pattern_Octave
skip1	ldx CompositeKey
.)
	lda ASCIICode,x
	sta Pattern_Semitone
	jmp StoreNSO

pe_Bar
	ldy PatternCursorY
	jsr FetchNSO
	lda #"B"
	sta Pattern_Semitone
	lda #"A"
	sta Pattern_Sharp
	lda #"R"
	sta Pattern_Octave
	jmp StoreNSO

;Fetch Semitone Sharp and Octave from current pattern channel entry
;Returns..
;Pattern_Semitone	0-7
;Pattern_Sharp	0-1
;Pattern_Octave	0-6
FetchNSO
	jsr FetchPatternRowAddress
	ldx PatternCursorX
	ldy PatternX2ChannelsNoteOffset,x
	lda (source),y
	lsr
	lsr
	tax
	lda NoteText_Semitone,x
	sta Pattern_Semitone
	lda NoteText_Sharp,x
	sta Pattern_Sharp
	lda NoteText_Octave,x
	sta Pattern_Octave
	rts
	
StoreNSO	
	ldx #63
.(
loop1	lda Pattern_Semitone
	cmp NoteText_Semitone,x
	bne skip1
	lda Pattern_Sharp
	cmp NoteText_Sharp,x
	bne skip1
	lda Pattern_Octave
	cmp NoteText_Octave,x
	beq skip2
skip1	dex
	bpl loop1
	rts
skip2	txa
.)
	asl
	asl
	sta Pattern_Note
	ldx PatternCursorX
	ldy PatternX2ChannelsNoteOffset,x
	lda (source),y
	and #3
	ora Pattern_Note
	sta (source),y
	rts
	
FetchPatternRowAddress
	ldx PatternID
	lda PatternAddressLo,x
	clc
	adc PatternRowOffsetLo,y
	sta source
	lda PatternAddressHi,x
	adc PatternRowOffsetHi,y
	sta source+1
	rts

PatternX2Channel
 .byt 0,0,0,0
 .byt 0,0,0,0,0,0
 .byt 1,1,1,1,1,1
 .byt 2,2,2,2,2,2
PatternX2ChannelsNoteOffset
 .byt 2,2,2,2
 .byt 2,2,2,2,2,2
 .byt 5,5,5,5,5,5
 .byt 8,8,8,8,8,8
pe_PlayRow
	;Ensure music is stopped
	lda #00
	sta pzMusicElementActivity
	;Calculate pattern row address
	sei
	ldy PatternID
	ldx PatternCursorY
	lda PatternAddressLo,y
	clc
	adc PatternRowOffsetLo,x
	sta pmPattern
	lda PatternAddressHi,y
	adc PatternRowOffsetHi,x
	sta pmPattern+1
	;Call ProcPattern for single row execution
;twi999	nop
;	jmp twi999
	lda #1
	sta pzPatternRowPlayFlag
	jsr ProcPattern
	cli
	jmp pe_Down
pe_PlayPattern
	;Ensure music is stopped
	lda #00
	sta pzMusicElementActivity
	sta pzPatternRowPlayFlag
	sta pbFlag
	sta pbFlag+1
	sta pbFlag+2
	
	;Calculate pattern row address
	sei
	ldy PatternID
	lda PatternAddressLo,y
	sta pmPattern
	lda PatternAddressHi,y
	sta pmPattern+1
	
	;Set Default Music Tempo
	lda mmMusicTempo
	sta pmMusicTempo
	
	;Call ProcPattern for single row execution
	lda #64
	sta pzPatternRowCounter
	sta pzMusicElementActivity
	cli
	rts
	
pe_PlayMusic
	jmp CommencePlay

;Copy current Pattern to next logical Pattern and select it
pe_DuplicatePattern
	;Prevent Duplicating Last pattern
	ldx PatternID
	cpx #23
.(
	bcs skip1
	
	;Fetch current pattern address
	lda PatternAddressLo,x
	sta source
	lda PatternAddressHi,x
	sta source+1

	;Look for next unused Pattern
	ldy #23
	lda #00
	tax
loop5	sta PatternUsed,y
	dey
	bpl loop5

	lda #1
loop4	ldy mmListMemory,x
	bmi skip2
	sta PatternUsed,y
	inx
	bpl loop4
skip2	ldx #00

loop6	lda PatternUsed,x
	beq skip3
	inx
	cpx #24
	bcc loop6
	rts

skip3	;Fetch next pattern address
	lda PatternAddressLo,x
	sta destination
	lda PatternAddressHi,x
	sta destination+1
	
	stx PatternID
	jsr DisplayPatternID

	
	;Copy all 704 Bytes (11x64)
	ldy #00
loop1	lda (source),y
	sta (destination),y
	iny
	bne loop1
	inc source+1
	inc destination+1
loop2	lda (source),y
	sta (destination),y
	iny
	bne loop2
	inc source+1
	inc destination+1
loop3	lda (source),y
	sta (destination),y
	iny
	cpy #192
	bcc loop3
	
skip1	rts
.)



	

