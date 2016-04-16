;Wave_CommonCode.s

nl_screen
	lda screen
	clc
	adc #40
	sta screen
	lda screen+1
	adc #00
	sta screen+1
	rts

add_screen
	clc
	adc screen
	sta screen
	lda screen+1
	adc #00
	sta screen+1
	rts
	
add_source
	clc
	adc source
	sta source
	lda source+1
	adc #00
	sta source+1
	rts

FlushInputBuffer
	jsr FetchKey
	lda pzKeyRegister
	cmp #NULLKEYCODE
	bne FlushInputBuffer
	rts

Display3DD
	stx InverseDisplayFlag
	ldx #47
	sec
.(
loop1	inx
	sbc #100
	bcs loop1
.)
	adc #100
	pha
	txa
	ora InverseDisplayFlag
	sta (screen),y
	iny
	pla
	ldx InverseDisplayFlag
Display2DD
	stx InverseDisplayFlag
	ldx #47
	sec
.(
loop1	inx
	sbc #10
	bcs loop1
.)
	adc #58
	pha
	txa
	ora InverseDisplayFlag
	sta (screen),y
	pla
	iny
	ora InverseDisplayFlag
	sta (screen),y
	iny
	rts

Display1DH
.(
	stx skip2+1
	cmp #10
	bcc skip1
	adc #6
skip1	adc #48
skip2	ora #00
.)
	sta (screen),y
	iny
	rts

TurnOffMusic
	;Ensure music is stopped
	sei
	jsr StopSample
	jsr StopSID

	lda #00
	sta pzMusicElementActivity
	sta ayVolume
	sta ayVolume+1
	sta ayVolume+2

	;Send AY
	lda #$DD
	sta VIA_PCR
	ldx #13
.(
loop1	lda ayBankCurrent,x
	sta ayBankReference,x
	ldy ayRealRegister,x
	sty VIA_PORTA
	ldy #$FF
	sty VIA_PCR
	ldy #$DD
	sty VIA_PCR
	sta VIA_PORTA
	lda #$FD
	sta VIA_PCR
	sty VIA_PCR
skip1	dex
	bpl loop1
.)
	cli
	rts

FetchKey
	lda MusicProcessFlag
.(
	beq skip1
	lda #00
	sta MusicProcessFlag
	jsr Main50HzIRQ
skip1	jsr DisplayChannelLevels
.)
	rts

CommonInkey
	jsr FetchKey
	;Wait for a key observing key delay and key repeat (utilising irq Counter)
	lda pzKeyRegister
	cmp #NULLKEYCODE
	beq NoKeyPressedOrKeyUp
	ldy pzIRQCounter+1
	bne CommonInkey	;Key Delayed
	ldy pzKeyInDelayPhase
	bne ProceedToRepeatKey
	ldy #16	;KeyDelayPeriod
	sty pzIRQCounter+1
	ldy #1
	sty pzKeyInDelayPhase
	rts
NoKeyPressedOrKeyUp
	lda #0
	sta pzKeyInDelayPhase
	jmp CommonInkey
ProceedToRepeatKey
	ldy #4
	sty pzIRQCounter+1
	rts
	

;The Channel Monitor consists of a number of displays just below the Sample window
;Bar1 Chip A Reflecting volume level(Bar), Sample (S), EG(E) or Noise (Dithered Bar)
;Bar2 Chip B Reflecting volume level(Bar), Sample (S), EG(E) or Noise (Dithered Bar)
;Bar3 Chip C Reflecting volume level(Bar), Sample (S), EG(E) or Noise (Dithered Bar)
;00   Current Pattern Row
;000  Current List Entry

;Each bar is limited to 6 levels but 7 if blank
;91 Level 1 Noise
;92 Level 2 Noise
;93 Level 3 Noise
;94 Level 4 Noise
;95 Level 5 Noise
;96 Level 6 Noise

;118 Level 1 Tone
;119 Level 2 Tone
;120 Level 3 Tone
;121 Level 4 Tone
;122 Level 5 Tone
;123 Level 6 Tone

;124 Muted Channel Flag
;125 Envelope Flag
;126 Sample Flag


DisplayChannelLevels
	;If the music is inactive reset both listindex and pattern index
	lda pzMusicElementActivity
.(
	bne skip1
	lda #64
	sta pzPatternRowCounter
	lda #00
	sta pzListIndex
skip1	;Sort Chip Channels by examining Volume	
.)
	ldx #2
