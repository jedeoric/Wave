;Wave_Menu.s

MenuKeyDescriptionIDList
 .byt 6,7,24,24,77,98,99
MenuKeyAreaIDList
 .byt 78,78,81,81,78,81,81
MenuKeyVectorLo
 .byt <meLeft
 .byt <meRight
 .byt <meSelect
 .byt <meSelect
 .byt <GenericHelp
 .byt <meDecrementTempo
 .byt <meIncrementTempo
MenuKeyVectorHi
 .byt >meLeft
 .byt >meRight
 .byt >meSelect
 .byt >meSelect
 .byt >GenericHelp
 .byt >meDecrementTempo
 .byt >meIncrementTempo

meLeft
	lda MenuCursorX
.(
	beq skip1
	dec MenuCursorX
skip1	rts
.)
meRight
	lda MenuCursorX
	ldx MenuID
	cmp MenuUltimateOption,x
.(
	bcs skip1
	inc MenuCursorX
skip1	rts
.)

MenuUltimateOption
 .byt 8,6

meDecrementTempo
	lda mmMusicTempo
	sec
	sbc #1
.(
	beq skip2
	bcs skip1
skip2	lda #99
skip1	sta mmMusicTempo
.)
	jmp EmbedTempoInMenuScreen

meIncrementTempo
	lda mmMusicTempo
	clc
	adc #1
.(
	bcc skip1
	lda #1
skip1	sta mmMusicTempo
.)
EmbedTempoInMenuScreen
	lda #<MenuEmbeddedTempoText
	sta screen
	lda #>MenuEmbeddedTempoText
	sta screen+1
	lda mmMusicTempo
	ldy #00
	ldx #128
	jmp Display2DD

meSelect
	lda MenuID
	bne FileMenu
	ldx MenuCursorX
	beq Switch2FileMenu
	cpx #6
.(
	beq skip1
	bcs PlayControls
	;swap 2/3
	lda MenuX2EditorID-1,x
	sta EditorID
skip1	rts
.)

MenuX2EditorID
 .byt LISTEDITOR
 .byt PATTERNEDITOR
 .byt EFFECTEDITOR
 .byt ORNAMENTEDITOR
 .byt SAMPLEVIEWER


Switch2FileMenu
	lda #1
	sta MenuID
	rts

GenericHelp
	lda EditorID
	sta PreviousEditorID
	lda #HELPEDITOR
	sta EditorID
	lda #0
	sta HelpPage
	sta HelpCursorY
	
	jsr PlotHelpLegend
	jsr ClearPatternArea
	jsr HelpPlot
	lda #87+128
	ldx #1
	ldy #27
	jsr DisplayMessage
	rts

PlayControls
	;7 Play
	;8 Stop
	cpx #7
	beq CommencePlay
	jmp TurnOffMusic

CommencePlayFromList
	sei
	lda ListCursorBase
	clc
	adc ListCursorX
	jmp CommencePlayRent1
CommencePlay
	;Initialise music
	sei
	lda #00
CommencePlayRent1
	sta pzListIndex
	lda #00
	sta pzPatternRowPlayFlag

	lda #%11000000
	sta pzMusicElementActivity
	
	;Setup List
	jsr ProcList
	
	;Set Default Music Tempo
	lda mmMusicTempo
	sta pmMusicTempo

	;Setup Pattern
	jsr ProcPattern
	
	;Commence Playing
	cli
	rts
	
	

;EDIT LOAD SAVE UPDATE DIR MAIN-MENU
FileMenu
	ldx MenuCursorX
	beq Switch2EditMenu
	cpx #2
	bcc LoadNewFile
	beq SaveNewFile
	cpx #4
	bcc UpdateSaveFile
	beq ShowDirectory
	jmp WaveMainMenu

Switch2EditMenu
	lda #0
	sta MenuID
	rts

LoadNewFile
	lda #1
FileOperation
	pha
	jsr CheckOverwriteExisting
	pla
.(
	bcc skip1
	jmp Revert2BasicParsingParam
skip1	rts
.)

SaveNewFile
	lda #2
	jmp Revert2BasicParsingParam

UpdateSaveFile
	lda #3
	jmp Revert2BasicParsingParam

ShowDirectory
	lda #4
	jmp Revert2BasicParsingParam

WaveMainMenu
	jsr CheckOverwriteExisting
.(
	bcc skip1
	ldx MenuCursorX
	cpx #5
	beq menuNew
menuBasic	lda #5
	jmp Revert2BasicParsingParam
menuNew	;Erase Headers
	lda #10
	sta mmMusicTempo
	lda #128
	sta mmListHeader
	
	;Erase Ornament and Effect Loops
	ldx #14
loop4	sta mmOrnamentLoops,x
	sta mmEffectLoops,x
	dex
	bpl loop4
	
	;Erase List memory
	jsr EraseListMemory
	
	;Erase Ornament and Effect Memory
	ldx #00
loop6	sta mmOrnamentMemory,x
	sta mmOrnamentMemory+224,x
	sta mmEffectMemory,x
	sta mmEffectMemory+224,x
	inx
	bne loop6
	
	;Erase Patterns with default Pattern Row
	ldx #23
loop3	jsr ErasePattern
	dex
	bpl loop3
	
	;Redisplay all editors to reflect change
	jsr EmbedTempoInMenuScreen
	jsr PatternPlot
	jsr ListPlot
	jsr EffectPlot
	jsr OrnamentPlot
skip1	rts
.)
	
