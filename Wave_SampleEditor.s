;Sample Editor

SampleKeyDescriptionIDList
 .byt 8,9,77,18,19,22,21,23
 .byt 66
 .byt 72,75
SampleKeyAreaIDList
 .dsb 8,78
 .byt 81
 .dsb 2,82

SampleKeyVectorLo
 .byt <se_Up
 .byt <se_Down
 .byt <GenericHelp 
 .byt <se_SwitchList
 .byt <se_SwitchPattern
 .byt <se_SwitchOrnament
 .byt <se_SwitchEffect
 .byt <se_SwitchMenu
 .byt <se_Use
 .byt <se_Play
 .byt <se_Stop
SampleKeyVectorHi
 .byt >se_Up
 .byt >se_Down
 .byt >GenericHelp 
 .byt >se_SwitchList
 .byt >se_SwitchPattern
 .byt >se_SwitchOrnament
 .byt >se_SwitchEffect
 .byt >se_SwitchMenu
 .byt >se_Use
 .byt >se_Play
 .byt >se_Stop

se_Up
	lda SampleCursorY
.(
	beq skip1
	dec SampleCursorY
skip1	rts
.)

se_Down
	lda SampleCursorY
	cmp #6
.(
	bcs skip1
	inc SampleCursorY
skip1	rts
.)

se_SwitchList
	lda #LISTEDITOR
	sta EditorID
	rts
se_SwitchPattern
	lda #PATTERNEDITOR
	sta EditorID
	rts
se_SwitchOrnament
	lda #ORNAMENTEDITOR
	sta EditorID
	rts
se_SwitchEffect
	lda #EFFECTEDITOR
	sta EditorID
	rts
se_SwitchMenu
	lda #TOPMENU
	sta EditorID
	rts

se_Stop	jmp TurnOffMusic

se_Use	;Switch to Pattern Editor and Insert this sample in the row
	ldy PatternCursorY
	ldx #00
	jsr FetchPatternRowAddress
	jsr FetchPatternFieldRange2
	lda SampleCursorY
	clc
	adc #01
	jsr StorePatternFieldRange2
	;Display It
	jsr PatternPlot

	;Now switch to PatternEditor
	jmp se_SwitchPattern

se_Play
	;Ensure nothing interrupts us
	sei
	
	;disable status noise and tone and turn off all music
	lda SAMRegister+1
	and #3
	tax
	lda #%01111111
	sta ayStatus
	jsr TurnOffMusic
	
	;Start sample
	ldx SampleCursorY
	inx
	jsr StartSample
	ldx #00
	jsr pmCom_ApplySample
	
	cli
	rts