.(
loop1	;Check on Sample
	lda SAMVector+1
	cmp #<SAMNoSAM
	beq skip2
	ldy #126
	txa
	ora #8
	cpx SAMRegister+1
	beq skip1
	
skip2	;Check on Zero Volume
	ldy #8+128
	lda ayVolume,x
	beq skip1
	
	;Check On EG
	ldy #125
	cmp #16
	bcs skip1
	
	;Fetch Tone level
	tay
	lda Bar6Level,y
	tay
	
	;Modify if noise active on channel
	lda ayStatus
	and pmNoiseBit,x
	bne skip1
	tya
	sec
	sbc #27
	tay
	
skip1	;Now display it
	tya
	ora #128
	sta $BF91,x
	dex
	bpl loop1
.)	

	;Display Current Pattern Row (if music tempo is reference)
	lda #<$BB80+40*26
	sta screen
	lda #>$BB80+40*26
	sta screen+1
	lda mmMusicTempo
	cmp pzNoteTempoCount
.(
	bne skip2

	ldy #5
	lda #63
	sec
	sbc pzPatternRowCounter
	bcs skip1
	lda #00
skip1	ldx #128

	jsr Display2DD
	
skip2	;Display Current List Entry (if different from last
.)
	lda pzListIndex
	cmp OldpzListIndex
.(
	beq skip2
	sta OldpzListIndex
	ldy #8
	lda pzListIndex

	beq skip1
	sec
	sbc #1
skip1	ldx #128
	jmp Display3DD
skip2	rts
.)	

OldpzListIndex
 .byt 0
Bar6Level
 .byt 118,118,118,119,119,119,120,120,121,121,121,122,122,123,123,123
DisplayPrompt_Message
	ldy #32
	lda #8+128
.(
loop1	sta $BB81+40*27,y
	dey
	bpl loop1
.)
	txa
	ora #128
	ldx #1
	ldy #27
	
;X Xpos on screen
;Y Ypos on screen
;A MessageID +B7 if Inversing required
DisplayMessage
	sta MessageID
	txa
	clc
	adc ScreenYLOCL,y
	sta screen
	lda ScreenYLOCH,y
	adc #00
	sta screen+1
	lda #<BaseOfMessages
	sta text
	lda #>BaseOfMessages
	sta text+1
	ldy #00
	lda MessageID
	and #127
	tax
.(
	beq skip2
loop1	lda (text),y
	bpl skip1
	dex
	beq skip2
skip1	iny
	bne loop1
	inc text+1
	jmp loop1
skip2	tya
	sec	;Add 1 more to proceed to next message
	adc text
	sta text
	bcc skip3
	inc text+1
skip3	ldy #00
loop2	lda (text),y
	sta CurrentCharacter
	and #127
	bit MessageID
	bpl skip4
	ora #128
skip4	sta (screen),y
	iny
	lda CurrentCharacter
	bpl loop2
.)
	rts
	
BaseOfMessages
 .byt 0
Message00
 .byt "LIST",8,"EDI","T"+128
Message01
 .byt "PATTERN",8,"EDI","T"+128
Message02
 .byt "ORNAMENT",8,"EDI","T"+128
Message03
 .byt "EFFECT",8,"EDI","T"+128
Message04
 .byt "SAMPLE",8,"VIE","W"+128
Message05
 .byt "MEN","U"+128
Message06
 .byt "MOVE",8,"LEF","T"+128
Message07
 .byt "MOVE",8,"RIGH","T"+128
Message08
 .byt "MOVE",8,"U","P"+128
Message09
 .byt "MOVE",8,"DOW","N"+128
Message10
 .byt "MOVE",8,"TRACK",8,"LEF","T"+128
Message11
 .byt "MOVE",8,"TRACK",8,"RIGH","T"+128
Message12
 .byt "PAGE",8,"U","P"+128
Message13
 .byt "PAGE",8,"DOW","N"+128
Message14
 .BYT "PREV",8,"EFFEC","T"+128
Message15
 .BYT "NEXT",8,"EFFEC","T"+128
Message16
 .byt "PREV",8,"ORNAMEN","T"+128
Message17
 .byt "NEXT",8,"ORNAMEN","T"+128
Message18
 .byt "GOTO",8,"LIST",8,"EDITO","R"+128
Message19
 .byt "GOTO",8,"PATTERN",8,"EDITO","R"+128
Message20
 .byt "GOTO",8,"SAMPLE",8,"VIEWE","R"+128
Message21
 .byt "GOTO",8,"EFFECT",8,"EDITO","R"+128
Message22
 .byt "GOTO",8,"ORNAMENT",8,"EDITO","R"+128
Message23
 .byt "GOTO",8,"MEN","U"+128
Message24
 .byt "SELECT",8,"OPTIO","N"+128
Message25
 .byt "HIGHLIGHT",8,"LEF","T"+128
Message26
 .byt "HIGHLIGHT",8,"RIGH","T"+128
Message27
 .byt "HIGHLIGHT",8,"U","P"+128
Message28
 .byt "HIGHLIGHT",8,"DOW","N"+128
Message29
 .byt "HIGHLIGHT",8,"AL","L"+128
Message30
 .byt "COP","Y"+128
Message31
 .byt "CU","T"+128
Message32
 .byt "PAST","E"+128
Message33
 .byt "MERG","E"+128
Message34
 .byt "GRAB",8,"ENTR","Y"+128
Message35
 .byt "DROP",8,"ENTR","Y"+128
Message36
 .byt "COPY",8,"LAS","T"+128
Message37
 .byt "COPY",8,"NEX","T"+128
Message38
 .byt "INC",8,"ENTR","Y"+128
Message39
 .byt "DEC",8,"ENTR","Y"+128
Message40
 .byt 128
Message41
 .byt 128
Message42
 .byt 128
Message43
 .byt 128
Message44
 .byt 128
Message45
 .byt 128
Message46
 .byt "SELECT",8,"OCTAV","E"+128
Message47
 .byt 128
Message48
 .byt 128
Message49
 .byt 128
Message50
 .byt 128
Message51
 .byt 128
Message52
 .byt 128
Message53
 .byt "SELECT",8,"NOT","E"+128
Message54
 .byt "BA","R"+128
Message55
 .byt "NOISE",8,"VARIAN","T"+128
Message56
 .byt "EG",8,"VARIAN","T"+128
Message57
 .byt "TONE",8,"OF","F"+128
Message58
 .byt "SET",8,"PITC","H"+128
Message59
 .byt "SET",8,"VOLUM","E"+128
Message60
 .byt "SET",8,"END/LOO","P"+128
Message61
 .byt "SIG","N"+128
Message62
 .byt "DELETE",8,"ENTR","Y"+128
Message63
 .byt "INSERT",8,"GA","P"+128
Message64
 .byt "DELETE",8,"GA","P"+128
Message65
 .byt "LOOP",8,"HER","E"+128
Message66
 .byt "USE",8,"SAMPL","E"+128
Message67
 .byt "USE",8,"EFFEC","T"+128
Message68
 .byt "USE",8,"ORNAMEN","T"+128
Message69
 .byt "PLAY",8,"PATTER","N"+128
Message70
 .byt "PLAY",8,"MUSI","C"+128
Message71
 .byt "PLAY",8,"RO","W"+128
Message72
 .byt "PLAY",8,"SAMPL","E"+128
Message73
 .byt "PLAY",8,"EFFEC","T"+128
Message74
 .byt "PLAY",8,"ORNAMEN","T"+128
Message75
 .byt "STOP",8,"SOUN","D"+128
Message76
 .byt "DUPLICATE",8,"PATTER","N"+128
Message77
 .byt "HELP",8,"KEY","S"+128
Message78
 .byt "NAVIGATE",3+128
Message79
 .byt "MODIFY",3+128
Message80
 .byt "COPYING",3+128
Message81
 .byt "OPERATOR",3+128
Message82
 .byt "PLAY",3+128
Message83
 .byt "SHF","T"+128
Message84
 .byt "CTR","L"+128
Message85
 .byt "FUN","C"+128
Message86
 .byt "COMMENCE",8,"MUSI","C"+128
Message87
 .byt 6,"CTRL)*",8,"TO",8,"PAGE",3,8,"$",8,"CHANGE",7,8,"!",8,"QUI","T"+128
Message88
 .byt "PREV",8,"PATTER","N"+128
Message89
 .byt "NEXT",8,"PATTER","N"+128
Message90
 .byt 12,6,"ERASE",12,"EXISTING",12,"MUSIC",12,"Y/N",8+128
Message91
 .byt 12,3,"PRESS",12,"KEY",12,"TO",12,"CHANGE",12,"TO",8+128
Message92
 .byt 12,6,"KEY",12,"IS",12,"ALREADY",12,"USED",8+128
Message93
 .byt "CHANGED",8+128
Message94
 .byt 6,"LOOP",8,"MUST",8,"CONTAIN",8,"A",8,"VOLUM","E"+128
Message95
 .byt 7,"EFFECT",8,"VALIDATE","D"+128
Message96
 .byt 7,"ORNAMENT",8,"VALIDATE","D"+128
Message97
 .byt 6,"LOOP",8,"MUST",8,"CONTAIN",8,"AN",8,"OFFSE","T"+128
Message98
 .byt "DEC",8,"MUSIC",8,"TEMP","O"+128
Message99
 .byt "INC",8,"MUSIC",8,"TEMP","O"+128
Message100
 .byt "WIPE",8,"LIS","T"+128
Message101
 .byt "WIPE",8,"PATTER","N"+128
Message102
 .byt "WIPE",8,"EFFEC","T"+128
Message103
 .byt "WIPE",8,"ORNAMEN","T"+128

ScreenYLOCL
 .byt <$BB80
 .byt <$BB80+40*1
 .byt <$BB80+40*2
 .byt <$BB80+40*3
 .byt <$BB80+40*4
 .byt <$BB80+40*5
 .byt <$BB80+40*6
 .byt <$BB80+40*7
 .byt <$BB80+40*8
 .byt <$BB80+40*9
 .byt <$BB80+40*10
 .byt <$BB80+40*11
 .byt <$BB80+40*12
 .byt <$BB80+40*13
 .byt <$BB80+40*14
 .byt <$BB80+40*15
 .byt <$BB80+40*16
 .byt <$BB80+40*17
 .byt <$BB80+40*18
 .byt <$BB80+40*19
 .byt <$BB80+40*20
 .byt <$BB80+40*21
 .byt <$BB80+40*22
 .byt <$BB80+40*23
 .byt <$BB80+40*24
 .byt <$BB80+40*25
 .byt <$BB80+40*26
 .byt <$BB80+40*27
ScreenYLOCH
 .byt >$BB80
 .byt >$BB80+40*1
 .byt >$BB80+40*2
 .byt >$BB80+40*3
 .byt >$BB80+40*4
 .byt >$BB80+40*5
 .byt >$BB80+40*6
 .byt >$BB80+40*7
 .byt >$BB80+40*8
 .byt >$BB80+40*9
 .byt >$BB80+40*10
 .byt >$BB80+40*11
 .byt >$BB80+40*12
 .byt >$BB80+40*13
 .byt >$BB80+40*14
 .byt >$BB80+40*15
 .byt >$BB80+40*16
 .byt >$BB80+40*17
 .byt >$BB80+40*18
 .byt >$BB80+40*19
 .byt >$BB80+40*20
 .byt >$BB80+40*21
 .byt >$BB80+40*22
 .byt >$BB80+40*23
 .byt >$BB80+40*24
 .byt >$BB80+40*25
 .byt >$BB80+40*26
 .byt >$BB80+40*27


;0   1   2   3   4   5   6   7   8   9   10  11  12  13  14  15  16  17  18  19  20  21  22  23
;240,241,242,243,244,245,246,247,248,249,250,251,252,253,254,255,000,001,002,003,004,005,006,007
DisplaySigned5DD
	sta dsTemp01
	cmp #16
.(
	bcc skip2
	ldx #"+"
	sbc #16
	jmp skip1
skip2	lda #16
	sec
	sbc dsTemp01
	ldx #"-"
skip1	pha
.)
	txa
	sta (screen),y
	pla
	iny
	ldx #00
	jmp Display2DD

DisplaySigned8DD
	sta dsTemp01
	cmp #128
.(
	bcc skip2
	ldx #"+"
	sbc #128
	jmp skip1
skip2	lda #128
	sec
	sbc dsTemp01
	ldx #"-"
skip1	pha
.)
	txa
	sta (screen),y
	pla
	iny
	ldx #00
	jmp Display3DD

SwapZeroPage
	ldx #00
.(
loop1	ldy $B800,x
	lda $00,x
	sty $00,x
	sta $B800,x
	inx
	bne loop1
.)
	rts