EraseListMemory
	ldx #00
	txa
.(
loop5	sta mmListMemory,x
	inx
	bpl loop5
.)
	rts

ErasePattern
	stx mePatternID
	lda PatternAddressLo,x
	sta source
	lda PatternAddressHi,x
	sta source+1
	ldx #64
.(
loop2	ldy #10
loop1	lda VoidPatternRow,y
	sta (source),y
	dey
	bpl loop1
	lda #11
	jsr add_source
	dex
	bne loop2
.)
	ldx mePatternID
	rts

CheckOverwriteExisting
	ldx #90
CheckOverwriteExisting2
	jsr DisplayPrompt_Message
	jsr FlushInputBuffer
	jsr WaitOnKey
	ldx #5
	jsr DisplayPrompt_Message
	lda pzKeyRegister
	cmp #6
.(
	beq skip1
	clc
skip1	rts
.)

WaitOnKey
	jsr FetchKey
	lda pzKeyRegister
	cmp #NULLKEYCODE
	beq WaitOnKey
	rts

Revert2BasicParsingParam
;	nop
;	jmp Revert2BasicParsingParam
	pha
	;Revert to BASIC to perform file ops
	sei
	
	;Restore original IRQ speed
	lda #>10000
	sta VIA_T1CH
	sta VIA_T1LH
	lda #<10000
	sta VIA_T1CL
	sta VIA_T1LL
	
	;Disable Virtual AY
	lda #$DD
	sta VIA_PCR
	
	;Turn off current song and disable any sample currently playing
	jsr StopSample
	lda #00
	sta pzMusicElementActivity
	
	;Store Screen and Std Character Set
	;B500-B7FF 768
	;BB80-BFDF 1120
	ldx #00
.(
loop1	lda $B500,x
	sta SCREENBACKUPPAGE1,x
	lda $B600,x
	sta SCREENBACKUPPAGE2,x
	lda $B700,x
	sta SCREENBACKUPPAGE3,x
	lda $BB00,x
	sta ScreenBackupPage4,x
	lda $BC00,x
	sta ScreenBackupPage5,x
	lda $BD00,x
	sta ScreenBackupPage6,x
	lda $BE00,x
	sta ScreenBackupPage7,x
	lda $BF00,x
	sta ScreenBackupPage8,x
	inx
	bne loop1
.)	
	
	;Restore Zero Page
	jsr SwapZeroPage
	
	;Store useful locations between 00 and 0B
	;00 Reserved for passing back and forth from basic
	;   0 Just entered WAVE
	;   1 Returning from disk op
	;01-02 Start of Music memory to save
	;03-04 End Of Music memory to save
	;05 
	;06 Line to return to
	;   4 Load new music, Sample or Element file
	;   5 Save new music file
	;   6 Update Save music file
	;   7 Show directory
	;   8 Return to Main memory
	;Code to return to WAVE from BASIC
	
	pla
	;   1 Load new music, Sample or Element file
	;   2 Save new music file
	;   3 Update Save music file
	;   4 Show directory
	;   5 Return to Main memory
	tax
	clc
	adc #3
	sta $06
	lda ExtensionCharacter-1,x
	sta $05
	lda #<StartOfMusic
	sta $01
	lda #>StartOfMusic
	sta $02
	lda #<EndOfMusic
	sta $03
	lda #>EndOfMusic
	sta $04
	
	;Restore Original IRQ
	lda BasicsIRQVector
	sta SYS_IRQVECTOR
	lda BasicsIRQVector+1
	sta SYS_IRQVECTOR+1
	
	;Restore original stack pointer
	ldx OriginalStackPointer
	txs
	
	;Clear interrupt and return to BASIC
	cli
	rts 

ExtensionCharacter
 .byt "?"	;Load new music, Sample or Element file	Allow loading of any Music element
 .byt "A"	;Save new music file		Always Save All
 .byt "A"	;Update Save music file		Always Save All
 .byt "?"	;Show directory			View All Types
 .byt 0	;Return to Main memory		Not bothered

ScreenBackupPage4
 .dsb 128,0
ActualScreen
 .dsb 40,0
 .dsb 22,0
FilenameText
 .dsb 18,0
 .dsb 40,0
 .dsb 8,0
ScreenBackupPage5
 .dsb 256,0
ScreenBackupPage6
 .dsb 256,0
ScreenBackupPage7
 .dsb 256,0
ScreenBackupPage8
 .dsb 256,0

RestoreScreen
	ldx #00
.(
loop1	lda SCREENBACKUPPAGE1,x
	sta $B500,x
	lda SCREENBACKUPPAGE2,x
	sta $B600,x
	lda SCREENBACKUPPAGE3,x
	sta $B700,x
	lda ScreenBackupPage4,x
	sta $BB00,x
	lda ScreenBackupPage5,x
	sta $BC00,x
	lda ScreenBackupPage6,x
	sta $BD00,x
	lda ScreenBackupPage7,x
	sta $BE00,x
	lda ScreenBackupPage8,x
	sta $BF00,x
	inx
	bne loop1
.)
	rts
